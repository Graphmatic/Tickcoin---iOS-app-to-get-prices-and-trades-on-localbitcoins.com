//
//  GMSlabelFromJson.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 30/03/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//
//                          ***INFO***
//  use this file if you do change in the structure of the Json string send by server
#import "GMSlabelFromJson.h"

static GMSlabelFromJson *_labels;
@implementation GMSlabelFromJson
@synthesize labelsArrayOfDict;
+ (void)initialize
{
	static BOOL classInitialized = NO;
    
	if (classInitialized == NO)
	{
		_labels = [[GMSlabelFromJson alloc]init];
        
		classInitialized = YES;
	}
}
+ (id)allocWithZone: (NSZone *)zone
{
	
	if (_labels == nil)
	{
		return [super allocWithZone: zone];
	}
	else
	{
	    return [self labels];
	}
}
- (id)init
{
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	// do additionnal edit if the json source structure is modified on server side
    NSDictionary *rates =       [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"_LAST", @"lastprice"), @"rates", nil];
    NSDictionary *volume_btc =  [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"_VOLUME", @"volume"), @"volume_btc", nil];
    NSDictionary *avg_1h =      [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"_AVG_1H", @"average 1H"), @"avg_1h", nil];
    NSDictionary *avg_3h =      [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"_AVG_3H", @"average 3H"), @"avg_3h", nil];
    NSDictionary *avg_12h =     [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"_AVG_12H", @"average 12H"), @"avg_12h", nil];
    NSDictionary *avg_24h =     [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"_AVG_24H", @"average 24H"), @"avg_24h", nil];
    labelsArrayOfDict = [[NSArray alloc]initWithObjects:rates, volume_btc, avg_1h, avg_3h, avg_12h, avg_24h, nil];
	return self;
}
+ (GMSlabelFromJson *)labels
{
	return _labels;
}
- (id)copyWithZone: (NSZone *)zone
{
	return self;
}
@end
