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
#import <sys/sysctl.h>
#import <sys/utsname.h>


@interface GMSChartsView ()
{
    
}
@end
@implementation GMSChartsView

@synthesize headerChartsImg, chartsPriceView, chartsVolumeView;


- (void)viewDidLoad
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *currentDevice = [NSString stringWithCString:systemInfo.machine
                                                 encoding:NSUTF8StringEncoding];
    NSString *currentSimulatorDevice = [NSString stringWithCString:getenv("SIMULATOR_MODEL_IDENTIFIER")
                                                          encoding:NSUTF8StringEncoding];
    
    [super viewDidLoad];
    
    //self.view.backgroundColor = GMSColorBlueGrey;
    
    // get parent view size
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    NSLog(@"height 1 : %f", viewHeight);
    
    if ( !IS_IPAD )
    {
        self.chartsPriceView.backgroundColor = GMSColorOrange;
        //add header
        self.headerChartsImg = [GMSTopBrandImage topImage:3];
        [self.view addSubview:self.headerChartsImg];
        // origine of subviews
        CGFloat chartViewOrigine = self.headerChartsImg.frame.size.height;
        CGFloat chartsWindowsHeight = (viewHeight - chartViewOrigine) / 2;
        
        
        if ( IS_IPHONE_X_XR_XS )
        {

            [self.chartsPriceView setFrame:CGRectMake(0,
                                                      chartViewOrigine,
                                                      viewWidth,
                                                      chartsWindowsHeight - 25)];
            
            [self.view addSubview:self.chartsPriceView];
            
            CGSize tabBarSize = [[[self tabBarController] tabBar] bounds].size;
            
            [self.chartsVolumeView setFrame:CGRectMake(0,
                                                       CGRectGetMaxY(self.chartsPriceView.frame) - 20, // 25 IS FOOTER HEIGHT
                                                       viewWidth,
                                                       viewHeight - tabBarSize.height - self.chartsPriceView.frame.size.height - chartViewOrigine
                                                       )];
            
            [self.view addSubview:self.chartsVolumeView];
        }
        
        else
        {
            [self.chartsPriceView setFrame:CGRectMake(0,
                                                      chartViewOrigine,
                                                      viewWidth,
                                                      chartsWindowsHeight )];
            
            [self.view addSubview:self.chartsPriceView];

            [self.chartsVolumeView setFrame:CGRectMake(0,
                                                       CGRectGetMaxY(self.chartsPriceView.frame) - 25, // 25 IS FOOTER HEIGHT
                                                       viewWidth,
                                                       chartsWindowsHeight )];
            
            [self.view addSubview:self.chartsVolumeView];
        }
    }
    
    
    else
    {
        [self.view addSubview:self.chartsPriceView];
        [self.view addSubview:self.chartsVolumeView];
    }
    
}


- (void) applicationDidEnterBackground:(NSNotification*)notification
{
    Globals *glob = [Globals globals];
    // save current selected currency to db (should have been already done...)
    [[NSUserDefaults standardUserDefaults] setObject:[glob currency] forKey:@"currency"];
}


@end


