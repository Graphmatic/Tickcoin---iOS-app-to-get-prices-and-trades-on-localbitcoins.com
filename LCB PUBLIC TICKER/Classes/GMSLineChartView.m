//
//  GMSLineChartView.m
//  Nudge
//
//  Created by Terry Worona on 9/4/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "GMSLineChartView.h"

// Drawing
#import <QuartzCore/QuartzCore.h>

// Enums
typedef NS_ENUM(NSUInteger, GMSLineChartHorizontalIndexClamp){
	GMSLineChartHorizontalIndexClampLeft,
    GMSLineChartHorizontalIndexClampRight,
    GMSLineChartHorizontalIndexClampNone
};

// Numerics (GMSLineChartLineView)
CGFloat static const kGMSLineChartLinesViewStrokeWidth = 5.0;
CGFloat static const kGMSLineChartLinesViewMiterLimit = -5.0;
CGFloat static const kGMSLineChartLinesViewDefaultLinePhase = 1.0f;
CGFloat static const kGMSLineChartLinesViewDefaultDimmedOpacity = 0.20f;
NSInteger static const kGMSLineChartLinesViewUnselectedLineIndex = -1;
CGFloat static const kGMSLineChartLinesViewSmoothThresholdSlope = 0.01f;
NSInteger static const kGMSLineChartLinesViewSmoothThresholdVertical = 1;

// Numerics (GMSLineChartDotsView)
NSInteger static const kGMSLineChartDotsViewDefaultRadiusFactor = 3; // 3x size of line width
NSInteger static const kGMSLineChartDotsViewUnselectedLineIndex = -1;

// Numerics (GMSLineSelectionView)
CGFloat static const kGMSLineSelectionViewWidth = 20.0f;

// Numerics (GMSLineChartView)
CGFloat static const kGMSBarChartViewUndefinedCachedHeight = -1.0f;
CGFloat static const kGMSLineChartViewStateAnimationDuration = 0.25f;
CGFloat static const kGMSLineChartViewStateAnimationDelay = 0.05f;
CGFloat static const kGMSLineChartViewStateBounceOffset = 15.0f;
NSInteger static const kGMSLineChartUnselectedLineIndex = -1;

// Collections (GMSLineChartLineView)
static NSArray *kGMSLineChartLineViewDefaultDashPattern = nil;

// Colors (GMSLineChartView)
static UIColor *kGMSLineChartViewDefaultLineColor = nil;
static UIColor *kGMSLineChartViewDefaultDotColor = nil;
static UIColor *kGMSLineChartViewDefaultLineSelectionColor = nil;
static UIColor *kGMSLineChartViewDefaultDotSelectionColor = nil;

@interface GMSChartView (Private)

- (BOOL)hasMaximumValue;
- (BOOL)hasMinimumValue;

@end

@interface GMSLineLayer : CAShapeLayer

@property (nonatomic, assign) NSUInteger tag;
@property (nonatomic, assign) GMSLineChartViewLineStyle lineStyle;

@end

@interface GMSLineChartPoint : NSObject

@property (nonatomic, assign) CGPoint position;

@end

@protocol GMSLineChartLinesViewDelegate;

@interface GMSLineChartLinesView : UIView

@property (nonatomic, assign) id<GMSLineChartLinesViewDelegate> delegate;
@property (nonatomic, assign) NSInteger selectedLineIndex; // -1 to unselect
@property (nonatomic, assign) BOOL animated;

// Data
- (void)reloadData;

// Setters
- (void)setSelectedLineIndex:(NSInteger)selectedLineIndex animated:(BOOL)animated;

// Callback helpers
- (void)fireCallback:(void (^)())callback;

// View helpers
- (GMSLineLayer *)lineLayerForLineIndex:(NSUInteger)lineIndex;

@end

@protocol GMSLineChartLinesViewDelegate <NSObject>

- (NSArray *)chartDataForLineChartLinesView:(GMSLineChartLinesView*)lineChartLinesView;
- (UIColor *)lineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView colorForLineAtLineIndex:(NSUInteger)lineIndex;
- (UIColor *)lineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView selectedColorForLineAtLineIndex:(NSUInteger)lineIndex;
- (CGFloat)lineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView widthForLineAtLineIndex:(NSUInteger)lineIndex;
- (CGFloat)paddingForLineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView;
- (GMSLineChartViewLineStyle)lineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex;
- (BOOL)lineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView smoothLineAtLineIndex:(NSUInteger)lineIndex;

@end

@protocol GMSLineChartDotsViewDelegate;

@interface GMSLineChartDotsView : UIView // GMSLineChartViewLineStyleDotted

@property (nonatomic, assign) id<GMSLineChartDotsViewDelegate> delegate;
@property (nonatomic, assign) NSInteger selectedLineIndex; // -1 to unselect
@property (nonatomic, strong) NSDictionary *dotViewsDict;

// Data
- (void)reloadData;

// Setters
- (void)setSelectedLineIndex:(NSInteger)selectedLineIndex animated:(BOOL)animated;

@end

@protocol GMSLineChartDotsViewDelegate <NSObject>

- (NSArray *)chartDataForLineChartDotsView:(GMSLineChartDotsView*)lineChartDotsView;
- (UIColor *)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView colorForLineAtLineIndex:(NSUInteger)lineIndex;
- (UIColor *)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex;
- (UIColor *)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView selectedColorForLineAtLineIndex:(NSUInteger)lineIndex;
- (UIColor *)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView selectedColorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex;
- (CGFloat)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView widthForLineAtLineIndex:(NSUInteger)lineIndex;
- (CGFloat)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView dotRadiusForLineAtLineIndex:(NSUInteger)lineIndex;
- (CGFloat)paddingForLineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView;
- (BOOL)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex;

@end

@interface GMSLineChartDotView : UIView

- (id)initWithRadius:(CGFloat)radius;

@end

@interface GMSLineChartView () <GMSLineChartLinesViewDelegate, GMSLineChartDotsViewDelegate>

@property (nonatomic, strong) NSArray *chartData;
@property (nonatomic, strong) GMSLineChartLinesView *linesView;
@property (nonatomic, strong) GMSLineChartDotsView *dotsView;
@property (nonatomic, strong) GMSChartVerticalSelectionView *verticalSelectionView;
@property (nonatomic, assign) CGFloat cachedMaxHeight;
@property (nonatomic, assign) CGFloat cachedMinHeight;
@property (nonatomic, assign) BOOL verticalSelectionViewVisible;

// Initialization
- (void)construct;

// View quick accessors
- (CGFloat)normalizedHeightForRawHeight:(CGFloat)rawHeight;
- (CGFloat)availableHeight;
- (CGFloat)padding;
- (NSUInteger)dataCount;

