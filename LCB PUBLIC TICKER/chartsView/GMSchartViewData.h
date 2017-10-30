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

@property  (retain, atomic) NSMutableDictionary *thisDayDatas;
@property (retain, atomic) NSMutableArray *dateAscSorted;
@property (retain, nonatomic) NSMutableDictionary *thisDayDatasAllCurrencies;
@property NSOperationQueue *cvsHandlerQ;

+ (id)sharedGraphViewTableData:(NSMutableString*)currency;
-(void)chartArray:(id)responseObject;
-(void)chartListingCleaned:(id)responseObject;
- (void)dummyArrayForMissingChart;
@end
