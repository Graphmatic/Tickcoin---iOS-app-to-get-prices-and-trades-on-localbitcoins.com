//
//  GMSStartView.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//
#import "GMSStartView.h"
#import <MessageUI/MessageUI.h>
#import "GMSUtilitiesFunction.h"
#import <sys/utsname.h>
#import "GMSGlobals.h"

@interface GMSStartView ()
{
    int messagesCount;
    BOOL alt;
}
@end

@implementation GMSStartView

@synthesize previousDatas ,firstViewDatas,  messageBoxLabel, messageBoxMessage, headerImg, refreshTicker, timerMessages, tweetIt, emailIt, faceBook, messageIt, title, picker, prevSelRow, tabViewOrigin, socialStack, rowHeight;

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // get device model
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *currentDevice = [NSString stringWithCString:systemInfo.machine
                                                 encoding:NSUTF8StringEncoding];
    NSString *currentSimulatorDevice = [NSString stringWithCString:getenv("SIMULATOR_MODEL_IDENTIFIER")
                                                          encoding:NSUTF8StringEncoding];
    
    Globals *glob = [Globals globals];

    // debug
    NSLog(@"globals test: currency => %@", [glob currency]);
    // get parent view size
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    
    // debug
    NSLog(@"W x H : %f x %f", viewWidth, viewHeight);
    
    //add header
    self.headerImg = [GMSTopBrandImage topImage:0];
    [self.view addSubview:self.headerImg];
    
    // Some position helpers
    CGFloat pickerOrigY = self.headerImg.topBrand.size.height;
    CGFloat pickerHeight = self.picker.frame.size.height;
    CGFloat messageBoxOrigY = pickerOrigY + pickerHeight;
    
    // Dynamic messages
    self.messageBoxMessage = [[GMSMessageBoxProcessor alloc]init];
    
    // if not an iPad
    if ( !IS_IPAD ) {
        
        // position of Currencies picker
        if ( IS_IPHONE_4_5 )
        {
            [self.picker setFrame:CGRectMake(0, pickerOrigY, viewWidth, 120)];
        }
        else if ( IS_IPHONE_6_7_8 || IS_IPHONE_X )
        {
            [self.picker setFrame:CGRectMake(0, pickerOrigY, viewWidth, 160)];
        }
        else if ( IS_IPHONE_PLUS )
        {
            [self.picker setFrame:CGRectMake(0, pickerOrigY, viewWidth, 180)];
        }
      
        [self.view addSubview:self.picker];
        messageBoxOrigY = pickerOrigY + pickerHeight;
        
        // position of message box
        CGFloat tableViewOrigY = messageBoxOrigY;
        if ( IS_IPHONE_4_5 )
        {
            [self.messageBoxLabel setFrame:CGRectMake(0, messageBoxOrigY, viewWidth, 50)];
            // postion tableView
            tableViewOrigY += 50;
        }
        else if ( IS_IPHONE_6_7_8 )
        {
            [self.messageBoxLabel setFrame:CGRectMake(0, messageBoxOrigY, viewWidth, 64)];
            // postion tableView
            tableViewOrigY += 64;
        }
        else if ( IS_IPHONE_PLUS )
        {
            [self.messageBoxLabel setFrame:CGRectMake(0, messageBoxOrigY, viewWidth, 80)];
            // postion tableView
            tableViewOrigY += 80;
        }
        else if ( IS_IPHONE_X )
        {
            [self.messageBoxLabel setFrame:CGRectMake(0, messageBoxOrigY, viewWidth, 70)];
            // postion tableView
            tableViewOrigY += 70;
        }
        if ( IS_IPHONE_X )
        {
            NSLog(@"IS_IPHONE_X");
            // 35 is the room reserved for gesture in iPhone X
            [self.tableView setFrame:CGRectMake(0, tableViewOrigY, viewWidth, (viewHeight - tableViewOrigY - 49 - 35) )];
           
        }
        else
        {
            NSLog(@"!IS_IPHONE_X");
            [self.tableView setFrame:CGRectMake(0, tableViewOrigY, viewWidth, (viewHeight - tableViewOrigY - 49) )];
        }
        
        [self.view addSubview:self.tableView];

        // This will remove extra separators from tableview
        self.tableView.tableFooterView = [UIView new];
    }
    
    else
    {
        [self.messageBoxLabel setFrame:CGRectMake(0, messageBoxOrigY + 2, self.tableView.bounds.size.width + self.picker.frame.size.width + 2, 62)];
    }
    
    self.messageBoxLabel.text = self.messageBoxMessage.messageBoxString;

    self.rowHeight = (self.tableView.bounds.size.height / 5);
    
    // add social buttons
    [self.socialStack setFrame:self.messageBoxLabel.frame];
    //resize buttons
    if ( !IS_IPAD ) {
        self.tweetIt.imageEdgeInsets = UIEdgeInsetsMake(45, 45, 45, 45);
        self.messageIt.imageEdgeInsets = UIEdgeInsetsMake(45, 45, 45, 45);
        self.faceBook.imageEdgeInsets = UIEdgeInsetsMake(45, 45, 45, 45);
        self.emailIt.imageEdgeInsets = UIEdgeInsetsMake(45, 45, 45, 45);
    }
    else {
        self.tweetIt.imageEdgeInsets = UIEdgeInsetsMake(50, 50, 50, 50);
        self.messageIt.imageEdgeInsets = UIEdgeInsetsMake(50, 50, 50, 50);
        self.faceBook.imageEdgeInsets = UIEdgeInsetsMake(50, 50, 50, 50);
        self.emailIt.imageEdgeInsets = UIEdgeInsetsMake(50, 50, 50, 50);
    }
    // add them to parent view
    [self.socialStack addSubview:self.tweetIt];
    [self.socialStack addSubview:self.messageIt];
    [self.socialStack addSubview:self.faceBook];
    [self.socialStack addSubview:self.emailIt];
    
    // constraint to spread buttons accros its superview
    [GMSUtilitiesFunction evenlySpaceItems:@[self.tweetIt, self.messageIt, self.faceBook, self.emailIt] :self.socialStack];
    
    [self.view addSubview:self.socialStack];
    
    self.socialStack.hidden = YES;
    
    NSUInteger pickerDefIndex = [self.firstViewDatas.currenciesList indexOfObject:[glob currency]];
    [self.picker reloadAllComponents];
    [self.picker selectRow:pickerDefIndex inComponent:0 animated:YES];
    
    [self.tableView reloadData];
    
    //init refreshing touch item
    self.refreshTicker = [[UIRefreshControl alloc] init];
    self.refreshTicker.tintColor = GMSColorDarkGrey;
    [self.refreshTicker addTarget:self action:@selector(updateTicker)forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshTicker];
    self.tableView.backgroundColor = GMSColorDarkGrey;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    // Register for notification. (placed in viewDidLoad(), notifs are not re-activated after views switching.)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDatas:) name:@"currencySwitching" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePickerList:) name:@"currencyListUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageBoxChange:) name:@"previousPriceChange" object:nil];
    
    self.firstViewDatas = [GMSfirstViewTableData sharedFirstViewTableData];
    [self updateTicker];
}

