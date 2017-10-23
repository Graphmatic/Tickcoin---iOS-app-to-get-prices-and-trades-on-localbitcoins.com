//
//  GMSmessageBox.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMSMessageBox : UIView
{
    UIView *messageBoxBackground;
}
+ (id)messageBox:(CGFloat)posY;

@property (nonatomic, retain) UIView *messageBoxBackground;
@end
