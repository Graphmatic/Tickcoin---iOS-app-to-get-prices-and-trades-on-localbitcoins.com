//
//  GMSSecondViewTableData.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 15/04/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMSfirstViewTableData.h"
extern BOOL firstLaunch;
extern NSMutableString *currentCurrency;

@interface GMSSecondViewTableData : NSObject

+(id)sharedSecondViewTableData:(BOOL)firstLaunch currency:(NSMutableString*)currency;
- (void)updateFromWeb:(float)maxDeviation json:(NSMutableDictionary*)responseObj type:(NSString*)type;
- (void)update:(float)maxDeviationtype type:(NSString*)type;

@property (retain, atomic) NSMutableArray *orderBids;
@property (retain, atomic) NSMutableArray *orderAsks;
@property (retain, nonatomic) NSMutableDictionary *orderBidsAllCurrency;
@property (retain, nonatomic) NSMutableDictionary *orderAsksAllCurrency;
@property (strong, atomic) GMSfirstViewTableData *firstViewDatas;


@end
