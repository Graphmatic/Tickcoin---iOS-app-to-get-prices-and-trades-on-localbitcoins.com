//
//  GMSSecondViewTableData.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 15/04/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import "GMSSecondViewTableData.h"
#import "GMSfirstViewTableData.h"

@interface GMSSecondViewTableData ()
{
    float maxPlow;
    float maxPhigh;
}

@end
@implementation GMSSecondViewTableData
@synthesize firstViewDatas, orderBids, orderAsks, orderBidsAllCurrency, orderAsksAllCurrency;

+(id)sharedSecondViewTableData:(BOOL)firstLaunch currency:(NSMutableString*)currency
{
    static GMSSecondViewTableData *sharedGMSSecondViewTableData = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedGMSSecondViewTableData = [[self alloc] init:firstLaunch currency:currency];
        
    });
    return sharedGMSSecondViewTableData;
}
- (id)init:(BOOL)firstlaunch currency:(NSMutableString*)currency
{
    
    if (self = [super init])
    {
        dispatch_queue_t serialQueue = dispatch_queue_create("com.graphmatic.mustBeSerial", DISPATCH_QUEUE_SERIAL);
        dispatch_sync(serialQueue, ^{
      
            orderBids = [[NSMutableArray alloc] init];
            orderAsks = [[NSMutableArray alloc] init];
            orderBidsAllCurrency = [[NSMutableDictionary alloc]init];
            orderAsksAllCurrency = [[NSMutableDictionary alloc]init];
            if(firstlaunch)
            {
                //prepare (fake) tableView
                NSMutableArray *orderForCur = [[NSMutableArray alloc]init];
                for (int i = 0; i <= 12; i++) {
                
                [orderForCur addObject:[[NSString alloc] initWithString:NSLocalizedString(@"_NO_DATAS", @"no data")]];
                [orderForCur addObject:[[NSString alloc] initWithString:NSLocalizedString(@"_NO_DATAS", @"no data")]];
                [orderBids addObject:orderForCur];
                [orderAsks addObject:orderForCur];
                }
            }//end first launch
            else
            {
                NSData *tmp = [[NSUserDefaults standardUserDefaults]objectForKey:@"previousBidsTicker"];
                orderBidsAllCurrency = [[NSKeyedUnarchiver unarchiveObjectWithData:tmp]mutableCopy];
                orderBids  = [self.orderBidsAllCurrency objectForKey:currency];
                NSData *tmp2 = [[NSUserDefaults standardUserDefaults]objectForKey:@"previousAsksTicker"];
                orderAsksAllCurrency = [[NSKeyedUnarchiver unarchiveObjectWithData:tmp2]mutableCopy];
                orderAsks  = [self.orderBidsAllCurrency objectForKey:currency];
            }
        });
    }
    return self;
    
}
- (void)updateFromWeb:(float)maxDeviation json:(NSMutableDictionary*)responseObj type:(NSString *)type
{
    if ([type isEqualToString:@"bids"])
    {
        self.orderBids  = [responseObj objectForKey:type];
        [self.orderBidsAllCurrency setObject:self.orderBids forKey:currentCurrency];
        NSData *theBidsTicker = [NSKeyedArchiver archivedDataWithRootObject:self.orderBidsAllCurrency];
        [[NSUserDefaults standardUserDefaults]setObject:theBidsTicker forKey:@"previousBidsTicker"];
    }
    else
    {
        self.orderAsks  = [responseObj objectForKey:type];
        [self.orderAsksAllCurrency setObject:[responseObj objectForKey:type] forKey:currentCurrency];
        NSData *theAsksTicker = [NSKeyedArchiver archivedDataWithRootObject:self.orderAsksAllCurrency];
        [[NSUserDefaults standardUserDefaults]setObject:theAsksTicker forKey:@"previousAsksTicker"];
    }
    [self update:maxDeviation type:type];
}
    
- (void)update:(float)maxDeviation type:(NSString*)type
{
    self.firstViewDatas = [GMSfirstViewTableData sharedFirstViewTableData:currentCurrency];
        NSString *dayPriceForSelectedCurrency = [self.firstViewDatas.cellValues objectForKey:NSLocalizedString(@"_AVG_24H", @"average 24H")];
        if (maxDeviation == 201)
        {
            if ([type isEqualToString:@"bids"])
            {
                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:[self.orderBidsAllCurrency objectForKey:currentCurrency]];
                self.orderBids = (NSMutableArray*)orderedSet.array;
            }
            if ([type isEqualToString:@"asks"])
            {
                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:[self.orderAsksAllCurrency objectForKey:currentCurrency]];
                self.orderAsks = (NSMutableArray*)orderedSet.array;
            }
        }
        else
        {
            float dayPriceForSelectedCur = [dayPriceForSelectedCurrency floatValue];
            float diffP = dayPriceForSelectedCur / 100;
            diffP *= maxDeviation;
            maxPlow = dayPriceForSelectedCur - diffP;      
            maxPhigh = dayPriceForSelectedCur + diffP;
     

    //Reorder and merge
    if ([type isEqualToString:@"bids"])
    {
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:[GMSUtilitiesFunction listingCleaned:[self.orderBidsAllCurrency objectForKey:currentCurrency] maxDev:maxDeviation maxPhigh:maxPhigh maxPlow:maxPlow]];
        self.orderBids = (NSMutableArray*)orderedSet.array;
    }
    if ([type isEqualToString:@"asks"])
    {
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:[GMSUtilitiesFunction listingCleaned:[self.orderAsksAllCurrency objectForKey:currentCurrency] maxDev:maxDeviation maxPhigh:maxPhigh maxPlow:maxPlow]];
        self.orderAsks = (NSMutableArray*)orderedSet.array;
    }
    }
     NSString *maxDevString = [NSString stringWithFormat:@"%f", maxDeviation];

     dispatch_async(dispatch_get_main_queue(), ^{
         if([type isEqualToString: @"bids"])
         {
                 [self sendNotifToViewController:@"changeBidsNow"];
             [[NSUserDefaults standardUserDefaults]  setObject:maxDevString forKey:@"maxDeviationBids"];
         }
         else
         {
                 [self sendNotifToViewController:@"changeAsksNow"];
             [[NSUserDefaults standardUserDefaults]  setObject:maxDevString forKey:@"maxDeviationAsks"];
        }
     
     });
   
    
}

- (void)sendNotifToViewController:(NSString*)theNotif
{
    NSDictionary *userInfo = [[NSDictionary alloc]init];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:theNotif
     object:nil
     userInfo:userInfo];
}
@end
