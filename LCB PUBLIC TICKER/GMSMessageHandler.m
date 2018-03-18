//
//  GMSMessageHandler.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 30/03/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import "GMSMessageHandler.h"

@interface GMSMessageHandler  ()

@end

@implementation GMSMessageHandler

@synthesize infoMessagesStr, tic, switchTic, nextInfoMessageStr, alt, connectionError;

static dispatch_once_t onceToken;
static GMSMessageHandler *messageHandler = nil;

+ (id)messageHandler:(int)view
{
    dispatch_once(&onceToken, ^{
        messageHandler = [[self alloc] init:view];
    });
    return messageHandler;
}

+ (void)reset{
    @synchronized(self) {
        messageHandler = nil;
        onceToken = 0;
    }
}

- (id)init:(int)view
{
    if (self = [super init])
    {
        self.nextInfoMessageStr = [NSMutableString stringWithFormat:NSLocalizedString(@"_WAIT_FOR_DATAS", @"please wait - update...")];
        // Cancel a preexisting timer.
        if( self.tic != nil )
        {
            [self.tic invalidate];
        }
        if( self.switchTic != nil )
        {
            [self.switchTic invalidate];
        }
        NSTimer *tmr1 = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                         target:self selector:@selector(refresh)
                                                       userInfo:nil repeats:YES];
        self.tic = tmr1;

        NSTimer *tmr2;
        
        switch (view)
        {
            case 0:
                tmr2 = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                          target:self selector:@selector(swapFirstViewMessage)
                                                        userInfo: nil repeats:YES];
                break;
                
            default:
                tmr2 = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                        target:self selector:@selector(swapFirstViewMessage)
                                                      userInfo: nil repeats:YES];
                break;
        }
        self.switchTic = tmr2;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noConnection:) name:@"connectionError" object:nil];

        self.connectionError = nil;
        [self waitWhileLoading];
    }
    return self;
}

- (void)waitWhileLoading
{
    self.nextInfoMessageStr = [NSMutableString stringWithFormat:NSLocalizedString(@"_WAIT_FOR_DATAS", @"please wait - update...")];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName: @"infoRefresh" object:nil];
    });
}

- (void)refresh
{
    if( !([self.infoMessagesStr isEqualToString:self.nextInfoMessageStr]) )
    {
        self.infoMessagesStr = self.nextInfoMessageStr;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName: @"infoRefresh" object:nil];
        });
    }
}

- (void)stopTic
{
    if( self.tic != nil )
    {
        [self.tic invalidate];
    }
    if( self.switchTic != nil )
    {
        [self.switchTic invalidate];
    }
}

- (void)swapFirstViewMessage
{
    
    Globals *glob = [Globals globals];

    //NSLog([glob networkAvailable] ? @"Yes" : @"No");
//    NSLog(@"glob : %@", [glob networkAvailable]);

    if ( [glob isNetworkAvailable] == YES )
    {
        //NSLog(@"IS NETWORK");
        if ( self.alt )
        {
            self.nextInfoMessageStr = [NSMutableString  stringWithFormat:NSLocalizedString(@"_DAILY_PRICE_IN", @"daily price in"), [glob lastRecordDate], [glob currency]];
        }
        else
        {
            self.nextInfoMessageStr = [NSMutableString  stringWithFormat:NSLocalizedString(@"_SWIPE_DOWN_TO_REFRESH", @"swipe down to refresh")];
        }
    }
    else
    {
        //NSLog(@"IS not NETWORK");

        if ( self.alt )
        {
            if ( self.connectionError != nil )
            {
                self.nextInfoMessageStr = self.connectionError.localizedDescription;
            }
            else
            {
                self.nextInfoMessageStr = [NSMutableString stringWithFormat:NSLocalizedString(@"_THIS_APP_NEED_INTERNET", @"internet connection is required to use this app")];
            }
        }
        else
        {
            if( ![glob isNetworkAvailable] && ![glob isOldTickerDatas] )  // no internet connection and no datas previously saved
            {
                self.nextInfoMessageStr = [NSMutableString stringWithFormat:NSLocalizedString(@"_THIS_APP_NEED_INTERNET", @"internet connection is required to use this app")];
            }
            else if( ![glob isNetworkAvailable] && [glob isOldTickerDatas] ) // no internet connection but previously saved datas
            {
                self.nextInfoMessageStr = [NSMutableString stringWithFormat:NSLocalizedString(@"_NO_CONNECT_OUTDATED", @"datas outdated"), [glob lastRecordDate]];
            }
            else if ( [glob isNetworkAvailable] ) //
            {
                self.nextInfoMessageStr = [NSMutableString stringWithFormat:NSLocalizedString(@"_NO_CONNECT_OUTDATED", @"datas outdated"), [glob lastRecordDate]];
            }
        }
    }
    self.alt = !self.alt;

}

