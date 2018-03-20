//
//  globals.h
//  tickCoin
//
//  Created by rio on 30/11/2017.
//  Copyright © 2017 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface Globals : NSObject

// methodes
+(id)globals;
- (NSString*) currency;
- (NSDate*) lastRecordDate;
- (NSDate*) lastRecordDateOrderBook;
- (NSDate*) queryStartDate;
- (BOOL) isNetworkAvailable;
- (BOOL) isOldTickerDatas;

- (void) setCurrency:(NSString*)newCurrency;
- (void) setQueryStartDate:(NSDate*)newDate;
- (void) setLastRecordDate:(NSDate*)newDate;
- (void) setLastRecordDateOrderBook:(NSDate*)newDate;

//// URL of web ressources
- (NSString*) urlStart;
- (NSString*) tickerURLstart;
- (NSString*) orderBookURLend;
- (NSString*) graphURLStart;
- (NSString*) graphURLEnd;
- (NSString*) mapURL:(CLLocationCoordinate2D) uLocation;

@property (retain, atomic) NSString *currency;
@property (retain, atomic) NSDate *lastRecordDate;
@property (retain, atomic) NSDate *lastRecordDateOrderBook;
@property (retain, atomic) NSDate *queryStartDate;
@property (atomic) BOOL networkAvailable;
@property ( atomic ) BOOL oldTickerDatas;

@end
