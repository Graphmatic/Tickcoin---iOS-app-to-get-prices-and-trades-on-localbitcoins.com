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

@synthesize headerChartsImg, chartsPriceView, chartsVolumeView;


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = GMSColorBlueGrey;
    
    // get parent view size
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;

    if ( !IS_IPAD )
    {
        //add header
        self.headerChartsImg = [GMSTopBrandImage topImage:3];
        [self.view addSubview:self.headerChartsImg];
        // origine of subviews
        CGFloat chartViewOrigine = self.headerChartsImg.frame.size.height + 2;

        
        [self.chartsPriceView setFrame:CGRectMake(0,
                                                  chartViewOrigine,
                                                  viewWidth,
                                                  (viewHeight - chartViewOrigine) / 2)];
        [self.view addSubview:self.chartsPriceView];

        [self.chartsVolumeView setFrame:CGRectMake(0,
                                                  ((viewHeight - chartViewOrigine) / 2) + 22,
                                                  viewWidth,
                                                  (viewHeight - chartViewOrigine) / 2)];

        [self.view addSubview:self.chartsVolumeView];
    }
    
    else
    {
        [self.view addSubview:self.chartsPriceView];
        [self.view addSubview:self.chartsVolumeView];
    }
   
}


- (void) applicationDidEnterBackground:(NSNotification*)notification
{
    // save current selected currency to db (should have been already done...)
    [[NSUserDefaults standardUserDefaults] setObject:currentCurrency forKey:@"currentCurrency"];
}


@end


