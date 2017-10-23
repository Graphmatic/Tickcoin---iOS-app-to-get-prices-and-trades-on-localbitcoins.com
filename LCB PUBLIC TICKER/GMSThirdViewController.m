//
//  GMSSecondViewController.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "GMSThirdViewController.h"
#import "GMSSecondViewTableData.h"

@interface GMSThirdViewController ()
{
    NSMutableArray *ordersAsks;
    float maxDeviation;
    BOOL alt;
    BOOL settingOn;
    NSString *lastRecordDate;
    int messagesCount;
    BOOL doubleTapLabel;
    BOOL graphs;
    UIButton *done;
}
@end

@implementation GMSThirdViewController

@synthesize timerMessages, editMaxDev, settingSquare, secondViewDatas, sliderVal, sliderValName, thirdViewMessage, messageBox, headerView, headerTitleLeft, firstViewC, adBannerForiPhone5;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [self.view setBackgroundColor:GMSColorOrange];
    if ( (!UI_USER_INTERFACE_IDIOM()) == UIUserInterfaceIdiomPad )
    {
        [self.tableView setBackgroundColor:GMSColorBlue];
        settingOn = NO;
        //init swipe right that show maxDeviation slider
        UISwipeGestureRecognizer *displaySettings = [[UISwipeGestureRecognizer alloc]initWithTarget:self
                                                                                             action:@selector(displayMaxDeviationSlider:)];
        displaySettings.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:displaySettings];
    }
    else
    {
        [self.tableView setBackgroundColor:[UIColor blackColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateTickerThirdView:)
                                                     name:@"changeNow"
                                                   object:nil];
        self.sliderVal.hidden =YES;
        settingOn = YES;
        [self showOverlaySetting];
    }
    

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    messagesCount = 0;
    graphs = NO;
    //add messageBox
    self.messageBox = [GMSMessageBox messageBox:46.0];
    [self.view addSubview:self.messageBox];
    //load message for messageBox
    self.messageBoxMessage = [[GMSMessageBoxProcessor alloc]init];
    [self.messageBox addSubview:self.thirdViewMessage];
    self.thirdViewMessage.text = self.messageBoxMessage.messageBoxString;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDatas:) name:@"changeAsksNow" object:nil];
    if(firstLaunchAsks)
    {
        self->maxDeviation = 30;
        self.sliderVal.text = [NSString stringWithFormat:@"%d%%",(int)self->maxDeviation];
        self.editMaxDev.value = (int)self->maxDeviation;
        self.sliderValName.text = [NSString stringWithFormat:NSLocalizedString(@"_SLIDER_DEVIATION_NAME_IPAD", @"max diff from 24H average: %@"), self.sliderVal.text];
        self.secondViewDatas = [GMSSecondViewTableData sharedSecondViewTableData:firstLaunchAsks currency:nil];
        [self.tableView reloadData];
    }
    else
    {
        self->maxDeviation = [[[NSUserDefaults standardUserDefaults]objectForKey:@"maxDeviationBids"]floatValue];
        self.editMaxDev.value = (int)self->maxDeviation;
        self.sliderVal.text = [NSString stringWithFormat:@"%d%%",(int)self->maxDeviation];
        self.sliderValName.text = [NSString stringWithFormat:NSLocalizedString(@"_SLIDER_DEVIATION_NAME_IPAD", @"max diff from 24H average: %@"), self.sliderVal.text];
        self.secondViewDatas = [GMSSecondViewTableData sharedSecondViewTableData:firstLaunchAsks currency:currentCurrency];
    }
    //add header
    self.headerImg = [GMSTopBrandImage topImage:2];
    [self.view addSubview:self.headerImg];
    //add double tap to reassort tableView ascending/descending
    UITapGestureRecognizer *tapToChangeOrder = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToChangeArrOrder:)];
    [self.tableView addGestureRecognizer:tapToChangeOrder];
    tapToChangeOrder.numberOfTapsRequired=2;
    //constraints
    [NSLayoutConstraint constraintWithItem:self.thirdViewMessage attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual toItem:self.messageBox
                                 attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:+0.0];
    [NSLayoutConstraint constraintWithItem:self.thirdViewMessage attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual toItem:self.messageBox
                                 attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:+0.0];
        //tableview header
    CGRect frameHeader = CGRectMake(0, (self.thirdViewMessage.frame.origin.y + self.thirdViewMessage.frame.size.height + 1), self.view.bounds.size.width, 30);
    self.headerView.frame = frameHeader;
    [self.headerView setBackgroundColor:[UIColor whiteColor]];
    CGRect frameHeaderL = CGRectMake(0, 0, self.tableView.bounds.size.width, 30);
    CGRect frameHeaderR = frameHeaderL;
    frameHeaderL.origin.x = 5;
    frameHeaderL.size.width = self.tableView.bounds.size.width - frameHeaderL.origin.x;
    frameHeaderR.origin.x = -5;
    frameHeaderR.size.width = self.tableView.bounds.size.width - frameHeaderL.origin.x;
    self.headerTitleLeft = [[UILabel alloc] initWithFrame:frameHeaderL];
    [self.headerTitleLeft setFont:[UIFont fontWithName:@"Avenir-BookOblique" size:14]];
    self.headerTitleLeft.textAlignment = NSTextAlignmentLeft;
    self.headerTitleLeft.text = [NSString stringWithFormat:NSLocalizedString(@"_ASK_BID_TITLE_LEFT", @"Price-currency-maxvolume"), currentCurrency];
    UILabel *headerTitleRight = [[UILabel alloc] initWithFrame:frameHeaderR];
    [headerTitleRight setFont:[UIFont fontWithName:@"Avenir-BookOblique" size:14]];
    headerTitleRight.textAlignment = NSTextAlignmentRight;
    headerTitleRight.text = [NSString stringWithFormat:NSLocalizedString(@"_ASK_BID_TITLE_RIGHT", @"Price-currency-maxvolume"), currentCurrency];
    //neat to prev. el
    if ( (!UI_USER_INTERFACE_IDIOM()) == UIUserInterfaceIdiomPad )
    {
    [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual toItem:self.messageBox
                                 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:+1.0];
    }
    [self.view addSubview:self.headerView];
    [self.headerView addSubview:self.headerTitleLeft];
   [self.headerView addSubview:headerTitleRight];
  
    self.thirdViewMessage.text = [NSString stringWithFormat:NSLocalizedString(@"_BUY_ADD_FOR_CUR_x", @"BIDS - %@"), currentCurrency];
    if (!test)
    {
         [self updateTickerThirdView:nil];
    }
  
    //  [self.graphView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.thirdViewMessage.text = [NSString stringWithFormat:NSLocalizedString(@"_BUY_ADD_FOR_CUR_x", @"BIDS - %@"), currentCurrency];
    if ([self.secondViewDatas.orderAsksAllCurrency objectForKey:currentCurrency] == nil)
    {
        [self updateTickerThirdView:nil];
    }
    else
    {
        dispatch_queue_t parserQu = dispatch_queue_create("parserQ", NULL);
        dispatch_async(parserQu, ^{
            [self.secondViewDatas update:self->maxDeviation type:@"asks"];
        });
    }
   self.headerTitleLeft.text = [NSString stringWithFormat:NSLocalizedString(@"_ASK_BID_TITLE_LEFT", @"Price-currency-maxvolume"), currentCurrency];
    [self.editMaxDev addTarget:self
                  action:@selector(closeSettingView:)
        forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
}
//tableView
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tableHeaderBG=[[UIView alloc]initWithFrame:CGRectMake(0,0,320,3)];
    tableHeaderBG.backgroundColor =  GMSColorOrange;
    return tableHeaderBG;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.secondViewDatas.orderAsks count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *cellVal;
    NSString *key = [[self.secondViewDatas.orderAsks objectAtIndex:indexPath.row]objectAtIndex:0];
    static NSString *CellIdentifier = @"Item2";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_background_sel.png"]];
     if ( (!UI_USER_INTERFACE_IDIOM()) == UIUserInterfaceIdiomPad )
    {
    cell.backgroundColor = GMSColorBlue;
    }
    cell.textLabel.text = key;
    cellVal = [[self.secondViewDatas.orderAsks objectAtIndex:indexPath.row]objectAtIndex:1];
    if(cellVal != NULL)
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", cellVal];
    }
    else
    {
        cell.detailTextLabel.text = [NSString stringWithFormat: NSLocalizedString(@"_NO_DATAS", @"no data")];
    }
    return cell;
}



