//
//  GMSLineChartViewController.m
//  GMSChartViewDemo
//
//  Created by Terry Worona on 11/5/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "GMSLineChartViewController.h"

// Views
#import "GMSLineChartView.h"
#import "GMSChartHeaderView.h"
#import "GMSLineChartFooterView.h"
#import "GMSChartInformationView.h"

#define ARC4RANDOM_MAX 0x100000000

typedef NS_ENUM(NSInteger, GMSLineChartLine){
	GMSLineChartLineSolid,
    GMSLineChartLineDashed,
    GMSLineChartLineCount
};

// Numerics
CGFloat const kGMSLineChartViewControllerChartHeight = 250.0f;
CGFloat const kGMSLineChartViewControllerChartPadding = 10.0f;
CGFloat const kGMSLineChartViewControllerChartHeaderHeight = 75.0f;
CGFloat const kGMSLineChartViewControllerChartHeaderPadding = 20.0f;
CGFloat const kGMSLineChartViewControllerChartFooterHeight = 20.0f;
CGFloat const kGMSLineChartViewControllerChartSolidLineWidth = 6.0f;
CGFloat const kGMSLineChartViewControllerChartDashedLineWidth = 2.0f;
NSInteger const kGMSLineChartViewControllerMaxNumChartPoints = 7;

// Strings
NSString * const kGMSLineChartViewControllerNavButtonViewKey = @"view";

@interface GMSLineChartViewController () <GMSLineChartViewDelegate, GMSLineChartViewDataSource>

@property (nonatomic, strong) GMSLineChartView *lineChartView;
@property (nonatomic, strong) GMSChartInformationView *informationView;
@property (nonatomic, strong) NSArray *chartData;
@property (nonatomic, strong) NSArray *daysOfWeek;

// Buttons
- (void)chartToggleButtonPressed:(id)sender;

// Helpers
- (void)initFakeData;
- (NSArray *)largestLineData; // largest collection of fake line data

@end

@implementation GMSLineChartViewController

#pragma mark - Alloc/Init

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initFakeData];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initFakeData];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self initFakeData];
    }
    return self;
}

#pragma mark - Data

- (void)initFakeData
{
    NSMutableArray *mutableLineCharts = [NSMutableArray array];
    for (int lineIndex=0; lineIndex<GMSLineChartLineCount; lineIndex++)
    {
        NSMutableArray *mutableChartData = [NSMutableArray array];
        for (int i=0; i<kGMSLineChartViewControllerMaxNumChartPoints; i++)
        {
            [mutableChartData addObject:[NSNumber numberWithFloat:((double)arc4random() / ARC4RANDOM_MAX)]]; // random number between 0 and 1
        }
        [mutableLineCharts addObject:mutableChartData];
    }
    _chartData = [NSArray arrayWithArray:mutableLineCharts];
    _daysOfWeek = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
}

