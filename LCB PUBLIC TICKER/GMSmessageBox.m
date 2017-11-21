//
//  GMSmessageBox.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import "GMSmessageBox.h"
#import <UIKit/UIKit.h>

@implementation GMSMessageBox

@synthesize messageBox;

+ (id)init:(CGFloat)posY
{
    GMSMessageBox *messageBox = nil;
    messageBox = [[self alloc] initWithPosY:posY];
    
    return messageBox;
}
- (id)initWithPosY:(CGFloat)posY
{
    if (self = [super init])
    {
        CGRect frame = CGRectMake(0.0, posY, self.window.bounds.size.width, 64.0);
        self = [self initWithFrame:frame];
    }
    return self;
    
}

@end