- (void)updateTickerThirdView:(NSNotification *)notification
{
    if (!test)
    {
    //SEND REQUEST
    self.thirdViewMessage.text = [NSMutableString stringWithFormat:NSLocalizedString(@"_WAIT_FOR_DATAS", @"please wait - update...")];

    NSString *fullURL = [GMSUtilitiesFunction orderBookUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:fullURL]];
    AFHTTPRequestOperation *operationOrdersBook = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operationOrdersBook.responseSerializer = [AFJSONResponseSerializer serializer];
    [operationOrdersBook setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operationOrdersBook, id responseObjectOB)
     {
         dispatch_queue_t parserQuThree = dispatch_queue_create("parserQuThree", NULL);
         dispatch_async(parserQuThree, ^{
             [self.secondViewDatas updateFromWeb:self->maxDeviation json:responseObjectOB type:@"asks"];
         });

         if(timerMessages)[timerMessages invalidate];
         timerMessages = nil;
         connected = YES;
         if (firstLaunchAsks)
         {
           [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"firstLaunchAsks"];
         }
         self.timerMessages = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerStartMulti:) userInfo:nil repeats:YES];
     }
    failure:^(AFHTTPRequestOperation *operationOrdersBook, NSError *error) {
                                                   NSLog(@"%@", error.localizedDescription);
        connected = NO;
        if(self.timerMessages)[self.timerMessages invalidate];
        self.timerMessages = nil;
        self.timerMessages = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerStartNoConnect:) userInfo:error repeats:YES];
                                                   
                                               }];
    [operationOrdersBook start];
    }
}
- (void)prepareDatas:(NSNotification *)notification
{
   
    if ([self.secondViewDatas.orderAsks count] == 0) {
        if(self.timerMessages)[self.timerMessages invalidate];
        self.timerMessages = nil;
        self.thirdViewMessage.text = [NSString stringWithFormat:NSLocalizedString(@"_EDIT_FILTER_NULL", @"no order in this range, please edit display filter")];
    }
    else
    {
        if(self.timerMessages)[self.timerMessages invalidate];
        self.timerMessages = nil;
        self.timerMessages = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerStartMulti:) userInfo:nil repeats:YES];
    }
     [self.tableView reloadData];
}

