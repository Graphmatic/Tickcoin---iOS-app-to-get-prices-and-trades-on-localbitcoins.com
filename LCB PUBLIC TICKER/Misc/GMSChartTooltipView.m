//
//  GMSChartTooltipView.m
//  GMSChartViewDemo
//
//  Created by Terry Worona on 3/12/14.
//  Copyright (c) 2014 Jawbone. All rights reserved.
//

#import "GMSChartTooltipView.h"

// Drawing
#import <QuartzCore/QuartzCore.h>

// Numerics
CGFloat static const GMSChartTooltipViewCornerRadius = 2.0;
CGFloat const GMSChartTooltipViewDefaultWidth = 75.0f;
CGFloat const GMSChartTooltipViewDefaultHeight = 75.0f;

@interface GMSChartTooltipView ()

@property (nonatomic, strong) UILabel *textLabel;
@property (strong, nonatomic) UILabel *noChartMessage;
@end

@implementation GMSChartTooltipView

#pragma mark - Alloc/Init

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, GMSChartTooltipViewDefaultWidth, GMSChartTooltipViewDefaultHeight)];
    if (self)
    {
        self.backgroundColor = GMSColorTooltipColor;
        self.layer.cornerRadius = GMSChartTooltipViewCornerRadius;
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = GMSFontTooltipText;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = GMSColorTooltipTextColor;
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.numberOfLines = 2;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        
      
        [self addSubview:_textLabel];
     
    }
    return self;
}

#pragma mark - Setters

- (void)setText:(NSString *)text
{
    self.textLabel.text = text;
    [self setNeedsLayout];
}

- (void)setTooltipColor:(UIColor *)tooltipColor
{
    self.backgroundColor = tooltipColor;
    [self setNeedsDisplay];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    _textLabel.frame = self.bounds;
}

@end
