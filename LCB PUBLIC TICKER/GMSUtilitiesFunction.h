//
//  GMSUtilitiesFunction.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 30/03/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSMutableString *currentCurrency;
extern NSString *const tickerURLstart; //see main.m
extern NSString *const tickerURLOrderBookEnd; //see main.m
extern NSString *const graphURLStart;
extern NSString *const graphURLEnd;
extern NSDate *graphRequestStart;
@interface GMSUtilitiesFunction : NSObject
+ (NSString*) currencyFormatThat: (NSString *) theStringVal;
+ (int) getVariation: (NSString *)newDayPrice oldDayPrice:(NSString *)newDayPrice;
+ (NSMutableArray*)listingCleaned:(NSMutableArray*)rawArray maxDev:(float)maxDeviation maxPhigh:(float)maxPhigh maxPlow:(float)maxPlow;
+ (NSString*)orderBookUrl;
+ (NSString*)graphUrl;
+ (NSString*)verifyAndForceCastToString:(id)theVar;
+ (NSDate *)roundDateToHour:(NSDate *)date;
+ (NSString*)roundTwoDecimal:(NSString *)theNumb;
+ (void) evenlySpaceTheseButtonsInThisView : (NSArray *) buttonArray : (UIView *) thisView;
@end