// no internet connection warning
-(void)timerStartNoConnect:(NSTimer *)theTimer
{
    alt = !alt;
    NSError *err = [theTimer userInfo];
    [self.messageBoxMessage noConnAlert:err alt:alt];
}
//message box

-(void)timerStartMulti:(NSTimer*)theTimer
{
    if(messagesCount == 4){messagesCount = 0;}
    NSArray *callBack = [self.messageBoxMessage asksViewMessages:messagesCount connected:connected maxDeviation:self->maxDeviation doubleTap:doubleTapLabel];
    messagesCount = [[callBack objectAtIndex:0]intValue];
    self.thirdViewMessage.text = [callBack objectAtIndex:1];
}

//double tap to change order
-(void) tapToChangeArrOrder:(UIGestureRecognizer*) recognizer {
    if(self.timerMessages)[self.timerMessages invalidate];
    self.timerMessages = nil;
    self.thirdViewMessage.text = nil;
    NSArray* reverseOrder = [[self.secondViewDatas.orderAsks reverseObjectEnumerator] allObjects];
    self.secondViewDatas.orderAsks = (NSMutableArray*)reverseOrder;
    if(doubleTapLabel == YES)
    {
        doubleTapLabel = NO;
    }
    else{
        doubleTapLabel = YES;
    }
    [self prepareDatas:nil];
}
-(void) displayMaxDeviationSlider:(UIGestureRecognizer*) recognizer
{
    if (settingOn == NO)
    {
        [self showOverlaySetting];
    }
}
-(void)showOverlaySetting
{
     if ( (!UI_USER_INTERFACE_IDIOM()) == UIUserInterfaceIdiomPad )
    {
    settingOn = YES;
    [self.settingSquare setBackgroundColor:[UIColor blackColor]];
    self.settingSquare.alpha = 0.8;
    }
    else
    {
    [self.settingSquare setBackgroundColor:[UIColor whiteColor]];
    }
    self.settingSquare.layer.borderColor = [UIColor whiteColor].CGColor;
    self.settingSquare.layer.borderWidth = 0.7f;
    
    self.settingSquare.hidden = YES;
    self.editMaxDev = [[UISlider alloc]init];
    CGRect posSlider = editMaxDev.frame;
     if ( (!UI_USER_INTERFACE_IDIOM()) == UIUserInterfaceIdiomPad )
    {
        posSlider.size.width = 270;
        posSlider.origin.y=21;
        posSlider.origin.x= 8;
    }
    else
    {
        posSlider.size.width = 230;
        posSlider.origin.y=21;
        posSlider.origin.x= 10;
    }
    self.editMaxDev.frame= posSlider;
    self.editMaxDev.thumbTintColor = [UIColor whiteColor];
    self.editMaxDev.minimumValue = 1;
    self.editMaxDev.maximumValue = 201;
    self.editMaxDev.value = (int)self->maxDeviation;
    self.editMaxDev.continuous = YES;
     if ( (!UI_USER_INTERFACE_IDIOM()) == UIUserInterfaceIdiomPad )
    {
    self.editMaxDev.minimumTrackTintColor = [UIColor whiteColor];
    }
    else
    {
        self.editMaxDev.minimumTrackTintColor = [UIColor darkGrayColor];
    }
    [self.editMaxDev addTarget:self
                        action:@selector(sliderMoving:)
              forControlEvents:UIControlEventValueChanged];
    
    [self.editMaxDev addTarget:self
                        action:@selector(sliderMovingUpdateLabel:)
              forControlEvents:UIControlEventValueChanged];
    //label
    if (self->maxDeviation == 201) {
        self.sliderVal.text = [NSString stringWithFormat:@"ALL"];
    }
    else
    {
        self.sliderVal.text = [NSString stringWithFormat:@"%d%%",(int)self->maxDeviation];
    }
   
    self.sliderValName.text = [NSString stringWithFormat:NSLocalizedString(@"_SLIDER_DEVIATION_NAME_IPAD", @"max diff from 24H average: %@"), self.sliderVal.text];
     if ( (!UI_USER_INTERFACE_IDIOM()) == UIUserInterfaceIdiomPad )
    {
        self.sliderValName.textColor=[UIColor whiteColor];
    }
    else
    {
        self.sliderValName.textColor=[UIColor darkGrayColor];
    }
    [self.sliderValName setFont:[UIFont fontWithName:@"Gill Sans" size:14]];
    self.sliderValName.textAlignment = NSTextAlignmentCenter;
    
    //OK button - iPhone only
    
     if ( (!UI_USER_INTERFACE_IDIOM()) == UIUserInterfaceIdiomPad )
    {
        self->done = [UIButton buttonWithType:UIButtonTypeSystem];
        self->done.tintColor = [UIColor whiteColor];
        [self->done addTarget:self
                       action:@selector(closeSettingView:)
             forControlEvents:UIControlEventTouchUpInside];
        [self->done setTitle:@"OK" forState:UIControlStateNormal];
        [[self->done titleLabel] setFont:[UIFont fontWithName:@"Avenir-BookOblique" size:16]];
        self->done.frame = CGRectMake(278.0, 21.0, 40.0, 30.0);
    }
    self.thirdViewMessage.text = nil;
    [self.settingSquare addSubview:self.sliderValName];
    [self.settingSquare addSubview:self.sliderVal];
    [self.settingSquare addSubview:self.editMaxDev];
    [self.settingSquare addSubview:self->done];
    [self.view addSubview:self.settingSquare];
    self.settingSquare.hidden = NO;
}

