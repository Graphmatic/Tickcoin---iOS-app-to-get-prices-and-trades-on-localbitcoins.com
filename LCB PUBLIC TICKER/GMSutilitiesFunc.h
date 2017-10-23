//
//  GSutilitiesFunc.h
//  localbitcoins
//
//  Created by frup on 27/03/2014.
//  Copyright (c) 2014 Graphmatic.Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSMutableString *devise;
extern NSString *const urlStart; //see main.m
extern NSString *const tickerURLOrderBookEnd; //see main.m

@interface GMSutilitiesFunc : NSObject

+ (NSString*) currencyFormatThat: (NSString *) theStringVal;
+ (int) getVariation: (NSString *)newDayPrice oldDayPrice:(NSString *)newDayPrice;
+ (NSMutableArray*)listingCleaned:(NSMutableArray*)rawArray maxDev:(float)maxDeviation maxPhigh:(float)maxPhigh maxPlow:(float)maxPlow;
+ (NSString*)orderBookUrl;
@end