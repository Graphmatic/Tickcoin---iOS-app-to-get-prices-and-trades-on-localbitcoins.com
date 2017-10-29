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

+(id)sharedFirstViewTableData:(NSMutableString*)currency
{
    
    static GMSfirstViewTableData *sharedGMSfirstViewTableData = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedGMSfirstViewTableData = [[self alloc] init:firstLaunch currency:currency];
      
    });
    return sharedGMSfirstViewTableData;
}

- (id)init:(BOOL)firstlaunch currency:(NSMutableString*)currency
{
    if (self = [super init])
    {
        dispatch_queue_t serialQueue = dispatch_queue_create("com.graphmatic.mustBeSerial", DISPATCH_QUEUE_SERIAL);
        dispatch_sync(serialQueue, ^{
        self.ticker = [[NSMutableDictionary alloc]init];
        self.cellValues = [[NSMutableDictionary alloc] init];
        self.cellTitles = [[NSMutableArray alloc] init];
        currenciesList = [[NSMutableArray alloc] init];
        if(firstLaunch)
        {
            //load default local json (filled with keys and null values)
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tickerAllCurDefault" ofType:@"json"]]];
            AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation.responseSerializer = [AFJSONResponseSerializer serializer];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 NSLog(@"local request ok");
                 self.ticker = responseObject;
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
            self.ticker   = [[NSKeyedUnarchiver unarchiveObjectWithData:tmp]mutableCopy];
            currentCurrency = [[NSUserDefaults standardUserDefaults] valueForKey:@"currentCurrency"];
            lastRecordDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"recordDate"];
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
                     self.ticker = responseObject;
                     [self initTicker];
                 }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error)
                 {
                     NSLog(@"local request ERROR");
                 }];
                [operation start];
            

            }
            self.cellValues = [self cellValFromTicker:self.ticker currency:currency];
            self.cellTitles = [self titlesFromCellVal:cellValues];
            self.currenciesList = [[[self.ticker allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]mutableCopy];
           
        }
        });
    }
    return self;
    
}
-(void)initTicker  //first boot
{
    self.currenciesList = [[[self.ticker allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]mutableCopy];
    self.cellValues = [self cellValFromTicker:self.ticker currency:currentCurrency];
    self.cellTitles = [self titlesFromCellVal:self.cellValues];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendNotifToViewController:@"changeCurrenciesList"];
        [self sendNotifToViewController:@"changeNow"];
    });
}
-(void)currencyChange:(NSMutableString*)currency
{
        self.cellValues = [self cellValFromTicker:self.ticker currency:currency];
        self.cellTitles = [self titlesFromCellVal:self.cellValues];
        [self sendNotifToViewController:@"changeNow"];
}

-(void)update:(NSMutableDictionary*)theNewTicker
{
    self.ticker = theNewTicker;
    self.currenciesList = [[[theNewTicker allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]mutableCopy];
    self.cellValues = [self cellValFromTicker:self.ticker currency:currentCurrency];
    self.cellTitles = [self titlesFromCellVal:self.cellValues];

    dispatch_async(dispatch_get_main_queue(), ^{
    [self sendNotifToViewController:@"changeCurrenciesList"];
    [self sendNotifToViewController:@"changeNow"];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self saveTicker];
        if (firstLaunch){
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"firstLaunch"];
        }
    });
}

//update values and titles of daily price ticker for selected currency and return a cleaned dict
-(NSMutableDictionary*)cellValFromTicker:(NSMutableDictionary*)theTicker currency:(NSMutableString*)currency
{
//    NSLog(@"downloadedfullticker = %@", downloadedFullTicker);
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


- (void)sendNotifToViewController:(NSString*)theNotif
{
    NSDictionary *userInfo = [[NSDictionary alloc]init];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:theNotif
     object:nil
     userInfo:userInfo];
}
- (void)saveTicker
{
    // dict to nsdata package
    NSData *theTicker = [NSKeyedArchiver archivedDataWithRootObject:self.ticker];
    // store
     [[NSUserDefaults standardUserDefaults] setObject:currentCurrency forKey:@"currentCurrency"];
     [[NSUserDefaults standardUserDefaults] setObject:lastRecordDate forKey:@"lastRecordDate"];
     [[NSUserDefaults standardUserDefaults] setObject:theTicker forKey:@"theTicker"];

    NSLog(@"ticker datas saved");
}
@end