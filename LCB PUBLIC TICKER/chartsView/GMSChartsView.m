//
//  GMSChartsView.m
//  tickCoin
//
//  Created by rio on 30/10/2017.
//  Copyright © 2017 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMSChartsView.h"
#import "GMSUtilitiesFunction.h"

@interface GMSChartsView ()
{

}
@end
@implementation GMSChartsView

@synthesize headerChartsImg, chartsPriceView, chartsVolumeView, stackWrapper;


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = GMSColorBlueGrey;
    
    
    // backup parent view size
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    
    //add header
    self.headerChartsImg = [GMSTopBrandImage topImage:3];
    [self.view addSubview:self.headerChartsImg];

    // origine of stackWrapper
    CGFloat chartViewOrigine = self.headerChartsImg.frame.size.height + 2;
    NSLog(@"chartViewOrigine : %f", chartViewOrigine);
    [self.stackWrapper setFrame:CGRectMake(0, chartViewOrigine, viewWidth, viewHeight - chartViewOrigine -50)];
    
//    self.stackWrapper.axis = UILayoutConstraintAxisVertical;
//    self.stackWrapper.distribution = UIStackViewDistributionEqualSpacing;
////    self.stackWrapper.alignment = UIStackViewAlignmentCenter;
//    self.stackWrapper.spacing = 2;
    
//    [self.chartsVolumeView setFrame:CGRectMake(0, 0, viewWidth, viewHeight - chartViewOrigine)];
    
    
//    CGFloat chartViewOrigine = self.headerChartsImg.frame.size.height + 2;
////     [self.chartsPriceView setFrame:CGRectMake(0, chartViewOrigine, viewWidth, viewHeight - chartViewOrigine)];
//    self.chartsPriceView.frame = CGRectMake(0, chartViewOrigine, viewWidth, viewHeight - chartViewOrigine);
//    [self.view addSubview:self.chartsPriceView];
//     [self.view layoutIfNeeded];
//    self.chartsVolumeView.frame = CGRectMake(0, viewHeight, viewWidth, viewHeight - chartViewOrigine);
//    [self.view addSubview:self.chartsVolumeView];
////    [self.view setNeedsLayout];
    
    
}

@end
