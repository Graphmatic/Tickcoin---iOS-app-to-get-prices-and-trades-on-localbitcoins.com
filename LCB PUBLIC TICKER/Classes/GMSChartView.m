//
//  GMSChartView.m
//  Nudge
//
//  Created by Terry Worona on 9/4/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "GMSChartView.h"

// Numerics
CGFloat const kGMSChartViewDefaultAnimationDuration = 0.25f;

// Color (GMSChartSelectionView)
static UIColor *kGMSChartVerticalSelectionViewDefaultBgColor = nil;

@interface GMSChartView ()

@property (nonatomic, assign) BOOL hasMaximumValue;
@property (nonatomic, assign) BOOL hasMinimumValue;

// Construction
- (void)constructChartView;

// Validation
- (void)validateHeaderAndFooterHeights;

@end

@implementation GMSChartView

#pragma mark - Alloc/Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self constructChartView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self constructChartView];
    }
    return self;
}

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

#pragma mark - Construction

- (void)constructChartView
{
   // self.frame = CGRectMake(2, 358, 516, 254);
   
    self.clipsToBounds = YES;
}

#pragma mark - Public

- (void)reloadData
{
    // Override
}

#pragma mark - Validation

- (void)validateHeaderAndFooterHeights
{
    NSAssert((self.headerView.bounds.size.height + self.footerView.bounds.size.height) <= self.bounds.size.height, @"GMSChartView // the combined height of the footer and header can not be greater than the total height of the chart.");
}

#pragma mark - Setters

- (void)setHeaderView:(UIView *)headerView
{
    if (_headerView)
    {
        [_headerView removeFromSuperview];
        _headerView = nil;
    }
    _headerView = headerView;
    _headerView.clipsToBounds = YES;
    
    [self validateHeaderAndFooterHeights];
    
    [self addSubview:_headerView];
    [self reloadData];
}

- (void)setFooterView:(UIView *)footerView
{
    if (_footerView)
    {
        [_footerView removeFromSuperview];
        _footerView = nil;
    }
    _footerView = footerView;
    _footerView.clipsToBounds = YES;
    
    [self validateHeaderAndFooterHeights];
    
    [self addSubview:_footerView];
    [self reloadData];
}

- (void)setState:(GMSChartViewState)state animated:(BOOL)animated callback:(void (^)(void))callback force:(BOOL)force
{
    if ((_state == state) && !force)
    {
        return;
    }
    
    _state = state;
    
    // Override
}

- (void)setState:(GMSChartViewState)state animated:(BOOL)animated callback:(void (^)(void))callback
{
    [self setState:state animated:animated callback:callback force:NO];
}

- (void)setState:(GMSChartViewState)state animated:(BOOL)animated
{
    [self setState:state animated:animated callback:nil];
}

- (void)setState:(GMSChartViewState)state
{
    [self setState:state animated:NO];
}

- (void)setMinimumValue:(CGFloat)minimumValue
{
    NSAssert(minimumValue >= 0, @"GMSChartView // the minimumValue must be >= 0.");
    _minimumValue = minimumValue;
    _hasMinimumValue = YES;
}

- (void)setMaximumValue:(CGFloat)maximumValue
{
    NSAssert(maximumValue >= 0, @"GMSChartView // the maximumValue must be >= 0.");
    _maximumValue = maximumValue;
    _hasMaximumValue = YES;
}

- (void)resetMinimumValue
{
    _hasMinimumValue = NO; // clears min
}

- (void)resetMaximumValue
{
    _hasMaximumValue = NO; // clears max
}

@end

@implementation GMSChartVerticalSelectionView

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [GMSChartVerticalSelectionView class])
	{
		kGMSChartVerticalSelectionViewDefaultBgColor = GMSColorOrange;
	}
}

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
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] set];
    CGContextFillRect(context, rect);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 0.8 };
    
    NSArray *colors = nil;
    if (self.bgColor != nil)
    {
        colors = @[(__bridge id)self.bgColor.CGColor, (__bridge id)[self.bgColor colorWithAlphaComponent:0.0].CGColor];
    }
    else
    {
        colors = @[(__bridge id)kGMSChartVerticalSelectionViewDefaultBgColor.CGColor, (__bridge id)[kGMSChartVerticalSelectionViewDefaultBgColor colorWithAlphaComponent:0.0].CGColor];
    }
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    
    CGContextSaveGState(context);
    {
        CGContextAddRect(context, rect);
        CGContextClip(context);
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    }
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

#pragma mark - Setters

- (void)setBgColor:(UIColor *)bgColor
{
    _bgColor = bgColor;
    [self setNeedsDisplay];
}

@end