// Touch helpers
- (CGPoint)clampPoint:(CGPoint)point toBounds:(CGRect)bounds padding:(CGFloat)padding;
- (NSInteger)horizontalIndexForPoint:(CGPoint)point indexClamp:(GMSLineChartHorizontalIndexClamp)indexClamp lineData:(NSArray *)lineData;
- (NSInteger)horizontalIndexForPoint:(CGPoint)point indexClamp:(GMSLineChartHorizontalIndexClamp)indexClamp; // uses largest line data
- (NSInteger)horizontalIndexForPoint:(CGPoint)point;
- (NSInteger)lineIndexForPoint:(CGPoint)point;
- (void)touchesBeganOrMovedWithTouches:(NSSet *)touches;
- (void)touchesEndedOrCancelledWithTouches:(NSSet *)touches;

// Setters
- (void)setVerticalSelectionViewVisible:(BOOL)verticalSelectionViewVisible animated:(BOOL)animated;

@end

@implementation GMSLineChartView

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [GMSLineChartView class])
	{
		kGMSLineChartViewDefaultLineColor = [UIColor blackColor];
        kGMSLineChartViewDefaultDotColor = [UIColor blackColor];
		kGMSLineChartViewDefaultLineSelectionColor = [UIColor whiteColor];
        kGMSLineChartViewDefaultDotSelectionColor = [UIColor whiteColor];
	}
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self construct];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self construct];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self construct];
    }
    return self;
}

- (void)construct
{
    _showsVerticalSelection = YES;
    _showsLineSelection = YES;
    _cachedMinHeight = kGMSBarChartViewUndefinedCachedHeight;
    _cachedMaxHeight = kGMSBarChartViewUndefinedCachedHeight;
}

#pragma mark - Data

- (void)reloadData
{
    // Reset cached max height
    self.cachedMinHeight = kGMSBarChartViewUndefinedCachedHeight;
    self.cachedMaxHeight = kGMSBarChartViewUndefinedCachedHeight;
    
    // Padding
    CGFloat chartPadding = [self padding];

    /*
     * Subview rectangle calculations
     */
    CGRect mainViewRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, [self availableHeight]);

    /*
     * The data collection holds all position and marker information:
     * constructed via datasource and delegate functions
     */
    dispatch_block_t createChartData = ^{

        CGFloat pointSpace = (self.bounds.size.width - (chartPadding * 2)) / ([self dataCount] - 1); // Space in between points
        CGFloat xOffset = chartPadding;
        CGFloat yOffset = 0;

        NSMutableArray *mutableChartData = [NSMutableArray array];
        NSAssert([self.dataSource respondsToSelector:@selector(numberOfLinesInLineChartView:)], @"GMSLineChartView // dataSource must implement - (NSUInteger)numberOfLinesInLineChartView:(GMSLineChartView *)lineChartView");
        for (NSUInteger lineIndex=0; lineIndex<[self.dataSource numberOfLinesInLineChartView:self]; lineIndex++)
        {
            NSAssert([self.dataSource respondsToSelector:@selector(lineChartView:numberOfVerticalValuesAtLineIndex:)], @"GMSLineChartView // dataSource must implement - (NSUInteger)lineChartView:(GMSLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex");
            NSUInteger dataCount = [self.dataSource lineChartView:self numberOfVerticalValuesAtLineIndex:lineIndex];
            NSMutableArray *chartPointData = [NSMutableArray array];
            for (NSUInteger horizontalIndex=0; horizontalIndex<dataCount; horizontalIndex++)
            {               
                NSAssert([self.delegate respondsToSelector:@selector(lineChartView:verticalValueForHorizontalIndex:atLineIndex:)], @"GMSLineChartView // delegate must implement - (CGFloat)lineChartView:(GMSLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex");
                CGFloat rawHeight =  [self.delegate lineChartView:self verticalValueForHorizontalIndex:horizontalIndex atLineIndex:lineIndex];
                NSAssert(rawHeight >= 0, @"GMSLineChartView // delegate function - (CGFloat)lineChartView:(GMSLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex must return a CGFloat >= 0");

                CGFloat normalizedHeight = [self normalizedHeightForRawHeight:rawHeight];
                yOffset = mainViewRect.size.height - normalizedHeight;
                
                GMSLineChartPoint *chartPoint = [[GMSLineChartPoint alloc] init];
                chartPoint.position = CGPointMake(xOffset, yOffset);
                
                [chartPointData addObject:chartPoint];
                xOffset += pointSpace;
            }
            [mutableChartData addObject:chartPointData];
            xOffset = chartPadding;
        }
        self.chartData = [NSArray arrayWithArray:mutableChartData];
	};

    /*
     * Creates a new line graph view using the previously calculated data model
     */
    dispatch_block_t createLineGraphView = ^{

        // Remove old line view
        if (self.linesView)
        {
            [self.linesView removeFromSuperview];
            self.linesView = nil;
        }

        // Create new line and overlay subviews
        self.linesView = [[GMSLineChartLinesView alloc] initWithFrame:CGRectOffset(mainViewRect, 0, self.headerView.frame.size.height + self.headerPadding)];
        self.linesView.delegate = self;

        // Add new lines view
        if (self.footerView)
        {
            [self insertSubview:self.linesView belowSubview:self.footerView];
        }
        else
        {
            [self addSubview:self.linesView];
        }
    };

    /*
     * Creates a new dot graph view using the previously calculated data model
     */
    dispatch_block_t createDotGraphView = ^{
        
        // Remove old dot view
        if (self.dotsView)
        {
            [self.dotsView removeFromSuperview];
            self.dotsView = nil;
        }
        
        // Create new line and overlay subviews
        self.dotsView = [[GMSLineChartDotsView alloc] initWithFrame:CGRectOffset(mainViewRect, 0, self.headerView.frame.size.height + self.headerPadding)];
        self.dotsView.delegate = self;
        
        // Add new dots view
        if (self.footerView)
        {
            [self insertSubview:self.dotsView belowSubview:self.footerView];
        }
        else
        {
            [self addSubview:self.dotsView];
        }
    };
    
    /*
     * Creates a vertical selection view for touch events
     */
    dispatch_block_t createSelectionView = ^{
        if (self.verticalSelectionView)
        {
            [self.verticalSelectionView removeFromSuperview];
            self.verticalSelectionView = nil;
        }

        CGFloat selectionViewWidth = kGMSLineSelectionViewWidth;
        if ([self.dataSource respondsToSelector:@selector(verticalSelectionWidthForLineChartView:)])
        {
            selectionViewWidth = MIN([self.dataSource verticalSelectionWidthForLineChartView:self], self.bounds.size.width);
        }
        self.verticalSelectionView = [[GMSChartVerticalSelectionView alloc] initWithFrame:CGRectMake(0, 0, selectionViewWidth, self.bounds.size.height - self.footerView.frame.size.height)];
        self.verticalSelectionView.alpha = 0.0;
        self.verticalSelectionView.hidden = !self.showsVerticalSelection;
        if ([self.dataSource respondsToSelector:@selector(verticalSelectionColorForLineChartView:)])
        {
            self.verticalSelectionView.bgColor = [self.dataSource verticalSelectionColorForLineChartView:self];
        }

        // Add new selection bar
        if (self.footerView)
        {
            [self insertSubview:self.verticalSelectionView belowSubview:self.footerView];
        }
        else
        {
            [self addSubview:self.verticalSelectionView];
        }
    };

    createChartData();
    createLineGraphView();
    createDotGraphView();
    createSelectionView();

    // Reload views
    [self.linesView reloadData];
    [self.dotsView reloadData];

    // Position header and footer
    self.headerView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.headerView.frame.size.height);
    self.footerView.frame = CGRectMake(self.bounds.origin.x, self.bounds.size.height - self.footerView.frame.size.height, self.bounds.size.width, self.footerView.frame.size.height);

    // Refresh state
    [self setState:self.state animated:NO callback:nil force:YES];
}

