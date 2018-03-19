//
//  GMSBidsView.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "GMSMapsView.h"


@interface GMSMapsView ()
{


}
@end

@implementation GMSMapsView

@synthesize headerImg;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // layout
    // get parent view size
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = (self.view.bounds.size.height / 100) * 94;
    
    Globals *glob = [Globals globals];
    
    //add header
    self.headerImg = [GMSTopBrandImage topImage:4];
    [self.view addSubview:self.headerImg];

    
}

-(void)viewWillAppear:(BOOL)animated
{

    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload
{
    
}

- (void) viewWillDisappear:(BOOL)animated
{
   
}

- (void) applicationDidEnterBackground:(NSNotification*)notification
{
    
}

@end

