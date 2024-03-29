//
//  GMSBarChartFooterView.h
//  GMSChartViewDemo
//
//  Created by Terry Worona on 11/6/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMSBarChartFooterView : UIView

@property (nonatomic, strong) UIColor *footerBackgroundColor; // footer background (default = black)
@property (nonatomic, assign) CGFloat padding; // label left & right padding (default = 4.0)
@property (nonatomic, readonly) UILabel *leftLabel;
@property (nonatomic, readonly) UILabel *rightLabel;

@end
