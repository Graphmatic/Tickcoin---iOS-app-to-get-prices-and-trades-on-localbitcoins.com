//
//  GMStodayPriceValues.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 05/04/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import "tickerDatas.h"
#import "GMSlabelFromJson.h"

@implementation TickerDatas

@synthesize cellValues, cellTitles, currenciesList, ticker, recordDate;


+(id)tickerDatas
{
    static TickerDatas *tickerDatas = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tickerDatas = [[self alloc] init];
    });
    return tickerDatas;
}

- (id)init
{
    if (self = [super init])
    {
        ticker = [[NSMutableDictionary alloc]init];
        cellValues = [[NSMutableDictionary alloc] init];
        cellTitles = [[NSMutableArray alloc] init];
        currenciesList = [[NSMutableArray alloc] init];
        
        [self apiQuery];
    }
    return self;
}

- (void) apiQuery
{
    Globals *glob = [Globals globals];
    dispatch_queue_t parser = dispatch_queue_create("parsecvs", DISPATCH_QUEUE_SERIAL);

    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[glob urlStart]]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         dispatch_async(parser, ^{
             [self triggerViewRefresh:responseObject];
         });
         glob.networkAvailable = YES;
         NSDate *recdATE = [[NSDate alloc]init];
         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
         [dateFormatter setDateStyle:NSDateFormatterLongStyle];
         [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
         [glob setLastRecordDate:[[dateFormatter stringFromDate:recdATE]mutableCopy]];
         [[NSUserDefaults standardUserDefaults]setObject:[glob lastRecordDate] forKey:@"lastRecordDate"];
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         glob.networkAvailable = NO;
         
         NSUserDefaults *localStorage = [NSUserDefaults standardUserDefaults];
         // check if we have saved data from past
         if( [[[localStorage dictionaryRepresentation] allKeys] containsObject:@"ticker"] )
         {
             NSData *tmp = [[NSUserDefaults standardUserDefaults]objectForKey:@"ticker"];
             ticker = [[NSKeyedUnarchiver unarchiveObjectWithData:tmp]mutableCopy];
             if( ( [[[localStorage dictionaryRepresentation] allKeys] containsObject:@"currency"] ) && ( [[NSUserDefaults standardUserDefaults] valueForKey:@"currency"] != nil ) )
             {
                 [glob setCurrency:[[NSUserDefaults standardUserDefaults] valueForKey:@"currency"]];
             }
             if( ( [[[localStorage dictionaryRepresentation] allKeys] containsObject:@"recordDate"] ) && ( [[NSUserDefaults standardUserDefaults] valueForKey:@"recordDate"] != nil ) )
             {
                 [glob setLastRecordDate:[[NSUserDefaults standardUserDefaults] valueForKey:@"recordDate"]];
             }
             glob.oldTickerDatas = YES;
             NSLog(@"NO NETWORK - OLD TICKER FOUND");
             dispatch_async(parser, ^{
                 [self triggerViewRefresh:ticker];
             });
         }
         else
         {
             NSLog(@"NO NETWORK - OLD TICKER NOT FOUND");
             glob.oldTickerDatas = NO;
             // load dummy json from local (filled with keys and null values)
             NSURLRequest *localQuery = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tickerAllCurDefault" ofType:@"json"]]];
             AFHTTPRequestOperation *localOperation = [[AFHTTPRequestOperation alloc] initWithRequest:localQuery];
             localOperation.responseSerializer = [AFJSONResponseSerializer serializer];
             [localOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *localOperation, id responseObject)
              {
                  NSLog(@"NO NETWORK - OLD TICKER NOT FOUND - BEFORE DISPATCH");

                  dispatch_queue_t parser = dispatch_queue_create("parsecvs", DISPATCH_QUEUE_SERIAL);
                  dispatch_async(parser, ^{
                      [self triggerViewRefresh:responseObject];
                  });
                  dispatch_async(dispatch_get_main_queue(), ^{
                      NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"error"];
                      [self sendNotifToViewController:@"connectionError" datas:userInfo];
                  });
              }
                                              failure:^(AFHTTPRequestOperation *localOperation, NSError *error)
              {
                  NSLog(@"local request ERROR");
              }];
             [localOperation start];
         }
     }];
    [operation start];
}

