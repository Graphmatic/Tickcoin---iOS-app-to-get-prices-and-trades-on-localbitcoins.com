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
    float dayPriceForSelectedCurrency;
}
@end
@implementation GMSchartViewData

static GMSchartViewData* _sharedGraphViewTableData = nil;

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
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fullURL]];
    AFHTTPRequestOperation *operationGraph = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operationGraph setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operationGraph, id responseObject)
     {
         // debug
         NSLog(@"API query OK");
         self.apiQuerySuccess = YES;
         // Build the datas object
         [self chartListingCleaned:responseObject];
     }
                                          failure:^(AFHTTPRequestOperation *operationGraph, NSError *error)
     {
         // debug
         NSLog(@"API query NOK");
         self.apiQuerySuccess = NO;
         // try to get previous recorded datas from DB and check if datas exist for given currency
         if ( [[[NSUserDefaults standardUserDefaults] objectForKey:@"previousPricesAndVolumes"]objectForKey:self.currency] != nil )
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
         
         
     }];
    [operationGraph start];
}

// helper to refresh data (no currency switching)
-(void)refreshFromWeb
{
    [self apiQuery];
}

-(void)chartListingCleaned:(id)responseObject
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
-(void)chartArray:(id)responseObject
{
    // debug
    NSLog(@"Reorder and merge chart datas");
    
    dispatch_queue_t chartPrepareQueue = dispatch_queue_create("com.graphmatic.cvsHandler", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(chartPrepareQueue, ^{
        lockChart = YES;
        
        NSMutableDictionary *thisDayDatasTmp = [[NSMutableDictionary alloc]init];
        // parsing datas
        NSString *data =  [[NSString alloc] initWithBytes:[responseObject bytes] length:[responseObject length] encoding:NSUTF8StringEncoding];
        NSMutableArray *rawArray = [[NSMutableArray alloc]init];
        NSArray *all = [data componentsSeparatedByString: @"\n"];
        for (int x = 0; x < [all count]; x++)
        {
            NSArray *oneKey = [[all objectAtIndex:x] componentsSeparatedByString: @","];
            [rawArray addObject:oneKey];
        }
        
        NSDate *startDate = [[NSDate alloc]initWithTimeIntervalSince1970:[[[rawArray objectAtIndex:0] objectAtIndex:0]floatValue]];
        NSTimeInterval secondsPerHour = 60 * 60;
        NSDate *startDatePlusOneH = [[NSDate alloc]init];
        startDatePlusOneH  = [startDate dateByAddingTimeInterval: secondsPerHour];
        
        // group by date (each hour)
        for(int z = 0; z < [rawArray count]; z++)
        {
            NSDate *thisDate = [[NSDate alloc]initWithTimeIntervalSince1970:[[[rawArray objectAtIndex:z] objectAtIndex:0]floatValue]];
            thisDate = [GMSUtilitiesFunction roundDateToHour:thisDate];
            
            
            if ([thisDayDatasTmp objectForKey:thisDate])
            {
                // sum amount in BTC
                float a = [[[thisDayDatasTmp objectForKey:thisDate]objectAtIndex:2]floatValue];
                float b = a + [[[rawArray objectAtIndex:z]objectAtIndex:2]floatValue];
                
                // price average - first summing and counting ops for given time
                int cnt = 1;
                float c = [[[thisDayDatasTmp objectForKey:thisDate]objectAtIndex:1]floatValue];
                float d = c + [[[rawArray objectAtIndex:z]objectAtIndex:1]floatValue];
                if ( [[thisDayDatasTmp objectForKey:thisDate] count] > 3 )
                {
                    cnt += [[[thisDayDatasTmp objectForKey:thisDate]objectAtIndex:3]intValue];
                }
                // to compute weighted avaerage later
                NSMutableArray *pvs;
                NSArray *pv = [NSArray arrayWithObjects:[NSNumber numberWithFloat:[[[rawArray objectAtIndex:z]objectAtIndex:1]floatValue]], [NSNumber numberWithFloat:[[[rawArray objectAtIndex:z]objectAtIndex:2]floatValue]], nil];

                if ( [[thisDayDatasTmp objectForKey:thisDate] count] > 4 )
                {
                    pvs = [[thisDayDatasTmp objectForKey:thisDate]objectAtIndex:4];
                    [pvs addObject:pv];
                }
                else {
                    pvs = [[NSMutableArray alloc]initWithObjects:pv, nil];
                }
               
                
                NSNumber *newAmt = [NSNumber numberWithFloat:b];
                NSNumber *newCnt = [NSNumber numberWithInt:cnt];
                NSNumber *newPrSum = [NSNumber numberWithFloat:d];
            
                NSMutableArray *bump = [[NSMutableArray alloc]initWithObjects:[[rawArray objectAtIndex:z]objectAtIndex:0], newPrSum, newAmt, newCnt, pvs, nil];
                [thisDayDatasTmp setObject:bump forKey:thisDate];
            }
            else
            {
                [thisDayDatasTmp setObject:[rawArray objectAtIndex:z] forKey:thisDate];
            }
        }
        
        // debug

        
        // calculation of hourly price average (non-weighted)
        NSArray *ks = [thisDayDatasTmp allKeys];
        for ( NSString *k in ks )
        {
            NSMutableArray *arr = [thisDayDatasTmp objectForKey:k];
            
            if ( [[thisDayDatasTmp objectForKey:k] count] > 3 )
            { // there is sorted datas for this time
                float priceAverage = [[arr objectAtIndex:1]floatValue] / [[arr objectAtIndex:3]floatValue];
                NSNumber *pAverage = [NSNumber numberWithFloat:priceAverage];
                [arr replaceObjectAtIndex:1 withObject:pAverage];
                [thisDayDatasTmp setObject:arr forKey:k];
            }
        }
        
        // calculation of weighted average : (p x v) + (p x v) + ... / sum(v)
        for ( NSString *k in ks )
        {
            if ( [[thisDayDatasTmp objectForKey:k] count] > 3 )
            { // there is sorted datas for this time
                float pMultv = 0;
                float sumVol = 0;
                NSMutableArray *pvs  = [[NSMutableArray alloc]initWithObjects:[[thisDayDatasTmp objectForKey:k]objectAtIndex:4], nil];
                for(int x = 0; x < [pvs count]; x++)
                {
                    pMultv += ([[[[pvs objectAtIndex:x]objectAtIndex:0]objectAtIndex:0]floatValue] * [[[[pvs objectAtIndex:x]objectAtIndex:0]objectAtIndex:1]floatValue]);
                    sumVol += [[[[pvs objectAtIndex:x]objectAtIndex:0]objectAtIndex:1]floatValue];
                }
                float wAverage = pMultv / sumVol;
                NSLog(@"wAverage :%f", wAverage);
            
                [[thisDayDatasTmp objectForKey:k] setObject:[NSNumber numberWithFloat:wAverage] atIndex:4];
            }
        }

        
        // debug
        NSLog(@"second :%@", thisDayDatasTmp);
        
        //check if we get datas for each hour, if not add empty array
        if ([thisDayDatasTmp count] < 24)
        {
            NSTimeInterval secondsPerHour = 60 * 60;
            NSDate *nextHour  = [[NSDate alloc] init];
            nextHour = [graphRequestStart dateByAddingTimeInterval: secondsPerHour];
            NSLog(@"starting 24 loop");
            for (int o = 0; o < 24; o++)
            {
                if(![thisDayDatasTmp objectForKey:nextHour])
                {
                    NSLog(@"adding one empty keydate - %d", o);
                    NSNumber *zeroVal =[[NSNumber alloc]initWithInt:0];
                    
                    NSTimeInterval zeroTimestamp = ([nextHour timeIntervalSince1970]);
                    NSInteger zeroTimestampInt = zeroTimestamp;
                    NSString *zeroTimestampIntStr = [[NSString alloc]init];
                    zeroTimestampIntStr = [NSString stringWithFormat:@"%ld", (long)zeroTimestampInt ];
                    
                    NSArray *bump = [[NSArray alloc]initWithObjects:zeroTimestampIntStr, zeroVal, zeroVal, nil];
                    [thisDayDatasTmp setObject:bump forKey:nextHour];
                }
                nextHour = [nextHour dateByAddingTimeInterval: secondsPerHour];
            }
        }
    
        NSArray *keys = [thisDayDatasTmp allKeys];
        self.dateAscSorted = [[keys sortedArrayUsingSelector:@selector(compare:)]mutableCopy];
        
        self.thisDayDatas = [thisDayDatasTmp mutableCopy];
        [self.previousPricesAndVolumes setObject:thisDayDatas forKey:currentCurrency];
        
        // Calculation of visual ranges
        self.visualRangeForPricesAndVolumes = [GMSchartViewData datasDeltasLoop:thisDayDatasTmp];
        
        // Backup datas
        NSData *thisDayDatasToSave = [NSKeyedArchiver archivedDataWithRootObject:self.previousPricesAndVolumes];
        [[NSUserDefaults standardUserDefaults] setObject:thisDayDatasToSave forKey:@"previousPricesAndVolumes"];
    });
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
        
        NSLog(@"starting 24 loop");
        for (int o = 0; o < 24; o++)
        {
            
            NSLog(@"adding one empty keydate - %d", o);
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
        CGFloat p = [[todayDatas[key]objectAtIndex:1] floatValue];
        CGFloat v = [[todayDatas[key]objectAtIndex:2] floatValue];
        if ( loopCnt > 1 )
        {
            if ( p < lowestPrice)
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

