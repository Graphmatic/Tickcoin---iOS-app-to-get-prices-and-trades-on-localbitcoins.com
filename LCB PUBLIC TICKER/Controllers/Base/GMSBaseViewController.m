//
//  GMSBaseViewController.m
//  GMSChartViewDemo
//
//  Created by Terry Worona on 11/7/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "GMSBaseViewController.h"

@interface GMSBaseViewController ()

@end

@implementation GMSBaseViewController

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.view.backgroundColor = GMSColorBlueGreyDark;
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        return UIInterfaceOrientationMaskLandscape;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}





@end
