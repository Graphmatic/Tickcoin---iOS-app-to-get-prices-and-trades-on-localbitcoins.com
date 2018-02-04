//
//  GMSBidsView.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "GMSAsksView.h"
#import "GMSBidsAsksDatas.h"

@interface GMSAsksView ()
{
    BOOL alt;
    BOOL connected;
    int messagesCount;
    UIButton *done;
    
}
@end

@implementation GMSAsksView

@synthesize timerMessages, editMaxDev, asksDatas, sliderVal, sliderOn, sliderInfoTxt, dynamicMessage, tableViewHeader, headerTitleLeft, headerTitleRight, maxDeviation, waitingSpin, sortedDesc;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // layout
    // get parent view size
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = (self.view.bounds.size.height / 100) * 94;
    
    Globals *glob = [Globals globals];

    // add header
    self.headerImg = [GMSTopBrandImage topImage:2];
    [self.view addSubview:self.headerImg];
    
    // Some position helpers
    CGFloat messageBoxOrigY = self.headerImg.topBrand.size.height + 2;
    CGFloat ipadLayoutWidth = self.headerImg.topBrand.size.width - 4;
    
    // add empty room for dynamic messages
    CGFloat messageBoxHeight = 64.0;
    
    // add dynamic label in messageBox
    if ( !IS_IPAD )
    {
        self.dynamicMessage.frame = CGRectMake(0, messageBoxOrigY, viewWidth, messageBoxHeight - 4);
    }
    else
    {
        self.dynamicMessage.frame = CGRectMake(2, messageBoxOrigY, ipadLayoutWidth, messageBoxHeight - 4);
    }
    self.dynamicMessage.backgroundColor = [UIColor clearColor];
    self.dynamicMessage.textColor = GMSColorBlueGreyDark;
    [self.view addSubview:self.dynamicMessage];
    
    // Frame position for setting slider view
    if ( !IS_IPAD )
    {
        self.settingSquare.frame = CGRectMake(0, messageBoxOrigY, viewWidth, messageBoxHeight - 4);
    }
    else
    {
        self.settingSquare.frame = CGRectMake(2, messageBoxOrigY, ipadLayoutWidth, messageBoxHeight - 4);
    }
    self.settingSquare.backgroundColor = GMSColorBlueGreyDark;
    self.settingSquare.alpha = 0.80;
    self.settingSquare.hidden = YES;
    
    // tableview pseudo header (an UIView..)
    CGFloat tableViewHeaderOriginY = messageBoxOrigY + messageBoxHeight;
    if ( !IS_IPAD )
    {
        self.tableViewHeader.frame = CGRectMake(0, tableViewHeaderOriginY -7, viewWidth, 24);
    }
    else
    {
        self.tableViewHeader.frame = CGRectMake(2, tableViewHeaderOriginY -7, ipadLayoutWidth, 24);
    }
    
    [self.tableViewHeader setBackgroundColor: GMSColorBlueGreyDark];
    // left and right label in tableView header
    CGRect frameHeaderL;
    if ( !IS_IPAD )
    {
        frameHeaderL = CGRectMake(0, 0, viewWidth, 24);
    }
    else
    {
        frameHeaderL = CGRectMake(2, 0, ipadLayoutWidth, 24);
    }
    CGRect frameHeaderR = frameHeaderL;
    CGFloat fhWidth;
    if ( !IS_IPAD )
    {
        fhWidth = viewWidth - frameHeaderL.origin.x;
    }
    else
    {
        fhWidth = ipadLayoutWidth - frameHeaderL.origin.x;
    }
    frameHeaderL.origin.x = 5;
    frameHeaderL.size.width = fhWidth;
    frameHeaderR.origin.x = -5;
    frameHeaderR.size.width = fhWidth;
    self.headerTitleLeft = [[UILabel alloc] initWithFrame:frameHeaderL];
    [self.headerTitleLeft setFont:GMSAvenirNextCondensedMedium];
    self.headerTitleLeft.textAlignment = NSTextAlignmentLeft;
    self.headerTitleLeft.textColor = GMSColorBlueGrey;
    self.headerTitleLeft.text = [NSString stringWithFormat:NSLocalizedString(@"_ASK_BID_TITLE_LEFT", @"Price-currency-maxvolume"), [glob currency]];
    self.headerTitleRight = [[UILabel alloc] initWithFrame:frameHeaderR];
    [self.headerTitleRight setFont:GMSAvenirNextCondensedMedium];
    self.headerTitleRight.textAlignment = NSTextAlignmentRight;
    self.headerTitleRight.textColor = GMSColorBlueGrey;
    self.headerTitleRight.text = [NSString stringWithFormat:NSLocalizedString(@"_ASK_BID_TITLE_RIGHT", @"Price-currency-maxvolume"), [glob currency]];
    
    [self.tableViewHeader addSubview:self.headerTitleLeft];
    [self.tableViewHeader addSubview:self.headerTitleRight];
    [self.view addSubview:self.tableViewHeader];
    
    // add tableView
    CGFloat tableViewOrigY = tableViewHeaderOriginY + 19;
    if ( !IS_IPAD )
    {
        [self.tableView setFrame:CGRectMake(0, tableViewOrigY, viewWidth, (viewHeight - tableViewOrigY) )];
    }
    else
    {
        [self.tableView setFrame:CGRectMake(2, tableViewOrigY, ipadLayoutWidth, (viewHeight - tableViewOrigY) )];
    }
    
    [self.tableView setBackgroundColor: GMSColorDarkGrey];
    // no footer
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    
    
    
    //add double tap to reassort tableView ascending/descending
    UITapGestureRecognizer *tapToChangeOrder = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToChangeArrOrder:)];
    [self.tableView addGestureRecognizer:tapToChangeOrder];
    tapToChangeOrder.numberOfTapsRequired=2;
    
    //init swipe to right that shows maxDeviation slider
    UISwipeGestureRecognizer *displaySettings = [[UISwipeGestureRecognizer alloc]initWithTarget:self
                                                                                         action:@selector(displayMaxDeviationSlider:)];
    displaySettings.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:displaySettings];
    
    // various init
    messagesCount = 0;
}