#pragma mark - View Quick Accessors

- (CGFloat)normalizedHeightForRawHeight:(CGFloat)rawHeight
{
    CGFloat minHeight = [self minimumValue];
    CGFloat maxHeight = [self maximumValue];

    if ((maxHeight - minHeight) <= 0)
    {
        return 0;
    }

    return ((rawHeight - minHeight) / (maxHeight - minHeight)) * [self availableHeight];
}

- (CGFloat)availableHeight
{
    return self.bounds.size.height - self.headerView.frame.size.height - self.footerView.frame.size.height - self.headerPadding;
}

- (CGFloat)padding
{
    CGFloat maxLineWidth = 0.0f;
    NSAssert([self.dataSource respondsToSelector:@selector(numberOfLinesInLineChartView:)], @"GMSLineChartView // dataSource must implement - (NSUInteger)numberOfLinesInLineChartView:(GMSLineChartView *)lineChartView");

    for (NSUInteger lineIndex=0; lineIndex<[self.dataSource numberOfLinesInLineChartView:self]; lineIndex++)
    {
        BOOL showsDots = NO;
        if ([self.dataSource respondsToSelector:@selector(lineChartView:showsDotsForLineAtLineIndex:)])
        {
            showsDots = [self.dataSource lineChartView:self showsDotsForLineAtLineIndex:lineIndex];
        }

        CGFloat lineWidth = kGMSLineChartLinesViewStrokeWidth; // default
        if ([self.dataSource respondsToSelector:@selector(lineChartView:widthForLineAtLineIndex:)])
        {
            lineWidth = [self.dataSource lineChartView:self widthForLineAtLineIndex:lineWidth];
        }
        
        CGFloat dotRadius = lineWidth * kGMSLineChartDotsViewDefaultRadiusFactor; // default
        if (showsDots)
        {
            if ([self.dataSource respondsToSelector:@selector(lineChartView:dotRadiusForLineAtLineIndex:)])
            {
                dotRadius = [self.dataSource lineChartView:self dotRadiusForLineAtLineIndex:lineIndex];
            }
        }
        
        CGFloat currentMaxLineWidth = MAX(dotRadius, lineWidth);
        if (currentMaxLineWidth > maxLineWidth)
        {
            maxLineWidth = currentMaxLineWidth;
        }
    }
    return ceil(maxLineWidth * 0.5);
}

- (NSUInteger)dataCount
{
    NSUInteger dataCount = 0;
    NSAssert([self.dataSource respondsToSelector:@selector(numberOfLinesInLineChartView:)], @"GMSLineChartView // dataSource must implement - (NSUInteger)numberOfLinesInLineChartView:(GMSLineChartView *)lineChartView");
    for (NSUInteger lineIndex=0; lineIndex<[self.dataSource numberOfLinesInLineChartView:self]; lineIndex++)
    {
        NSAssert([self.dataSource respondsToSelector:@selector(lineChartView:numberOfVerticalValuesAtLineIndex:)], @"GMSLineChartView // dataSource must implement - (NSUInteger)lineChartView:(GMSLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex");
        NSUInteger lineDataCount = [self.dataSource lineChartView:self numberOfVerticalValuesAtLineIndex:lineIndex];
        if (lineDataCount > dataCount)
        {
            dataCount = lineDataCount;
        }
    }
    return dataCount;
}

#pragma mark - GMSLineChartLinesViewDelegate

- (NSArray *)chartDataForLineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView
{
    return self.chartData;
}

- (UIColor *)lineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    if ([self.dataSource respondsToSelector:@selector(lineChartView:colorForLineAtLineIndex:)])
    {
        return [self.dataSource lineChartView:self colorForLineAtLineIndex:lineIndex];
    }
    return kGMSLineChartViewDefaultLineColor;
}

- (UIColor *)lineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView selectedColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    if ([self.dataSource respondsToSelector:@selector(lineChartView:selectionColorForLineAtLineIndex:)])
    {
        return [self.dataSource lineChartView:self selectionColorForLineAtLineIndex:lineIndex];
    }
    return kGMSLineChartViewDefaultLineSelectionColor;
}

- (CGFloat)lineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    if ([self.dataSource respondsToSelector:@selector(lineChartView:widthForLineAtLineIndex:)])
    {
        return [self.dataSource lineChartView:self widthForLineAtLineIndex:lineIndex];
    }
    return kGMSLineChartLinesViewStrokeWidth;
}

- (CGFloat)paddingForLineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView
{
    return [self padding];
}

- (GMSLineChartViewLineStyle)lineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    if ([self.dataSource respondsToSelector:@selector(lineChartView:lineStyleForLineAtLineIndex:)])
    {
        return [self.dataSource lineChartView:self lineStyleForLineAtLineIndex:lineIndex];
    }
    return GMSLineChartViewLineStyleSolid;
}

- (BOOL)lineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView smoothLineAtLineIndex:(NSUInteger)lineIndex
{
    if ([self.dataSource respondsToSelector:@selector(lineChartView:smoothLineAtLineIndex:)])
    {
        return [self.dataSource lineChartView:self smoothLineAtLineIndex:lineIndex];
    }
    return NO;
}

#pragma mark - GMSLineChartDotsViewDelegate

- (NSArray *)chartDataForLineChartDotsView:(GMSLineChartDotsView*)lineChartDotsView
{
    return self.chartData;
}

- (UIColor *)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    if ([self.dataSource respondsToSelector:@selector(lineChartView:colorForLineAtLineIndex:)])
    {
        return [self.dataSource lineChartView:self colorForLineAtLineIndex:lineIndex];
    }
    return kGMSLineChartViewDefaultLineColor;
}

- (UIColor *)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    if ([self.dataSource respondsToSelector:@selector(lineChartView:colorForDotAtHorizontalIndex:atLineIndex:)])
    {
        return [self.dataSource lineChartView:self colorForDotAtHorizontalIndex:horizontalIndex atLineIndex:lineIndex];
    }
    return kGMSLineChartViewDefaultDotColor;
}

