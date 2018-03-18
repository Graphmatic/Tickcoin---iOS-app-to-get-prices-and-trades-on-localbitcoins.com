//
//  GMSChartTooltipView.h
//  GMSChartViewDemo
//
//  Created by Terry Worona on 3/12/14.
//  Copyright (c) 2014 Jawbone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMSGlobals.h"

@interface GMSChartTooltipView : UIView

@property (strong, nonatomic) IBOutlet UILabel *dateTime;
@property (strong, nonatomic) IBOutlet UILabel *priceAverage;
@property (strong, nonatomic) IBOutlet UILabel *sumVolume;
@property (strong, nonatomic) IBOutlet UILabel *lowPrice;
@property (strong, nonatomic) IBOutlet UILabel *lowVolume;
@property (strong, nonatomic) IBOutlet UILabel *currency;
@property (strong, nonatomic) IBOutlet UILabel *highTitle;
@property (strong, nonatomic) IBOutlet UILabel *lowTitle;
@property (strong, nonatomic) IBOutlet UILabel *lowPriceVol;
@property (strong, nonatomic) IBOutlet UILabel *highPrice;
@property (strong, nonatomic) IBOutlet UILabel *highPriceVol;
@property (strong, nonatomic) IBOutlet UILabel *highVol;
@property (strong, nonatomic) IBOutlet UILabel *lowVolprice;
@property (strong, nonatomic) IBOutlet UILabel *highVolPrice;

@property (atomic) BOOL isTrade;

//- (void)setText:(NSString *)text;
- (void)bindAllValues:(BOOL)isTrade :(NSArray *)datasCollection;

@end