// no internet connection warning
- (void)noConnection:(NSNotification *)notification
{
    self.connectionError = [notification.userInfo objectForKey:@"error"];
}

//message box
- (void)dailyMessages
{
    Globals *glob = [Globals globals];
    if (self.alt)
    {
        self.nextInfoMessageStr = [NSMutableString  stringWithFormat:NSLocalizedString(@"_DAILY_PRICE_IN", @"daily price in"), [glob lastRecordDate], [glob currency]];
    }
    else
    {
        self.nextInfoMessageStr = [NSMutableString  stringWithFormat:NSLocalizedString(@"_SWIPE_DOWN_TO_REFRESH", @"swipe down to refresh")];
    }
    self.alt = !self.alt;

//    return self.infoMessagesStr;
    
}
- (NSArray*)bidsViewMessages:(int)messagesCount connected:(BOOL)connected maxDeviation:(float)maxDev isAscSorted:(bool)isAscSorted
{
    Globals *glob = [Globals globals];

    switch (messagesCount)
    {
        case 0:
//            if ( !IS_IPAD )
//            {
                if(maxDev == 201)
                {
                    self.infoMessagesStr = [NSString stringWithFormat:NSLocalizedString(@"_DEVIATION_TRESHOLD_FILTER_DISABLED", @"display filter: disabled")];
                }
                else
                {
                    self.infoMessagesStr = [NSString stringWithFormat:NSLocalizedString(@"_DEVIATION_TRESHOLD_FILTER", @"display filter: +/- %d%% of last price"),(int)maxDev];
                }
//            }
            break;
        case 1:
            if ( !IS_IPAD )
            {
                self.infoMessagesStr = [NSString stringWithFormat:NSLocalizedString(@"_EDIT_SETTING", @"swipe to right to edit this filter threshold")];
            }
            break;
        default:
            self.infoMessagesStr = [NSString stringWithFormat:NSLocalizedString(@"_SELL_ADD_FOR_CUR_x", @"Sell ads - %@"), [glob currency]];
            break;
        case 2:
            if ( isAscSorted == NO )
            {
                self.infoMessagesStr = [NSString stringWithFormat:NSLocalizedString(@"_DOUBLE_TAP_ASCENDING", "double tap to sort ascending")];
            }
            else
            {
                self.infoMessagesStr = [NSString stringWithFormat:NSLocalizedString(@"_DOUBLE_TAP_DESCENDING", "double tap to sort descending")];
            }
            
            
    }
    messagesCount +=1;
    NSNumber *newMessageCount = [NSNumber numberWithInteger:messagesCount];
    NSArray *bidsMessageBack = [[NSArray alloc]initWithObjects:newMessageCount,self.infoMessagesStr, nil];
    return bidsMessageBack;
}
- (NSArray*)asksViewMessages:(int)messagesCount connected:(BOOL)connected maxDeviation:(float)maxDev isDescSorted:(bool)isDescSorted
{
    Globals *glob = [Globals globals];

    switch (messagesCount)
    {
        case 0:
//            if ( !IS_IPAD )
//            {
                if(maxDev == 201)
                {
                    self.infoMessagesStr = [NSString stringWithFormat:NSLocalizedString(@"_DEVIATION_TRESHOLD_FILTER_DISABLED", @"display filter: disabled")];
                }
                else
                {
                    self.infoMessagesStr = [NSString stringWithFormat:NSLocalizedString(@"_DEVIATION_TRESHOLD_FILTER", @"display filter: +/- %d%% of last price"),(int)maxDev];
                }
//            }
            break;
        case 1:
            if ( !IS_IPAD )
            {
                self.infoMessagesStr = [NSString stringWithFormat:NSLocalizedString(@"_EDIT_SETTING", @"swipe to right to edit this filter threshold")];
            }
            break;
        default:
            self.infoMessagesStr = [NSString stringWithFormat:NSLocalizedString(@"_SELL_ADD_FOR_CUR_x", @"Sell ads - %@"), [glob currency]];
            break;
        case 2:
            if ( isDescSorted == NO )
            {
                self.infoMessagesStr = [NSString stringWithFormat:NSLocalizedString(@"_DOUBLE_TAP_DESCENDING", "double tap to sort descending")];
            }
            else
            {
                self.infoMessagesStr = [NSString stringWithFormat:NSLocalizedString(@"_DOUBLE_TAP_ASCENDING", "double tap to sort ascending")];
            }
            
            
    }
    messagesCount +=1;
    NSNumber *newMessageCount = [NSNumber numberWithInteger:messagesCount];
    NSArray *asksMessageBack = [[NSArray alloc]initWithObjects:newMessageCount,self.infoMessagesStr, nil];
    return asksMessageBack;
}
@end
