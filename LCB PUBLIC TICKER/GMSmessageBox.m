//
//  GMSmessageBox.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import "GMSmessageBox.h"

@implementation GMSMessageBox

@synthesize messageBoxBackground;

+ (id)messageBox:(CGFloat)posY {
     GMSMessageBox *messageBox = nil;
  
        messageBox = [[self alloc] initWithPosY:posY];
   
    return messageBox;
}
- (id)initWithPosY:(CGFloat)posY
{
    if (self = [super init])
    {
        messageBoxBackground = [[UIView alloc] init];
        
       // messageBoxBackground = [UIImage imageNamed:@"LCB_messageBox.png"];
       // [self setFrame:CGRectMake(0.0, 120.0, self.window.bounds.size.width, 64.0)];
        CGRect frame = CGRectMake(0.0, posY, self.window.bounds.size.width, 64.0);
        self = [super initWithFrame:frame];
        messageBoxBackground.backgroundColor = [UIColor colorWithRed:0.827 green:0.827 blue:0.827 alpha:1.0];
    }
    return self;
    
}

@end
