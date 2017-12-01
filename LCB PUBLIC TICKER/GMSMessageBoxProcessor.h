//
//  GMSMessageBoxProcessor.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 30/03/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMSGlobals.h"

@interface GMSMessageBoxProcessor : NSObject
{
         NSString *messageBoxString;
}
- (id)init;
//- (NSMutableString*)dailyMessages:(int)messagesCount connected:(BOOL)connected;
- (NSArray*)bidsViewMessages:(int)messagesCount connected:(BOOL)connected maxDeviation:(float)maxDev isAscSorted:(bool)isAscSorted;
- (NSArray*)asksViewMessages:(int)messagesCount connected:(BOOL)connected maxDeviation:(float)maxDev isDescSorted:(bool)isDescSorted;
- (NSString*)noConnAlert: (NSError*)error alt:(BOOL)altMessages;
- (NSString*)dailyMessages:(int)messagesCount connected:(BOOL)connected;

@property (nonatomic, strong)  NSString *messageBoxString;
@property (strong, atomic) Globals *Globals;

@end
