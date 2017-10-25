//
//  GMSFirstViewController.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMSMessageBoxProcessor.h"
#import "GMSfirstViewTableData.h"
#import <MessageUI/MessageUI.h>

extern NSString *const urlStart;
extern NSMutableString *lastRecordDate;
extern BOOL firstLaunch;
extern NSMutableString *currentCurrency;
extern BOOL connected;
extern BOOL test;
@interface GMSFirstViewController : UIViewController <UITableViewDelegate,UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate , MFMessageComposeViewControllerDelegate>
{
    __weak IBOutlet UIPickerView *picker;
}


@property (weak, nonatomic) IBOutlet UIView *bgMaskOrange;
@property (weak, nonatomic) IBOutlet UIView *bgMaskOrangeTop;
@property (weak, nonatomic) IBOutlet UIView *bgMaskOrangeBotPicker;

@property (strong, nonatomic) IBOutlet UIView *screenSocial;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshTicker;
@property (strong, nonatomic) GMSMessageBox *messageBox;
@property (strong, atomic) GMSTopBrandImage *headerImg;
@property (nonatomic, weak) NSTimer *timerMessages;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) GMSMessageBoxProcessor *messageBoxMessage;
@property (weak, nonatomic) IBOutlet UILabel *messageBoxLabel;
//@property (weak, nonatomic) IBOutlet UIStackView *socialStack;
@property (weak, nonatomic) IBOutlet UIButton *tweetIt;
@property (weak, nonatomic) IBOutlet UIButton *faceBook;
@property (weak, nonatomic) IBOutlet UIButton *emailIt;
@property (weak, nonatomic) IBOutlet UIButton *messageIt;
@property (weak, nonatomic) NSUserDefaults *previousDatas;
@property (strong, atomic) GMSfirstViewTableData *firstViewDatas;
@property (strong, atomic) NSIndexPath *prevSelRow;
@property (nonatomic) CGPoint tabViewOrigin;

- (IBAction)tweetSelectedRow:(id)sender;
- (void)updateTicker;
@end
