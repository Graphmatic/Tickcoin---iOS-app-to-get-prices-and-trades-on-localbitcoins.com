//
//  GMSLineChartFooterView.m
//  GMSChartViewDemo
//
//  Created by Terry Worona on 11/8/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "GMSLineChartFooterView.h"

// Numerics
CGFloat const kGMSLineChartFooterViewSeparatorWidth = 0.5f;
CGFloat const kGMSLineChartFooterViewSeparatorHeight = 3.0f;
CGFloat const kGMSLineChartFooterViewSeparatorSectionPadding = 1.0f;

// Colors
static UIColor *kGMSLineChartFooterViewDefaultSeparatorColor = nil;

@interface GMSLineChartFooterView ()

@property (nonatomic, strong) UIView *topSeparatorView;

@end

@implementation GMSLineChartFooterView

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [GMSLineChartFooterView class])
	{
		kGMSLineChartFooterViewDefaultSeparatorColor = [UIColor whiteColor];
	}
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        _footerSeparatorColor = kGMSLineChartFooterViewDefaultSeparatorColor;
        
        _topSeparatorView = [[UIView alloc] init];
        _topSeparatorView.backgroundColor = _footerSeparatorColor;
        [self addSubview:_topSeparatorView];
        
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.adjustsFontSizeToFitWidth = YES;
        _leftLabel.font = GMSFontFooterSubLabel;
        _leftLabel.textAlignment = NSTextAlignmentLeft;
        _leftLabel.textColor = [UIColor whiteColor];
        _leftLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_leftLabel];
        
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.adjustsFontSizeToFitWidth = YES;
        _rightLabel.font = GMSFontFooterSubLabel;
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.textColor = [UIColor whiteColor];
        _rightLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_rightLabel];
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, self.footerSeparatorColor.CGColor);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetShouldAntialias(context, YES);

    CGFloat xOffset = 0;
    CGFloat yOffset = kGMSLineChartFooterViewSeparatorWidth;
    CGFloat stepLength = ceil((self.bounds.size.width) / (self.sectionCount - 1));
    
    for (int i=0; i<self.sectionCount; i++)
    {
        CGContextSaveGState(context);
        {
            CGContextMoveToPoint(context, xOffset + (kGMSLineChartFooterViewSeparatorWidth * 0.5), yOffset);
            CGContextAddLineToPoint(context, xOffset + (kGMSLineChartFooterViewSeparatorWidth * 0.5), yOffset + kGMSLineChartFooterViewSeparatorHeight);
            CGContextStrokePath(context);
            xOffset += stepLength;
        }
        CGContextRestoreGState(context);
    }
    
    if (self.sectionCount > 1)
    {
        CGContextSaveGState(context);
        {
            CGContextMoveToPoint(context, self.bounds.size.width - (kGMSLineChartFooterViewSeparatorWidth * 0.5), yOffset);
            CGContextAddLineToPoint(context, self.bounds.size.width - (kGMSLineChartFooterViewSeparatorWidth * 0.5), yOffset + kGMSLineChartFooterViewSeparatorHeight);
            CGContextStrokePath(context);
        }
        CGContextRestoreGState(context);
    }
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _topSeparatorView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, kGMSLineChartFooterViewSeparatorWidth);
    
    CGFloat xOffset = 0;
    CGFloat yOffset = kGMSLineChartFooterViewSeparatorSectionPadding;
    CGFloat width = ceil(self.bounds.size.width * 0.5);
    
    self.leftLabel.frame = CGRectMake(xOffset, yOffset, width, self.bounds.size.height);
    self.rightLabel.frame = CGRectMake(CGRectGetMaxX(_leftLabel.frame), yOffset, width, self.bounds.size.height);
}

#pragma mark - Setters

- (void)setSectionCount:(NSInteger)sectionCount
{
    _sectionCount = sectionCount;
    [self setNeedsDisplay];
}

- (void)setFooterSeparatorColor:(UIColor *)footerSeparatorColor
{
    _footerSeparatorColor = footerSeparatorColor;
    _topSeparatorView.backgroundColor = _footerSeparatorColor;
    [self setNeedsDisplay];
}

@end
