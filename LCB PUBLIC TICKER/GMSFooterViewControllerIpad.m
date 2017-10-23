//
//  GMSFooterViewControllerIpad.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 09/05/2014.
//  Copyright (c) 2014 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#import "GMSFooterViewControllerIpad.h"
#import "GMSFirstViewController.h"
#import "GMSSecondViewController.h"
#import "GMSThirdViewController.h"


@interface GMSFooterViewControllerIpad ()

@property (strong, nonatomic) GMSFirstViewController *firstViewController;
@property (strong, nonatomic) GMSSecondViewController *secondViewController;
@property (strong, nonatomic) GMSThirdViewController *thirdViewController;
@property (strong, nonatomic) NSMutableArray *bidsDatas;

@end

@implementation GMSFooterViewControllerIpad

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bidsDatas = self.secondViewDatas.orderBids;
    self.barChartView = [[JBBarChartView alloc] init];
     self.barChartView.frame = CGRectMake( 0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
    self.barChartView.delegate = self;
    self.barChartView.dataSource = self;
    [self.view addSubview:self.barChartView];
   
   
	[self.barChartView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.barChartView setState:JBChartViewStateExpanded];
}

#pragma mark - JBBarChartViewDelegate

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtAtIndex:(NSUInteger)index
{
    return [[self.bidsDatas objectAtIndex:index] floatValue];
}

#pragma mark - JBBarChartViewDataSource

- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView
{
    return [self.bidsDatas count];
}

//- (NSUInteger)barPaddingForBarChartView:(JBBarChartView *)barChartView
//{
//    return kJBBarChartViewControllerBarPadding;
//}

- (UIView *)barChartView:(JBBarChartView *)barChartView barViewAtIndex:(NSUInteger)index
{
    UIView *barView = [[UIView alloc] init];
    barView.backgroundColor = (index % 2 == 0) ? GMSColorBlue : GMSColorOrange;
    return barView;
}

- (UIColor *)barSelectionColorForBarChartView:(JBBarChartView *)barChartView
{
    return [UIColor whiteColor];
}

//- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
//{
//    NSNumber *valueNumber = [self.chartData objectAtIndex:index];
//    [self.informationView setValueText:[NSString stringWithFormat:kJBStringLabelDegreesFahrenheit, [valueNumber intValue], kJBStringLabelDegreeSymbol] unitText:nil];
//    [self.informationView setTitleText:kJBStringLabelWorldwideAverage];
//    [self.informationView setHidden:NO animated:YES];
//    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
//    [self.tooltipView setText:[[self.monthlySymbols objectAtIndex:index] uppercaseString]];
//}
//
//- (void)didUnselectBarChartView:(JBBarChartView *)barChartView
//{
//    [self.informationView setHidden:YES animated:YES];
//    [self setTooltipVisible:NO animated:YES];
//}

//#pragma mark - Buttons
//
//- (void)chartToggleButtonPressed:(id)sender
//{
//    UIView *buttonImageView = [self.navigationItem.rightBarButtonItem valueForKey:kJBBarChartViewControllerNavButtonViewKey];
//    buttonImageView.userInteractionEnabled = NO;
//    
//    CGAffineTransform transform = self.barChartView.state == JBChartViewStateExpanded ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformMakeRotation(0);
//    buttonImageView.transform = transform;
//    
//    [self.barChartView setState:self.barChartView.state == JBChartViewStateExpanded ? JBChartViewStateCollapsed : JBChartViewStateExpanded animated:YES callback:^{
//        buttonImageView.userInteractionEnabled = YES;
//    }];
//}

#pragma mark - Overrides

- (JBChartView *)chartView
{
    return self.barChartView;
}
@end