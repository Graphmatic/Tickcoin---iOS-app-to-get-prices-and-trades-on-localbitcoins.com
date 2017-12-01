//
//  GMSMessageBoxProcessor.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 30/03/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import "GMSMessageBoxProcessor.h"

@interface GMSMessageBoxProcessor  ()

@end

@implementation GMSMessageBoxProcessor

@synthesize messageBoxString, Globals;

- (id)init
{
	if ((self = [super init]) == nil)
	{
		return nil;
	}
    messageBoxString = [[NSMutableString alloc]init];
    
    messageBoxString = [NSMutableString stringWithFormat:NSLocalizedString(@"_WAIT_FOR_DATAS", @"please wait - update...")];
    
    self = [super init];
    return self;
}
// no internet connection warning
- (NSString*)noConnAlert: (NSError*)error alt:(BOOL)altMessages
{
    if(altMessages)
    {
        self.messageBoxString = (NSMutableString*) error.localizedDescription;
    }
    else
    {
        if([self.Globals isNetworkAvailable])
        {
            self.messageBoxString = [NSMutableString stringWithFormat:NSLocalizedString(@"_THIS_APP_NEED_INTERNET", @"internet connection is required to use this app")];
        }
        else
        {
            self.messageBoxString = [NSMutableString stringWithFormat:NSLocalizedString(@"_NO_CONNECT_OUTDATED", @"datas outdated"), [self.Globals lastRecordDate]];
        }
    }
    return self.messageBoxString;
}
//message box
- (NSString*)dailyMessages:(int)messagesCount connected:(BOOL)connected
{
    switch (messagesCount)
    {
        case 0:
            self.messageBoxString = [NSMutableString  stringWithFormat:NSLocalizedString(@"_DAILY_PRICE_IN", @"daily price in"), [self.Globals lastRecordDate], [self.Globals currency]];
        break;
        case 1:
            self.messageBoxString = [NSMutableString  stringWithFormat:NSLocalizedString(@"_SWIPE_DOWN_TO_REFRESH", @"swipe down to refresh")];
            break;
        
            
        default:
            self.messageBoxString = [NSMutableString  stringWithFormat:NSLocalizedString(@"_DAILY_PRICE_IN", @"daily price in"), [self.Globals currency]];
            break;
    }

    return self.messageBoxString;
    
}
- (NSArray*)bidsViewMessages:(int)messagesCount connected:(BOOL)connected maxDeviation:(float)maxDev isAscSorted:(bool)isAscSorted
{
    switch (messagesCount)
    {
        case 0:
            if ( !IS_IPAD )
            {
                if(maxDev == 201)
                {
                    self.messageBoxString = [NSString stringWithFormat:NSLocalizedString(@"_DEVIATION_TRESHOLD_FILTER_DISABLED", @"display filter: disabled")];
                }
                else
                {
                    self.messageBoxString = [NSString stringWithFormat:NSLocalizedString(@"_DEVIATION_TRESHOLD_FILTER", @"display filter: +/- %d%% of last price"),(int)maxDev];
                }
            }
            break;
        case 1:
            if ( !IS_IPAD )
            {
                self.messageBoxString = [NSString stringWithFormat:NSLocalizedString(@"_EDIT_SETTING", @"swipe to right to edit this filter threshold")];
            }
            break;
        default:
            self.messageBoxString = [NSString stringWithFormat:NSLocalizedString(@"_SELL_ADD_FOR_CUR_x", @"Sell ads - %@"), [self.Globals currency]];
            break;
        case 2:
            if ( isAscSorted == NO )
            {
                self.messageBoxString = [NSString stringWithFormat:NSLocalizedString(@"_DOUBLE_TAP_ASCENDING", "double tap to sort ascending")];
            }
            else
            {
                self.messageBoxString = [NSString stringWithFormat:NSLocalizedString(@"_DOUBLE_TAP_DESCENDING", "double tap to sort descending")];
            }
            
            
    }
    messagesCount +=1;
    NSNumber *newMessageCount = [NSNumber numberWithInteger:messagesCount];
    NSArray *bidsMessageBack = [[NSArray alloc]initWithObjects:newMessageCount,self.messageBoxString, nil];
    return bidsMessageBack;
}
- (NSArray*)asksViewMessages:(int)messagesCount connected:(BOOL)connected maxDeviation:(float)maxDev isDescSorted:(bool)isDescSorted
{
    switch (messagesCount)
    {
        case 0:
            if ( !IS_IPAD )
            {
                if(maxDev == 201)
                {
                    self.messageBoxString = [NSString stringWithFormat:NSLocalizedString(@"_DEVIATION_TRESHOLD_FILTER_DISABLED", @"display filter: disabled")];
                }
                else
                {
                    self.messageBoxString = [NSString stringWithFormat:NSLocalizedString(@"_DEVIATION_TRESHOLD_FILTER", @"display filter: +/- %d%% of last price"),(int)maxDev];
                }
            }
            break;
        case 1:
            if ( !IS_IPAD )
            {
                self.messageBoxString = [NSString stringWithFormat:NSLocalizedString(@"_EDIT_SETTING", @"swipe to right to edit this filter threshold")];
            }
            break;
        default:
            self.messageBoxString = [NSString stringWithFormat:NSLocalizedString(@"_SELL_ADD_FOR_CUR_x", @"Sell ads - %@"), [self.Globals currency]];
            break;
        case 2:
            if ( isDescSorted == NO )
            {
                self.messageBoxString = [NSString stringWithFormat:NSLocalizedString(@"_DOUBLE_TAP_DESCENDING", "double tap to sort descending")];
            }
            else
            {
                self.messageBoxString = [NSString stringWithFormat:NSLocalizedString(@"_DOUBLE_TAP_ASCENDING", "double tap to sort ascending")];
            }
            
            
    }
    messagesCount +=1;
    NSNumber *newMessageCount = [NSNumber numberWithInteger:messagesCount];
    NSArray *asksMessageBack = [[NSArray alloc]initWithObjects:newMessageCount,self.messageBoxString, nil];
    return asksMessageBack;
}
@end
