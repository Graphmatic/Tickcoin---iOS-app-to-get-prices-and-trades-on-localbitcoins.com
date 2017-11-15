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
CGFloat GMSVolumeChartPadding = 2.0f;
CGFloat GMSVolumeChartsViewPaddingTop = 0.0f;

CGFloat const GMSVolumeChartHeaderHeight = 50.0f;
CGFloat const GMSVolumeChartHeaderPadding = 10.0f;
CGFloat GMSVolumeChartFooterHeight = 25.0f;
CGFloat const GMSVolumeChartFooterPadding = 5.0f;
NSUInteger GMSVolumeBarPadding = 1;
NSInteger const GMSVolumeMaxBarHeight = 5000;
NSInteger const GMSVolumeMinBarHeight = 0;

// Strings
NSString * const kGMSVolumeNavButtonViewKey = @"view";

@interface GMSBarChartViewVolumeController () <GMSBarChartViewDelegate, GMSBarChartViewDataSource>
{
    GMSBarChartFooterView *footerView;
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
    self.graphDatas = [GMSchartViewData sharedGraphViewTableData:currentCurrency];
}

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
    CGFloat childViewWidth = self.view.bounds.size.width;
    CGFloat childViewHeight = self.view.bounds.size.height;
    if ( IS_IPAD )
    {
        GMSVolumeChartPadding = 0.0f;
        GMSVolumeChartFooterHeight = 22.0f;
    }
    // header of first chart (price)
    self.headerView = [[GMSChartHeaderView alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           childViewWidth - GMSVolumeChartPadding,
                                                                           GMSVolumeChartHeaderHeight)];
    
    self.headerView.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_VOLUME_CURRENCY_CHART" ,  @"Volumes traded - last 24H - %@"), currentCurrency];
    self.headerView.separatorColor = GMSColorWhite;
    
    // footer of first chart (price)
    footerView = [[GMSBarChartFooterView alloc] initWithFrame:CGRectMake(GMSVolumeChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(GMSVolumeChartFooterHeight * 0.5), self.view.bounds.size.width - GMSVolumeChartPadding, GMSVolumeChartFooterHeight)];
    footerView.padding = GMSVolumeChartFooterPadding;
    footerView.leftLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_Yesterday", @"Yesterday")];
    footerView.leftLabel.textColor = [UIColor whiteColor];
    footerView.rightLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_Now", @"Now")];
    footerView.rightLabel.textColor = [UIColor whiteColor];
    
    // the bargraph itself
    CGRect frameForBarChartView;
    if ( IS_IPAD )
    {
        frameForBarChartView = CGRectMake(0,
                                          0,
                                          516,
                                          206);
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
    
    // add observer so visual range is adapted as soon as graphDatas are updated
    [self.graphDatas addObserver:self forKeyPath:@"isReady" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self.view addSubview:self.barChartView];

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
    if ( self.graphDatas.isReady == YES )
    {
        NSArray *hourlyDatas;
        BOOL isTrade = true;
        
        float value = [[[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:2]floatValue];
        
        if ( value == 0 )
        {
            isTrade = NO;
            hourlyDatas = nil;
        }
        else
        {
            hourlyDatas = [NSArray arrayWithArray:[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]];
        }
        
        [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
        
        hourlyDatas = [NSArray arrayWithArray:[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]];
        [self.tooltipView bindAllValues:isTrade :hourlyDatas];
    }
}

- (void)didUnselectBarChartView:(GMSBarChartView *)barChartView
{
    if ( self.graphDatas.isReady == YES )
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

- (void)setupVisibleElement
{
    if ( self.graphDatas.isReady == YES )
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
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ( [keyPath isEqualToString:@"isReady"] && [[change objectForKey:@"new"]intValue] == 1 ) //  are datas ready to use ?
    {
        dispatch_async(dispatch_get_main_queue(), ^{  // we are in an block op, so ensure that UI update is done on the main thread
            // Update misc. visible elements
            [self setupVisibleElement];
            
            // setup visual range
            self.barChartView.minimumValue = [[self.graphDatas.visualRangeForPricesAndVolumes objectForKey:@"volumesDelta"][0]doubleValue] * 0.85;
            self.barChartView.maximumValue =  [[self.graphDatas.visualRangeForPricesAndVolumes objectForKey:@"volumesDelta"][1]doubleValue] * 1.15;
            
            //            // debug
            //            NSLog(@"visualRange was changed.");
            //            NSLog(@"in Prices barchart:  LOW = %f   ****  HIGH = %f", self.barChartView.minimumValue, self.barChartView.maximumValue);
            
            // triggering re-drawn
            [self.barChartView reloadData];
        });
    }
}

@end