- (UIColor *)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView selectedColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    if ([self.dataSource respondsToSelector:@selector(lineChartView:selectionColorForLineAtLineIndex:)])
    {
        return [self.dataSource lineChartView:self selectionColorForLineAtLineIndex:lineIndex];
    }
    return kGMSLineChartViewDefaultLineSelectionColor;
}

- (UIColor *)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView selectedColorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    if ([self.dataSource respondsToSelector:@selector(lineChartView:selectionColorForDotAtHorizontalIndex:atLineIndex:)])
    {
        return [self.dataSource lineChartView:self selectionColorForDotAtHorizontalIndex:horizontalIndex atLineIndex:lineIndex];
    }
    return kGMSLineChartViewDefaultDotSelectionColor;
}

- (CGFloat)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    if ([self.dataSource respondsToSelector:@selector(lineChartView:widthForLineAtLineIndex:)])
    {
        return [self.dataSource lineChartView:self widthForLineAtLineIndex:lineIndex];
    }
    return kGMSLineChartLinesViewStrokeWidth;
}

- (CGFloat)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView dotRadiusForLineAtLineIndex:(NSUInteger)lineIndex
{
    if ([self.dataSource respondsToSelector:@selector(lineChartView:dotRadiusForLineAtLineIndex:)])
    {
        return [self.dataSource lineChartView:self dotRadiusForLineAtLineIndex:lineIndex];
    }
    else
    {
        return [self lineChartDotsView:lineChartDotsView widthForLineAtLineIndex:lineIndex] * kGMSLineChartDotsViewDefaultRadiusFactor;
    }
}

- (CGFloat)paddingForLineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView
{
    return [self padding];
}

- (BOOL)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    if ([self.dataSource respondsToSelector:@selector(lineChartView:showsDotsForLineAtLineIndex:)])
    {
        return [self.dataSource lineChartView:self showsDotsForLineAtLineIndex:lineIndex];
    }
    return NO;
}

#pragma mark - Setters

- (void)setState:(GMSChartViewState)state animated:(BOOL)animated callback:(void (^)())callback force:(BOOL)force
{
    [super setState:state animated:animated callback:callback force:force];
    
    if ([self.chartData count] > 0)
    {
        CGRect mainViewRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, [self availableHeight]);
        CGFloat yOffset = self.headerView.frame.size.height + self.headerPadding;
        
        dispatch_block_t adjustViewFrames = ^{
            self.linesView.frame = CGRectMake(self.linesView.frame.origin.x, yOffset + ((self.state == GMSChartViewStateCollapsed) ? (self.linesView.frame.size.height + self.footerView.frame.size.height) : 0.0), self.linesView.frame.size.width, self.linesView.frame.size.height);
            self.dotsView.frame = CGRectMake(self.dotsView.frame.origin.x, yOffset + ((self.state == GMSChartViewStateCollapsed) ? (self.dotsView.frame.size.height + self.footerView.frame.size.height) : 0.0), self.dotsView.frame.size.width, self.dotsView.frame.size.height);
        };
        
        dispatch_block_t adjustViewAlphas = ^{
            self.linesView.alpha = (self.state == GMSChartViewStateExpanded) ? 1.0 : 0.0;
            self.dotsView.alpha = (self.state == GMSChartViewStateExpanded) ? 1.0 : 0.0;
        };
        
        if (animated)
        {
            [UIView animateWithDuration:(kGMSLineChartViewStateAnimationDuration * 0.5) delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.linesView.frame = CGRectOffset(mainViewRect, 0, yOffset - kGMSLineChartViewStateBounceOffset); // bounce
                self.dotsView.frame = CGRectOffset(mainViewRect, 0, yOffset - kGMSLineChartViewStateBounceOffset);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:kGMSLineChartViewStateAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    adjustViewFrames();
                } completion:^(BOOL adjustFinished) {
                    if (callback)
                    {
                        callback();
                    }
                }];
            }];
            [UIView animateWithDuration:kGMSLineChartViewStateAnimationDuration delay:(self.state == GMSChartViewStateExpanded) ? kGMSLineChartViewStateAnimationDelay : 0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                adjustViewAlphas();
            } completion:nil];
        }
        else
        {
            adjustViewAlphas();
            adjustViewFrames();
            if (callback)
            {
                callback();
            }
        }
    }
    else
    {
        if (callback)
        {
            callback();
        }
    }
}

- (void)setState:(GMSChartViewState)state animated:(BOOL)animated callback:(void (^)())callback
{
    [self setState:state animated:animated callback:callback force:NO];
}

#pragma mark - Getters

- (CGFloat)cachedMinHeight
{
    if (_cachedMinHeight == kGMSBarChartViewUndefinedCachedHeight)
    {
        CGFloat minHeight = FLT_MAX;
        NSAssert([self.dataSource respondsToSelector:@selector(numberOfLinesInLineChartView:)], @"GMSLineChartView // dataSource must implement - (NSUInteger)numberOfLinesInLineChartView:(GMSLineChartView *)lineChartView");
        for (NSUInteger lineIndex=0; lineIndex<[self.dataSource numberOfLinesInLineChartView:self]; lineIndex++)
        {
            NSAssert([self.dataSource respondsToSelector:@selector(lineChartView:numberOfVerticalValuesAtLineIndex:)], @"GMSLineChartView // dataSource must implement - (NSUInteger)lineChartView:(GMSLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex");
            NSUInteger dataCount = [self.dataSource lineChartView:self numberOfVerticalValuesAtLineIndex:lineIndex];
            for (NSUInteger horizontalIndex=0; horizontalIndex<dataCount; horizontalIndex++)
            {
                NSAssert([self.delegate respondsToSelector:@selector(lineChartView:verticalValueForHorizontalIndex:atLineIndex:)], @"GMSLineChartView // delegate must implement - (CGFloat)lineChartView:(GMSLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex");
                CGFloat height = [self.delegate lineChartView:self verticalValueForHorizontalIndex:horizontalIndex atLineIndex:lineIndex];
                NSAssert(height >= 0, @"GMSLineChartView // delegate function - (CGFloat)lineChartView:(GMSLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex must return a CGFloat >= 0");
                if (height < minHeight)
                {
                    minHeight = height;
                }
            }
        }
        _cachedMinHeight = minHeight;
    }
    return _cachedMinHeight;
}

