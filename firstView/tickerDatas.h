//
//  GMStodayPriceValues.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 05/04/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "GMSGlobals.h"

@interface TickerDatas : NSObject

+ (id)tickerDatas;
- (void) currencyChange:(NSMutableString*)currency;
- (void) triggerViewRefresh:(NSMutableDictionary*)theNewTicker;
- (NSMutableDictionary*) cellValFromTicker:(NSMutableDictionary*)ticker currency:(NSMutableString*)currency;
- (NSMutableArray*) titlesFromCellVal:(NSMutableDictionary *)tickerCellValDict;
- (void) sendNotifToViewController:(NSString*)theNotif;
- (void) currencyChangeNotify:(NSString*)notification newCurrency:(NSMutableString*)currency;
- (void) apiQuery;
- (void)saveTicker;

@property ( atomic, retain )  NSMutableDictionary *ticker;
@property ( atomic, retain ) NSMutableDictionary *cellValues;
@property ( atomic, retain )  NSMutableArray *cellTitles;
@property ( atomic, retain )  NSMutableArray *currenciesList;
@property ( atomic, retain )  NSDate *recordDate;


@end
