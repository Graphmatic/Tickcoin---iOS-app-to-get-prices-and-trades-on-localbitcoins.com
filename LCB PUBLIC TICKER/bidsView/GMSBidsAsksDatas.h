//
//  GMSSecondViewTableData.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 15/04/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tickerDatas.h"
#import "GMSGlobals.h"

@interface GMSBidsAsksDatas : NSObject

+ (GMSBidsAsksDatas*)sharedBidsAsksDatas;

@property  (retain, atomic) NSString *currency;
@property (retain, atomic) NSMutableArray *orderBids;
@property (retain, atomic) NSMutableArray *orderAsks;
@property (retain, nonatomic) NSMutableDictionary *bidsAsksAllCurrencies;
@property (retain, nonatomic) NSMutableDictionary *previousBidsAsksListing;
@property (strong, atomic) TickerDatas *firstViewDatas;
@property NSOperationQueue *datasBuilderOp;
@property int bidsMaxDeviation;
@property int asksMaxDeviation;
@property (readwrite) BOOL apiQuerySuccess;
@property (readwrite) BOOL isReady;
@property (readwrite) BOOL isDatas;
@property BOOL isConnection;

- (void)apiQuery;
- (void)resetSharedInstance;
- (void)listingBuilder:(id)responseObject;
- (void)changeDeviation:(int)maxDeviation orderType:(NSString *)orderType;

@end