- (CGFloat)cachedMaxHeight
{
    if (_cachedMaxHeight == kGMSBarChartViewUndefinedCachedHeight)
    {
        CGFloat maxHeight = 0;
        NSAssert([self.dataSource respondsToSelector:@selector(numberOfLinesInLineChartView:)], @"GMSLineChartView // dataSource must implement - (NSUInteger)numberOfLinesInLineChartView:(GMSLineChartView *)lineChartView");
        for (NSUInteger lineIndex=0; lineIndex<[self.dataSource numberOfLinesInLineChartView:self]; lineIndex++)
        {
            NSAssert([self.dataSource respondsToSelector:@selector(lineChartView:numberOfVerticalValuesAtLineIndex:)], @"GMSLineChartView // dataSource must implement - (NSUInteger)lineChartView:(GMSLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex");
            NSUInteger dataCount = [self.dataSource lineChartView:self numberOfVerticalValuesAtLineIndex:lineIndex];
            for (NSUInteger horizontalIndex=0; horizontalIndex<dataCount; horizontalIndex++)
            {
                NSAssert([self.delegate respondsToSelector:@selector(lineChartView:verticalValueForHorizontalIndex:atLineIndex:)], @"GMSLineChartView // delegate must implement - (CGFloat)lineChartView:(GMSLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex");
                CGFloat height = [self.delegate lineChartView:self verticalValueForHorizontalIndex:horizontalIndex atLineIndex:lineIndex];
                NSAssert(height >= 0, @"GMSLineChartView // delegate function - (CGFloat)lineChartView:(GMSLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex must return a CGFloat >= 0");
                if (height > maxHeight)
                {
                    maxHeight = height;
                }
            }
        }
        _cachedMaxHeight = maxHeight;
    }
    return _cachedMaxHeight;
}

- (CGFloat)minimumValue
{
    if ([self hasMinimumValue])
    {
        return fminf(self.cachedMinHeight, [super minimumValue]);
    }
    return self.cachedMinHeight;
}

- (CGFloat)maximumValue
{
    if ([self hasMaximumValue])
    {
        return fmaxf(self.cachedMaxHeight, [super maximumValue]);
    }
    return self.cachedMaxHeight;
}

#pragma mark - Touch Helpers

- (CGPoint)clampPoint:(CGPoint)point toBounds:(CGRect)bounds padding:(CGFloat)padding
{
    return CGPointMake(MIN(MAX(bounds.origin.x + padding, point.x), bounds.size.width - padding),
                       MIN(MAX(bounds.origin.y + padding, point.y), bounds.size.height - padding));
}

- (NSInteger)horizontalIndexForPoint:(CGPoint)point indexClamp:(GMSLineChartHorizontalIndexClamp)indexClamp lineData:(NSArray *)lineData
{
    NSUInteger index = 0;
    CGFloat currentDistance = INT_MAX;
    NSInteger selectedIndex = kGMSLineChartUnselectedLineIndex;
    
    for (GMSLineChartPoint *lineChartPoint in lineData)
    {
        BOOL clamped = (indexClamp == GMSLineChartHorizontalIndexClampNone) ? YES : (indexClamp == GMSLineChartHorizontalIndexClampLeft) ? (point.x - lineChartPoint.position.x >= 0) : (point.x - lineChartPoint.position.x <= 0);
        if ((abs(point.x - lineChartPoint.position.x)) < currentDistance && clamped == YES)
        {
            currentDistance = (abs(point.x - lineChartPoint.position.x));
            selectedIndex = index;
        }
        index++;
    }
    
    return selectedIndex != kGMSLineChartUnselectedLineIndex ? selectedIndex : [lineData count] - 1;
}

- (NSInteger)horizontalIndexForPoint:(CGPoint)point indexClamp:(GMSLineChartHorizontalIndexClamp)indexClamp
{
    NSArray *largestLineData = nil;
    for (NSArray *lineData in self.chartData)
    {
        if ([lineData count] > [largestLineData count])
        {
            largestLineData = lineData;
        }
    }
    return [self horizontalIndexForPoint:point indexClamp:indexClamp lineData:largestLineData];
}

- (NSInteger)horizontalIndexForPoint:(CGPoint)point
{
    return [self horizontalIndexForPoint:point indexClamp:GMSLineChartHorizontalIndexClampNone];
}

- (NSInteger)lineIndexForPoint:(CGPoint)point
{
    // Find the horizontal indexes
    NSUInteger leftHorizontalIndex = [self horizontalIndexForPoint:point indexClamp:GMSLineChartHorizontalIndexClampLeft];
    NSUInteger rightHorizontalIndex = [self horizontalIndexForPoint:point indexClamp:GMSLineChartHorizontalIndexClampRight];
    
    // Padding
    CGFloat chartPadding = [self padding];
    
    NSUInteger shortestDistance = INT_MAX;
    NSInteger selectedIndex = kGMSLineChartUnselectedLineIndex;
    NSAssert([self.dataSource respondsToSelector:@selector(numberOfLinesInLineChartView:)], @"GMSLineChartView // dataSource must implement - (NSUInteger)numberOfLinesInLineChartView:(GMSLineChartView *)lineChartView");
    
    // Iterate all lines
    for (NSUInteger lineIndex=0; lineIndex<[self.dataSource numberOfLinesInLineChartView:self]; lineIndex++)
    {
        NSAssert([self.dataSource respondsToSelector:@selector(lineChartView:numberOfVerticalValuesAtLineIndex:)], @"GMSLineChartView // dataSource must implement - (NSUInteger)lineChartView:(GMSLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex");
        if ([self.dataSource lineChartView:self numberOfVerticalValuesAtLineIndex:lineIndex] > rightHorizontalIndex)
        {
            NSArray *lineData = [self.chartData objectAtIndex:lineIndex];

            // Left point
            GMSLineChartPoint *leftLineChartPoint = [lineData objectAtIndex:leftHorizontalIndex];
            CGPoint leftPoint = CGPointMake(leftLineChartPoint.position.x, fmin(fmax(chartPadding, self.linesView.bounds.size.height - leftLineChartPoint.position.y), self.linesView.bounds.size.height - chartPadding));
            
            // Right point
            GMSLineChartPoint *rightLineChartPoint = [lineData objectAtIndex:rightHorizontalIndex];
            CGPoint rightPoint = CGPointMake(rightLineChartPoint.position.x, fmin(fmax(chartPadding, self.linesView.bounds.size.height - rightLineChartPoint.position.y), self.linesView.bounds.size.height - chartPadding));
            
            // Touch point
            CGPoint normalizedTouchPoint = CGPointMake(point.x, self.linesView.bounds.size.height - point.y);

            // Slope
            CGFloat lineSlope = (CGFloat)(rightPoint.y - leftPoint.y) / (CGFloat)(rightPoint.x - leftPoint.x);

            // Insersection point
            CGPoint interesectionPoint = CGPointMake(normalizedTouchPoint.x, (lineSlope * (normalizedTouchPoint.x - leftPoint.x)) + leftPoint.y);

            CGFloat currentDistance = abs(interesectionPoint.y - normalizedTouchPoint.y);
            if (currentDistance < shortestDistance)
            {
                shortestDistance = currentDistance;
                selectedIndex = lineIndex;
            }
        }
    }
    return selectedIndex;
}

