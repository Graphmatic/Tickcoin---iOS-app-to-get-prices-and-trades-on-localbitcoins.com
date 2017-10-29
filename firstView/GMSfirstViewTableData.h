//
//  GMStodayPriceValues.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 05/04/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//
#import <Foundation/Foundation.h>
extern BOOL firstLaunch;
extern BOOL connected;
extern NSMutableString *lastRecordDate;

@interface GMSfirstViewTableData : NSObject

+ (id)sharedFirstViewTableData:(NSMutableString*)currency;
-(void)currencyChange:(NSMutableString*)currency;
-(void)update:(NSMutableDictionary*)theNewTicker;
-(NSMutableDictionary*)cellValFromTicker:(NSMutableDictionary*)theTicker currency:(NSMutableString*)currency;
-(NSMutableArray*)titlesFromCellVal:(NSMutableDictionary *)tickerCellValDict;
-(void)sendNotifToViewController:(NSString*)theNotif;

@property ( atomic, retain )  NSMutableDictionary *ticker;
@property ( atomic, retain ) NSMutableDictionary *cellValues;
@property ( atomic, retain )  NSMutableArray *cellTitles;
@property ( atomic, retain )  NSMutableArray *currenciesList;
@property ( atomic, retain )  NSDate *recordDate;
@end