-(void)currencyChange:(NSMutableString*)currency
{
    // debug
    NSLog(@"@Currency switching: change to %@", currency);
    
    Globals *glob = [Globals globals];
    
    [self triggerViewRefresh:nil];
    
    // save selecteed currency to DB
    [[NSUserDefaults standardUserDefaults] setObject:[glob currency] forKey:@"currency"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)triggerViewRefresh:(NSMutableDictionary*)theNewTicker
{

    NSLog(@"ticker triggered ViewRefresh");
    NSOperationQueue *normalizeRawDatasQueue = [[NSOperationQueue alloc]init];
    
    NSInvocationOperation *normalizeRawDatas = [[NSInvocationOperation alloc]initWithTarget:self
                                                                                   selector:@selector(normalizeForView:)
                                                                                     object:theNewTicker];
    
    [normalizeRawDatas setCompletionBlock:^{
        if ( theNewTicker != nil )
        {
            // debug
//            NSLog(@"ticker is new : %@", theNewTicker);
            ticker = theNewTicker;
            // refresh currencies displayed in picker
            dispatch_async(dispatch_get_main_queue(), ^{
                // debug
                NSLog(@"ticker UPDATE");
                [self sendNotifToViewController:@"updatePickerList" datas:nil];
            });

           
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // debug
            NSLog(@"ticker REFRESH");
            [self sendNotifToViewController:@"tickerRefresh" datas:nil];
        });
        [self saveTicker];
    }];
    
    [normalizeRawDatas setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [normalizeRawDatasQueue addOperation:normalizeRawDatas];

}

-(void)normalizeForView:(NSMutableDictionary *)theNewTicker
{
    NSLog(@"normalizeForView");
    Globals *glob = [Globals globals];
    if ( theNewTicker != nil )
    {
        currenciesList = [[[theNewTicker allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]mutableCopy];
    }
    cellValues = [self cellValFromTicker:ticker currency:[NSMutableString stringWithString:[glob currency]]];
    cellTitles = [self titlesFromCellVal:cellValues];
}

//update values and titles of daily price ticker for selected currency and return a cleaned dict
-(NSMutableDictionary*)cellValFromTicker:(NSMutableDictionary*)ticker currency:(NSMutableString*)currency
{
    NSMutableDictionary *newTickerCellVal = [[NSMutableDictionary alloc]init];
    
    NSDictionary *tickerForSelectedCurrency;
    tickerForSelectedCurrency = [ticker objectForKey:currency];
    
    NSArray *suppKeys = [[NSArray alloc]initWithArray:[self supposedKeys]];
    for(NSUInteger k = 0; k < [suppKeys count]; k++)
    {
        NSDictionary *dicto = [suppKeys objectAtIndex:k];
        NSEnumerator *enumKey = [dicto keyEnumerator];
        
        for(NSString *aKey in enumKey)
        {
            NSDictionary *tmpDict = [tickerForSelectedCurrency objectForKey:aKey];
            if([aKey isEqualToString:@"rates"])
            {
                NSString *tmpDictString = [GMSUtilitiesFunction verifyAndForceCastToString:[tmpDict objectForKey:@"last"]];
                [newTickerCellVal setObject:tmpDictString forKey:[[suppKeys objectAtIndex:k]objectForKey:aKey]];
            }
            else
            {
                if ([tickerForSelectedCurrency objectForKey:aKey])
                {
                    NSString *tmpDictString = [GMSUtilitiesFunction verifyAndForceCastToString:[tickerForSelectedCurrency objectForKey:aKey]];
                    [newTickerCellVal setObject:tmpDictString forKey:[[suppKeys objectAtIndex:k]objectForKey:aKey]];
                }
            }
        }
    }
    return newTickerCellVal;
}

// return ticker key resp. to value present in newTickerCellVal
-(NSMutableArray*)titlesFromCellVal:(NSMutableDictionary *)tickerCellValDict
{
    NSMutableArray *cellTitleTmp;
    cellTitleTmp = [[NSMutableArray alloc]init];
    NSArray *suppKeys;
    suppKeys = [[NSArray alloc]initWithArray:[self supposedKeys]];
    for(NSUInteger k = 0; k < [suppKeys count]; k++)
    {
        NSDictionary *dicto = [suppKeys objectAtIndex:k];
        NSEnumerator *enumKey = [dicto keyEnumerator];
        for(NSString *aKey in enumKey)
        {
            if([tickerCellValDict objectForKey:[[suppKeys objectAtIndex:k]objectForKey:aKey]])
            {
                [cellTitleTmp addObject:[[suppKeys objectAtIndex:k]objectForKey:aKey]];
            }
        }
    }
    return cellTitleTmp;
}

//get list of keys Json message should have
-(NSArray*)supposedKeys
{
    GMSlabelFromJson *compareKeys = [[GMSlabelFromJson alloc]init];
    NSArray *supposedKeys = compareKeys.labelsArrayOfDict;
    return supposedKeys;
}

// generic
- (void)sendNotifToViewController:(NSString*)theNotif datas:(NSDictionary*)datas
{
    if ( [theNotif isEqualToString:@"tickerRefresh"] || [theNotif isEqualToString:@"updatePickerList"] )
    {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:theNotif
            object:nil
            userInfo:nil];
    }
    
    if ( [theNotif isEqualToString:@"connectionError"] )
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:theNotif
         object:nil
         userInfo:datas];
    }
}

// specific to currency change
-(void)currencyChangeNotify:(NSString*)theNotif newCurrency:(NSMutableString*)currency
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:currency forKey:@"newCurrency"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:theNotif
     object:nil
     userInfo:userInfo];
}

- (void)saveTicker
{
    Globals *glob = [Globals globals];
    if ( [glob isOldTickerDatas] )  // if isOldTickerDatas == NO, app is showing the dummy empty json
    {
        // dict to nsdata package
        NSData *tickerToSave = [NSKeyedArchiver archivedDataWithRootObject:ticker];
        // store
        [[NSUserDefaults standardUserDefaults] setObject:[glob currency] forKey:@"currency"];
        [[NSUserDefaults standardUserDefaults] setObject:[glob lastRecordDate] forKey:@"lastRecordDate"];
        [[NSUserDefaults standardUserDefaults] setObject:tickerToSave forKey:@"ticker"];
        glob.oldTickerDatas = YES;
        NSLog(@"ticker datas saved");
    }
}
@end