- (void)touchesBeganOrMovedWithTouches:(NSSet *)touches
{
    if (self.state == GMSChartViewStateCollapsed || [self.chartData count] <= 0)
    {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [self clampPoint:[touch locationInView:self.linesView] toBounds:self.linesView.bounds padding:[self padding]];

    if ([self.delegate respondsToSelector:@selector(lineChartView:didSelectLineAtIndex:horizontalIndex:touchPoint:)])
    {
        NSUInteger lineIndex = self.linesView.selectedLineIndex != kGMSLineChartLinesViewUnselectedLineIndex ? self.linesView.selectedLineIndex : [self lineIndexForPoint:touchPoint];
        NSUInteger horizontalIndex = [self horizontalIndexForPoint:touchPoint indexClamp:GMSLineChartHorizontalIndexClampNone lineData:[self.chartData objectAtIndex:lineIndex]];
        [self.delegate lineChartView:self didSelectLineAtIndex:lineIndex horizontalIndex:horizontalIndex touchPoint:[touch locationInView:self]];
    }
    
    if ([self.delegate respondsToSelector:@selector(lineChartView:didSelectLineAtIndex:horizontalIndex:)])
    {
        NSUInteger lineIndex = self.linesView.selectedLineIndex != kGMSLineChartLinesViewUnselectedLineIndex ? self.linesView.selectedLineIndex : [self lineIndexForPoint:touchPoint];
        [self.delegate lineChartView:self didSelectLineAtIndex:lineIndex horizontalIndex:[self horizontalIndexForPoint:touchPoint indexClamp:GMSLineChartHorizontalIndexClampNone lineData:[self.chartData objectAtIndex:lineIndex]]];
    }
    
    CGFloat xOffset = fmin(self.bounds.size.width - self.verticalSelectionView.frame.size.width, fmax(0, touchPoint.x - (ceil(self.verticalSelectionView.frame.size.width * 0.5))));
    self.verticalSelectionView.frame = CGRectMake(xOffset, self.verticalSelectionView.frame.origin.y, self.verticalSelectionView.frame.size.width, self.verticalSelectionView.frame.size.height);
    [self setVerticalSelectionViewVisible:YES animated:YES];
}

- (void)touchesEndedOrCancelledWithTouches:(NSSet *)touches
{
    if (self.state == GMSChartViewStateCollapsed || [self.chartData count] <= 0)
    {
        return;
    }

    [self setVerticalSelectionViewVisible:NO animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(didUnselectLineInLineChartView:)])
    {
        [self.delegate didUnselectLineInLineChartView:self];
    }
    
    if (self.showsLineSelection)
    {
        [self.linesView setSelectedLineIndex:kGMSLineChartLinesViewUnselectedLineIndex animated:YES];
        [self.dotsView setSelectedLineIndex:kGMSLineChartDotsViewUnselectedLineIndex animated:YES];
    }
}

#pragma mark - Setters

- (void)setVerticalSelectionViewVisible:(BOOL)verticalSelectionViewVisible animated:(BOOL)animated
{
    _verticalSelectionViewVisible = verticalSelectionViewVisible;

    [self bringSubviewToFront:self.verticalSelectionView];

    if (animated)
    {
        [UIView animateWithDuration:kGMSChartViewDefaultAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.verticalSelectionView.alpha = self.verticalSelectionViewVisible ? 1.0 : 0.0;
        } completion:nil];
    }
    else
    {
        self.verticalSelectionView.alpha = _verticalSelectionViewVisible ? 1.0 : 0.0;
    }
}

- (void)setVerticalSelectionViewVisible:(BOOL)verticalSelectionViewVisible
{
    [self setVerticalSelectionViewVisible:verticalSelectionViewVisible animated:NO];
}

- (void)setShowsVerticalSelection:(BOOL)showsVerticalSelection
{
    _showsVerticalSelection = showsVerticalSelection;
    self.verticalSelectionView.hidden = _showsVerticalSelection ? NO : YES;
}

#pragma mark - Gestures

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [self clampPoint:[touch locationInView:self.linesView] toBounds:self.linesView.bounds padding:[self padding]];
    if (self.showsLineSelection)
    {
        [self.linesView setSelectedLineIndex:[self lineIndexForPoint:touchPoint] animated:YES];
        [self.dotsView setSelectedLineIndex:[self lineIndexForPoint:touchPoint] animated:YES];
    }
    [self touchesBeganOrMovedWithTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesBeganOrMovedWithTouches:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEndedOrCancelledWithTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEndedOrCancelledWithTouches:touches];
}

@end

@implementation GMSLineLayer

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [GMSLineLayer class])
	{
		kGMSLineChartLineViewDefaultDashPattern = @[@(3), @(2)];
	}
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.zPosition = 0.0f;
        self.fillColor = [UIColor clearColor].CGColor;
    }
    return self;
}

#pragma mark - Setters

- (void)setLineStyle:(GMSLineChartViewLineStyle)lineStyle
{
    _lineStyle = lineStyle;
    
    if (_lineStyle == GMSLineChartViewLineStyleDashed)
    {
        self.lineDashPhase = kGMSLineChartLinesViewDefaultLinePhase;
        self.lineDashPattern = kGMSLineChartLineViewDefaultDashPattern;
    }
    else if (_lineStyle == GMSLineChartViewLineStyleSolid)
    {
        self.lineDashPhase = 0.0;
        self.lineDashPattern = nil;
    }
}

@end

@implementation GMSLineChartPoint

#pragma mark - Alloc/Init

- (id)init
{
    self = [super init];
    if (self)
    {
        _position = CGPointZero;
    }
    return self;
}

#pragma mark - Compare

- (NSComparisonResult)compare:(GMSLineChartPoint *)otherObject
{
    return self.position.x > otherObject.position.x;
}

@end

@implementation GMSLineChartLinesView

