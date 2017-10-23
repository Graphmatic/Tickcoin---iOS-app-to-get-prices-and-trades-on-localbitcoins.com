//
//  GMSChartInformationView.m
//  GMSChartViewDemo
//
//  Created by Terry Worona on 11/11/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "GMSChartInformationView.h"

// Numerics
CGFloat const kGMSChartValueViewPadding = 10.0f;
CGFloat const kGMSChartValueViewSeparatorSize = 0.5f;
CGFloat const kGMSChartValueViewTitleHeight = 50.0f;
CGFloat const kGMSChartValueViewTitleWidth = 75.0f;
CGFloat const kGMSChartValueViewDefaultAnimationDuration = 0.25f;

// Colors (GMSChartInformationView)
static UIColor *kGMSChartViewSeparatorColor = nil;
static UIColor *kGMSChartViewTitleColor = nil;
static UIColor *kGMSChartViewShadowColor = nil;

// Colors (GMSChartInformationView)
static UIColor *kGMSChartInformationViewValueColor = nil;
static UIColor *kGMSChartInformationViewUnitColor = nil;
static UIColor *kGMSChartInformationViewShadowColor = nil;

@interface GMSChartValueView : UIView

@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *unitLabel;

@end

@interface GMSChartInformationView ()

@property (nonatomic, strong) GMSChartValueView *valueView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *separatorView;

// Position
- (CGRect)valueViewRect;
- (CGRect)titleViewRectForHidden:(BOOL)hidden;
- (CGRect)separatorViewRectForHidden:(BOOL)hidden;

@end

@implementation GMSChartInformationView

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [GMSChartInformationView class])
	{
		kGMSChartViewSeparatorColor = [UIColor whiteColor];
        kGMSChartViewTitleColor = [UIColor whiteColor];
        kGMSChartViewShadowColor = [UIColor blackColor];
	}
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.clipsToBounds = YES;

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = GMSChartFontInformationTitle;
        _titleLabel.numberOfLines = 1;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = kGMSChartViewTitleColor;
        _titleLabel.shadowColor = kGMSChartViewShadowColor;
        _titleLabel.shadowOffset = CGSizeMake(0, 1);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];

        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = kGMSChartViewSeparatorColor;
        [self addSubview:_separatorView];

        _valueView = [[GMSChartValueView alloc] initWithFrame:[self valueViewRect]];
        [self addSubview:_valueView];
        
        [self setHidden:YES animated:NO];
    }
    return self;
}

#pragma mark - Position

- (CGRect)valueViewRect
{
    CGRect valueRect = CGRectZero;
    valueRect.origin.x = kGMSChartValueViewPadding;
    valueRect.origin.y = kGMSChartValueViewPadding + kGMSChartValueViewTitleHeight;
    valueRect.size.width = self.bounds.size.width - (kGMSChartValueViewPadding * 2);
    valueRect.size.height = self.bounds.size.height - valueRect.origin.y - kGMSChartValueViewPadding;
    return valueRect;
}

- (CGRect)titleViewRectForHidden:(BOOL)hidden
{
    CGRect titleRect = CGRectZero;
    titleRect.origin.x = kGMSChartValueViewPadding;
    titleRect.origin.y = hidden ? -kGMSChartValueViewTitleHeight : kGMSChartValueViewPadding;
    titleRect.size.width = self.bounds.size.width - (kGMSChartValueViewPadding * 2);
    titleRect.size.height = kGMSChartValueViewTitleHeight;
    return titleRect;
}

- (CGRect)separatorViewRectForHidden:(BOOL)hidden
{
    CGRect separatorRect = CGRectZero;
    separatorRect.origin.x = kGMSChartValueViewPadding;
    separatorRect.origin.y = kGMSChartValueViewTitleHeight;
    separatorRect.size.width = self.bounds.size.width - (kGMSChartValueViewPadding * 2);
    separatorRect.size.height = kGMSChartValueViewSeparatorSize;
    if (hidden)
    {
        separatorRect.origin.x -= self.bounds.size.width;
    }
    return separatorRect;
}

#pragma mark - Setters

- (void)setTitleText:(NSString *)titleText
{
    self.titleLabel.text = titleText;
    self.separatorView.hidden = !(titleText != nil);
}

- (void)setValueText:(NSString *)valueText unitText:(NSString *)unitText
{
    self.valueView.valueLabel.text = valueText;
    self.valueView.unitLabel.text = unitText;
    [self.valueView setNeedsLayout];
}

- (void)setTitleTextColor:(UIColor *)titleTextColor
{
    self.titleLabel.textColor = titleTextColor;
    [self.valueView setNeedsDisplay];
}

