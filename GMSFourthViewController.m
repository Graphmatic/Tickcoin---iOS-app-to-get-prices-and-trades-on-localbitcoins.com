//
//  GMSFourthViewController.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 17/05/2014.
//  Copyright (c) 2014 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#import "GMSFourthViewController.h"
#import "JBBarChartViewController.h"
@interface GMSFourthViewController ()
@property JBBaseChartViewController *charViewCtlr;
@end

@implementation GMSFourthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.charViewCtlr = [[JBBaseChartViewController alloc]init];
    [self.view addSubview:self.charViewCtlr.view];
    //4 inch ?
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
        if ([[UIScreen mainScreen] scale] == 2.0)
        {
            if([UIScreen mainScreen].bounds.size.height == 568)
            {
                // iPhone retina-4 inch
                
                
                //... other setting for iPhone 4inch
            }
            else
            {
                // iPhone retina-3.5 inch
                //add messageBox
               
            }
        }
        else {
            // not retina display
        }
    }
    
  }
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (void) viewDidUnload
{
   }
- (void)viewWillDisappear:(BOOL)animated
{
   }
- (void) applicationDidEnterBackground:(NSNotification*)notification
{
   
}

@end
