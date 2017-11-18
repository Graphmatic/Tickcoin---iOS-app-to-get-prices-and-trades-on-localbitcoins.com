//
//  GMSchartViewData.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 13/05/2014.
//  Copyright (c) 2014 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#import "GMSchartViewData.h"
#import "GMSUtilitiesFunction.h"
@interface GMSchartViewData ()
{

}
@end

@implementation GMSchartViewData

static GMSchartViewData * _sharedGraphViewTableData = nil;

@synthesize thisDayDatas, previousPricesAndVolumes, dateAscSorted, cvsHandlerQ, visualRangeForPricesAndVolumes, apiQuerySuccess, isReady;

+(GMSchartViewData*)sharedGraphViewTableData:(NSMutableString*)currency
{
    @synchronized([GMSchartViewData class])
    {
        if ( !_sharedGraphViewTableData || ( ![currency isEqualToString:_sharedGraphViewTableData.currency] ) ) {
            _sharedGraphViewTableData = [[self alloc] init:currency];
        }
        return _sharedGraphViewTableData;
    }
    return nil;
}

+(id)alloc
{
    @synchronized([GMSchartViewData class])
    {
        NSAssert(_sharedGraphViewTableData == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedGraphViewTableData = [super alloc];
        return _sharedGraphViewTableData;
    }
    
    return nil;
}

- (id)init:(NSMutableString*)currency
{
    self = [super init];
    if ( self != nil ){
        // debug
        NSLog(@"initializing a ChartViewData");
        // Init self's objects
        self.isReady = NO;
        self.cvsHandlerQ = [NSOperationQueue new];
        self.cvsHandlerQ.maxConcurrentOperationCount=1;
        self.dateAscSorted = [[NSMutableArray alloc] init];
        self.thisDayDatas = [[NSMutableDictionary alloc] init];
        self.previousPricesAndVolumes = [[NSMutableDictionary alloc]init];
        self.currency = currency;
        
        // Add Notification observer to be informed of currency switching
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencySwitching:) name:@"currencySwitching" object:nil];
        // start web query
        [self apiQuery];
    }
    return self;
}

- (void)resetSharedInstance {
    @synchronized(self) {
        _sharedGraphViewTableData = nil;
    }
}

- (void)currencySwitching:(NSNotification*)theNotif
{
    NSDictionary *rxNotifDatas = theNotif.userInfo;
    [self resetSharedInstance];
    _sharedGraphViewTableData = [self init:[rxNotifDatas objectForKey:@"newCurrency"]];
}

// the initial XHR query
- (void)apiQuery
{
    self.isReady = NO;
    NSString *fullURL = [GMSUtilitiesFunction graphUrl];
    NSLog(@"URL : %@", fullURL);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fullURL]];
    AFHTTPRequestOperation *operationGraph = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operationGraph setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operationGraph, id responseObject)
     {
          NSLog(@"Obj Success : %@", responseObject);
         self.apiQuerySuccess = YES;
         // Build the datas object
         [self chartListingCleaned:responseObject];
     }
                                          failure:^(AFHTTPRequestOperation *operationGraph, NSError *error)
     {
         NSLog(@"Query failure");
         self.apiQuerySuccess = NO;
         // try to get previous recorded datas from DB and check if datas exist for given currency
         if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"previousPricesAndVolumes"] != nil )
         {
             NSLog(@"Query failure : something in DB");

             self.previousPricesAndVolumes  = [[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"previousPricesAndVolumes"]]mutableCopy];
             if ( [self.previousPricesAndVolumes objectForKey:self.currency] != nil )
             {
                 self.previousPricesAndVolumes  = [[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"previousPricesAndVolumes"]]mutableCopy];
                 self.thisDayDatas = [[self.previousPricesAndVolumes objectForKey:self.currency]mutableCopy];
                 self.isReady = YES;
             }
             else
             {
                 // generate fake datas
                 [self dummyArrayForMissingChart];
             }
         }
         else
         {
             NSLog(@"Query failure : nothing in DB");
             // generate fake datas
             [self dummyArrayForMissingChart];
         }
     }];
    [operationGraph start];
}

// helper to refresh data (no currency switching)
- (void)refreshFromWeb
{
    [self apiQuery];
}

- (void)chartListingCleaned:(id)responseObject
{
    NSInvocationOperation *buildTheChartData = [[NSInvocationOperation alloc]initWithTarget:self
                                                                                   selector:@selector(chartArray:)
                                                                                     object:responseObject];
    
    [buildTheChartData setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // Notify UI that Instance is ready to use
            self.isReady = YES;
            
        });
    }];
    [buildTheChartData setQueuePriority:NSOperationQueuePriorityHigh];
    [self.cvsHandlerQ addOperation:buildTheChartData];
}

