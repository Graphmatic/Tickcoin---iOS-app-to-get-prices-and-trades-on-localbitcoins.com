//
//  ContainerViewController.m
//  EmbeddedSwapping
//
//  Created by Michael Luton on 11/13/12.
//  Copyright (c) 2012 Sandmoose Software. All rights reserved.
//  Heavily inspired by http://orderoo.wordpress.com/2012/02/23/container-view-controllers-in-the-storyboard/
//

#import "ContainerViewController.h"


#define first @"firstController"
#define second @"secondController"
#define third @"thirdController"
#define fourth @"fourthController"

//#define fifth @"fifthController"

@interface ContainerViewController () 

@property (strong, nonatomic) IBOutlet UIView *topbarBg;


@end

@implementation ContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
  //  self.view.backgroundColor = [UIColor whiteColor];
 
    [self performSegueWithIdentifier:first sender:nil];
    [self performSegueWithIdentifier:second sender:nil];
    [self performSegueWithIdentifier:third sender:nil];
    [self performSegueWithIdentifier:fourth sender:nil];
//     [self performSegueWithIdentifier:fifth sender:nil];
    _topbarBg.frame = CGRectMake(0, 0, 512, 20);
    [_topbarBg setFrame:CGRectMake(0, 0, 512, 20)];
     [self.view addSubview:_topbarBg];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Layout helpers
    float vWidth = self.view.frame.size.width;
    float vHeight = self.view.frame.size.height;
    float leftPaneWidth = ceil(vWidth / 3);
    float rightPaneWidth = vWidth - leftPaneWidth;
    
    if ([segue.identifier isEqualToString:first]) {
        self.firstViewController = segue.destinationViewController;
        [self addChildViewController:segue.destinationViewController];
        UIView* destView = ((UIViewController *)segue.destinationViewController).view;
        destView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        destView.frame = CGRectMake(0, 0, self.firstViewController.view.frame.size.width, self.firstViewController.view.frame.size.height);
        
        [self.view addSubview:destView];
        [segue.destinationViewController didMoveToParentViewController:self];
    }
    if ([segue.identifier isEqualToString:second]) {
        self.secondViewController = segue.destinationViewController;
            // If this is the very first time we're loading this we need to do
            // an initial load and not a swap.
            [self addChildViewController:segue.destinationViewController];
            UIView* destView2 = ((UIViewController *)segue.destinationViewController).view;
            destView2.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            destView2.frame = CGRectMake(520, 0, self.secondViewController.view.frame.size.width, self.secondViewController.view.frame.size.height);
            [self.view addSubview:destView2];
            [segue.destinationViewController didMoveToParentViewController:self];
    }
    if ([segue.identifier isEqualToString:third])
    {
        self.thirdViewController = segue.destinationViewController;
        // If this is the very first time we're loading this we need to do
        // an initial load and not a swap.
        [self addChildViewController:segue.destinationViewController];
        UIView* destView3 = ((UIViewController *)segue.destinationViewController).view;
        destView3.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        destView3.frame = CGRectMake(772, 0, self.thirdViewController.view.frame.size.width, self.thirdViewController.view.frame.size.height);
        [self.view addSubview:destView3];
        [segue.destinationViewController didMoveToParentViewController:self];
    }
    if ([segue.identifier isEqualToString:fourth])
    {
        self.fourthViewController = segue.destinationViewController;
        [self addChildViewController:self.fourthViewController];
        UIView* destView4 = ((UIViewController *)self.fourthViewController).view;
        destView4.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:destView4];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenHeight = screenRect.size.height;
        destView4.frame = CGRectMake(0, 355, self.fourthViewController.view.frame.size.width, screenHeight - 354);
        [segue.destinationViewController didMoveToParentViewController:self];
    }

//    if ([segue.identifier isEqualToString:fifth])
//    {
//        self.fifthViewController = segue.destinationViewController;
//        [self addChildViewController:self.fifthViewController];
//        UIView* destView5 = ((UIViewController *)self.fifthViewController).view;
//        destView5.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        [self.view addSubview:destView5];
//        destView5.frame = CGRectMake(1, 626, self.fifthViewController.view.frame.size.width-3, self.fifthViewController.view.frame.size.height);
//        [segue.destinationViewController didMoveToParentViewController:self];
//    }
 
}





@end
