//
//  GMSSecondViewTableData.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 15/04/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import "GMSBidsAsksDatas.h"
#import "tickerDatas.h"

@interface GMSBidsAsksDatas ()
{
    float maxPlowBids;
    float maxPhighBids;
    float maxPlowAsks;
    float maxPhighAsks;
}

@end

@implementation GMSBidsAsksDatas

static GMSBidsAsksDatas * _sharedBidsAsksDatas = nil;

@synthesize firstViewDatas, orderBids, orderAsks, bidsAsksAllCurrencies, previousBidsAsksListing, bidsMaxDeviation, asksMaxDeviation, datasBuilderOp, currency, isDatas;

+(GMSBidsAsksDatas *)sharedBidsAsksDatas:(NSMutableString*)currency
{
    @synchronized([GMSBidsAsksDatas class])
    {
        if ( !_sharedBidsAsksDatas || ( ![currency isEqualToString:_sharedBidsAsksDatas.currency] ) ) {
            _sharedBidsAsksDatas = [[self alloc] init:currency];
        }
        return _sharedBidsAsksDatas;
    }
    return nil;
}

+(id)alloc
{
    @synchronized([GMSBidsAsksDatas class])
    {
        NSAssert(_sharedBidsAsksDatas == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedBidsAsksDatas = [super alloc];
        return _sharedBidsAsksDatas;
    }
    
    return nil;
}

- (id)init:(NSMutableString*)currency
{
    self = [super init];
    if (self != nil)
    {
        // debug
        NSLog(@"initializing a GMSBidsAsksDatas");
        
        // init properties
        self.isReady = NO;
        self.datasBuilderOp = [NSOperationQueue new];
        self.datasBuilderOp.maxConcurrentOperationCount=1;
        self.orderBids = [[NSMutableArray alloc] init];
        self.orderAsks = [[NSMutableArray alloc] init];
        self.bidsAsksAllCurrencies = [[NSMutableDictionary alloc] init];
        self.currency = currency;
        if ( [[NSUserDefaults standardUserDefaults]objectForKey:@"bidsMaxDeviation"] != nil )
        {
            self.bidsMaxDeviation =  [[[NSUserDefaults standardUserDefaults]objectForKey:@"bidsMaxDeviation"]intValue];
        }
        else
        {
            self.bidsMaxDeviation = 201;
        }
        if ( [[NSUserDefaults standardUserDefaults]objectForKey:@"asksMaxDeviation"] != nil )
        {
            self.asksMaxDeviation =  [[[NSUserDefaults standardUserDefaults]objectForKey:@"asksMaxDeviation"]intValue];
        }
        else
        {
            self.asksMaxDeviation = 201;
        }
        // Add Notification observer to be informed of currency switching
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullUpdate:) name:@"tickerRefresh" object:nil];
        
        // start web query
        [self apiQuery];
    }
    return self;
}

- (void)resetSharedInstance {
    @synchronized(self) {
        _sharedBidsAsksDatas = nil;
    }
}

// the initial XHR query
- (void)apiQuery
{
    NSString *fullURL = [GMSUtilitiesFunction orderBookUrl];
    NSLog(@"BIDS ASKS URL : %@", fullURL);
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:fullURL]];
    AFHTTPRequestOperation *operationOrdersBook = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operationOrdersBook.responseSerializer = [AFJSONResponseSerializer serializer];
    [operationOrdersBook setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operationOrdersBook, id responseObjectOB)
     {
         if( [responseObjectOB count] > 0 )
         {
             NSLog(@"Query success and count >= 1");
             self.apiQuerySuccess = YES;
             self.isDatas = YES;
             // Build the datas object
             [self listingBuilder:responseObjectOB];
         }
         else
         {
             NSLog(@"Query failure count == 0");
             self.apiQuerySuccess = NO;
             // try to get previous recorded datas from DB and check if datas exist for given currency and type
             bidsAsksDatasFromDB(self);
         }
     }
     failure:^(AFHTTPRequestOperation *operationOrdersBook, NSError *error)
     {
         self.apiQuerySuccess = NO;
         // try to get previous recorded datas from DB and check if datas exist for given currency and type
         bidsAsksDatasFromDB(self);
     }];
    [operationOrdersBook start];
}

-(void)listingBuilder:(id)responseObject
{
    NSInvocationOperation *builAsksBidsDatas = [[NSInvocationOperation alloc]initWithTarget:self
                                                                                   selector:@selector(filterDatas:)
                                                                                     object:responseObject];
    
    [builAsksBidsDatas setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // Notify UI that Instance is ready to use
            self.isReady = YES;
        });

        // backup today datas in DB
        [self.bidsAsksAllCurrencies setObject:responseObject forKey:self.currency];
//        [[NSUserDefaults standardUserDefaults]setObject:self.bidsAsksAllCurrencies forKey:@"bidsAsksListing"];
    }];
    
    [builAsksBidsDatas setQueuePriority:NSOperationQueuePriorityHigh];
    [self.datasBuilderOp addOperation:builAsksBidsDatas];
}