//Reorder and merge chart datas
- (void)chartArray:(id)responseObject
{
    dispatch_queue_t chartPrepareQueue = dispatch_queue_create("com.graphmatic.cvsHandler", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(chartPrepareQueue, ^{
        // parsing datas
        NSString *data =  [[NSString alloc] initWithBytes:[responseObject bytes] length:[responseObject length] encoding:NSUTF8StringEncoding];
        NSMutableArray *rawArray = [[NSMutableArray alloc]init];
        NSArray *all = [data componentsSeparatedByString: @"\n"];
        for (int x = 0; x < [all count]; x++)
        {
            NSArray *oneKey = [[all objectAtIndex:x] componentsSeparatedByString: @","];
            [rawArray addObject:oneKey];
        }
        
        NSMutableDictionary *thisDayDatasTmp = [[NSMutableDictionary alloc]init];
        
        [self sortAndSumVolumes:rawArray:^(NSMutableDictionary *thisDayDatasTmpSorted ) {
            // calculation of weighted average : (p x v) + (p x v) + ... / sum(v)
            [self weightedAverage:thisDayDatasTmpSorted:^(NSMutableDictionary *thisDayDatasTmpWeighted ) {
                // Calculation of visual ranges
                self.visualRangeForPricesAndVolumes = [GMSchartViewData datasDeltasLoop:thisDayDatasTmpWeighted];
                // fill empty time slots
                [self zeroEmptyTimeSlots:thisDayDatasTmpWeighted:^(NSMutableDictionary *thisDayDatasTmpFull ) {
                    [thisDayDatasTmp setDictionary:thisDayDatasTmpFull];
                    NSArray *keys = [thisDayDatasTmpFull allKeys];
                    self.dateAscSorted = [[keys sortedArrayUsingSelector:@selector(compare:)]mutableCopy];
                    // assign resulting Dictionnary to instance property
                    self.thisDayDatas = [thisDayDatasTmpFull mutableCopy];
                    // debug
                     NSLog(@"cooked! : %@", thisDayDatasTmpFull);
                    // Backup datas
                    [self.previousPricesAndVolumes setObject:thisDayDatas forKey:currentCurrency];
                    NSData *thisDayDatasToSave = [NSKeyedArchiver archivedDataWithRootObject:self.previousPricesAndVolumes];
                    [[NSUserDefaults standardUserDefaults] setObject:thisDayDatasToSave forKey:@"previousPricesAndVolumes"];
                }];
            }];
        }];
    });
}

// summing of volumes and sorting
- (void)sortAndSumVolumes:(NSMutableArray *)rawArray :(void(^)(NSMutableDictionary *thisDayDatasTmp))completion
{
    NSDate *startDate = [[NSDate alloc]initWithTimeIntervalSince1970:[[[rawArray objectAtIndex:0] objectAtIndex:0]floatValue]];
    NSTimeInterval secondsPerHour = 60 * 60;
    NSDate *startDatePlusOneH = [[NSDate alloc]init];
    startDatePlusOneH  = [startDate dateByAddingTimeInterval: secondsPerHour];
    
    NSMutableDictionary *thisDayDatasTmp = [[NSMutableDictionary alloc]init];
    
    // group by date (each hour)
    for(int z = 0; z < [rawArray count]; z++)
    {
        NSDate *thisDate = [[NSDate alloc]initWithTimeIntervalSince1970:[[[rawArray objectAtIndex:z] objectAtIndex:0]floatValue]];
        thisDate = [GMSUtilitiesFunction roundDateToHour:thisDate];
        
        // to compute weighted average later
        NSMutableArray *pvs;
        NSArray *pv = [NSArray arrayWithObjects:[NSNumber numberWithFloat:[[[rawArray objectAtIndex:z]objectAtIndex:1]floatValue]], [NSNumber numberWithFloat:[[[rawArray objectAtIndex:z]objectAtIndex:2]floatValue]], nil];

        NSMutableArray *bump;
        
        if ([thisDayDatasTmp objectForKey:thisDate])
        {
            // sum amount in BTC
            float a = [[[thisDayDatasTmp objectForKey:thisDate]objectAtIndex:1]floatValue];
            float b = a + [[[rawArray objectAtIndex:z]objectAtIndex:2]floatValue];
            
            // build helper pairs to calculation of weighted price average
            if ( [[[thisDayDatasTmp objectForKey:thisDate]objectAtIndex:2]isKindOfClass:[NSMutableArray class]] )
            {
                pvs = [[thisDayDatasTmp objectForKey:thisDate]objectAtIndex:2];
                [pvs addObject:pv];
            }
            else {
                pvs = [[NSMutableArray alloc]initWithObjects:pv, nil];
            }
            
            NSNumber *newAmt = [NSNumber numberWithFloat:b];
            
            bump = [[NSMutableArray alloc]initWithObjects:[[rawArray objectAtIndex:z]objectAtIndex:0], newAmt, pvs, thisDate, nil];
            [thisDayDatasTmp setObject:bump forKey:thisDate];
        }
        else
        {
            pvs = [[NSMutableArray alloc]initWithObjects:pv, nil];
            bump = [[NSMutableArray alloc]initWithObjects:[[rawArray objectAtIndex:z]objectAtIndex:0], [NSNumber numberWithFloat:[[[rawArray objectAtIndex:z]objectAtIndex:2]floatValue]], pvs, thisDate, nil];
            [thisDayDatasTmp setObject:bump forKey:thisDate];
        }
    }

    completion(thisDayDatasTmp);
}

// calculation of weighted average : (p x v) + (p x v) + ... / sum(v) and high/low extraction
- (void)weightedAverage:(NSMutableDictionary *)thisDayDatasTemp :(void(^)(NSMutableDictionary *thisDayDatasTmp))completion
{
    for ( NSString *k in thisDayDatasTemp )
    {
        NSMutableArray *pvs  = [[NSMutableArray alloc]initWithObjects:[[thisDayDatasTemp objectForKey:k]objectAtIndex:2], nil];

        float pMultv = 0;
        float sumVol = 0;
        
        float highP = 0; // the highest Price in this hour
        float lowP = INFINITY; // the lowest price
        float highPv = 0; // the volume for highest Price in this hour
        float lowPv = 0; // the volume for lowest Price in this hour
        
        float highV = 0;  // same for volume
        float lowV = INFINITY;
        float highVp = 0;
        float lowVp = 0;
        
        for(int x = 0; x < [[pvs objectAtIndex:0] count]; x++)
        {
            float p = [[[[pvs objectAtIndex:0]objectAtIndex:x]objectAtIndex:0]floatValue];
            float v = [[[[pvs objectAtIndex:0]objectAtIndex:x]objectAtIndex:1]floatValue];
            
            pMultv += (p * v);
            sumVol += v;
            // low and high
            if ( p > highP )
            {
                highP = p;
                highPv = v;
            }
            if ( p < lowP )
            {
                lowP = p;
                lowPv = v;
            }
            if ( v > highV )
            {
                highV = v;
                highVp = p;
            }
            if ( v < lowV )
            {
                lowV = v;
                lowVp = p;
            }
        }
        float wAverage = pMultv / sumVol;
        [[thisDayDatasTemp objectForKey:k] setObject:[NSNumber numberWithFloat:wAverage] atIndex:2];
        NSArray *highAndLow = [NSArray arrayWithObjects:[NSNumber numberWithFloat:lowP], [NSNumber numberWithFloat:lowPv], [NSNumber numberWithFloat:highP], [NSNumber numberWithFloat:highPv], [NSNumber numberWithFloat:lowV], [NSNumber numberWithFloat:lowVp], [NSNumber numberWithFloat:highV], [NSNumber numberWithFloat:highVp], nil];
        [[thisDayDatasTemp objectForKey:k] setObject:[NSNumber numberWithFloat:wAverage] atIndex:2];
        [[thisDayDatasTemp objectForKey:k] setObject:highAndLow atIndex:4];
    }
    completion(thisDayDatasTemp);
}

// fill empty time slots with zeroed datas
- (void)zeroEmptyTimeSlots:(NSMutableDictionary *)thisDayDatasTemp :(void(^)(NSMutableDictionary *thisDayDatasTmp))completion
{
    //check if we get datas for each hour, if not add empty array
    if ([thisDayDatasTemp count] < 24)
    {
        NSTimeInterval secondsPerHour = 60 * 60;
        NSDate *nextHour  = [[NSDate alloc] init];
        nextHour = [graphRequestStart dateByAddingTimeInterval: secondsPerHour];

        for (int o = 0; o < 24; o++)
        {
            if(![thisDayDatasTemp objectForKey:nextHour])
            {
                NSNumber *zeroVal =[[NSNumber alloc]initWithInt:0];
                NSTimeInterval zeroTimestamp = ([nextHour timeIntervalSince1970]);
                NSInteger zeroTimestampInt = zeroTimestamp;
                NSString *zeroTimestampIntStr = [[NSString alloc]init];
                zeroTimestampIntStr = [NSString stringWithFormat:@"%ld", (long)zeroTimestampInt ];
                NSDate *thisDate = [[NSDate alloc]initWithTimeIntervalSince1970:zeroTimestamp];
//                thisDate = [GMSUtilitiesFunction roundDateToHour:thisDate];
                
                NSArray *bump = [[NSArray alloc]initWithObjects:zeroTimestampIntStr, zeroVal, zeroVal, thisDate, nil];
                [thisDayDatasTemp setObject:bump forKey:nextHour];
            }
            nextHour = [nextHour dateByAddingTimeInterval: secondsPerHour];
        }
    }
    completion(thisDayDatasTemp);
}


// generate fake datas if connection error and if no old datas are available
- (void)dummyArrayForMissingChart
{
    dispatch_queue_t chartPrepareQueue = dispatch_queue_create("com.graphmatic.cvsHandlerDummy", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(chartPrepareQueue, ^{
        
        NSMutableDictionary *dummyOne = [[NSMutableDictionary alloc]init];
        NSTimeInterval secondsPerHour = 60 * 60;
        NSDate *nextHour  = [[NSDate alloc] init];
        nextHour = [graphRequestStart dateByAddingTimeInterval: secondsPerHour];
        for (int o = 0; o < 24; o++)
        {
            NSNumber *zeroVal =[[NSNumber alloc]initWithInt:0];
            NSTimeInterval zeroTimestamp = ([nextHour timeIntervalSince1970]);
            NSInteger zeroTimestampInt = zeroTimestamp;
            NSString *zeroTimestampIntStr = [[NSString alloc]init];
            zeroTimestampIntStr = [NSString stringWithFormat:@"%ld", (long)zeroTimestampInt ];
            NSArray *bump = [[NSArray alloc]initWithObjects:zeroTimestampIntStr, zeroVal, zeroVal, nil];
            [dummyOne setObject:bump forKey:nextHour];
            nextHour = [nextHour dateByAddingTimeInterval: secondsPerHour];
        }
        NSArray *keys = [dummyOne allKeys];
        self.dateAscSorted = [[keys sortedArrayUsingSelector:@selector(compare:)]mutableCopy];
        self.thisDayDatas = [dummyOne mutableCopy];
        [self.previousPricesAndVolumes setObject:self.thisDayDatas forKey:currentCurrency];
        // Notify UI
        self.isReady = YES;
    });
}

+ (NSMutableDictionary*)datasDeltasLoop: (NSMutableDictionary*)todayDatas
{
    float lowestPrice = 0;
    float highestPrice = 0;
    float lowestVolume = 0;
    float highestVolume = 0;
    int loopCnt = 0;
    for (NSString *key in todayDatas)
    {
        loopCnt += 1;
        CGFloat p = [[todayDatas[key]objectAtIndex:2] floatValue];
        CGFloat v = [[todayDatas[key]objectAtIndex:1] floatValue];
        if ( loopCnt > 1 )
        {
            if ( p < lowestPrice && p )
            {
                lowestPrice = p;
            }
            else {
                if (p > highestPrice )
                {
                    highestPrice = p;
                }
            }
            if ( v < lowestVolume)
            {
                lowestVolume = v;
            }
            else {
                if (v > highestVolume )
                {
                    highestVolume = v;
                }
            }
            
        }
        else
        {
            lowestPrice = highestPrice = p;
            lowestVolume = highestVolume = v;
        }
    }
    NSMutableArray *vRanges = [NSMutableArray array];
    [vRanges addObject:[NSNumber numberWithFloat:lowestVolume]];
    [vRanges addObject:[NSNumber numberWithFloat:highestVolume]];
    NSMutableArray *pRanges = [NSMutableArray array];
    [pRanges addObject:[NSNumber numberWithFloat:lowestPrice]];
    [pRanges addObject:[NSNumber numberWithFloat:highestPrice]];
    
    NSMutableDictionary *volumesAndPricesRanges = [[NSMutableDictionary alloc]init];
    [volumesAndPricesRanges setObject:pRanges forKey:@"pricesDelta"];
    [volumesAndPricesRanges setObject:vRanges forKey:@"volumesDelta"];
    
    return volumesAndPricesRanges;
}

@end