-(void)viewWillAppear:(BOOL)animated
{
    Globals *glob = [Globals globals];
    
    // init message processor
    self.messageBoxMessage = [[GMSMessageHandler alloc]init];
    
    self.dynamicMessage.text = [NSString stringWithFormat:NSLocalizedString(@"_SELL_ADD_FOR_CUR_x", @"BIDS - %@"), [glob currency]];
    
    if (  [[NSUserDefaults standardUserDefaults]objectForKey:@"asksMaxDeviation"] != nil )
    {
        self.maxDeviation = [[[NSUserDefaults standardUserDefaults]objectForKey:@"asksMaxDeviation"]intValue];
    }
    else
    {
        self.maxDeviation = self.editMaxDev.value = 201;
    }
    if (self.maxDeviation == 201) {
        self.sliderVal.text = [NSString stringWithFormat:@"ALL"];
    }
    else
    {
        self.sliderVal.text = [NSString stringWithFormat:@"%d%%", self.maxDeviation];
    }
    
    self.sliderInfoTxt.text = [NSString stringWithFormat:NSLocalizedString(@"_SLIDER_DEVIATION_NAME_IPAD", @"max diff from 24H average: %@"), [NSString stringWithFormat:@"%d%%", self.maxDeviation]];
    
    self.asksDatas = [GMSBidsAsksDatas sharedBidsAsksDatas];
    
    // add observer
    [self.asksDatas addObserver:self forKeyPath:@"isReady" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    // notif listener
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    self.headerTitleLeft.text = [NSString stringWithFormat:NSLocalizedString(@"_ASK_BID_TITLE_LEFT", @"Price-currency-maxvolume"), [glob currency]];
    
    [self.editMaxDev addTarget:self
                        action:@selector(closeSettingView:)
              forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    
    
    
    if ( !self.asksDatas.isReady )
    {
        self.waitingSpin = [[UIActivityIndicatorView alloc]
                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        if ( !IS_IPAD )
        {
            self.waitingSpin.center = CGPointMake(160, 240);
        }
        else
        {
            self.waitingSpin.center = CGPointMake(self.tableView.frame.origin.x + (self.tableView.frame.size.width / 2), self.tableView.frame.origin.y + (self.tableView.frame.size.height / 2));
        }
        self.waitingSpin.hidesWhenStopped = YES;
        [self.view addSubview:self.waitingSpin];
        [self.waitingSpin startAnimating];
    }
    else
    {
        [self.waitingSpin stopAnimating];
        [self.tableView reloadData];
    }
    
    self.dynamicMessage.text = self.messageBoxMessage.infoMessagesStr;
    if(self.timerMessages)[self.timerMessages invalidate];
    self.timerMessages = nil;
    self.timerMessages = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerStartMulti:) userInfo:nil repeats:YES];
    
}

//tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.asksDatas.orderAsks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *cellVal;
    NSString *key = [[self.asksDatas.orderAsks objectAtIndex:indexPath.row]objectAtIndex:0];
    static NSString *CellIdentifier = @"Item2";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = GMSColorDarkGrey;
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_background_sel.png"]];
    cell.textLabel.font = GMSAvenirNextCondensedMedium;
    cell.textLabel.text = key;
    cellVal = [[self.asksDatas.orderAsks objectAtIndex:indexPath.row]objectAtIndex:1];
    cell.detailTextLabel.font = GMSAvenirNextCondensedMedium;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", cellVal];
    
    return cell;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ( [keyPath isEqualToString:@"isReady"] && [[change objectForKey:@"new"]intValue] == 1 ) //  are datas ready to use ?
    {
        Globals *glob = [Globals globals];

        dispatch_async(dispatch_get_main_queue(), ^{  // we are in an block op, so ensure that UI update is done on the main thread
            // remove spinner if any
            [self.waitingSpin stopAnimating];
            self.sortedDesc = NO;
            // update table headers
            self.headerTitleLeft.text = [NSString stringWithFormat:NSLocalizedString(@"_ASK_BID_TITLE_LEFT", @"Price-currency-maxvolume"), [glob currency]];
            // Update misc. visible elements
            if ( ( [self.asksDatas.orderAsks count] == 0 ) && ( self.asksDatas.isDatas == YES ) ) {
                if(self.timerMessages)[self.timerMessages invalidate];
                self.timerMessages = nil;
                self.dynamicMessage.text = [NSString stringWithFormat:NSLocalizedString(@"_EDIT_FILTER_NULL", @"no order in this range, please edit display filter")];
                if(self.timerMessages)[self.timerMessages invalidate];
                self.timerMessages = nil;
                self.timerMessages = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerStartMulti:) userInfo:nil repeats:YES];
            }
            else
            {
                if ( self.asksDatas.isDatas ==  NO )
                {
                    if(self.timerMessages)[self.timerMessages invalidate];
                    self.timerMessages = nil;
                    self.timerMessages = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerStartMulti:) userInfo:nil repeats:YES];
                }
            }
            [self.tableView reloadData];
        });
    }
}


