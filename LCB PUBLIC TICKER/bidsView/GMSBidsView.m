//
//  GMSBidsView.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "GMSBidsView.h"
#import "GMSBidsAsksDatas.h"

@interface GMSBidsView ()
{
    BOOL alt;
    BOOL connected;
    BOOL settingOn;
    int messagesCount;
    BOOL doubleTapLabel;
    BOOL graphs;
    UIButton *done;

}
@end

@implementation GMSBidsView

@synthesize timerMessages, editMaxDev, settingSquare, bidsDatas, sliderVal, sliderValName, secondViewMessage, messageBox, tableViewHeader, headerTitleLeft, headerTitleRight, maxDeviation;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // layout
    // get parent view size
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    
    // add header
    self.headerImg = [GMSTopBrandImage topImage:1];
    [self.view addSubview:self.headerImg];
    
    // Some position helpers
    CGFloat messageBoxOrigY = self.headerImg.topBrand.size.height + 2;
    
    // add messageBox
    self.messageBox = [GMSMessageBox init:messageBoxOrigY];
    [self.view addSubview:self.messageBox];
    CGFloat messageBoxHeight = 64.0;
    CGFloat tableViewHeaderOriginY = messageBoxOrigY + messageBoxHeight;
    
    // add dynamic label in messageBox
    [self.messageBox addSubview:self.secondViewMessage];
    
    // constraints to position message label in wrapper
    [NSLayoutConstraint constraintWithItem:self.secondViewMessage attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual toItem:self.messageBox
                                 attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:+0.0];
    [NSLayoutConstraint constraintWithItem:self.secondViewMessage attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual toItem:self.messageBox
                                 attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:+0.0];
    
    // tableview pseudo header (an UIView..)
    self.tableViewHeader.frame = CGRectMake(0, tableViewHeaderOriginY -7, viewWidth, 24);
    [self.tableViewHeader setBackgroundColor: GMSColorBlueGreyDark];
    // left and right label in tableView header
    CGRect frameHeaderL = CGRectMake(0, 0, viewWidth, 24);
    CGRect frameHeaderR = frameHeaderL;
    CGFloat fhWidth = viewWidth - frameHeaderL.origin.x;
    frameHeaderL.origin.x = 5;
    frameHeaderL.size.width = fhWidth;
    frameHeaderR.origin.x = -5;
    frameHeaderR.size.width = fhWidth;
    self.headerTitleLeft = [[UILabel alloc] initWithFrame:frameHeaderL];
    [self.headerTitleLeft setFont:GMSAvenirNextCondensedMedium];
    self.headerTitleLeft.textAlignment = NSTextAlignmentLeft;
    self.headerTitleLeft.textColor = GMSColorBlueGrey;
    self.headerTitleLeft.text = [NSString stringWithFormat:NSLocalizedString(@"_ASK_BID_TITLE_LEFT", @"Price-currency-maxvolume"), currentCurrency];
    self.headerTitleRight = [[UILabel alloc] initWithFrame:frameHeaderR];
    [self.headerTitleRight setFont:GMSAvenirNextCondensedMedium];
    self.headerTitleRight.textAlignment = NSTextAlignmentRight;
    self.headerTitleRight.textColor = GMSColorBlueGrey;
    self.headerTitleRight.text = [NSString stringWithFormat:NSLocalizedString(@"_ASK_BID_TITLE_RIGHT", @"Price-currency-maxvolume"), currentCurrency];

    [self.tableViewHeader addSubview:self.headerTitleLeft];
    [self.tableViewHeader addSubview:self.headerTitleRight];
    [self.view addSubview:self.tableViewHeader];

    // add tableView
    CGFloat tableViewOrigY = tableViewHeaderOriginY + 19;
    [self.tableView setFrame:CGRectMake(0, tableViewOrigY, viewWidth, (viewHeight - tableViewOrigY) )];
    [self.tableView setBackgroundColor:[UIColor blackColor]];
    // no footer
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    
    //add double tap to reassort tableView ascending/descending
    UITapGestureRecognizer *tapToChangeOrder = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToChangeArrOrder:)];
    [self.tableView addGestureRecognizer:tapToChangeOrder];
    tapToChangeOrder.numberOfTapsRequired=2;
    
    if ( !IS_IPAD )
    {
        //init swipe to right that shows maxDeviation slider
        UISwipeGestureRecognizer *displaySettings = [[UISwipeGestureRecognizer alloc]initWithTarget:self
                                                                                             action:@selector(displayMaxDeviationSlider:)];
        displaySettings.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:displaySettings];
    }
    else
    {
        // slider always visible
        self.sliderVal.hidden =YES;
        settingOn = YES;
        [self showOverlaySetting];
    }
    
    // various init
    messagesCount = 0;
    graphs = NO;
    
    self.sliderVal.text = [NSString stringWithFormat:@"%d%%", self.maxDeviation];
    self.editMaxDev.value = self.maxDeviation;
    self.sliderValName.text = [NSString stringWithFormat:NSLocalizedString(@"_SLIDER_DEVIATION_NAME_IPAD", @"max diff from 24H average: %@"), self.sliderVal.text];

    // init message processor
    self.messageBoxMessage = [[GMSMessageBoxProcessor alloc]init];
    self.secondViewMessage.text = self.messageBoxMessage.messageBoxString;
    

}