//
//---------------------------------------------------------------------------------------------------------------------------//
//                                                    //datas handler//
//---------------------------------------------------------------------------------------------------------------------------//
//parse JSON datas from LCB
- (void)updateTicker
{
    if(self.timerMessages)[self.timerMessages invalidate];
    self.timerMessages = nil;
    self.messageBoxLabel.text = [NSMutableString stringWithFormat:NSLocalizedString(@"_WAIT_FOR_DATAS", @"please wait - update...")];
    
    Globals *glob = [Globals globals];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[glob urlStart]]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         [self.refreshTicker endRefreshing];
         dispatch_queue_t parser = dispatch_queue_create("parsecvs", DISPATCH_QUEUE_SERIAL);
         dispatch_async(parser, ^{
             [self.firstViewDatas update:responseObject];
         });
         
         NSDate *recdATE = [[NSDate alloc]init];
         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
         [dateFormatter setDateStyle:NSDateFormatterLongStyle];
         [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
         [glob setLastRecordDate:[[dateFormatter stringFromDate:recdATE]mutableCopy]];
         [[NSUserDefaults standardUserDefaults]setObject:[glob lastRecordDate] forKey:@"lastRecordDate"];
         if(self.timerMessages)[self.timerMessages invalidate];
         self.timerMessages = nil;
         self.timerMessages = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerStartMulti:) userInfo:nil repeats:YES];
         
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self.refreshTicker endRefreshing];
         [glob setNetworkAvailable:NO];
         if(self.timerMessages)[self.timerMessages invalidate];
         self.timerMessages = nil;
         self.timerMessages = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerStartNoConnect:) userInfo:error repeats:YES];
     }];
    [operation start];
}

