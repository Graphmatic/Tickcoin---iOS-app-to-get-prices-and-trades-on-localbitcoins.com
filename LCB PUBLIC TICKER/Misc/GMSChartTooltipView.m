//
//  GMSChartTooltipView.m
//  GMSChartViewDemo
//
//  Created by Terry Worona on 3/12/14.
//  Copyright (c) 2014 Jawbone. All rights reserved.
//

#import "GMSChartTooltipView.h"
#import "GMSUtilitiesFunction.h"
// Drawing
#import <QuartzCore/QuartzCore.h>

// Numerics
CGFloat static const GMSChartTooltipViewCornerRadius = 2.0;
CGFloat const GMSChartTooltipViewDefaultWidth = 240.0f;
CGFloat const GMSChartTooltipViewDefaultHeight = 320.0f;

@interface GMSChartTooltipView ()



@property (strong, nonatomic) UILabel *noChartMessage;
@end

@implementation GMSChartTooltipView

@synthesize dateTime, priceAverage, sumVolume, currency, lowPrice, lowVolume, highTitle, lowTitle, lowPriceVol, highPrice, highPriceVol, lowVolprice, highVolPrice, highVol, isTrade;
#pragma mark - Alloc/Init

- (id)init
{

    self = [super initWithFrame:CGRectMake(0, 0, GMSChartTooltipViewDefaultWidth, GMSChartTooltipViewDefaultHeight)];
    if (self)
    {
        self.backgroundColor = GMSColorWhiteBlue;
        self.layer.cornerRadius = GMSChartTooltipViewCornerRadius;
        
        self.currency = [[UILabel alloc] init];
        self.currency.font = GMSHeaderFont;
        self.currency.backgroundColor = GMSColorBlueGreyDark;
        self.currency.textColor = GMSColorWhiteBlue;
        self.currency.adjustsFontSizeToFitWidth = YES;
        self.currency.numberOfLines = 1;
        self.currency.textAlignment = NSTextAlignmentCenter;
        
        self.dateTime = [[UILabel alloc] init];
        self.dateTime.font = GMSAvenirNextCondensedMediumSmall;
        self.dateTime.backgroundColor = GMSColorWhiteBlue;
        self.dateTime.textColor = GMSColorBlueGreyDark;
        self.dateTime.adjustsFontSizeToFitWidth = NO;
        self.dateTime.numberOfLines = 1;
        self.dateTime.textAlignment = NSTextAlignmentCenter;
        
        self.priceAverage = [[UILabel alloc] init];
        self.priceAverage.font = GMSHeaderFont;
        self.priceAverage.backgroundColor = GMSSColorBlueSoft;
        self.priceAverage.textColor = GMSColorWhite;
        self.priceAverage.adjustsFontSizeToFitWidth = YES;
        self.priceAverage.numberOfLines = 1;
        self.priceAverage.textAlignment = NSTextAlignmentCenter;
        
        self.sumVolume = [[UILabel alloc] init];
        self.sumVolume.font = GMSHeaderFont;
        self.sumVolume.backgroundColor = GMSSColorBlueSoft;
        self.sumVolume.textColor = GMSColorWhite;
        self.sumVolume.adjustsFontSizeToFitWidth = YES;
        self.sumVolume.numberOfLines = 1;
        self.sumVolume.textAlignment = NSTextAlignmentCenter;
        
        self.lowPrice = [[UILabel alloc] init];
        self.lowPrice.font = GMSHeaderFont;
        self.lowPrice.backgroundColor = GMSColorWhiteBlue;
        self.lowPrice.textColor = GMSColorBlueGreyDark;
        self.lowPrice.adjustsFontSizeToFitWidth = YES;
        self.lowPrice.numberOfLines = 1;
        self.lowPrice.textAlignment = NSTextAlignmentCenter;
        
        self.lowPriceVol = [[UILabel alloc] init];
        self.lowPriceVol.font = GMSAvenirNextCondensedMediumSmall;
        self.lowPriceVol.backgroundColor = GMSColorWhiteBlue;
        self.lowPriceVol.textColor = GMSColorBlueGrey;
        self.lowPriceVol.adjustsFontSizeToFitWidth = YES;
        self.lowPriceVol.numberOfLines = 1;
        self.lowPriceVol.textAlignment = NSTextAlignmentCenter;
        
        self.highPrice = [[UILabel alloc] init];
        self.highPrice.font = GMSHeaderFont;
        self.highPrice.backgroundColor = GMSColorWhiteBlue;
        self.highPrice.textColor = GMSColorBlueGreyDark;
        self.highPrice.adjustsFontSizeToFitWidth = YES;
        self.highPrice.numberOfLines = 1;
        self.highPrice.textAlignment = NSTextAlignmentCenter;
        
        self.highPriceVol = [[UILabel alloc] init];
        self.highPriceVol.font = GMSAvenirNextCondensedMediumSmall;
        self.highPriceVol.backgroundColor = GMSColorWhiteBlue;
        self.highPriceVol.textColor = GMSColorBlueGrey;
        self.highPriceVol.adjustsFontSizeToFitWidth = YES;
        self.highPriceVol.numberOfLines = 1;
        self.highPriceVol.textAlignment = NSTextAlignmentCenter;
        
        self.lowVolume = [[UILabel alloc] init];
        self.lowVolume.font = GMSHeaderFont;
        self.lowVolume.backgroundColor = GMSColorWhiteBlue;
        self.lowVolume.textColor = GMSColorBlueGreyDark;
        self.lowVolume.adjustsFontSizeToFitWidth = YES;
        self.lowVolume.numberOfLines = 1;
        self.lowVolume.textAlignment = NSTextAlignmentCenter;
        
        self.lowVolprice = [[UILabel alloc] init];
        self.lowVolprice.font = GMSAvenirNextCondensedMediumSmall;
        self.lowVolprice.backgroundColor = GMSColorWhiteBlue;
        self.lowVolprice.textColor = GMSColorBlueGrey;
        self.lowVolprice.adjustsFontSizeToFitWidth = YES;
        self.lowVolprice.numberOfLines = 1;
        self.lowVolprice.textAlignment = NSTextAlignmentCenter;
        
        self.highVol = [[UILabel alloc] init];
        self.highVol.font = GMSHeaderFont;
        self.highVol.backgroundColor = GMSColorWhiteBlue;
        self.highVol.textColor = GMSColorBlueGreyDark;
        self.highVol.adjustsFontSizeToFitWidth = YES;
        self.highVol.numberOfLines = 1;
        self.highVol.textAlignment = NSTextAlignmentCenter;
        
        self.highVolPrice = [[UILabel alloc] init];
        self.highVolPrice.font = GMSAvenirNextCondensedMediumSmall;
        self.highVolPrice.backgroundColor = GMSColorWhiteBlue;
        self.highVolPrice.textColor = GMSColorBlueGrey;
        self.highVolPrice.adjustsFontSizeToFitWidth = YES;
        self.highVolPrice.numberOfLines = 1;
        self.highVolPrice.textAlignment = NSTextAlignmentCenter;
        
        self.lowTitle = [[UILabel alloc] init];
        self.lowTitle.font = GMSHeaderFont;
        self.lowTitle.backgroundColor = GMSColorBlueGreyDark;
        self.lowTitle.textColor = GMSColorWhiteBlue;
        self.lowTitle.adjustsFontSizeToFitWidth = YES;
        self.lowTitle.numberOfLines = 1;
        self.lowTitle.textAlignment = NSTextAlignmentCenter;
        
        self.highTitle = [[UILabel alloc] init];
        self.highTitle.font = GMSHeaderFont;
        self.highTitle.backgroundColor = GMSColorBlueGreyDark;
        self.highTitle.textColor = GMSColorWhiteBlue;
        self.highTitle.adjustsFontSizeToFitWidth = YES;
        self.highTitle.numberOfLines = 1;
        self.highTitle.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.currency];
        [self addSubview:self.dateTime];
        [self addSubview:self.priceAverage];
        [self addSubview:self.sumVolume];
        [self addSubview:self.lowPrice];
        [self addSubview:self.lowPriceVol];
        [self addSubview:self.highPrice];
        [self addSubview:self.highPriceVol];
        [self addSubview:self.lowVolume];
        [self addSubview:self.lowVolprice];
        [self addSubview:self.highVol];
        [self addSubview:self.highVolPrice];
        [self addSubview:self.lowTitle];
        [self addSubview:self.highTitle];
    }
    return self;
}