// no internet connection warning
//-(void)timerStartNoConnect:(NSTimer *)theTimer
//{
//    alt = !alt;
//    NSError *err = [theTimer userInfo];
//    [self.messageBoxMessage noConnection:err alt:alt];
//}
//message box

-(void)timerStartMulti:(NSTimer*)theTimer
{
    if(messagesCount == 3){messagesCount = 0;}
    NSArray *callBack = [self.messageBoxMessage asksViewMessages:messagesCount connected:connected maxDeviation:self.maxDeviation isDescSorted:self.sortedDesc];
    messagesCount = [[callBack objectAtIndex:0]intValue];
    self.dynamicMessage.text = [callBack objectAtIndex:1];
}

//double tap to change order
- (void)tapToChangeArrOrder:(UIGestureRecognizer*) recognizer
{
    NSArray* reverseOrder = [[self.asksDatas.orderAsks reverseObjectEnumerator] allObjects];
    self.asksDatas.orderAsks = (NSMutableArray*)reverseOrder;
    self.sortedDesc = !self.sortedDesc;
    [self.tableView reloadData];
}

- (void) displayMaxDeviationSlider:(UIGestureRecognizer*) recognizer
{
    if (self.sliderOn == NO)
    {
        [self showOverlaySetting];
    }
}
- (void)showOverlaySetting
{
    self.sliderOn = YES;
    self.settingSquare.backgroundColor = GMSColorBlueGreyDark;
    self.settingSquare.alpha = 0.80;
    self.settingSquare.layer.borderColor = (__bridge CGColorRef _Nullable)(GMSColorBlueGrey);
    self.settingSquare.layer.borderWidth = 0.8f;
    
    self.settingSquare.hidden = YES;
    self.editMaxDev = [[UISlider alloc]init];
    CGRect posSlider = editMaxDev.frame;
    CGRect okButtonFrame;

    posSlider.size.width = ( self.settingSquare.frame.size.width / 100 ) * 70;
    posSlider.origin.y = ( self.settingSquare.frame.size.height - self.editMaxDev.frame.size.height ) / 2;
    posSlider.origin.x = ( self.settingSquare.frame.size.width / 100 ) * 10;
    okButtonFrame = CGRectMake( ( self.settingSquare.frame.size.width / 100 ) * 80, ( self.settingSquare.frame.size.height - self.editMaxDev.frame.size.height) / 2 , self.editMaxDev.frame.size.height, self.editMaxDev.frame.size.height);

    self.editMaxDev.frame = posSlider;
    self.editMaxDev.thumbTintColor = [UIColor whiteColor];
    self.editMaxDev.minimumValue = 1;
    self.editMaxDev.maximumValue = 201;
    self.editMaxDev.value = self.maxDeviation;
    self.editMaxDev.continuous = YES;

    self.editMaxDev.minimumTrackTintColor = [UIColor whiteColor];

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
    CGRect tbFrame = self.tableView.frame;
    self.sliderVal.frame = CGRectMake(0, tbFrame.origin.y - 49, tbFrame.size.width, tbFrame.size.height);
    
    self.sliderInfoTxt.text = [NSString stringWithFormat:NSLocalizedString(@"_SLIDER_DEVIATION_NAME_IPAD", @"max diff from 24H average: %@"), self.sliderVal.text];

    self.sliderInfoTxt.textColor=[UIColor whiteColor];

    self.sliderInfoTxt.frame = self.tableViewHeader.frame;
    self.sliderInfoTxt.backgroundColor = GMSColorBlueGreyDark;
    
    
    [self.sliderInfoTxt setFont:[UIFont fontWithName:@"Gill Sans" size:14]];
    self.sliderInfoTxt.textAlignment = NSTextAlignmentCenter;
    
    self->done = [UIButton buttonWithType:UIButtonTypeSystem];
    self->done.tintColor = [UIColor whiteColor];
    [self->done addTarget:self
                   action:@selector(closeSettingView:)
         forControlEvents:UIControlEventTouchUpInside];
    [self->done setTitle:@"OK" forState:UIControlStateNormal];
    [[self->done titleLabel] setFont:[UIFont fontWithName:@"Avenir-BookOblique" size:16]];
    self->done.frame = okButtonFrame;

    self.dynamicMessage.text = nil;
    self.sliderVal.hidden = NO;
    [self.view addSubview:self.sliderInfoTxt];
    [self.view addSubview:self.sliderVal];
    [self.settingSquare addSubview:self.editMaxDev];
    [self.settingSquare addSubview:self->done];
    [self.view addSubview:self.settingSquare];
    self.settingSquare.hidden = NO;
    
}