- (void)prepareDatas:(NSNotification *)notification
{
    [self.tableView reloadData];
}

//---------------------------------------------------------------------------------------------------------------------------//
//                                                    //currency Picker//
//---------------------------------------------------------------------------------------------------------------------------//
- (void) updatePickerList:(NSNotification *)notification
{
    Globals *glob = [Globals globals];
    NSUInteger pickerDefIndex = [self.firstViewDatas.currenciesList indexOfObject:[glob currency]];
    [self.picker reloadAllComponents];
    [self.picker selectRow:pickerDefIndex inComponent:0 animated:YES];
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.firstViewDatas.currenciesList.count;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSMutableParagraphStyle *centeredStyle = [[NSMutableParagraphStyle alloc] init];
    centeredStyle.alignment = NSTextAlignmentCenter;
    NSString *pickerTitle = [self.firstViewDatas.currenciesList objectAtIndex:row];
    NSAttributedString *pickerTitleColor = [[NSAttributedString alloc] initWithString:pickerTitle attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSParagraphStyleAttributeName:centeredStyle}];
    return pickerTitleColor;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    Globals *glob = [Globals globals];
    [self deselectRow:[self.tableView indexPathForSelectedRow]];
    self.messageBoxLabel.text = nil;
    [glob setCurrency:[self.firstViewDatas.currenciesList objectAtIndex:row]];
    self.messageBoxLabel.text = [NSMutableString  stringWithFormat:NSLocalizedString(@"_DAILY_PRICE_IN" , "%@  -  %@"), [glob lastRecordDate], [glob currency]];
    [self.firstViewDatas currencyChange:[self.firstViewDatas.currenciesList objectAtIndex:row]];
    
}

//-----------------------------------------------------------------------------------------------------------------------------//
//                                                    //tableView//
//-----------------------------------------------------------------------------------------------------------------------------//

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tableHeaderBG=[[UIView alloc]initWithFrame:CGRectMake(0,0,320,1)];
    tableHeaderBG.backgroundColor =  [UIColor clearColor];
    return tableHeaderBG;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // debug
    // NSLog(@"CELLS = %@", self.firstViewDatas.cellTitles);
    return [self.firstViewDatas.cellTitles count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //local var to hold value
    NSString *cellVal = [self.firstViewDatas.cellValues objectForKey:[self.firstViewDatas.cellTitles objectAtIndex:indexPath.row]];
    //get title for the cell
    NSString *key = [self.firstViewDatas.cellTitles objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"Item";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_background_sel.png"]];
    cell.backgroundColor = GMSColorDarkGrey;
    
    //populate cell
    cell.textLabel.text = key;
    if([cellVal isEqualToString:NSLocalizedString(@"_NO_DATAS", @"no data")])
    {
        cell.detailTextLabel.text = cellVal;
    }
    else
    {
        if([key isEqualToString:NSLocalizedString(@"_VOLUME", @"volume")])
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Btc", cellVal];
        }
        else
        {
            cell.detailTextLabel.text = [GMSUtilitiesFunction currencyFormatThat:cellVal];
        }
    }
    return cell;
}

// rows height
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rowHeight;
}