- (NSArray *)largestLineData
{
    NSArray *largestLineData = nil;
    for (NSArray *lineData in self.chartData)
    {
        if ([lineData count] > [largestLineData count])
        {
            largestLineData = lineData;
        }
    }
    return largestLineData;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = kGMSColorLineChartControllerBackground;
    self.navigationItem.rightBarButtonItem = [self chartToggleButtonWithTarget:self action:@selector(chartToggleButtonPressed:)];
        
    self.lineChartView = [[GMSLineChartView alloc] init];
    self.lineChartView.frame = CGRectMake(kGMSLineChartViewControllerChartPadding, kGMSLineChartViewControllerChartPadding, self.view.bounds.size.width - (kGMSLineChartViewControllerChartPadding * 2), kGMSLineChartViewControllerChartHeight);
    self.lineChartView.delegate = self;
    self.lineChartView.dataSource = self;
    self.lineChartView.headerPadding = kGMSLineChartViewControllerChartHeaderPadding;
    self.lineChartView.backgroundColor = kGMSColorLineChartBackground;
    
    GMSChartHeaderView *headerView = [[GMSChartHeaderView alloc] initWithFrame:CGRectMake(kGMSLineChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kGMSLineChartViewControllerChartHeaderHeight * 0.5), self.view.bounds.size.width - (kGMSLineChartViewControllerChartPadding * 2), kGMSLineChartViewControllerChartHeaderHeight)];
    headerView.titleLabel.text = [kGMSStringLabelAverageDailyRainfall uppercaseString];
    headerView.titleLabel.textColor = kGMSColorLineChartHeader;
    headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    headerView.titleLabel.shadowOffset = CGSizeMake(0, 1);
    headerView.subtitleLabel.text = kGMSStringLabel2013;
    headerView.subtitleLabel.textColor = kGMSColorLineChartHeader;
    headerView.subtitleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    headerView.subtitleLabel.shadowOffset = CGSizeMake(0, 1);
    headerView.separatorColor = kGMSColorLineChartHeaderSeparatorColor;
    self.lineChartView.headerView = headerView;
    
    GMSLineChartFooterView *footerView = [[GMSLineChartFooterView alloc] initWithFrame:CGRectMake(kGMSLineChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kGMSLineChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (kGMSLineChartViewControllerChartPadding * 2), kGMSLineChartViewControllerChartFooterHeight)];
    footerView.backgroundColor = [UIColor clearColor];
    footerView.leftLabel.text = [[self.daysOfWeek firstObject] uppercaseString];
    footerView.leftLabel.textColor = [UIColor whiteColor];
    footerView.rightLabel.text = [[self.daysOfWeek lastObject] uppercaseString];;
    footerView.rightLabel.textColor = [UIColor whiteColor];
    footerView.sectionCount = [[self largestLineData] count];
    self.lineChartView.footerView = footerView;
    
    [self.view addSubview:self.lineChartView];
    
    self.informationView = [[GMSChartInformationView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, CGRectGetMaxY(self.lineChartView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.lineChartView.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
    [self.informationView setValueAndUnitTextColor:[UIColor colorWithWhite:1.0 alpha:0.75]];
    [self.informationView setTitleTextColor:kGMSColorLineChartHeader];
    [self.informationView setTextShadowColor:nil];
    [self.informationView setSeparatorColor:kGMSColorLineChartHeaderSeparatorColor];
    [self.view addSubview:self.informationView];
    
    [self.lineChartView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.lineChartView setState:GMSChartViewStateExpanded];
}

#pragma mark - GMSLineChartViewDelegate

- (CGFloat)lineChartView:(GMSLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return [[[self.chartData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex] floatValue];
}

- (void)lineChartView:(GMSLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    NSNumber *valueNumber = [[self.chartData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex];
    [self.informationView setValueText:[NSString stringWithFormat:@"%.2f", [valueNumber floatValue]] unitText:kGMSStringLabelMm];
    [self.informationView setTitleText:lineIndex == GMSLineChartLineSolid ? kGMSStringLabelMetropolitanAverage : kGMSStringLabelNationalAverage];
    [self.informationView setHidden:NO animated:YES];
    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
    [self.tooltipView setText:[[self.daysOfWeek objectAtIndex:horizontalIndex] uppercaseString]];
}

- (void)didUnselectLineInLineChartView:(GMSLineChartView *)lineChartView
{
    [self.informationView setHidden:YES animated:YES];
    [self setTooltipVisible:NO animated:YES];
}

#pragma mark - GMSLineChartViewDataSource

- (NSUInteger)numberOfLinesInLineChartView:(GMSLineChartView *)lineChartView
{
    return [self.chartData count];
}

- (NSUInteger)lineChartView:(GMSLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return [[self.chartData objectAtIndex:lineIndex] count];
}

- (UIColor *)lineChartView:(GMSLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == GMSLineChartLineSolid) ? kGMSColorLineChartDefaultSolidLineColor: kGMSColorLineChartDefaultDashedLineColor;
}

- (UIColor *)lineChartView:(GMSLineChartView *)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == GMSLineChartLineSolid) ? kGMSColorLineChartDefaultSolidLineColor: kGMSColorLineChartDefaultDashedLineColor;
}

- (CGFloat)lineChartView:(GMSLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == GMSLineChartLineSolid) ? kGMSLineChartViewControllerChartSolidLineWidth: kGMSLineChartViewControllerChartDashedLineWidth;
}

- (CGFloat)lineChartView:(GMSLineChartView *)lineChartView dotRadiusForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == GMSLineChartLineSolid) ? 0.0: (kGMSLineChartViewControllerChartDashedLineWidth * 4);
}

- (UIColor *)verticalSelectionColorForLineChartView:(GMSLineChartView *)lineChartView
{
    return [UIColor whiteColor];
}

- (UIColor *)lineChartView:(GMSLineChartView *)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == GMSLineChartLineSolid) ? kGMSColorLineChartDefaultSolidSelectedLineColor: kGMSColorLineChartDefaultDashedSelectedLineColor;
}

- (UIColor *)lineChartView:(GMSLineChartView *)lineChartView selectionColorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == GMSLineChartLineSolid) ? kGMSColorLineChartDefaultSolidSelectedLineColor: kGMSColorLineChartDefaultDashedSelectedLineColor;
}

- (GMSLineChartViewLineStyle)lineChartView:(GMSLineChartView *)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == GMSLineChartLineSolid) ? GMSLineChartViewLineStyleSolid : GMSLineChartViewLineStyleDashed;
}

- (BOOL)lineChartView:(GMSLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex == GMSLineChartViewLineStyleDashed;
}

- (BOOL)lineChartView:(GMSLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex == GMSLineChartViewLineStyleSolid;
}

#pragma mark - Buttons

- (void)chartToggleButtonPressed:(id)sender
{
	UIView *buttonImageView = [self.navigationItem.rightBarButtonItem valueForKey:kGMSLineChartViewControllerNavButtonViewKey];
    buttonImageView.userInteractionEnabled = NO;
    
    CGAffineTransform transform = self.lineChartView.state == GMSChartViewStateExpanded ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformMakeRotation(0);
    buttonImageView.transform = transform;

    [self.lineChartView setState:self.lineChartView.state == GMSChartViewStateExpanded ? GMSChartViewStateCollapsed : GMSChartViewStateExpanded animated:YES callback:^{
        buttonImageView.userInteractionEnabled = YES;
    }];
}

#pragma mark - Overrides

- (GMSChartView *)chartView
{
    return self.lineChartView;
}

@end