// Try to get datas from DB if web service unavailable
static void bidsAsksDatasFromDB(GMSBidsAsksDatas *object) {
    if ( [[NSUserDefaults standardUserDefaults]objectForKey:@"bidsAsksListing"] != nil )
    {
        if ( [[[NSUserDefaults standardUserDefaults]objectForKey:@"bidsAsksListing"]objectForKey:object.currency]!= nil )
        {
            object.previousBidsAsksListing  = [[[[NSUserDefaults standardUserDefaults]objectForKey:@"bidsAsksListing"]objectForKey:object.currency]mutableCopy];
            [object listingBuilder:object.previousBidsAsksListing];
            object.isDatas = YES;
        }
    }
    else
    {
        // generate empty data
        NSMutableArray *emptyArr = [[NSMutableArray alloc]init];
        [emptyArr addObject:[[NSString alloc] initWithString:NSLocalizedString(@"_NO_DATAS", @"no data")]];
        [emptyArr addObject:[[NSString alloc] initWithString:NSLocalizedString(@"_NO_DATAS", @"no data")]];
        [object.orderBids addObject:emptyArr];
        [object.orderAsks addObject:emptyArr];
        
        // notify UI
        object.isReady = YES;
    }
}

- (void)filterDatas:(NSMutableDictionary*)responseObj
{
    // BIDS
    if (self.bidsMaxDeviation == 201) // no deviation filter
    {
        self.orderBids = (NSMutableArray*)[NSOrderedSet orderedSetWithArray:[responseObj objectForKey:@"bids"]].array;
    }
    else
    {
        [self deviationFilter:[responseObj objectForKey:@"bids"] deviation:self.bidsMaxDeviation :^(NSMutableArray *sortedBidsDatas ) {
            self.orderBids = sortedBidsDatas;
            // save deviation value in DB
            [[NSUserDefaults standardUserDefaults]  setObject:[NSString stringWithFormat:@"%i", self.bidsMaxDeviation] forKey:@"bidsMaxDeviation"];
        }];
    }
    
    // ASKS
    if (self.asksMaxDeviation == 201) // no deviation filter
    {
        self.orderAsks = (NSMutableArray*)[NSOrderedSet orderedSetWithArray:[responseObj objectForKey:@"asks"]].array;
    }
    else
    {
        [self deviationFilter:[responseObj objectForKey:@"asks"] deviation:self.asksMaxDeviation :^(NSMutableArray *sortedAsksDatas ) {
            self.orderBids = sortedAsksDatas;
            // save deviation value in DB
            [[NSUserDefaults standardUserDefaults]  setObject:[NSString stringWithFormat:@"%i", self.asksMaxDeviation] forKey:@"asksMaxDeviation"];
        }];
    }
}

- (void)deviationFilter:(NSMutableArray *)dataset deviation:(int)deviation :(void(^)(NSMutableArray *filteredDatas))completion
{
    self.firstViewDatas = [TickerDatas tickerDatas];
    NSString *priceAverageForSelectedCurrency = [self.firstViewDatas.cellValues objectForKey:NSLocalizedString(@"_AVG_24H", @"average 24H")];
    float pa = [priceAverageForSelectedCurrency floatValue];
    
    float diff = pa / 100;
    diff *= deviation;
    maxPlowBids = pa - diff;
    maxPhighBids = pa + diff;
    
    //Reorder and merge
    NSMutableArray *result = (NSMutableArray*)[NSOrderedSet orderedSetWithArray:[GMSUtilitiesFunction listingCleaned:dataset maxDev:deviation maxPhigh:maxPhighBids maxPlow:maxPlowBids]].array;
    
    completion(result);
}

- (void)fullUpdate:(NSNotification*)theNotif
{
    
    NSDictionary *rxNotifDatas = theNotif.userInfo;
    [self resetSharedInstance];
    _sharedBidsAsksDatas = [self init:[rxNotifDatas objectForKey:@"newCurrency"]];
}

- (void)changeDeviation:(int)maxDeviation orderType:(NSString *)orderType
{
    self.isReady = NO;

    if ( [orderType isEqualToString:@"bids"] )
    {
        NSMutableArray *bArr = (NSMutableArray*)[[self.bidsAsksAllCurrencies objectForKey:self.currency] objectForKey:@"bids"];
        self.bidsMaxDeviation = maxDeviation;
        
        if (self.bidsMaxDeviation == 201) // no deviation filter
        {
            self.orderBids = (NSMutableArray*)[NSOrderedSet orderedSetWithArray:bArr].array;
        }
        else
        {
            [self deviationFilter:bArr deviation:self.bidsMaxDeviation :^(NSMutableArray *sortedBidsDatas ) {
                self.orderBids = sortedBidsDatas;
                // save deviation value in DB
                [[NSUserDefaults standardUserDefaults]  setObject:[NSString stringWithFormat:@"%i", self.bidsMaxDeviation] forKey:@"bidsMaxDeviation"];
                self.isReady = YES;
            }];
        }
    }
    else
    {
        NSMutableArray *aArr = (NSMutableArray*)[[self.bidsAsksAllCurrencies objectForKey:self.currency] objectForKey:@"asks"];
        self.asksMaxDeviation = maxDeviation;
        
        if (self.bidsMaxDeviation == 201) // no deviation filter
        {
            self.orderAsks = (NSMutableArray*)[NSOrderedSet orderedSetWithArray:aArr].array;
        }
        else
        {
            [self deviationFilter:aArr deviation:self.bidsMaxDeviation :^(NSMutableArray *sortedAsksDatas ) {
                self.orderAsks = sortedAsksDatas;
                // save deviation value in DB
                [[NSUserDefaults standardUserDefaults]  setObject:[NSString stringWithFormat:@"%i", self.asksMaxDeviation] forKey:@"asksMaxDeviation"];
                self.isReady = YES;
            }];
        }
    }
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
