//
//  GMSchartViewData.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 13/05/2014.
//  Copyright (c) 2014 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMSfirstViewTableData.h"

@interface GMSchartViewData : NSObject
extern BOOL firstLaunch;
extern BOOL connected;
extern BOOL lockChart;
extern NSDate *graphRequestStart;

@property  (retain, nonatomic) NSMutableDictionary *thisDayDatas;
// thisDayDatas datas structure:
//    [0] -> Timestamp
//    [1] -> Volumes sum
//    [2] -> Price average (weighted)

@property  (retain, atomic) NSString *currency;
@property (retain, atomic) NSMutableArray *dateAscSorted;
@property (retain, nonatomic) NSMutableDictionary *previousPricesAndVolumes;
@property NSOperationQueue *cvsHandlerQ;
@property (retain, nonatomic) NSMutableDictionary *visualRangeForPricesAndVolumes;
@property (readwrite) BOOL apiQuerySuccess;
@property (readwrite) BOOL isReady;

+ (GMSchartViewData *)sharedGraphViewTableData:(NSMutableString*)currency;
- (void)resetSharedInstance;
- (void)chartArray:(id)responseObject;
- (void)chartListingCleaned:(id)responseObject;
- (void)dummyArrayForMissingChart;
- (void)apiQuery;
- (void)refreshFromWeb;

+ (NSMutableDictionary*)datasDeltasLoop: (NSMutableDictionary*)todayDatas;
@end
