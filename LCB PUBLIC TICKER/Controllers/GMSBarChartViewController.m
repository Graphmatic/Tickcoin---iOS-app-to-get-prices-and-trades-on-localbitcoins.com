//
//  GMSBarChartViewController.m
//  GMSChartViewDemo
//
//  Created by Terry Worona on 11/5/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "GMSBarChartViewController.h"
// Views
#import "GMSBarChartView.h"
#import "GMSChartHeaderView.h"
#import "GMSBarChartFooterView.h"
#import "GMSchartViewData.h"
// Numerics
CGFloat const GMSBarChartViewControllerChartHeight = 254.0f;
CGFloat const GMSBarChartViewControllerChartPadding = 0.0f;
CGFloat const GMSBarChartViewControllerChartHeaderHeight = 80.0f;
CGFloat const GMSBarChartViewControllerChartHeaderPadding = 10.0f;
CGFloat const GMSBarChartViewControllerChartFooterHeight = 25.0f;
CGFloat const GMSBarChartViewControllerChartFooterPadding = 5.0f;
NSUInteger GMSBarChartViewControllerBarPadding = 1;
NSInteger const GMSBarChartViewControllerMaxBarHeight = 2000;
NSInteger const GMSBarChartViewControllerMinBarHeight = 0;

// Strings
NSString * const kGMSBarChartViewControllerNavButtonViewKey = @"view";

@interface GMSBarChartViewController () <GMSBarChartViewDelegate, GMSBarChartViewDataSource>
{
    GMSBarChartFooterView *footerView;
    BOOL noChartForCurrX;
}
@property (nonatomic, strong) GMSBarChartView *barChartView;
@property (nonatomic, strong) GMSchartViewData *graphDatas;
@property (nonatomic, strong) GMSChartHeaderView *headerView;


// Data
- (void)initFakeData;

@end

@implementation GMSBarChartViewController

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

#pragma mark - Date

- (void)initFakeData
{
    noChartForCurrX = NO;
    self.graphDatas = [GMSchartViewData sharedGraphViewTableData:currentCurrency];
}

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
 
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
    CGRect frameForBarChartView = CGRectMake(GMSBarChartViewControllerChartPadding, GMSBarChartViewControllerChartPadding, 518 -(GMSBarChartViewControllerChartPadding * 2), 258);
    self.barChartView = [[GMSBarChartView alloc] initWithFrame:frameForBarChartView];
    self.barChartView.bounds = frameForBarChartView;
    }
    else
    {
        CGRect frameForBarChartView = CGRectMake(GMSBarChartViewControllerChartPadding, GMSBarChartViewControllerChartPadding+20, 320 -(GMSBarChartViewControllerChartPadding * 2), 430);
        self.barChartView = [[GMSBarChartView alloc] initWithFrame:frameForBarChartView];
        self.barChartView.bounds = frameForBarChartView;

    }
//    self.barChartView.frame = CGRectMake(GMSBarChartViewControllerChartPadding, kGMSBarChartViewControllerChartPadding, self.view.bounds.size.width - (kGMSBarChartViewControllerChartPadding * 2), kGMSBarChartViewControllerChartHeight);
    self.barChartView.delegate = self;
    self.barChartView.dataSource = self;
    self.barChartView.headerPadding = GMSBarChartViewControllerChartHeaderPadding;
    self.barChartView.backgroundColor = [UIColor whiteColor];
    
    
    self.headerView = [[GMSChartHeaderView alloc] initWithFrame:CGRectMake(GMSBarChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(GMSBarChartViewControllerChartHeaderHeight * 0.5), self.view.bounds.size.width - (GMSBarChartViewControllerChartPadding * 2), GMSBarChartViewControllerChartHeaderHeight)];
    self.headerView.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_PRICE_VOLUMES_CURRENCY - last 24H" ,  @"Price & Volumes traded - last 24H - %@"), currentCurrency];
    self.headerView.separatorColor = GMSColorWhite;
    self.barChartView.headerView = self.headerView;
    
     footerView = [[GMSBarChartFooterView alloc] initWithFrame:CGRectMake(GMSBarChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(GMSBarChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (GMSBarChartViewControllerChartPadding * 2), GMSBarChartViewControllerChartFooterHeight)];
    footerView.padding = GMSBarChartViewControllerChartFooterPadding;
    footerView.leftLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_Yesterday",@"Yesterday")];
    footerView.leftLabel.textColor = [UIColor whiteColor];
    footerView.rightLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_Now",@"Now")];

    footerView.rightLabel.textColor = [UIColor whiteColor];
    self.barChartView.footerView = footerView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareDatas:)
                                                 name:@"thisDayChartChange"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateGraph:)
                                                 name:@"changeNow"
                                               object:nil];
 
    
    lockChart = NO;
    [self.view addSubview:self.barChartView];

   
    [self updateGraph:nil];
   [self prepareDatas:nil];
    //[self.barChartView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.barChartView setState:GMSChartViewStateExpanded];
}

#pragma mark - GMSBarChartViewDelegate