- (void)setValueAndUnitTextColor:(UIColor *)valueAndUnitColor
{
    self.valueView.valueLabel.textColor = valueAndUnitColor;
    self.valueView.unitLabel.textColor = valueAndUnitColor;
    [self.valueView setNeedsDisplay];
}

- (void)setTextShadowColor:(UIColor *)shadowColor
{
    self.valueView.valueLabel.shadowColor = shadowColor;
    self.valueView.unitLabel.shadowColor = shadowColor;
    self.titleLabel.shadowColor = shadowColor;
    [self.valueView setNeedsDisplay];
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    self.separatorView.backgroundColor = separatorColor;
    [self setNeedsDisplay];
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (animated)
    {
        if (hidden)
        {
            [UIView animateWithDuration:kGMSChartValueViewDefaultAnimationDuration * 0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.titleLabel.alpha = 0.0;
                self.separatorView.alpha = 0.0;
                self.valueView.valueLabel.alpha = 0.0;
                self.valueView.unitLabel.alpha = 0.0;
            } completion:^(BOOL finished) {
                self.titleLabel.frame = [self titleViewRectForHidden:YES];
                self.separatorView.frame = [self separatorViewRectForHidden:YES];
            }];
        }
        else
        {
            [UIView animateWithDuration:kGMSChartValueViewDefaultAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.titleLabel.frame = [self titleViewRectForHidden:NO];
                self.titleLabel.alpha = 1.0;
                self.valueView.valueLabel.alpha = 1.0;
                self.valueView.unitLabel.alpha = 1.0;
                self.separatorView.frame = [self separatorViewRectForHidden:NO];
                self.separatorView.alpha = 1.0;
            } completion:nil];
        }
    }
    else
    {
        self.titleLabel.frame = [self titleViewRectForHidden:hidden];
        self.titleLabel.alpha = hidden ? 0.0 : 1.0;
        self.separatorView.frame = [self separatorViewRectForHidden:hidden];
        self.separatorView.alpha = hidden ? 0.0 : 1.0;
        self.valueView.valueLabel.alpha = hidden ? 0.0 : 1.0;
        self.valueView.unitLabel.alpha = hidden ? 0.0 : 1.0;
    }
}

- (void)setHidden:(BOOL)hidden
{
    [self setHidden:hidden animated:NO];
}

@end

@implementation GMSChartValueView

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [GMSChartValueView class])
	{
		kGMSChartInformationViewValueColor = [UIColor whiteColor];
        kGMSChartInformationViewUnitColor = [UIColor whiteColor];
        kGMSChartInformationViewShadowColor = [UIColor blackColor];
	}
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.font = GMSChartFontInformationValue;
        _valueLabel.textColor = kGMSChartInformationViewValueColor;
        _valueLabel.shadowColor = kGMSChartInformationViewShadowColor;
        _valueLabel.shadowOffset = CGSizeMake(0, 1);
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.textAlignment = NSTextAlignmentRight;
        _valueLabel.adjustsFontSizeToFitWidth = YES;
        _valueLabel.numberOfLines = 1;
        [self addSubview:_valueLabel];
        
        _unitLabel = [[UILabel alloc] init];
        _unitLabel.font = GMSChartFontInformationUnit;
        _unitLabel.textColor = kGMSChartInformationViewUnitColor;
        _unitLabel.shadowColor = kGMSChartInformationViewShadowColor;
        _unitLabel.shadowOffset = CGSizeMake(0, 1);
        _unitLabel.backgroundColor = [UIColor clearColor];
        _unitLabel.textAlignment = NSTextAlignmentLeft;
        _unitLabel.adjustsFontSizeToFitWidth = YES;
        _unitLabel.numberOfLines = 1;
        [self addSubview:_unitLabel];
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    CGSize valueLabelSize = [self.valueLabel.text sizeWithAttributes:@{NSFontAttributeName:self.valueLabel.font}];
    CGSize unitLabelSize = [self.unitLabel.text sizeWithAttributes:@{NSFontAttributeName:self.unitLabel.font}];
    
    CGFloat xOffset = ceil((self.bounds.size.width - (valueLabelSize.width + unitLabelSize.width)) * 0.5);

    self.valueLabel.frame = CGRectMake(xOffset, ceil(self.bounds.size.height * 0.5) - ceil(valueLabelSize.height * 0.5), valueLabelSize.width, valueLabelSize.height);
    self.unitLabel.frame = CGRectMake(CGRectGetMaxX(self.valueLabel.frame), ceil(self.bounds.size.height * 0.5) - ceil(unitLabelSize.height * 0.5) + kGMSChartValueViewPadding + 3, unitLabelSize.width, unitLabelSize.height);
}

@end