-(void)viewWillAppear:(BOOL)animated
{
    self.secondViewMessage.text = [NSString stringWithFormat:NSLocalizedString(@"_SELL_ADD_FOR_CUR_x", @"BIDS - %@"), currentCurrency];
    
    self.maxDeviation = [[[NSUserDefaults standardUserDefaults]objectForKey:@"maxDeviationBids"]intValue] || 201;
    self.bidsDatas = [GMSBidsAsksDatas sharedBidsAsksDatas:currentCurrency];
    
    // add observer
    [self.bidsDatas addObserver:self forKeyPath:@"isReady" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    // notif listener
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    self.headerTitleLeft.text = [NSString stringWithFormat:NSLocalizedString(@"_ASK_BID_TITLE_LEFT", @"Price-currency-maxvolume"), currentCurrency];
    
    [self.editMaxDev addTarget:self
                        action:@selector(closeSettingView:)
              forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
}

//tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return  [self.bidsDatas.orderBids count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *cellVal;
    NSString *key = [[self.bidsDatas.orderBids objectAtIndex:indexPath.row]objectAtIndex:0];
    static NSString *CellIdentifier = @"Item2";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_background_sel.png"]];
    
    cell.textLabel.text = key;
    cellVal = [[self.bidsDatas.orderBids objectAtIndex:indexPath.row]objectAtIndex:1];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", cellVal];
    
    // debug
    NSLog(@"index 1 : %@", [[self.bidsDatas.orderBids objectAtIndex:indexPath.row]objectAtIndex:1]);
    return cell;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ( [keyPath isEqualToString:@"isReady"] && [[change objectForKey:@"new"]intValue] == 1 ) //  are datas ready to use ?
    {
        dispatch_async(dispatch_get_main_queue(), ^{  // we are in an block op, so ensure that UI update is done on the main thread
            // Update misc. visible elements
            if ([self.bidsDatas.orderBids count] == 0) {
                if(self.timerMessages)[self.timerMessages invalidate];
                self.timerMessages = nil;
                self.secondViewMessage.text = [NSString stringWithFormat:NSLocalizedString(@"_EDIT_FILTER_NULL", @"no order in this range, please edit display filter")];
            }
            else
            {
                if(self.timerMessages)[self.timerMessages invalidate];
                self.timerMessages = nil;
                self.timerMessages = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerStartMulti:) userInfo:nil repeats:YES];
            }
            [self.tableView reloadData];
        });
    }
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
    NSArray *callBack = [self.messageBoxMessage bidsViewMessages:messagesCount connected:connected maxDeviation:self.maxDeviation doubleTap:doubleTapLabel];
    messagesCount = [[callBack objectAtIndex:0]intValue];
    self.secondViewMessage.text = [callBack objectAtIndex:1];
}

//double tap to change order
- (void)tapToChangeArrOrder:(UIGestureRecognizer*) recognizer {
    if(self.timerMessages)[self.timerMessages invalidate];
    self.timerMessages = nil;
    self.secondViewMessage.text = nil;
    NSArray* reverseOrder = [[self.bidsDatas.orderBids reverseObjectEnumerator] allObjects];
    self.bidsDatas.orderBids = (NSMutableArray*)reverseOrder;
    if(doubleTapLabel == YES)
    {
        doubleTapLabel = NO;
    }
    else{
        doubleTapLabel = YES;
    }
    [self.tableView reloadData];
}

- (void) displayMaxDeviationSlider:(UIGestureRecognizer*) recognizer
{
    if (settingOn == NO)
    {
        [self showOverlaySetting];
    }
}
- (void)showOverlaySetting
{
    if ( !IS_IPAD )
    {
        settingOn = YES;
        [self.settingSquare setBackgroundColor:[UIColor blackColor]];
        self.settingSquare.alpha = 0.9;
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
    if ( !IS_IPAD )
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
    self.editMaxDev.value = self.maxDeviation;
    self.editMaxDev.continuous = YES;
    
    if ( !IS_IPAD )
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
    if (self.maxDeviation == 201) {
        self.sliderVal.text = [NSString stringWithFormat:@"ALL"];
    }
    else
    {
        self.sliderVal.text = [NSString stringWithFormat:@"%d%%", self.maxDeviation];
    }
    
    self.sliderValName.text = [NSString stringWithFormat:NSLocalizedString(@"_SLIDER_DEVIATION_NAME_IPAD", @"max diff from 24H average: %@"), self.sliderVal.text];
    if ( !IS_IPAD )
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
    
    if ( !IS_IPAD )
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
    self.secondViewMessage.text = nil;
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
    self.maxDeviation = (int)lround(self.editMaxDev.value);
}

- (IBAction)sliderMovingUpdateLabel:(id)sender
{
    if(self.maxDeviation == 201)
    {
        self.sliderVal.text = @"ALL";
    }
    else
    {
        self.sliderVal.text = [NSString stringWithFormat:@"%d%%", self.maxDeviation];
    }
    
}

- (IBAction)closeSettingView:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.maxDeviation] forKey:@"maxDeviationBids"];
    if ( !IS_IPAD )
    {
        [UIView animateWithDuration:0.5f
                         animations:^{self.settingSquare.alpha = 0.0;}
                         completion:^(BOOL finished){
                             [self.sliderValName removeFromSuperview];
                             [self.editMaxDev removeFromSuperview];
                             [self->done removeFromSuperview];
                             self.settingSquare.hidden = YES;
                             settingOn = NO;  }];
    }
    self.sliderVal.hidden =YES;
    [self.bidsDatas changeDeviation:self.maxDeviation orderType:@"bids"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) applicationDidEnterBackground:(NSNotification*)notification
{
    NSDate *recdATE = [NSDate date];
    [[NSUserDefaults standardUserDefaults]setObject:recdATE forKey:@"lastRecordDateOrderBook"];
}
                          

@end
                          
                          
