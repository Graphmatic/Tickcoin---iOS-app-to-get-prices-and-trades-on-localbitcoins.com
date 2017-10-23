//
//  GMSChartTooltipTipView.m
//  GMSChartViewDemo
//
//  Created by Terry Worona on 3/17/14.
//  Copyright (c) 2014 Jawbone. All rights reserved.
//

#import "GMSChartTooltipTipView.h"

// Numerics
CGFloat const kGMSChartTooltipTipViewDefaultWidth = 8.0f;
CGFloat const kGMSChartTooltipTipViewDefaultHeight = 5.0f;

@implementation GMSChartTooltipTipView

#pragma mark - Alloc/Init

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, kGMSChartTooltipTipViewDefaultWidth, kGMSChartTooltipTipViewDefaultHeight)];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] set];
    CGContextFillRect(context, rect);
    
    CGContextSaveGState(context);
    {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, CGRectGetMidX(rect), CGRectGetMaxY(rect));
        CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
        CGContextClosePath(context);
        CGContextSetFillColorWithColor(context, GMSColorTooltipColor.CGColor);
        CGContextFillPath(context);
    }
    CGContextRestoreGState(context);
}

@end