- (IBAction)sliderMoving:(id)sender
{
    self.sliderVal.hidden = NO;
    self.sliderValName.text = [NSString stringWithFormat:NSLocalizedString(@"_SLIDER_DEVIATION_NAME_IPAD", @"max diff from 24H average: %@"), self.sliderVal.text];
    self->maxDeviation = lround(self.editMaxDev.value);
}
- (IBAction)sliderMovingUpdateLabel:(id)sender
{
    if(self->maxDeviation == 201)
    {
        self.sliderVal.text = @"ALL";
    }
    else
    {
        self.sliderVal.text = [NSString stringWithFormat:@"%d%%",(int)self->maxDeviation];
    }
    
}
- (IBAction)closeSettingView:(id)sender
{
[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self->maxDeviation] forKey:@"maxDeviationAsks"];
     if ( (!UI_USER_INTERFACE_IDIOM()) == UIUserInterfaceIdiomPad )
    {
   [UIView animateWithDuration:0.5f
                     animations:^{self.settingSquare.alpha = 0.0;}
                     completion:^(BOOL finished){
                         [self.sliderValName removeFromSuperview];
                         [self.editMaxDev removeFromSuperview];
                         [self->done removeFromSuperview];
                         self.settingSquare.hidden = YES;
                          settingOn = NO;   }];
    }
    self.sliderVal.hidden =YES;
    [self.secondViewDatas update:self->maxDeviation type:@"asks"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void) applicationDidEnterBackground:(NSNotification*)notification
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self->maxDeviation] forKey:@"maxDeviationAsks"];
    [[NSUserDefaults standardUserDefaults] setObject:currentCurrency forKey:@"currentCurrency"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"firstLaunchAsks"];
    [[NSUserDefaults standardUserDefaults] setObject:self.secondViewDatas.orderAsksAllCurrency forKey:currentCurrency];
    
    NSDate *recdATE = [NSDate date];
    [[NSUserDefaults standardUserDefaults]setObject:recdATE forKey:@"lastRecordDateOrderBook"];
}
#pragma mark - iAdBanner Delegates

-(void)bannerView:(ADBannerView *)banner
didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"Error in Loading Banner!");
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"iAd banner Loaded Successfully!");
}
-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
    NSLog(@"iAd Banner will load!");
}
-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
    NSLog(@"iAd Banner did finish");
    
}
@end