#pragma mark - Alloc/Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Memory Management

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    NSAssert([self.delegate respondsToSelector:@selector(chartDataForLineChartLinesView:)], @"GMSLineChartLinesView // delegate must implement - (NSArray *)chartDataForLineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView");
    NSArray *chartData = [self.delegate chartDataForLineChartLinesView:self];

    NSAssert([self.delegate respondsToSelector:@selector(paddingForLineChartLinesView:)], @"GMSLineChartLinesView // delegate must implement - (CGFloat)paddingForLineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView");
    CGFloat padding = [self.delegate paddingForLineChartLinesView:self];
    
    NSUInteger lineIndex = 0;
    for (NSArray *lineData in chartData)
    {
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.miterLimit = kGMSLineChartLinesViewMiterLimit;
        
        GMSLineChartPoint *previousLineChartPoint = nil;
        CGFloat previousSlope = 0.0f;
        
        NSAssert([self.delegate respondsToSelector:@selector(lineChartLinesView:smoothLineAtLineIndex:)], @"GMSLineChartLinesView // delegate must implement - (BOOL)lineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView smoothLineAtLineIndex:(NSUInteger)lineIndex");
        BOOL smoothLine = [self.delegate lineChartLinesView:self smoothLineAtLineIndex:lineIndex];
        
        NSUInteger index = 0;
        NSArray *sortedLineData = [lineData sortedArrayUsingSelector:@selector(compare:)];
        for (GMSLineChartPoint *lineChartPoint in sortedLineData)
        {
            if (index == 0)
            {
                [path moveToPoint:CGPointMake(lineChartPoint.position.x, fmin(self.bounds.size.height - padding, fmax(padding, lineChartPoint.position.y)))];
            }
            else
            {
                GMSLineChartPoint *nextLineChartPoint = nil;
                if (index != ([lineData count] - 1))
                {
                    nextLineChartPoint = [sortedLineData objectAtIndex:(index + 1)];
                }
                
                CGFloat nextSlope = (nextLineChartPoint != nil) ? ((nextLineChartPoint.position.y - lineChartPoint.position.y)) / ((nextLineChartPoint.position.x - lineChartPoint.position.x)) : previousSlope;
                CGFloat currentSlope = ((lineChartPoint.position.y - previousLineChartPoint.position.y)) / (lineChartPoint.position.x-previousLineChartPoint.position.x);
                
                BOOL deltaFromNextSlope = ((currentSlope >= (nextSlope + kGMSLineChartLinesViewSmoothThresholdSlope)) || (currentSlope <= (nextSlope - kGMSLineChartLinesViewSmoothThresholdSlope)));
                BOOL deltaFromPreviousSlope = ((currentSlope >= (previousSlope + kGMSLineChartLinesViewSmoothThresholdSlope)) || (currentSlope <= (previousSlope - kGMSLineChartLinesViewSmoothThresholdSlope)));
                BOOL deltaFromPreviousY = (lineChartPoint.position.y >= previousLineChartPoint.position.y + kGMSLineChartLinesViewSmoothThresholdVertical) || (lineChartPoint.position.y <= previousLineChartPoint.position.y - kGMSLineChartLinesViewSmoothThresholdVertical);
                
                if (smoothLine && deltaFromNextSlope && deltaFromPreviousSlope && deltaFromPreviousY)
                {
                    CGFloat deltaX = lineChartPoint.position.x - previousLineChartPoint.position.x;
                    CGFloat controlPointX = previousLineChartPoint.position.x + (deltaX / 2);
                    
                    CGPoint controlPoint1 = CGPointMake(controlPointX, previousLineChartPoint.position.y);
                    CGPoint controlPoint2 = CGPointMake(controlPointX, lineChartPoint.position.y);
                    
                    [path addCurveToPoint:CGPointMake(lineChartPoint.position.x, fmin(self.bounds.size.height - padding, fmax(padding, lineChartPoint.position.y))) controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                }
                else
                {
                    [path addLineToPoint:CGPointMake(lineChartPoint.position.x, fmin(self.bounds.size.height - padding, fmax(padding, lineChartPoint.position.y)))];
                }
                
                previousSlope = currentSlope;
            }
            previousLineChartPoint = lineChartPoint;
            index++;
        }
        
        GMSLineLayer *shapeLayer = [self lineLayerForLineIndex:lineIndex];
        if (shapeLayer == nil)
        {
            shapeLayer = [GMSLineLayer layer];
        }
        
        shapeLayer.tag = lineIndex;
        NSAssert([self.delegate respondsToSelector:@selector(lineChartLinesView:lineStyleForLineAtLineIndex:)], @"GMSLineChartLinesView // delegate must implement - (GMSLineChartViewLineStyle)lineChartLineView:(GMSLineChartLinesView *)lineChartLinesView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex");
        shapeLayer.lineStyle = [self.delegate lineChartLinesView:self lineStyleForLineAtLineIndex:lineIndex];
        
        NSAssert([self.delegate respondsToSelector:@selector(lineChartLinesView:colorForLineAtLineIndex:)], @"GMSLineChartLinesView // delegate must implement - (UIColor *)lineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView colorForLineAtLineIndex:(NSUInteger)lineIndex");
        shapeLayer.strokeColor = [self.delegate lineChartLinesView:self colorForLineAtLineIndex:lineIndex].CGColor;
        
        if (smoothLine == YES)
        {
            shapeLayer.lineCap = kCALineCapRound;
            shapeLayer.lineJoin = kCALineJoinRound;
        }
        else
        {
            shapeLayer.lineCap = kCALineCapButt;
            shapeLayer.lineJoin = kCALineJoinMiter;
        }
        
        NSAssert([self.delegate respondsToSelector:@selector(lineChartLinesView:widthForLineAtLineIndex:)], @"GMSLineChartLinesView // delegate must implement - (CGFloat)lineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView widthForLineAtLineIndex:(NSUInteger)lineIndex");
        shapeLayer.lineWidth = [self.delegate lineChartLinesView:self widthForLineAtLineIndex:lineIndex];
        shapeLayer.path = path.CGPath;
        shapeLayer.frame = self.bounds;
        [self.layer addSublayer:shapeLayer];

        lineIndex++;
    }

    self.animated = NO;
}

#pragma mark - Data

- (void)reloadData
{
    // Drawing is all done with CG (no subviews here)
    [self setNeedsDisplay];
}

#pragma mark - Setters

- (void)setSelectedLineIndex:(NSInteger)selectedLineIndex animated:(BOOL)animated
{
    _selectedLineIndex = selectedLineIndex;
    
    __weak GMSLineChartLinesView* weakSelf = self;
    
    dispatch_block_t adjustLines = ^{
        for (CALayer *layer in [weakSelf.layer sublayers])
        {
            if ([layer isKindOfClass:[GMSLineLayer class]])
            {
                if (((NSInteger)((GMSLineLayer *)layer).tag) == weakSelf.selectedLineIndex)
                {
                    NSAssert([self.delegate respondsToSelector:@selector(lineChartLinesView:selectedColorForLineAtLineIndex:)], @"GMSLineChartLinesView // delegate must implement - (UIColor *)lineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView selectedColorForLineAtLineIndex:(NSUInteger)lineIndex");
                    ((GMSLineLayer *)layer).strokeColor = [self.delegate lineChartLinesView:self selectedColorForLineAtLineIndex:((GMSLineLayer *)layer).tag].CGColor;
                    ((GMSLineLayer *)layer).opacity = 1.0f;
                }
                else
                {
                    NSAssert([self.delegate respondsToSelector:@selector(lineChartLinesView:colorForLineAtLineIndex:)], @"GMSLineChartLinesView // delegate must implement - (UIColor *)lineChartLinesView:(GMSLineChartLinesView *)lineChartLinesView colorForLineAtLineIndex:(NSUInteger)lineIndex");
                    ((GMSLineLayer *)layer).strokeColor = [self.delegate lineChartLinesView:self colorForLineAtLineIndex:((GMSLineLayer *)layer).tag].CGColor;
                    ((GMSLineLayer *)layer).opacity = (weakSelf.selectedLineIndex == kGMSLineChartLinesViewUnselectedLineIndex) ? 1.0f : kGMSLineChartLinesViewDefaultDimmedOpacity;
                }
            }
        }
    };

    if (animated)
    {
        [UIView animateWithDuration:kGMSChartViewDefaultAnimationDuration animations:^{
            adjustLines();
        }];
    }
    else
    {
        adjustLines();
    }
}