- (IBAction)sliderMoving:(id)sender
{
    self.sliderInfoTxt.text = [NSString stringWithFormat:NSLocalizedString(@"_SLIDER_DEVIATION_NAME_IPAD", @"max diff from 24H average: %@"), self.sliderVal.text];
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
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.maxDeviation] forKey:@"asksMaxDeviation"];
    //    if ( !IS_IPAD )
    //    {
    [UIView animateWithDuration:0.5f
                     animations:^{self.settingSquare.alpha = 0.0;}
                     completion:^(BOOL finished){
                         self.sortedDesc = NO;
                         [self.sliderInfoTxt removeFromSuperview];
                         [self.editMaxDev removeFromSuperview];
                         [self->done removeFromSuperview];
                         self.settingSquare.hidden = YES;
                         self.sliderOn = NO;  }];
    //    }
    self.sliderVal.hidden = YES;
    [self.asksDatas changeDeviation:self.maxDeviation orderType:@"asks"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(self.timerMessages)[self.timerMessages invalidate];
    self.timerMessages = nil;
    self.sortedDesc = NO;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(self.timerMessages)[self.timerMessages invalidate];
    self.timerMessages = nil;
    if ( self.sliderOn )
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.maxDeviation] forKey:@"asksMaxDeviation"];
        [self.sliderInfoTxt removeFromSuperview];
        [self.editMaxDev removeFromSuperview];
        [self->done removeFromSuperview];
        self.settingSquare.hidden = YES;
        self.sliderVal.hidden = YES;
        self.sliderOn = NO;
        // remove spinner if any
        [self.waitingSpin stopAnimating];
    }
    self.sortedDesc = NO;
}

- (void) applicationDidEnterBackground:(NSNotification*)notification
{
    Globals *glob = [Globals globals];
    
    // save current selected currency to db (should have been already done...)
    [[NSUserDefaults standardUserDefaults] setObject:[glob currency] forKey:@"currency"];
    NSDate *recdATE = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:recdATE forKey:@"lastRecordDateOrderBook"];
    if ( self.sliderOn )
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.maxDeviation] forKey:@"asksMaxDeviation"];
        [self.sliderInfoTxt removeFromSuperview];
        [self.editMaxDev removeFromSuperview];
        [self->done removeFromSuperview];
        self.settingSquare.hidden = YES;
        self.sliderVal.hidden = YES;
        self.sliderOn = NO;
    }
    // remove spinner if any
    [self.waitingSpin stopAnimating];
    self.sortedDesc = NO;
}

@end
