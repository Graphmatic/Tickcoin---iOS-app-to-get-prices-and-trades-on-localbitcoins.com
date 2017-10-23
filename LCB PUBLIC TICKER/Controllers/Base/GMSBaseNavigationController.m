//
//  GMSBaseNavigationController.m
//  GMSChartViewDemo
//
//  Created by Terry Worona on 11/7/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "GMSBaseNavigationController.h"

@implementation GMSBaseNavigationController

#pragma mark - Alloc/Init

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self)
    {
        self.navigationBar.translucent = NO;
        [[UINavigationBar appearance] setBarTintColor:kGMSColorNavigationTint];
        [[UINavigationBar appearance] setTintColor:kGMSColorNavigationBarTint];
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    return self;
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
