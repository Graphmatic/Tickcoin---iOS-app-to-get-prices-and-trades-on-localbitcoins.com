//
//  GMSBarChartViewVolumeController.m
//  Copyright (c) 2017 - Graphmatic
//

#import "GMSBarChartViewPriceController.h"
// Views
#import "GMSBarChartView.h"
#import "GMSChartHeaderView.h"
#import "GMSBarChartFooterView.h"
#import "GMSchartViewData.h"
#import <sys/sysctl.h>
#import <sys/utsname.h>

// Numerics
CGFloat const GMSPriceChartHeight = 254.0f;
CGFloat GMSPriceChartPadding = 2.0f;
CGFloat GMSPriceChartsViewPaddingTop = 0.0f;  

CGFloat const GMSPriceChartHeaderHeight = 48.0f;
CGFloat const GMSPriceChartHeaderPadding = 10.0f;
CGFloat GMSPriceChartFooterHeight = 25.0f;
CGFloat GMSPriceChartFooterPadding = 5.0f;
NSUInteger GMSPriceBarPadding = 1;
//NSInteger const GMSPriceMaxBarHeight = 20000;
//NSInteger const GMSPriceMinBarHeight = 2000;

// Strings
NSString * const kGMSBarChartViewControllerNavButtonViewKey = @"view";

@interface GMSBarChartViewPriceController () <GMSBarChartViewDelegate, GMSBarChartViewDataSource>
{
    GMSBarChartFooterView *footerView;
}
@property (nonatomic, strong) GMSBarChartView *barChartView;
@property (nonatomic, strong) GMSchartViewData *graphDatas;
@property (nonatomic, strong) GMSChartHeaderView *headerView;


// Data
- (void)initWithDatas;

@end

@implementation GMSBarChartViewPriceController

#pragma mark - Alloc/Init

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initWithDatas];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initWithDatas];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self initWithDatas];
    }
    return self;
}

- (void)initWithDatas
{
    self.graphDatas = [GMSchartViewData sharedGraphViewTableData];
}

#pragma mark - View Lifecycle

- (void)loadView
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *currentDevice = [NSString stringWithCString:systemInfo.machine
                                                 encoding:NSUTF8StringEncoding];
    NSString *currentSimulatorDevice = [NSString stringWithCString:getenv("SIMULATOR_MODEL_IDENTIFIER")
                                                          encoding:NSUTF8StringEncoding];
    
    [super loadView];
    
    CGFloat childViewWidth = self.view.bounds.size.width;
    CGFloat childViewHeight = self.view.bounds.size.height;
    
    Globals *glob = [Globals globals];

    
    if ( IS_IPAD )
    {
        GMSPriceChartPadding = 2.0f;
        GMSPriceChartFooterHeight = 22.0f;
    }
    // header of first chart (price)
    self.headerView = [[GMSChartHeaderView alloc] initWithFrame:CGRectMake(0, 0, childViewWidth - GMSPriceChartPadding, GMSPriceChartHeaderHeight)];
    self.headerView.titleLabel.backgroundColor = GMSColorBlueGreyDark;
    self.headerView.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_PRICE_CURRENCY_CHART" ,  @"Price & Volumes traded - last 24H - %@"), [glob currency]];
    self.headerView.separatorColor = GMSColorWhite;
    
    // footer of first chart (price)
    footerView = [[GMSBarChartFooterView alloc] initWithFrame:CGRectMake(GMSPriceChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(GMSPriceChartFooterHeight * 0.5), self.view.bounds.size.width - GMSPriceChartPadding, GMSPriceChartFooterHeight)];
    footerView.padding = GMSPriceChartFooterPadding;
    footerView.leftLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_Yesterday",@"Yesterday")];
    footerView.leftLabel.textColor = [UIColor whiteColor];
    footerView.rightLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_Now",@"Now")];
    footerView.rightLabel.textColor = [UIColor whiteColor];
    
    // the bargraph itself
    CGRect frameForBarChartView;
    if ( IS_IPAD )
    {
        frameForBarChartView = CGRectMake(2,
                                          0,
                                          518,
                                          206);
    }
    else if ( IS_IPHONE_X )
    {
        frameForBarChartView = CGRectMake(0,
                                          0,
                                          childViewWidth,
                                          childViewHeight / 2 - self.headerView.frame.size.height - 25);
    }
    else
    {
        frameForBarChartView = CGRectMake(0,
                                          0,
                                          childViewWidth,
                                          (childViewHeight / 2) - GMSPriceChartHeaderHeight);
    }
    
    self.barChartView = [[GMSBarChartView alloc] initWithFrame:frameForBarChartView];
    self.barChartView.bounds = frameForBarChartView;
    
    self.barChartView.delegate = self;
    self.barChartView.dataSource = self;
    self.barChartView.headerPadding = GMSPriceChartHeaderPadding;
    
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
    return [[[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:index]]objectAtIndex:2] floatValue];
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
    return GMSPriceBarPadding;
}

