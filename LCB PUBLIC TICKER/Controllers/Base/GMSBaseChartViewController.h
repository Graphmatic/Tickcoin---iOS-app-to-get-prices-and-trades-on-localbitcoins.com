//
//  GMSBaseChartViewController.h
//  GMSChartViewDemo
//
//  Created by Terry Worona on 3/13/14.
//  Copyright (c) 2014 Jawbone. All rights reserved.
//

#import "GMSBaseViewController.h"

// Views
#import "GMSChartTooltipView.h"
#import "GMSChartView.h"

@interface GMSBaseChartViewController : GMSBaseViewController

@property (nonatomic, strong, readonly) GMSChartTooltipView *tooltipView;
@property (nonatomic, assign) BOOL tooltipVisible;

// Settres
- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint;
- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated;

// Getters
- (GMSChartView *)chartView; // subclasses to return chart instance for tooltip functionality

@end
