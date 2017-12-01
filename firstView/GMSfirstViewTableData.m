//
//  GMStodayPriceValues.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 05/04/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import "GMSfirstViewTableData.h"
#import "GMSlabelFromJson.h"

@implementation GMSfirstViewTableData

@synthesize cellValues, cellTitles, currenciesList, ticker, recordDate;


+(id)sharedFirstViewTableData
{
    static GMSfirstViewTableData *sharedGMSfirstViewTableData = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedGMSfirstViewTableData = [[self alloc] init];
    });
    return sharedGMSfirstViewTableData;
}

- (id)init
{
    if (self = [super init])
    {
        dispatch_queue_t serialQueue = dispatch_queue_create("com.graphmatic.mustBeSerial", DISPATCH_QUEUE_SERIAL);
        dispatch_sync(serialQueue, ^{
            Globals *glob = [Globals globals];
            
            ticker = [[NSMutableDictionary alloc]init];
            cellValues = [[NSMutableDictionary alloc] init];
            cellTitles = [[NSMutableArray alloc] init];
            currenciesList = [[NSMutableArray alloc] init];
            
            NSUserDefaults *prevTicker = [NSUserDefaults standardUserDefaults];
            // test if datas have been recorded
            if([[[prevTicker dictionaryRepresentation] allKeys] containsObject:@"currency"])
            {
                //load default local json (filled with keys and null values)
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tickerAllCurDefault" ofType:@"json"]]];
                AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                operation.responseSerializer = [AFJSONResponseSerializer serializer];
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     NSLog(@"local request ok");
                     ticker = responseObject;
                     [self initTicker];
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
                 {
                     NSLog(@"local request ERROR");
                                }];
                [operation start];
            }//end first launch
            else
            {
                NSUserDefaults *prevTicker = [NSUserDefaults standardUserDefaults];
                if([[[prevTicker dictionaryRepresentation] allKeys] containsObject:@"theTicker"])
                {
                    NSData *tmp = [[NSUserDefaults standardUserDefaults]objectForKey:@"theTicker"];
                    ticker = [[NSKeyedUnarchiver unarchiveObjectWithData:tmp]mutableCopy];
                    [glob setCurrency:[[NSUserDefaults standardUserDefaults] valueForKey:@"currency"]];
                    [glob setLastRecordDate:[[NSUserDefaults standardUserDefaults] valueForKey:@"recordDate"]];
                }
                else
                {
                //load default local json
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tickerAllCurDefault" ofType:@"json"]]];
                    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                    operation.responseSerializer = [AFJSONResponseSerializer serializer];
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
                     {
                         NSLog(@"local request ok");
                         ticker = responseObject;
                         [self initTicker];
                     }
                       failure:^(AFHTTPRequestOperation *operation, NSError *error)
                     {
                         NSLog(@"local request ERROR");
                     }];
                    [operation start];
                

                }
                cellValues = [self cellValFromTicker:ticker currency:[NSMutableString stringWithString:[glob currency]]];
                cellTitles = [self titlesFromCellVal:cellValues];
                currenciesList = [[[ticker allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]mutableCopy];
               
            }
        });
    }
    return self;
    
}
-(void)initTicker  //first boot
{
    Globals *glob = [Globals globals];
    currenciesList = [[[ticker allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]mutableCopy];
    cellValues = [self cellValFromTicker:ticker currency:[NSMutableString stringWithString:[glob currency]]];
    cellTitles = [self titlesFromCellVal:cellValues];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendNotifToViewController:@"currencyListUpdate"];
        [self sendNotifToViewController:@"currencySwitching"];
    });
}

-(void)currencyChange:(NSMutableString*)currency
{
    // debug
    NSLog(@"@Currency switching: change to %@", currency);
    
    Globals *glob = [Globals globals];
    
    cellValues = [self cellValFromTicker:ticker currency:currency];
    cellTitles = [self titlesFromCellVal:cellValues];
    
    // save to DB
    [[NSUserDefaults standardUserDefaults] setObject:[glob currency] forKey:@"currency"];
    // send Notif' to propagate change
    [self currencyChangeNotify:@"currencySwitching" newCurrency:currency];
}

-(void)update:(NSMutableDictionary*)theNewTicker
{
    Globals *glob = [Globals globals];
    
    ticker = theNewTicker;
    currenciesList = [[[theNewTicker allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]mutableCopy];
    cellValues = [self cellValFromTicker:ticker currency:[NSMutableString stringWithString:[glob currency]]];
    cellTitles = [self titlesFromCellVal:cellValues];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendNotifToViewController:@"currencyListUpdate"];
        [self currencyChangeNotify:@"currencySwitching" newCurrency:[NSMutableString stringWithString:[glob currency]]];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self saveTicker];
    });
}

//update values and titles of daily price ticker for selected currency and return a cleaned dict
-(NSMutableDictionary*)cellValFromTicker:(NSMutableDictionary*)theTicker currency:(NSMutableString*)currency
{
    NSMutableDictionary *newTickerCellVal = [[NSMutableDictionary alloc]init];
    
    NSDictionary *tickerForSelectedCurrency;
    tickerForSelectedCurrency = [theTicker objectForKey:currency];
    
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
- (void)sendNotifToViewController:(NSString*)theNotif
{
    NSDictionary *userInfo = [[NSDictionary alloc]init];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:theNotif
     object:nil
     userInfo:userInfo];
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
    // dict to nsdata package
    NSData *theTicker = [NSKeyedArchiver archivedDataWithRootObject:ticker];
    // store
     [[NSUserDefaults standardUserDefaults] setObject:[glob currency] forKey:@"currency"];
     [[NSUserDefaults standardUserDefaults] setObject:[glob lastRecordDate] forKey:@"lastRecordDate"];
     [[NSUserDefaults standardUserDefaults] setObject:theTicker forKey:@"theTicker"];

    NSLog(@"ticker datas saved");
}
@end
