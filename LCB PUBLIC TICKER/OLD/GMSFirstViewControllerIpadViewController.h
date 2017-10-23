//
//  GMSFirstViewControllerIpadViewController.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 08/05/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMSMessageBoxProcessor.h"
#import "GMSfirstViewTableData.h"
#import <MessageUI/MessageUI.h>
extern NSString *const urlStart;
extern int variationSinceLastVisit;
extern NSMutableString *lastRecordDate;
extern BOOL firstLaunch;
extern NSMutableString *currentCurrency;
extern BOOL connected;
@interface GMSFirstViewControllerIpadViewController : UIViewController <UITableViewDelegate,UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate , MFMessageComposeViewControllerDelegate>
{
    __weak IBOutlet UIPickerView *picker;
}



@property (strong, atomic) IBOutlet GMSTopBrandImage *headerImg;

@property (strong, nonatomic) IBOutlet UIView *screenSocial;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshTicker;
@property (strong, nonatomic) GMSMessageBox *messageBox;
@property (nonatomic, weak) NSTimer *timerMessages;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) GMSMessageBoxProcessor *messageBoxMessage;
@property (weak, nonatomic) IBOutlet UILabel *messageBoxLabel;
@property (weak, nonatomic) IBOutlet UIButton *tweetIt;
@property (weak, nonatomic) IBOutlet UIButton *faceBook;
@property (weak, nonatomic) IBOutlet UIButton *emailIt;
@property (weak, nonatomic) IBOutlet UIButton *messageIt;
@property (weak, nonatomic) NSUserDefaults *previousDatas;
@property (strong, atomic) GMSfirstViewTableData *firstViewDatas;
@property (strong, atomic) NSIndexPath *prevSelRow;
@property (strong, nonatomic) NSNumber *tabViH;
- (IBAction)tweetSelectedRow:(id)sender;

@end

