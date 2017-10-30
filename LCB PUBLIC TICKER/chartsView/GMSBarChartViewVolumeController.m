//
//  GMSBarChartViewVolumeController.m
//  Copyright (c) 2017 - Graphmatic
//

#import "GMSBarChartViewVolumeController.h"
// Views
#import "GMSBarChartView.h"
#import "GMSChartHeaderView.h"
#import "GMSBarChartFooterView.h"
#import "GMSchartViewData.h"
// Numerics
CGFloat const GMSVolumeChartHeight = 254.0f;
CGFloat const GMSVolumeChartPadding = 2.0f;
CGFloat GMSVolumeChartsViewPaddingTop = 0.0f;  // overrided after header title positionning

CGFloat const GMSVolumeChartHeaderHeight = 50.0f;
CGFloat const GMSVolumeChartHeaderPadding = 10.0f;
CGFloat const GMSVolumeChartFooterHeight = 25.0f;
CGFloat const GMSVolumeChartFooterPadding = 5.0f;
NSUInteger GMSVolumeBarPadding = 1;
NSInteger const GMSVolumeMaxBarHeight = 2000;
NSInteger const GMSVolumeMinBarHeight = 0;

// Strings
NSString * const kGMSVolumeNavButtonViewKey = @"view";

@interface GMSBarChartViewVolumeController () <GMSBarChartViewDelegate, GMSBarChartViewDataSource>
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

@implementation GMSBarChartViewVolumeController

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
    
    CGFloat childViewWidth = self.view.bounds.size.width;
    CGFloat childViewHeight = self.view.bounds.size.height;
    
    // header of first chart (price)
    self.headerView = [[GMSChartHeaderView alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           self.view.bounds.size.width - (GMSVolumeChartPadding * 2),
                                                                           GMSVolumeChartHeaderHeight)];
    
    self.headerView.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_VOLUME_CURRENCY_CHART" ,  @"Volumes traded - last 24H - %@"), currentCurrency];
    self.headerView.separatorColor = GMSColorWhite;
    
    // footer of first chart (price)
    footerView = [[GMSBarChartFooterView alloc] initWithFrame:CGRectMake(GMSVolumeChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(GMSVolumeChartFooterHeight * 0.5), self.view.bounds.size.width - (GMSVolumeChartPadding * 2), GMSVolumeChartFooterHeight)];
    footerView.padding = GMSVolumeChartFooterPadding;
    footerView.leftLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_Yesterday",@"Yesterday")];
    footerView.leftLabel.textColor = [UIColor whiteColor];
    footerView.rightLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_Now",@"Now")];
    footerView.rightLabel.textColor = [UIColor whiteColor];
    
    // the bargraph itself
    CGRect frameForBarChartView;
    if ( IS_IPAD )
    {
        frameForBarChartView = CGRectMake(GMSVolumeChartPadding,
                                          GMSVolumeChartsViewPaddingTop,
                                          518 -(GMSVolumeChartPadding * 2),
                                          258);
    }
    else
    {
        frameForBarChartView = CGRectMake(0,
                                          0,
                                          childViewWidth,
                                          childViewHeight/2 - self.headerView.frame.size.height);
    }
    
    self.barChartView = [[GMSBarChartView alloc] initWithFrame:frameForBarChartView];
    self.barChartView.bounds = frameForBarChartView;
    
    self.barChartView.delegate = self;
    self.barChartView.dataSource = self;
    self.barChartView.headerPadding = GMSVolumeChartHeaderPadding;
    self.barChartView.backgroundColor = GMSColorBlueGrey;
    
    // add footer and header to bargraph
    self.barChartView.headerView = self.headerView;
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
    [self.barChartView reloadData];
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
    return GMSVolumeBarPadding;
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
        NSString *volumeForSelHour = [[NSString alloc] init];
        if ([[[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:2]floatValue] == 0)
        {
            detailsText = NSLocalizedString(@"_NO_TRADE" ,  @"NO TRADES");
        }
        else
        {
//            if ([[[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:1] isKindOfClass:[NSString class]])
//            {
//                priceForSelHour = [[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:1];
//            }
//            else
//            {
//                priceForSelHour = [[[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:1]stringValue];
//            }
//            priceForSelHour = [GMSUtilitiesFunction roundTwoDecimal:priceForSelHour];
//            priceForSelHour = [priceForSelHour stringByAppendingString:@"\n"];
            if ([[[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:2] isKindOfClass:[NSString class]])
            {
                volumeForSelHour = [[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:2];
            }
            else
            {
                volumeForSelHour = [[[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:2]stringValue];
            }
            
            detailsText = [detailsText stringByAppendingString:[GMSUtilitiesFunction roundTwoDecimal:volumeForSelHour]];
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

//- (void)chartToggleButtonPressed:(id)sender
//{
//    UIView *buttonImageView = [self.navigationItem.rightBarButtonItem valueForKey:kGMSVolumeNavButtonViewKey];
//    buttonImageView.userInteractionEnabled = NO;
//
//    CGAffineTransform transform = self.barChartView.state == GMSChartViewStateExpanded ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformMakeRotation(0);
//    buttonImageView.transform = transform;
//
//    [self.barChartView setState:self.barChartView.state == GMSChartViewStateExpanded ? GMSChartViewStateCollapsed : GMSChartViewStateExpanded animated:YES callback:^{
//        buttonImageView.userInteractionEnabled = YES;
//    }];
//}

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
        self.headerView.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_VOLUME_CURRENCY_CHART" ,  @"Price & Volumes traded - last 24H - %@"), currentCurrency];
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

