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

static GMSchartViewData* _sharedGraphViewTableData;

@synthesize thisDayDatas, thisDayDatasAllCurrencies, dateAscSorted, cvsHandlerQ, visualRangeForPrices;

+(GMSchartViewData*)sharedGraphViewTableData:(NSMutableString*)currency
{
    @synchronized([GMSchartViewData class])
    {
        if (!_sharedGraphViewTableData) {
            [[self alloc] init:firstLaunch currency:currency];
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

- (id)init:(BOOL)firstlaunch currency:(NSMutableString*)currency
{
    self = [super init];
    if (self != nil) {
        cvsHandlerQ = [NSOperationQueue new];
        cvsHandlerQ.maxConcurrentOperationCount=1;
        dateAscSorted = [[NSMutableArray alloc] init];
        thisDayDatas = [[NSMutableDictionary alloc] init];
        thisDayDatasAllCurrencies = [[NSMutableDictionary alloc]init];
        
        
        if(firstLaunch)
        {
            NSDate *datePlusOneH = [[NSDate alloc]init];
            NSTimeInterval secondsPerHour = 60 * 60;
            datePlusOneH  = [graphRequestStart dateByAddingTimeInterval: secondsPerHour];
            for (int i=0; i<23; i++)
            {
                NSNumber *fakeNum;
                NSString *fakeTimeStamp =[[NSString alloc]initWithFormat:@"1111111111"];
                if (i & 1) {
                    fakeNum = [[NSNumber alloc]initWithInt:500];
                } else {
                    fakeNum = [[NSNumber alloc]initWithInt:200];
                }
                NSArray *bump = [[NSArray alloc]initWithObjects:fakeTimeStamp,fakeNum,fakeNum, nil];
                [thisDayDatas setObject:bump forKey:datePlusOneH];
                datePlusOneH  = [datePlusOneH dateByAddingTimeInterval: secondsPerHour];
            }
            [thisDayDatasAllCurrencies setObject:thisDayDatas forKey:currency];
            NSData *thisDayDatasToSave = [NSKeyedArchiver archivedDataWithRootObject:thisDayDatasAllCurrencies];
            [[NSUserDefaults standardUserDefaults] setObject:thisDayDatasToSave forKey:@"previousDayGraph"];
        }//end first launch
        else
        {
            NSLog(@"seconds launch datas init");
            NSData *tmp = [[NSUserDefaults standardUserDefaults] objectForKey:@"previousDayGraph"];
            thisDayDatasAllCurrencies  = [[NSKeyedUnarchiver unarchiveObjectWithData:tmp]mutableCopy];
            thisDayDatas = [[thisDayDatasAllCurrencies objectForKey:currency]mutableCopy];
        }
        
    }
    return self;
    
}
-(void)chartListingCleaned:(id)responseObject
{
    
    NSInvocationOperation *buildTheChartData = [[NSInvocationOperation alloc]initWithTarget:self
                                                                                   selector:@selector(chartArray:)
                                                                                     object:responseObject];
    
    [buildTheChartData setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"thisDayChartChange"
             object:nil
             userInfo:nil];
            NSLog(@"notif send graph");
            //save that
        });
        NSData *thisDayDatasToSave = [NSKeyedArchiver archivedDataWithRootObject:thisDayDatasAllCurrencies];
        [[NSUserDefaults standardUserDefaults] setObject:thisDayDatasToSave forKey:@"previousDayGraph"];
    }];
    
    
    [buildTheChartData setQueuePriority:NSOperationQueuePriorityHigh];
    [cvsHandlerQ addOperation:buildTheChartData];
}

