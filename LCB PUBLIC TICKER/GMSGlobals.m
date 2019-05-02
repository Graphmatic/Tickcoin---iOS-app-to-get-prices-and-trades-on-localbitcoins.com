//
//  GMSglobals.m
//  tickCoin
//
//  Created by rio on 30/11/2017.
//  Copyright © 2017 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GMSGlobals.h"



@implementation Globals : NSObject

@synthesize currency, lastRecordDate, lastRecordDateOrderBook, queryStartDate, networkAvailable, oldTickerDatas;


+(id)globals
{
    static Globals *sharedGlobals = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedGlobals = [[self alloc] init];
    });
    return sharedGlobals;
}

- (id)init
{
    if (self = [super init])
    {
        currency = [[NSString alloc] init];
        lastRecordDate = [[NSDate alloc] init];
        lastRecordDateOrderBook = [[NSDate alloc] init];
        queryStartDate = [[NSDate alloc] init];
        networkAvailable = NO;
        oldTickerDatas = NO;
    }
    return self;
}


//// return network status
- (BOOL)isNetworkAvailable
{
    return networkAvailable;
}
//// set network status flag
//- (void) setNetworkAvailable:(BOOL)status
//{
//    networkAvailable = status;
//}
//
//- (BOOL) networkAvailable
//{
//    return networkAvailable;
//}
//
// return true if a ticker have been previously recorded
- (BOOL) isOldTickerDatas
{
    return oldTickerDatas;
}
//// set network status flag
//- (void) setOldTickerDatas:(BOOL)status
//{
//    oldTickerDatas = status;
//}
//
//- (BOOL) oldTickerDatas
//{
//    return oldTickerDatas;
//}

// return selected currency
- (NSString*) currency
{
    return currency;
}


// set currency
- (void) setCurrency:(NSString*)newCurrency
{
    currency = newCurrency;
}

// return date of ticker's last recording in db
- (NSDate*) lastRecordDate
{
    return lastRecordDate;
}

- (void) setLastRecordDate:(NSDate*)newDate
{
    lastRecordDate = newDate;
}

// return date of orderbook's last recording in db
- (NSDate*) lastRecordDateOrderBook
{
    return lastRecordDateOrderBook;
}

- (void) setLastRecordDateOrderBook:(NSDate*)newDate
{
    lastRecordDateOrderBook = newDate;
}

// return the first part of ressources URL
- (NSString*) urlStart
{
    return [NSString stringWithFormat:@"https://localbitcoins.com/bitcoinaverage/ticker-all-currencies/"];
}

// return the first part of ressources URL
- (NSString*) tickerURLstart
{
    return [NSString stringWithFormat:@"https://localbitcoins.com/bitcoincharts/"];
}

// return the last part of ressources URL
- (NSString*) orderBookURLend
{
    return [NSString stringWithFormat:@"/orderbook.json"];
}

// return the first part of ressources URL
- (NSString*) graphURLStart
{
    // * old url, now is down.. :-(
    //    return [NSString stringWithFormat:@"https://api.bitcoincharts.com/v1/trades.csv?symbol=localbtc"];
    // *
    // for this new url, we can pass 'max_tid' param to get older datas. Simple query return only the last 500 transactions
    return [NSString stringWithFormat:@"https://localbitcoins.com/bitcoincharts/"];
}

// return the last part of ressources URL
- (NSString*) graphURLEnd
{
    // * old url, now is down.. :-(
    //   return [NSString stringWithFormat:@"&start="];
    // *
    return [NSString stringWithFormat:@"/trades.json"];
}

// return the first part of ressources URL
- (NSString*) mapURL:(CLLocationCoordinate2D) uLocation;
{
    NSString *urlStart = [NSString stringWithFormat:@"https://localbitcoins.com/api/places/?lat="];
    NSString *tmpUrl = [[NSString alloc] initWithString:[urlStart stringByAppendingString:[NSString stringWithFormat:@"%f",uLocation.latitude]]];
    NSString *tmpurlx = [[NSString alloc] initWithString:[tmpUrl stringByAppendingString:@"&lon="]];
    return [[NSString alloc] initWithString:[tmpurlx stringByAppendingString:[NSString stringWithFormat:@"%f",uLocation.longitude]]];
}
// return beginning date used for query
- (NSDate*) queryStartDate
{
    return queryStartDate;
}

- (void) setQueryStartDate:(NSDate*)startDate
{
    queryStartDate = startDate;
}



@end
