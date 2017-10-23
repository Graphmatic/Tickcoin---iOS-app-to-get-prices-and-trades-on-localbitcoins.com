//
//  GMSChartHeaderView.m
//  GMSChartViewDemo
//
//  Created by Terry Worona on 11/6/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "GMSChartHeaderView.h"

// Numerics
CGFloat const GMSChartHeaderViewPadding = 10.0f;
CGFloat const GMSChartHeaderViewSeparatorHeight = 0.5f;

// Colors
static UIColor *kGMSChartHeaderViewDefaultSeparatorColor = nil;

@interface GMSChartHeaderView ()

@property (nonatomic, strong) UIView *separatorView;

@end

@implementation GMSChartHeaderView

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [GMSChartHeaderView class])
	{
		kGMSChartHeaderViewDefaultSeparatorColor = [UIColor whiteColor];
	}
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 1;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = GMSChartFontHeaderTitle;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = GMSColorBlue;
        [self addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.numberOfLines = 1;
        _subtitleLabel.adjustsFontSizeToFitWidth = YES;
        _subtitleLabel.font = GMSFontHeaderSubtitle;
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.textColor = GMSColorBlue;
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_subtitleLabel];
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = GMSColorWhite;
        [self addSubview:_separatorView];
    }
    return self;
}

#pragma mark - Setters

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    _separatorColor = separatorColor;
    self.separatorView.backgroundColor = _separatorColor;
    [self setNeedsLayout];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat titleHeight = ceil(self.bounds.size.height * 0.5);
    CGFloat subTitleHeight = self.bounds.size.height - titleHeight - GMSChartHeaderViewSeparatorHeight;
    CGFloat xOffset = 0;
    CGFloat yOffset = 0;
    
    self.titleLabel.frame = CGRectMake(xOffset, yOffset, self.bounds.size.width - (xOffset * 2), titleHeight);
    yOffset += self.titleLabel.frame.size.height;
    self.separatorView.frame = CGRectMake(xOffset * 2, yOffset, self.bounds.size.width - (xOffset * 4), GMSChartHeaderViewSeparatorHeight);
    yOffset += self.separatorView.frame.size.height;
    self.subtitleLabel.frame = CGRectMake(xOffset, yOffset, self.bounds.size.width - (xOffset * 2), subTitleHeight);
}

@end