//row selected : show share buttons
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.prevSelRow isEqual:indexPath]) {
        self.prevSelRow = nil;
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        [self deselectRow:indexPath];
    }
    else
    {
        UITableViewCell *prevCell = [self.tableView cellForRowAtIndexPath:self.prevSelRow];
        prevCell.textLabel.textColor = [UIColor whiteColor];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.textColor = GMSColorOrange;
        if(self.timerMessages)[self.timerMessages invalidate];
        self.timerMessages = nil;
        self.messageBoxLabel.text = Nil;
        self.socialStack.hidden = NO;
        self.prevSelRow = indexPath;
    }
}

- (void)deselectRow:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor whiteColor];

     self.socialStack.hidden = YES;
    [self messageBoxChange:nil];
    self.prevSelRow = nil;
}

//---------------------------------------------------------------------------------------------------------------------------//
//                                                    //messages handler//
//---------------------------------------------------------------------------------------------------------------------------//
- (void)messageBoxChange:(NSNotification *)notification
{
    Globals *glob = [Globals globals];
    self.messageBoxLabel.text = [NSMutableString  stringWithFormat:NSLocalizedString(@"_DAILY_PRICE_IN", "%@  -  %@"), [glob lastRecordDate], [glob currency]];
    
    //start message box carroussel
    if(self.timerMessages)[self.timerMessages invalidate];
    self.timerMessages = nil;
    self.timerMessages = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerStartMulti:) userInfo:nil repeats:YES];
    
}
- (void)timerStartNoConnect:(NSTimer *)theTimer
{
    alt = !alt;
    NSError *err = [theTimer userInfo];
    
    //  [self.messageBoxLabel setFont:[UIFont systemFontOfSize:35]];
    self.messageBoxLabel.text = [self.messageBoxMessage noConnAlert:err alt:alt];
}
-(void)timerStartMulti:(NSTimer*)theTimer
{
    Globals *glob = [Globals globals];
    alt = !alt;
    self.messageBoxLabel.text = [self.messageBoxMessage dailyMessages:alt connected:[glob isNetworkAvailable]];
}

