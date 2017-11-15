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
// Numerics
CGFloat const GMSPriceChartHeight = 254.0f;
CGFloat GMSPriceChartPadding = 2.0f;
CGFloat GMSPriceChartsViewPaddingTop = 0.0f;  

CGFloat const GMSPriceChartHeaderHeight = 50.0f;
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
    BOOL noChartForCurrX;
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

#pragma mark - Date

- (void)initWithDatas
{
    noChartForCurrX = NO;
    self.graphDatas = [GMSchartViewData sharedGraphViewTableData:currentCurrency];
}

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
    [self.view layoutIfNeeded];
    [self.view setNeedsLayout];
    CGFloat childViewWidth = self.view.bounds.size.width;
    CGFloat childViewHeight = self.view.bounds.size.height;
    
    if ( IS_IPAD )
    {
        GMSPriceChartPadding = 0.0f;
        GMSPriceChartFooterHeight = 22.0f;
    }
    // header of first chart (price)

    self.headerView = [[GMSChartHeaderView alloc] initWithFrame:CGRectMake(0, 0, childViewWidth - GMSPriceChartPadding, GMSPriceChartHeaderHeight)];
    
    self.headerView.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_PRICE_CURRENCY_CHART" ,  @"Price & Volumes traded - last 24H - %@"), currentCurrency];
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
    
    lockChart = NO;  // this flag is used to check if GMSchartViewData singleton is computing

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
    if( lockChart == NO)
    {
        [self setTooltipVisible:NO animated:YES];
    }
}


#pragma mark - Buttons


//- (IBAction)chartToggleButtonPressed:(id)sender
//{
//    UIView *buttonImageView = [self.navigationItem.rightBarButtonItem valueForKey:kGMSBarChartViewControllerNavButtonViewKey];
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
    if ( noChartForCurrX == NO )
    {
        self.headerView.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_PRICE_CURRENCY_CHART" ,  @"Price & Volumes traded - last 24H - %@"), currentCurrency];
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

    lockChart = NO;
    startingApp = NO;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ( [keyPath isEqualToString:@"isReady"] && [[change objectForKey:@"new"]intValue] == 1 ) //  are datas ready to use ?
    {
        dispatch_async(dispatch_get_main_queue(), ^{  // we are in an block op, so ensure that UI update is done on the main thread
            // Update misc. visible elements
            [self setupVisibleElement];
            
            // setup visual range
            self.barChartView.minimumValue = [[self.graphDatas.visualRangeForPricesAndVolumes objectForKey:@"pricesDelta"][0]doubleValue] * 0.85;
            self.barChartView.maximumValue =  [[self.graphDatas.visualRangeForPricesAndVolumes objectForKey:@"pricesDelta"][1]doubleValue] * 1.15;
            
//            // debug
//            NSLog(@"visualRange was changed.");
//            NSLog(@"in Prices barchart:  LOW = %f   ****  HIGH = %f", self.barChartView.minimumValue, self.barChartView.maximumValue);

            // triggering re-drawn
            [self.barChartView reloadData];
        });
    }
}

@end
