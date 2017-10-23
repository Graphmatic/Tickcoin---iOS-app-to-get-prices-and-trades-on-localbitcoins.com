//
//  GMSChartFooterView.m
//  GMSChartViewDemo
//
//  Created by Terry Worona on 11/6/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "GMSBarChartFooterView.h"

// Numerics
CGFloat const kGMSBarChartFooterPolygonViewDefaultPadding = 4.0f;
CGFloat const kGMSBarChartFooterPolygonViewArrowHeight = 8.0f;
CGFloat const kGMSBarChartFooterPolygonViewArrowWidth = 16.0f;

// Colors
static UIColor *kGMSBarChartFooterPolygonViewDefaultBackgroundColor = nil;

@protocol GMSBarChartFooterPolygonViewDelegate;

@interface GMSBarChartFooterPolygonView : UIView

@property (nonatomic, weak) id<GMSBarChartFooterPolygonViewDelegate> delegate;

@end

@protocol GMSBarChartFooterPolygonViewDelegate <NSObject>

- (UIColor *)backgroundColorForChartFooterPolygonView:(GMSBarChartFooterPolygonView *)chartFooterPolygonView;
- (CGFloat)paddingForChartFooterPolygonView:(GMSBarChartFooterPolygonView *)chartFooterPolygonView;

@end

@interface GMSBarChartFooterView () <GMSBarChartFooterPolygonViewDelegate>

@property (nonatomic, strong) GMSBarChartFooterPolygonView *polygonView;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;

@end

@implementation GMSBarChartFooterView

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [GMSBarChartFooterView class])
	{
		kGMSBarChartFooterPolygonViewDefaultBackgroundColor = kGMSColorBarChartControllerBackground;
	}
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = kGMSBarChartFooterPolygonViewDefaultBackgroundColor;
        
        _footerBackgroundColor = kGMSBarChartFooterPolygonViewDefaultBackgroundColor;
        _padding = kGMSBarChartFooterPolygonViewDefaultPadding;
        
        _polygonView = [[GMSBarChartFooterPolygonView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y - kGMSBarChartFooterPolygonViewArrowHeight, self.bounds.size.width, self.bounds.size.height + kGMSBarChartFooterPolygonViewArrowHeight)];
        _polygonView.delegate = self;
        [self addSubview:_polygonView];
        
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.adjustsFontSizeToFitWidth = YES;
        _leftLabel.font = GMSFontFooterLabel;
        _leftLabel.textAlignment = NSTextAlignmentLeft;
        _leftLabel.shadowColor = [UIColor blackColor];
        _leftLabel.shadowOffset = CGSizeMake(0, 1);
        _leftLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_leftLabel];
        
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.adjustsFontSizeToFitWidth = YES;
        _rightLabel.font = GMSFontFooterLabel;
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.shadowColor = [UIColor blackColor];
        _rightLabel.shadowOffset = CGSizeMake(0, 1);
        _rightLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_rightLabel];
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat xOffset = self.padding;
    CGFloat yOffset = 0;
    CGFloat width = ceil(self.bounds.size.width * 0.5) - self.padding;
    
    self.leftLabel.frame = CGRectMake(xOffset, yOffset, width, self.bounds.size.height);
    self.rightLabel.frame = CGRectMake(CGRectGetMaxX(_leftLabel.frame), yOffset, width, self.bounds.size.height);
}

#pragma mark - GMSBarChartFooterPolygonViewDelegate

- (UIColor *)backgroundColorForChartFooterPolygonView:(GMSBarChartFooterPolygonView *)chartFooterPolygonView
{
    return self.footerBackgroundColor;
}

- (CGFloat)paddingForChartFooterPolygonView:(GMSBarChartFooterPolygonView *)chartFooterPolygonView
{
    return self.padding;
}

@end

@implementation GMSBarChartFooterPolygonView

#pragma mark - Alloc/Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
    
    // Background gradient
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSAssert([self.delegate respondsToSelector:@selector(backgroundColorForChartFooterPolygonView:)], @"GMSChartFooterPolygonView // delegate must implement - (UIColor *)backgroundColorForChartFooterPolygonView");
    NSAssert([self.delegate respondsToSelector:@selector(paddingForChartFooterPolygonView:)], @"GMSChartFooterPolygonView // delegate must implement - (CGFloat)paddingForChartFooterPolygonView");

    UIColor *bgColor = [self.delegate backgroundColorForChartFooterPolygonView:self];
    
    NSArray *colors = @[(__bridge id)bgColor.CGColor, (__bridge id)bgColor.CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    // Polygon shape
    CGFloat xOffset = self.bounds.origin.x;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat padding = [self.delegate paddingForChartFooterPolygonView:self];
    NSArray *polygonPoints = @[[NSValue valueWithCGPoint:CGPointMake(xOffset, height)],
                               [NSValue valueWithCGPoint:CGPointMake(xOffset, kGMSBarChartFooterPolygonViewArrowHeight)],
                               [NSValue valueWithCGPoint:CGPointMake(xOffset + padding, kGMSBarChartFooterPolygonViewArrowHeight)],
                               [NSValue valueWithCGPoint:CGPointMake(xOffset + padding + ceil(kGMSBarChartFooterPolygonViewArrowWidth * 0.5), 0)],
                               [NSValue valueWithCGPoint:CGPointMake(xOffset + padding + kGMSBarChartFooterPolygonViewArrowWidth, kGMSBarChartFooterPolygonViewArrowHeight)],
                               [NSValue valueWithCGPoint:CGPointMake(width - padding - kGMSBarChartFooterPolygonViewArrowWidth, kGMSBarChartFooterPolygonViewArrowHeight)],
                               [NSValue valueWithCGPoint:CGPointMake(width - padding - ceil(kGMSBarChartFooterPolygonViewArrowWidth * 0.5), 0.0)],
                               [NSValue valueWithCGPoint:CGPointMake(width - padding, kGMSBarChartFooterPolygonViewArrowHeight)],
                               [NSValue valueWithCGPoint:CGPointMake(width, kGMSBarChartFooterPolygonViewArrowHeight)],
                               [NSValue valueWithCGPoint:CGPointMake(width, height)],
                               [NSValue valueWithCGPoint:CGPointMake(xOffset, height)]];
    
    // Draw polygon
    NSValue *pointValue = polygonPoints[0];
    CGContextSaveGState(context);
    {
        NSInteger index = 0;
        for (pointValue in polygonPoints)
        {
            CGPoint point = [pointValue CGPointValue];
            if (index == 0)
            {
                CGContextMoveToPoint(context, point.x, point.y);
            }
            else
            {
                CGContextAddLineToPoint(context, point.x, point.y);
            }
            index++;
        }
        CGContextClip(context);
        CGContextDrawLinearGradient(context, gradient, CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect)), CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect)), 0);
    }
    CGContextRestoreGState(context);
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
}

@end