//---------------------------------------------------------------------------------------------------------------------------//
//                                                    // facebook //
//---------------------------------------------------------------------------------------------------------------------------//
- (IBAction)fbSelectedRow:(id)sender
{
    NSIndexPath *indexP = [self.tableView indexPathForSelectedRow];
    UITableViewCell *celltoFb = [self.tableView cellForRowAtIndexPath:indexP];
    if(![celltoFb.detailTextLabel.text isEqualToString:NSLocalizedString(@"_NO_DATAS", @"no data")])
    {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            
            NSIndexPath *indexP = [self.tableView indexPathForSelectedRow];
            UITableViewCell *celltoFb = [self.tableView cellForRowAtIndexPath:indexP];
            NSDate *date = [[NSDate alloc]init];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            NSString *twDate = [dateFormatter stringFromDate:date];
            SLComposeViewController *fbSheet = [SLComposeViewController
                                                composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            NSString *fbText = [NSString stringWithFormat:NSLocalizedString(@"_TWEET_DAILY_TICKER", @"%@ - Localbitcoins.com: BTC %@: %@"),twDate, celltoFb.textLabel.text, celltoFb.detailTextLabel.text];
            [fbSheet setInitialText:fbText];
            
            [self presentViewController:fbSheet animated:YES completion:nil];
        }
        else
        {
            [GMSUtilitiesFunction popAlert:@"_ERROR" :@"_FACEBOOK_NOT_CONF" :self];
            [self deselectRow:indexP];
        }
    }
    else
    {
        [GMSUtilitiesFunction popAlert:@"_ERROR" :@"_NOTHING_TO_SHARE" :self];
        [self deselectRow:indexP];
    }
    
}
//---------------------------------------------------------------------------------------------------------------------------//
//                                                    // twitter //
//---------------------------------------------------------------------------------------------------------------------------//
- (IBAction)tweetSelectedRow:(id)sender
{
    NSIndexPath *indexP = [self.tableView indexPathForSelectedRow];
    UITableViewCell *celltoTweet = [self.tableView cellForRowAtIndexPath:indexP];
    if(![celltoTweet.detailTextLabel.text isEqualToString:NSLocalizedString(@"_NO_DATAS", @"no data")])
    {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            
            
            NSDate *date = [[NSDate alloc]init];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            NSString *twDate = [dateFormatter stringFromDate:date];
            SLComposeViewController *tweetSheet = [SLComposeViewController
                                                   composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            NSString *tweetText = [NSString stringWithFormat:NSLocalizedString(@"_TWEET_DAILY_TICKER", @"%@ - Localbitcoins.com: BTC %@: %@"),twDate, celltoTweet.textLabel.text, celltoTweet.detailTextLabel.text];
            [tweetSheet setInitialText:tweetText];
            tweetSheet.completionHandler = ^(SLComposeViewControllerResult result)
            {
                [self deselectRow:[self.tableView indexPathForSelectedRow]];
                switch(result) {
                        //  This means the user cancelled without sending the Tweet
                    case SLComposeViewControllerResultCancelled:
                        self.messageBoxLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_TWEET_SENDING_CANCELLED", @"Tweet canceled")];
                        break;
                        //  This means the user hit 'Send'
                    case SLComposeViewControllerResultDone:
                        self.messageBoxLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_TWEET_SENT", @"Tweet sent")];
                        
                        break;
                }
                
            };
            [self presentViewController:tweetSheet animated:YES completion:nil];
            
        }
        else
        {
            [GMSUtilitiesFunction popAlert:@"_ERROR" :@"_TWITTER_NOT_CONF" :self];
            [self deselectRow:indexP];
        }
    }
    else
    {
        [GMSUtilitiesFunction popAlert:@"_ERROR" :@"_NOTHING_TO_SHARE" :self];
        [self deselectRow:indexP];
    }
    
}
//---------------------------------------------------------------------------------------------------------------------------//
//                                                    // email //
//---------------------------------------------------------------------------------------------------------------------------//
- (IBAction)emailSelectedRow:(id)sender
{
    NSIndexPath *indexP = [self.tableView indexPathForSelectedRow];
    UITableViewCell *celltoTweet = [self.tableView cellForRowAtIndexPath:indexP];
    if(![celltoTweet.detailTextLabel.text isEqualToString:NSLocalizedString(@"_NO_DATAS", @"no data")])
    {
        if ([MFMailComposeViewController canSendMail])
        {
            
            NSDate *date = [[NSDate alloc]init];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            NSString *twDate = [dateFormatter stringFromDate:date];
            NSString *affiliateId = [[NSUserDefaults standardUserDefaults] objectForKey:@"affiliateTag"];
            NSString *titleForEmail = [NSString stringWithFormat:NSLocalizedString(@"_EMAIL_DAILY_TICKER", @"Localbitcoins.com: BTC DAILY PRICE")];
            NSString *body = [NSString stringWithFormat:NSLocalizedString(@"_TWEET_DAILY_TICKER", @"%@ - <a href='https://www.localbitcoins.com/%@>Localbitcoins.com</a>: BTC %@: %@\n"), twDate, affiliateId, celltoTweet.textLabel.text, celltoTweet.detailTextLabel.text];
            
            
            MFMailComposeViewController *newMailView = [[MFMailComposeViewController alloc] init];
            newMailView.mailComposeDelegate = self;
            [newMailView setSubject:titleForEmail];
            [newMailView setMessageBody:body isHTML:NO];
            [self presentViewController:newMailView animated:YES completion:nil];
        }
        else
            // The device can not send email.
        {
            [GMSUtilitiesFunction popAlert:@"_ERROR" :@"_MAIL_NOT_CONF" :self];
            [self deselectRow:indexP];
        }
    }
    else
    {
        [GMSUtilitiesFunction popAlert:@"_ERROR" :@"_NOTHING_TO_SHARE" :self];
        [self deselectRow:indexP];
    }
    
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self deselectRow:[self.tableView indexPathForSelectedRow]];
    [self dismissViewControllerAnimated:YES completion:NULL];
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            self.messageBoxLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_MAIL_SENDING_CANCELLED", @"Mail sending canceled")];
            break;
        case MFMailComposeResultSaved:
            self.messageBoxLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_MAIL_SAVED", @"Mail saved")];
            break;
        case MFMailComposeResultSent:
            self.messageBoxLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_MAIL_SENT", @"Mail sent")];
            break;
        case MFMailComposeResultFailed:
            self.messageBoxLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_MAIL_SEND_FAIL", @"Mail sending failed")];
            break;
        default:
            self.messageBoxLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_MAIL_NOT_SENT_DEFAULT", @"Mail not sent")];
            break;
    }
}

