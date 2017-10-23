//
//  Tickers.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 12/04/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tickers : NSManagedObject

@property (nonatomic, retain) NSData * ticker;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * currency;

@end
