//
//  GMSMessageBoxProcessor.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 30/03/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import <UIKit/UIKit.h>
extern int variationSinceLastVisit;
extern NSMutableString *currentCurrency;
extern NSMutableString *lastRecordDate;
extern BOOL firstLaunch;
@interface GMSMessageBoxProcessor : NSObject
{
         NSString *messageBoxString;
}
- (id)init;
//- (NSMutableString*)dailyMessages:(int)messagesCount connected:(BOOL)connected;
- (NSArray*)bidsViewMessages:(int)messagesCount connected:(BOOL)connected maxDeviation:(float)maxDev doubleTap:(bool)doubleTapLabel;
- (NSArray*)asksViewMessages:(int)messagesCount connected:(BOOL)connected maxDeviation:(float)maxDev doubleTap:(bool)doubleTapLabel;
- (NSString*)noConnAlert: (NSError*)error alt:(BOOL)altMessages;
- (NSString*)dailyMessages:(int)messagesCount connected:(BOOL)connected;
@property (nonatomic, strong)  NSString *messageBoxString;
@end