//---------------------------------------------------------------------------------------------------------------------------//
//                                                    // sms message //
//---------------------------------------------------------------------------------------------------------------------------//
- (IBAction)messageSelectedRow:(id)sender
{
    NSIndexPath *indexP = [self.tableView indexPathForSelectedRow];
    UITableViewCell *celltoTweet = [self.tableView cellForRowAtIndexPath:indexP];
    if(![celltoTweet.detailTextLabel.text isEqualToString:NSLocalizedString(@"_NO_DATAS", @"no data")])
    {
        if ([MFMessageComposeViewController canSendText])
        {
            UITableViewCell *celltoTweet = [self.tableView cellForRowAtIndexPath:indexP];
            NSDate *date = [[NSDate alloc]init];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            NSString *twDate = [dateFormatter stringFromDate:date];
            NSString *body = [NSString stringWithFormat:NSLocalizedString(@"_TWEET_DAILY_TICKER", @"%@ - Localbitcoins.com: BTC %@: %@"),twDate, celltoTweet.textLabel.text, celltoTweet.detailTextLabel.text];
            MFMessageComposeViewController *newMessageView = [[MFMessageComposeViewController alloc] init];
            newMessageView.messageComposeDelegate = self;
            newMessageView.body = body;
            [self presentViewController:newMessageView animated:YES completion:nil];
        }
        else
            // The device can not send sms.
        {
            [GMSUtilitiesFunction popAlert:@"_ERROR" :@"_MESSAGE_NOT_CONF" :self];
            [self deselectRow:indexP];
        }
    }
    else {
        [GMSUtilitiesFunction popAlert:@"_ERROR" :@"_NOTHING_TO_SHARE" :self];
        [self deselectRow:indexP];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self deselectRow:[self.tableView indexPathForSelectedRow]];
    switch (result)
    {
        case MessageComposeResultCancelled:
            self.messageBoxLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_SMS_SENDING_CANCELLED", @"SMS sending canceled")];
            break;
        case MessageComposeResultSent:
            self.messageBoxLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_SMS_SENT", @"SMS sent")];
            break;
        case MessageComposeResultFailed:
            self.messageBoxLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_SMS_SEND_FAIL", @"SMS sending failed")];
            break;
        default:
            self.messageBoxLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_SMS_NOT_SENT_DEFAULT", @"SMS not sent")];
            break;
    }
}

- (void) viewDidUnload
{
    [self deselectRow:[self.tableView indexPathForSelectedRow]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(self.timerMessages)[self.timerMessages invalidate];
    self.timerMessages = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    Globals *glob = [Globals globals];
    NSUInteger pickerDefIndex = [self.firstViewDatas.currenciesList indexOfObject:[glob currency]];
    [self.picker reloadAllComponents];
    [self.picker selectRow:pickerDefIndex inComponent:0 animated:NO];
    [self deselectRow:[self.tableView indexPathForSelectedRow]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(self.timerMessages)[self.timerMessages invalidate];
    self.timerMessages = nil;
}

- (void) applicationDidEnterBackground:(NSNotification*)notification
{
    Globals *glob = [Globals globals];
    // save current selected currency to db (should have been already done...)
    [[NSUserDefaults standardUserDefaults] setObject:[glob currency] forKey:@"currency"];
}

@end

