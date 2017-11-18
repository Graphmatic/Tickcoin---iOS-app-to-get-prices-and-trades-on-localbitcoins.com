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
    UIView *messageBox;
}

+ (id)init:(CGFloat)posY;

//@property (nonatomic, retain) UIView *messagebox;
@property (strong, nonatomic) IBOutlet UIView *messageBox;


@end