//Reorder and merge chart datas
-(void)chartArray:(id)responseObject
{
    
    dispatch_queue_t chartPrepareQueue = dispatch_queue_create("com.graphmatic.cvsHandler", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(chartPrepareQueue, ^{
        lockChart = YES;
        
        NSMutableDictionary *thisDayDatasTmp =[[NSMutableDictionary alloc]init];
        NSString *data =  [[NSString alloc] initWithBytes:[responseObject bytes] length:[responseObject length] encoding:NSUTF8StringEncoding];
        NSMutableArray *rawArray = [[NSMutableArray alloc]init];
        NSArray *all = [data componentsSeparatedByString: @"\n"];
        for (int x = 0; x < [all count]; x++)
        {
            NSArray *oneKey = [[all objectAtIndex:x] componentsSeparatedByString: @","];
            [rawArray addObject:oneKey];
        }
        // NSLog(@"rawArray = %@", rawArray);
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
                NSNumber *newAmt = [NSNumber numberWithFloat:b];
                
                // price average
                float c = [[[thisDayDatasTmp objectForKey:thisDate]objectAtIndex:1]floatValue];
                float d = (c + [[[rawArray objectAtIndex:z]objectAtIndex:1]floatValue]) / 2;
                
                NSNumber *newPr = [NSNumber numberWithFloat:d];
                NSArray *bump = [[NSArray alloc]initWithObjects:[[rawArray objectAtIndex:z]objectAtIndex:0], newPr, newAmt, nil];
                [thisDayDatasTmp setObject:bump forKey:thisDate];
            }
            else
            {
                [thisDayDatasTmp setObject:[rawArray objectAtIndex:z] forKey:thisDate];
            }
            
        }
        
        //check if we get datas for each hour, if not add empty array
        if ([thisDayDatasTmp count] < 24)
        {
            NSTimeInterval secondsPerHour = 60 * 60;
            NSDate *nextHour  = [[NSDate alloc] init];
            nextHour = [graphRequestStart dateByAddingTimeInterval: secondsPerHour];
            NSLog(@"starting 24 loop");
            for (int o = 0; o < 12; o++)
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
        [self.thisDayDatasAllCurrencies setObject:thisDayDatas forKey:currentCurrency];
        
        // Calculation of visual ranges
        self.visualRangeForPrices = [GMSchartViewData priceMinMax:thisDayDatasTmp];
        self.visualRangeForVolumes = [GMSchartViewData volumeMinMax:thisDayDatasTmp];
    });
    
}
- (void)dummyArrayForMissingChart  // where this function is used? it's probably useless
{
    dispatch_queue_t chartPrepareQueue = dispatch_queue_create("com.graphmatic.cvsHandlerDummy", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(chartPrepareQueue, ^{
        
        NSMutableDictionary *dummyOne = [[NSMutableDictionary alloc]init];
        NSTimeInterval secondsPerHour = 60 * 60;
        NSDate *nextHour  = [[NSDate alloc] init];
        nextHour = [graphRequestStart dateByAddingTimeInterval: secondsPerHour];
        NSLog(@"starting 24 loop");
        for (int o = 0; o < 23; o++)
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
        [self.thisDayDatasAllCurrencies setObject:thisDayDatas forKey:currentCurrency];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"thisDayChartChange"
             object:nil
             userInfo:nil];
            NSLog(@"notif send graph");
            //save that
        });
        NSData *thisDayDatasToSave = [NSKeyedArchiver archivedDataWithRootObject:thisDayDatasAllCurrencies];
        [[NSUserDefaults standardUserDefaults] setObject:thisDayDatasToSave forKey:@"previousDayGraph"];
        
    });
}

+ (NSMutableArray*)priceMinMax: (NSMutableDictionary*)todayDatas
{
    // we want the bargraph to explicit prices variation rather than absolute value, so...
    // we catch the lowest and highest values for the current day
    // we want the bargraph to explicit volumes variation rather than absolute value, so...
    // we catch the lowest and highest values for the current day
    return [self datasDeltasLoop:todayDatas: @"prices"];
}

+ (NSMutableArray*)volumeMinMax: (NSMutableDictionary*)todayDatas
{
    // we want the bargraph to explicit volumes variation rather than absolute value, so...
    // we catch the lowest and highest values for the current day
    return [self datasDeltasLoop:todayDatas: @"volumes"];
}

+ (NSMutableArray*)datasDeltasLoop: (NSMutableDictionary*)todayDatas :(NSString*)target
{
    int mode;
    [target  isEqual: @"prices"] ?  (mode = 1) : (mode = 2);
    float lowestValue = 0;
    float highestValue = 0;
    int loopCnt = 0;
    for (NSString *key in todayDatas)
    {
        loopCnt += 1;
        CGFloat value = [[todayDatas[key]objectAtIndex:mode] floatValue];
        if ( loopCnt == 1 )
        {
            lowestValue = value;
            highestValue = value;
        }
        else
        {
            if ( value < lowestValue)
            {
                lowestValue = value;
            }
            else {
                if (value > highestValue )
                {
                    highestValue = value;
                }
            }
        }
    }
    NSMutableArray *vRange = [NSMutableArray array];
    [vRange addObject:[NSNumber numberWithFloat:lowestValue]];
    [vRange addObject:[NSNumber numberWithFloat:highestValue]];
    NSString *modeStr;
    
    //debug
    [target  isEqual: @"prices"] ?  (modeStr = @"PRICES") : (modeStr = @"VOLUMES");
    NSLog(@"%@ BARCHART:  low : %f -- high : %f", modeStr, lowestValue, highestValue);
    return vRange;
}
@end

