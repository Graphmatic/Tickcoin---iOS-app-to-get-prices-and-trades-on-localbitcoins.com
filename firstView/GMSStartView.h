//
//  GMSStartView.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMSMessageBoxProcessor.h"
#import "GMSfirstViewTableData.h"
#import <MessageUI/MessageUI.h>
#import "GMSMessageBox.h"

extern NSString *const urlStart;
extern NSMutableString *lastRecordDate;
extern BOOL firstLaunch;
extern NSMutableString *currentCurrency;
extern BOOL connected;
extern BOOL test;
@interface GMSStartView : UIViewController <UITableViewDelegate,UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate , MFMessageComposeViewControllerDelegate>
{
    __weak IBOutlet UIPickerView *picker;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshTicker;
@property (strong, atomic) GMSTopBrandImage *headerImg;
@property (nonatomic, weak) NSTimer *timerMessages;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) GMSMessageBoxProcessor *messageBoxMessage;
@property (weak, nonatomic) IBOutlet UILabel *messageBoxLabel;
@property (weak, nonatomic) IBOutlet UIView *socialStack;
@property (weak, nonatomic) IBOutlet UIButton *tweetIt;
@property (weak, nonatomic) IBOutlet UIButton *faceBook;
@property (weak, nonatomic) IBOutlet UIButton *emailIt;
@property (weak, nonatomic) IBOutlet UIButton *messageIt;
@property (weak, nonatomic) NSUserDefaults *previousDatas;
@property (strong, atomic) GMSfirstViewTableData *firstViewDatas;
@property (strong, atomic) NSIndexPath *prevSelRow;
@property (nonatomic) CGPoint tabViewOrigin;
@property (nonatomic) CGFloat rowHeight;

- (IBAction)tweetSelectedRow:(id)sender;
- (void)updateTicker;
@end