- (void)setSelectedLineIndex:(NSInteger)selectedLineIndex
{
    [self setSelectedLineIndex:selectedLineIndex animated:NO];
}

#pragma mark - Callback Helpers

- (void)fireCallback:(void (^)())callback
{
    dispatch_block_t callbackCopy = [callback copy];

    if (callbackCopy != nil)
    {
        callbackCopy();
    }
}

- (GMSLineLayer *)lineLayerForLineIndex:(NSUInteger)lineIndex
{
    for (CALayer *layer in [self.layer sublayers])
    {
        if ([layer isKindOfClass:[GMSLineLayer class]])
        {
            if (((GMSLineLayer *)layer).tag == lineIndex)
            {
                return (GMSLineLayer *)layer;
            }
        }
    }
    return nil;
}

@end

@implementation GMSLineChartDotsView

#pragma mark - Alloc/Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Data

- (void)reloadData
{
    for (NSArray *dotViews in [self.dotViewsDict allValues])
    {
        for (GMSLineChartDotView *dotView in dotViews)
        {
            [dotView removeFromSuperview];
        }
    }
    
    NSAssert([self.delegate respondsToSelector:@selector(chartDataForLineChartDotsView:)], @"GMSLineChartDotsView // delegate must implement - (NSArray *)chartDataForLineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView");
    NSArray *chartData = [self.delegate chartDataForLineChartDotsView:self];

    NSAssert([self.delegate respondsToSelector:@selector(paddingForLineChartDotsView:)], @"GMSLineChartDotsView // delegate must implement - (CGFloat)paddingForLineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView");
    CGFloat padding = [self.delegate paddingForLineChartDotsView:self];
    
    NSUInteger lineIndex = 0;
    NSMutableDictionary *mutableDotViewsDict = [NSMutableDictionary dictionary];
    for (NSArray *lineData in chartData)
    {
        NSAssert([self.delegate respondsToSelector:@selector(lineChartDotsView:showsDotsForLineAtLineIndex:)], @"GMSLineChartDotsView // delegate must implement - (BOOL)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex");
        
        if ([self.delegate lineChartDotsView:self showsDotsForLineAtLineIndex:lineIndex]) // line at index contains dots
        {
            NSMutableArray *mutableDotViews = [NSMutableArray array];
            NSUInteger horizontalIndex = 0;
            for (GMSLineChartPoint *lineChartPoint in [lineData sortedArrayUsingSelector:@selector(compare:)])
            {                               
                NSAssert([self.delegate respondsToSelector:@selector(lineChartDotsView:dotRadiusForLineAtLineIndex:)], @"GMSLineChartDotsView // delegate must implement - (CGFloat)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView dotRadiusForLineAtLineIndex:(NSUInteger)lineIndex");
                CGFloat dotRadius = [self.delegate lineChartDotsView:self dotRadiusForLineAtLineIndex:lineIndex];
                
                GMSLineChartDotView *dotView = [[GMSLineChartDotView alloc] initWithRadius:dotRadius];
                dotView.center = CGPointMake(lineChartPoint.position.x, fmin(self.bounds.size.height - padding, fmax(padding, lineChartPoint.position.y)));
                
                NSAssert([self.delegate respondsToSelector:@selector(lineChartDotsView:colorForDotAtHorizontalIndex:atLineIndex:)], @"GMSLineChartDotsView // delegate must implement - (UIColor *)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex");
                dotView.backgroundColor = [self.delegate lineChartDotsView:self colorForDotAtHorizontalIndex:horizontalIndex atLineIndex:lineIndex];
                
                [mutableDotViews addObject:dotView];
                [self addSubview:dotView];
                
                horizontalIndex++;
            }
            [mutableDotViewsDict setObject:[NSArray arrayWithArray:mutableDotViews] forKey:[NSNumber numberWithInteger:lineIndex]];
        }
        lineIndex++;
    }
    self.dotViewsDict = [NSDictionary dictionaryWithDictionary:mutableDotViewsDict];
}

#pragma mark - Setters

- (void)setSelectedLineIndex:(NSInteger)selectedLineIndex animated:(BOOL)animated
{
    _selectedLineIndex = selectedLineIndex;
    
    __weak GMSLineChartDotsView* weakSelf = self;
    
    dispatch_block_t adjustDots = ^{
        [weakSelf.dotViewsDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSUInteger horizontalIndex = 0;
            for (GMSLineChartDotView *dotView in (NSArray *)obj)
            {
                if ([key isKindOfClass:[NSNumber class]])
                {
                    NSInteger lineIndex = [((NSNumber *)key) intValue];

                    if (weakSelf.selectedLineIndex == lineIndex)
                    {
                        NSAssert([self.delegate respondsToSelector:@selector(lineChartDotsView:selectedColorForDotAtHorizontalIndex:atLineIndex:)], @"GMSLineChartDotsView // delegate must implement - (UIColor *)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView selectedColorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex");
                        dotView.backgroundColor = [self.delegate lineChartDotsView:self selectedColorForDotAtHorizontalIndex:horizontalIndex atLineIndex:lineIndex];
                    }
                    else
                    {
                        NSAssert([self.delegate respondsToSelector:@selector(lineChartDotsView:colorForDotAtHorizontalIndex:atLineIndex:)], @"GMSLineChartDotsView // delegate must implement - (UIColor *)lineChartDotsView:(GMSLineChartDotsView *)lineChartDotsView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex");
                        dotView.backgroundColor = [self.delegate lineChartDotsView:self colorForDotAtHorizontalIndex:horizontalIndex atLineIndex:lineIndex];
                        dotView.alpha = (weakSelf.selectedLineIndex == kGMSLineChartDotsViewUnselectedLineIndex) ? 1.0f : 0.0f; // hide dots on off-selection
                    }
                }
                horizontalIndex++;
            }
        }];
    };
    
    if (animated)
    {
        [UIView animateWithDuration:kGMSChartViewDefaultAnimationDuration animations:^{
            adjustDots();
        }];
    }
    else
    {
        adjustDots();
    }
}

- (void)setSelectedLineIndex:(NSInteger)selectedLineIndex
{
    [self setSelectedLineIndex:selectedLineIndex animated:NO];
}

@end

@implementation GMSLineChartDotView

#pragma mark - Alloc/Init

- (id)initWithRadius:(CGFloat)radius
{
    self = [super initWithFrame:CGRectMake(0, 0, radius, radius)];
    if (self)
    {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = (radius * 0.5);
    }
    return self;
}

@end
