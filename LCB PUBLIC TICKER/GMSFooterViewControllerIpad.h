//
//  GMSFooterViewControllerIpad.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 09/05/2014.
//  Copyright (c) 2014 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBChartView.h"
#import "JBBarChartView.h"
#import "JBLineChartView.h"
#import "GMSSecondViewController.h"

@interface GMSFooterViewControllerIpad : UIViewController <JBBarChartViewDelegate,JBBarChartViewDataSource>

@property (strong, atomic) GMSSecondViewTableData *secondViewDatas;

@property (strong, nonatomic) IBOutlet JBBarChartView *barChartView;

@end
