//
//  GMSMessageHandler.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 30/03/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMSGlobals.h"

@interface GMSMessageHandler : NSObject
{
    NSString *infoMessagesStr;
    NSString *nextInfoMessageStr;
}
+ (id)messageHandler:(int)view;
- (void)waitWhileLoading;
//- (NSMutableString*)dailyMessages:(int)messagesCount connected:(BOOL)connected;
- (NSArray*)bidsViewMessages:(int)messagesCount connected:(BOOL)connected maxDeviation:(float)maxDev isAscSorted:(bool)isAscSorted;
- (NSArray*)asksViewMessages:(int)messagesCount connected:(BOOL)connected maxDeviation:(float)maxDev isDescSorted:(bool)isDescSorted;
- (void)noConnection:(NSNotification *)notification;
- (void)dailyMessages;
//- (void)restartTic;
- (void)stopTic;
- (void)reset;
- (void)refresh;
- (void)swapFirstViewMessage;

@property (nonatomic, strong)  NSString *infoMessagesStr;
@property (nonatomic, strong) NSString *nextInfoMessageStr;
// The repeating timer is a weak property.
// https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Timers/Articles/usingTimers.html
@property (weak) NSTimer *tic;
@property (weak) NSTimer *switchTic;
@property BOOL alt;
@property (nonatomic, strong) NSError *connectionError;


@end
