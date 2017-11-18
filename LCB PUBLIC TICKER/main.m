//
//  main.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMSAppDelegate.h"

//global var
NSMutableString *currentCurrency;
NSMutableString *lastRecordDate;
NSMutableString *lastRecordDateOrderBook;
//NSMutableArray *currenciesList;
NSString *const urlStart  = @"https://localbitcoins.com/bitcoinaverage/ticker-all-currencies/";
NSString *const tickerURLstart  = @"https://localbitcoins.com/bitcoincharts/";
NSString *const tickerURLOrderBookEnd = @"/orderbook.json";
NSString *const graphURLStart = @"https://api.bitcoincharts.com/v1/trades.csv?symbol=localbtc";
NSString *const graphURLEnd = @"&start=";
NSDate *graphRequestStart;
int variationSinceLastVisit;
BOOL firstLaunch;
BOOL firstLaunchBids;
BOOL firstLaunchAsks;
BOOL firstLaunchChart;
BOOL connected;
BOOL lockChart;
BOOL test;
BOOL startingApp;
int main(int argc, char * argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([GMSAppDelegate class]));
    }
}