- (CGFloat)barChartView:(GMSBarChartView *)barChartView heightForBarViewAtAtIndex:(NSUInteger)index
{
    return [[[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:1] floatValue];
}

#pragma mark - GMSBarChartViewDataSource

- (NSUInteger)numberOfBarsInBarChartView:(GMSBarChartView *)barChartView
{
    if ([self.graphDatas.dateAscSorted count] > 24) {
        return  24;
    }
    else
    return [self.graphDatas.dateAscSorted count];
}

- (NSUInteger)barPaddingForBarChartView:(GMSBarChartView *)barChartView
{
    return GMSBarChartViewControllerBarPadding;
}

- (UIColor *)barChartView:(GMSBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index
{
    return (index % 2 == 0) ? GMSColorBlue : GMSColorOrange;
}

- (UIColor *)barSelectionColorForBarChartView:(GMSBarChartView *)barChartView
{
    return [UIColor whiteColor];
}

- (void)barChartView:(GMSBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    
    if( lockChart == NO)
    {
        NSString *detailsText = [[NSString alloc] initWithString:currentCurrency];
        detailsText = [detailsText stringByAppendingString:@"\n"];
        NSString *priceForSelHour = [[NSString alloc] init];
        NSString *volumeForSelHour = [[NSString alloc] init];
        if ([[[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:2]floatValue] == 0)
        {
           detailsText = @"NO\nTRADE";
        }
        else
        {
            if ([[[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:1] isKindOfClass:[NSString class]])
            {
                priceForSelHour = [[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:1];
            }
            else
            {
                priceForSelHour = [[[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:1]stringValue];
            }
            priceForSelHour = [GMSUtilitiesFunction roundTwoDecimal:priceForSelHour];
            priceForSelHour = [priceForSelHour stringByAppendingString:@"\n"];
            if ([[[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:2] isKindOfClass:[NSString class]])
            {
                volumeForSelHour = [[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:2];
            }
            else
            {
                volumeForSelHour = [[[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:2]stringValue];
            }
            volumeForSelHour = [GMSUtilitiesFunction roundTwoDecimal:volumeForSelHour];
            priceForSelHour = [priceForSelHour stringByAppendingString:volumeForSelHour];
            detailsText = [detailsText stringByAppendingString:priceForSelHour];
        }
        [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
        [self.tooltipView setText:detailsText];
    }
}

- (void)didUnselectBarChartView:(GMSBarChartView *)barChartView
{
    if( lockChart == NO)
    {
    [self setTooltipVisible:NO animated:YES];
    }
}
    

#pragma mark - Buttons

- (void)chartToggleButtonPressed:(id)sender
{
    UIView *buttonImageView = [self.navigationItem.rightBarButtonItem valueForKey:kGMSBarChartViewControllerNavButtonViewKey];
    buttonImageView.userInteractionEnabled = NO;
    
    CGAffineTransform transform = self.barChartView.state == GMSChartViewStateExpanded ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformMakeRotation(0);
    buttonImageView.transform = transform;
    
    [self.barChartView setState:self.barChartView.state == GMSChartViewStateExpanded ? GMSChartViewStateCollapsed : GMSChartViewStateExpanded animated:YES callback:^{
        buttonImageView.userInteractionEnabled = YES;
    }];
}

#pragma mark - Overrides

- (GMSChartView *)chartView
{
    return self.barChartView;
}
#pragma mark - Data web request
- (void)prepareDatas:(NSNotification *)notification
{
    if (noChartForCurrX == NO)
    {
        self.headerView.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_PRICE_VOLUMES_CURRENCY - last 24H" ,  @"Price & Volumes traded - last 24H - %@"), currentCurrency];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        NSString* startingDate = [dateFormatter stringFromDate:graphRequestStart];
        footerView.leftLabel.text = startingDate;
        footerView.leftLabel.textColor = [UIColor whiteColor];
        footerView.rightLabel.text = @"Now";
    }
    else
    {
        self.headerView.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_NO_CHART_AVAILABLE" , @"No chart available for %@"), currentCurrency];
    }
    
    
    [self.barChartView reloadData];
    lockChart = NO;
    startingApp = NO;
    //  NSLog(@"output for graph= %@",self.graphDatas.thisDayDatas );  @"No Chart for\nthis currency ";
}

- (void)updateGraph:(NSNotification *)notification
{
    if (startingApp == YES)
    {
        [self graphWebRequest];
    }
    else
    {
    NSDate *isNow = [[NSDate alloc]init];
    isNow = [GMSUtilitiesFunction roundDateToHour:isNow];
    NSComparisonResult compareDate;
    NSTimeInterval plusOneH = (60 * 60);
    NSDate *minDelay = [graphRequestStart dateByAddingTimeInterval:plusOneH];
    compareDate = [isNow compare:minDelay]; // comparing two dates
    
    if(compareDate != NSOrderedAscending) //isNow is equal or later -->  try to send request
    {
        if( lockChart == NO)
        {
            [self graphWebRequest];
        }
        else
        {
            [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(graphWebRequest) userInfo:nil repeats:NO];
        }
    }
    else
    {
        if ([self.graphDatas.thisDayDatasAllCurrencies objectForKey:currentCurrency] != nil)
        {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"thisDayChartChange"
             object:nil
             userInfo:nil];
        }
        else
        {
            if( lockChart == NO)
            {
                [self graphWebRequest];
            }
            else
            {
                [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(graphWebRequest) userInfo:nil repeats:NO];
            }
        }
       
    }
    }
    
    
}
- (void) graphWebRequest
{
    NSString *fullURL = [GMSUtilitiesFunction graphUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fullURL]];
    AFHTTPRequestOperation *operationGraph = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operationGraph setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operationGraph, id responseObject)
     {
        [self.graphDatas chartListingCleaned:responseObject];
        noChartForCurrX = NO;
     }
     failure:^(AFHTTPRequestOperation *operationGraph, NSError *error)
     {
        [self.graphDatas dummyArrayForMissingChart];
         noChartForCurrX = YES;
       }];
    [operationGraph start];

}
@end
