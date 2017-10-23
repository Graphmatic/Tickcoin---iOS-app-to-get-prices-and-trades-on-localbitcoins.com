//
//  ContainerViewController.h
//  EmbeddedSwapping
//
//  Created by Michael Luton on 11/13/12.
//  Copyright (c) 2012 Sandmoose Software. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GMSFirstViewController.h"
#import "GMSSecondViewController.h"
#import "GMSThirdViewController.h"
#import "GMSFifthViewController.h"
#import "GMSBarChartViewController.h"
@interface ContainerViewController : UIViewController 
@property (strong, nonatomic) NSString *currentSegueIdentifier;
@property (strong, nonatomic) GMSFirstViewController *firstViewController;
@property (strong, nonatomic) GMSSecondViewController *secondViewController;
@property (strong, nonatomic) GMSThirdViewController *thirdViewController;
@property  (strong, nonatomic)GMSBarChartViewController *fourthViewController;
@property (strong, nonatomic) GMSFifthViewController *fifthViewController;

@end