#pragma mark - Setters

//- (void)setText:(NSString *)text
//{
//    self.textLabel.text = text;
//    [self setNeedsLayout];
//}

- (void)setTooltipColor:(UIColor *)tooltipColor
{
    self.backgroundColor = GMSColorPurpleLight;
    [self setNeedsDisplay];
}

- (void)bindAllValues:(BOOL)isTrade :(NSArray *)datasCollection
{
    self.isTrade = isTrade;
    if( isTrade )
    {
        Globals *glob = [Globals globals];

        // debug
        // NSLog(@"array tooltip : %@", datasCollection);
        
        NSLocale *locale = [NSLocale currentLocale];
        NSString *unit = [locale displayNameForKey:NSLocaleCurrencySymbol
                                             value:[glob currency]];
        self.currency.text = unit;
        
        self.dateTime.text = [NSDateFormatter localizedStringFromDate:[datasCollection objectAtIndex:3] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
        
        float value = [[datasCollection objectAtIndex:2]floatValue];
        NSString *wpa = @"Weighted price: ";
        NSString *p = [GMSUtilitiesFunction twoDecimalStrFormat:[NSString stringWithFormat:@"%f", value]];
        wpa = [wpa stringByAppendingString: p];
        self.priceAverage.text = [wpa stringByAppendingString:unit];
        
        value = [[datasCollection objectAtIndex:1]floatValue];
        NSString *sumV = @"Total volume: ";
        p = [GMSUtilitiesFunction twoDecimalStrFormat:[NSString stringWithFormat:@"%f", value]];
        sumV = [sumV stringByAppendingString: p];
        self.sumVolume.text = [sumV stringByAppendingString:@"Btc"];
        
        // lowest and highest
        NSString *lowTitleTxt = @"Minimum";
        NSString *highTitleTxt = @"Maximum";
        self.lowTitle.text = lowTitleTxt;
        self.highTitle.text = highTitleTxt;
        
        if ( [datasCollection objectAtIndex:4] != nil )
        {
            NSArray *lh = [datasCollection objectAtIndex:4];
            
            value = [[lh objectAtIndex:0]floatValue];
            NSString *lp = [GMSUtilitiesFunction twoDecimalStrFormat:[NSString stringWithFormat:@"%f", value]];
            self.lowPrice.text = [lp stringByAppendingString:unit];
            
            value = [[lh objectAtIndex:1]floatValue];
            NSString *lpv = [@"(" stringByAppendingString:[NSString stringWithFormat:@"%f", value]];
            self.lowPriceVol.text = [lpv stringByAppendingString:@"Btc)"];
            
            value = [[lh objectAtIndex:2]floatValue];
            NSString *hp = [GMSUtilitiesFunction twoDecimalStrFormat:[NSString stringWithFormat:@"%f", value]];
            self.highPrice.text = [hp stringByAppendingString:unit];
            
            value = [[lh objectAtIndex:3]floatValue];
            NSString *hpv = [@"(" stringByAppendingString:[NSString stringWithFormat:@"%f", value]];
            self.highPriceVol.text = [hpv stringByAppendingString:@"Btc)"];
            
            value = [[lh objectAtIndex:4]floatValue];
            NSString *lv = [NSString stringWithFormat:@"%f", value];
            self.lowVolume.text = [lv stringByAppendingString:@"Btc"];
            
            value = [[lh objectAtIndex:5]floatValue];
            NSString *lvp = [@"(" stringByAppendingString:[GMSUtilitiesFunction twoDecimalStrFormat:[NSString stringWithFormat:@"%f", value]]];
            self.lowVolprice.text = [lvp stringByAppendingString:[unit stringByAppendingString:@")"]];
            
            value = [[lh objectAtIndex:6]floatValue];
            NSString *hv = [NSString stringWithFormat:@"%f", value];
            self.highVol.text = [hv stringByAppendingString:@"Btc"];

            value = [[lh objectAtIndex:7]floatValue];
            NSString *hvp = [@"(" stringByAppendingString:[GMSUtilitiesFunction twoDecimalStrFormat:[NSString stringWithFormat:@"%f", value]]];
            self.highVolPrice.text = [[hvp stringByAppendingString:unit] stringByAppendingString:@")"];
        }
    }

    // ping UI
    [self setNeedsLayout];
}
#pragma mark - Layout

- (void)layoutSubviews
{
    if ( self.isTrade )
    {
        self.hidden = NO;
        
        CGFloat viewWidth = self.bounds.size.width;
        CGFloat halfW = ceilf(viewWidth / 2);
        CGFloat viewHeight = self.bounds.size.height;
        CGFloat currencyH = ceilf( (viewHeight / 100) * 10 );
        CGFloat dateH = ceilf((viewHeight - currencyH ) / 8);
        CGFloat subH = ceilf( (viewHeight - currencyH ) / 5 );
        
        // FLT_MAX here simply means no constraint in height
        // CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
        // CGSize highLow = [self frameForText:self.highPrice.text sizeWithFont:self.highPrice.font constrainedToSize:CGSizeMake(maximumLabelSize.height,self.highPrice.font.lineHeight) lineBreakMode:self.highPrice.lineBreakMode ];
        // float highLowH = ceilf(highLow.height);
        
        self.currency.frame = CGRectMake(0, 0, viewWidth, currencyH);
        self.dateTime.frame = CGRectMake(0, currencyH + 1, viewWidth, dateH);
        
        CGFloat priceAverageTop = currencyH + dateH;
        self.priceAverage.frame = CGRectMake(0, priceAverageTop, viewWidth, subH);
        
        CGFloat sumVolumeTop = priceAverageTop + subH + 2;
        self.sumVolume.frame = CGRectMake(0, sumVolumeTop, viewWidth, subH);
        
        CGFloat lowHighTitlesTop = sumVolumeTop + subH;
        self.lowTitle.frame = CGRectMake(0, lowHighTitlesTop, halfW, currencyH);
        self.highTitle.frame = CGRectMake(halfW, lowHighTitlesTop, halfW, currencyH);
        
        CGFloat lowHighTop = lowHighTitlesTop + currencyH + 8;
        CGFloat slot = ceilf(dateH / 3);
        self.lowPrice.frame = CGRectMake(0, lowHighTop, halfW, slot * 2);
        self.highPrice.frame = CGRectMake(halfW, lowHighTop, halfW, slot * 2);
        
        CGFloat lowHighPv = lowHighTop + (slot * 2);
        self.lowPriceVol.frame = CGRectMake(0, lowHighPv, halfW, slot);
        self.highPriceVol.frame = CGRectMake(halfW, lowHighPv, halfW, slot);
        
        CGFloat lowHighVol = lowHighPv + slot + 4;
        self.lowVolume.frame = CGRectMake(0, lowHighVol, halfW, slot * 2);
        self.highVol.frame = CGRectMake(halfW, lowHighVol, halfW, slot * 2);
        
        CGFloat lowHighVolP = lowHighVol + (slot * 2);
        self.lowVolprice.frame = CGRectMake(0, lowHighVolP, halfW, slot);
        self.highVolPrice.frame = CGRectMake(halfW, lowHighVolP, halfW, slot);
        
//        CGFloat allElementsHeight = (currencyH * 2) + (dateH * 2) + (subH * 2) + (highLowH * 2) + 5;

        [self drawRect:CGRectMake(0, 0, GMSChartTooltipViewDefaultWidth, GMSChartTooltipViewDefaultHeight)];
    }
    else
    {
        self.hidden = YES;
    }
}


// helper to get actual size of choosen font in UILabel
// source : https://stackoverflow.com/questions/20786067/replace-the-deprecation-sizewithfontminfontsizeactualfontsize-in-ios-7
- (CGSize)frameForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode  {
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    NSDictionary * attributes = @{NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName:paragraphStyle
                                  };
    
    
    CGRect textRect = [text boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    
    //Contains both width & height ... Needed: The height
    return textRect.size;
}

@end