- (UIColor *)barChartView:(GMSBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index
{
    return (index % 2 == 0) ? GMSColorWhiteBlue : GMSColorPurpleDark;
}

- (UIColor *)barSelectionColorForBarChartView:(GMSBarChartView *)barChartView
{
    return [UIColor whiteColor];
}

- (void)barChartView:(GMSBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    if( self.graphDatas.isReady == YES)
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
    if( self.graphDatas.isReady == YES)
    {
        [self setTooltipVisible:NO animated:YES];
    }
}

#pragma mark - Overrides

- (GMSChartView *)chartView
{
    return self.barChartView;
}

- (void)setupVisibleElement
{
    Globals *glob = [Globals globals];

    if ( self.graphDatas.isReady == YES)
    {
        if ( self.graphDatas.apiQuerySuccess )
        {
            
            self.headerView.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_PRICE_CURRENCY_CHART" ,  @"Price & Volumes traded - last 24H - %@"), [glob currency]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd HH:mm"];
            NSString* startingDate = [dateFormatter stringFromDate:[glob queryStartDate]];
            footerView.leftLabel.text = startingDate;
            footerView.leftLabel.textColor = [UIColor whiteColor];
            footerView.rightLabel.textColor = [UIColor whiteColor];
            footerView.rightLabel.text = @"Now";
        }
        else
        {
            self.headerView.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_PRICE_CURRENCY_CHART_OUTDATED" ,  @"Price & Volumes traded - Outdated! - %@"), [glob currency]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd HH:mm"];
            NSDate *outdatedStartingDate = [[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:0]]objectAtIndex:3];
            NSLog(@"start date : %@", outdatedStartingDate);
            NSString* startingDate = [dateFormatter stringFromDate:outdatedStartingDate];
            NSDate *outdatedEndDate = [[self.graphDatas.thisDayDatas objectForKey:[self.graphDatas.dateAscSorted objectAtIndex:23]]objectAtIndex:3];
            NSLog(@"start date : %@", outdatedEndDate);
            NSString *endDate = [dateFormatter stringFromDate:outdatedEndDate];
            footerView.leftLabel.text = startingDate;
            footerView.leftLabel.textColor = GMSColorRed;
            footerView.rightLabel.textColor = GMSColorRed;
            footerView.rightLabel.text = endDate;
        }
    }
    else
    {
        self.headerView.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_NO_CHART_AVAILABLE" , @"No chart available for %@"), [glob currency]];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ( object == self.graphDatas )
    {
        NSLog(@"observer triggered");
        
    if ( [keyPath isEqualToString:@"isReady"] && [change objectForKey:@"new"] ) //  are datas ready to use ?
        {
            NSLog(@"isReady triggered");
            dispatch_async(dispatch_get_main_queue(), ^{  // we are in an block op, so ensure that UI update is done on the main thread
                // Update misc. visible elements
                [self setupVisibleElement];
                
                // setup visual range
                self.barChartView.minimumValue = [[self.graphDatas.visualRangeForPricesAndVolumes objectForKey:@"pricesDelta"][0]doubleValue] * 0.85;
                self.barChartView.maximumValue =  [[self.graphDatas.visualRangeForPricesAndVolumes objectForKey:@"pricesDelta"][1]doubleValue] * 1.15;
                
    //            // debug
    //            NSLog(@"visualRange was changed.");
    //            NSLog(@"in Prices barchart:  LOW = %f   ****  HIGH = %f", self.barChartView.minimumValue, self.barChartView.maximumValue);

                [self.barChartView reloadData];
            });
       }
    }
        
}

@end
