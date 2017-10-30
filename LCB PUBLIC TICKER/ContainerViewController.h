//
//  ContainerViewController.h
//  EmbeddedSwapping
//
//  Created by Michael Luton on 11/13/12.
//  Copyright (c) 2012 Sandmoose Software. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GMSStartView.h"
#import "GMSBidsView.h"
#import "GMSAsksView.h"
//#import "GMSFifthViewController.h"
#import "GMSBarChartViewPriceController.h"
@interface ContainerViewController : UIViewController 
@property (strong, nonatomic) NSString *currentSegueIdentifier;
@property (strong, nonatomic) GMSStartView *firstViewController;
@property (strong, nonatomic) GMSBidsView *secondViewController;
@property (strong, nonatomic) GMSAsksView *thirdViewController;
@property  (strong, nonatomic)GMSBarChartViewPriceController *fourthViewController;
//@property (strong, nonatomic) GMSFifthViewController *fifthViewController;

@end
