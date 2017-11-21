//
//  GMSAsksView.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMSMessageBoxProcessor.h"
#import "GMSBidsAsksDatas.h"


extern NSMutableString *currentCurrency;

@interface GMSAsksView : UIViewController<UITableViewDelegate,UITableViewDataSource>
{

}

@property (strong, nonatomic) GMSMessageBox *messageBox;
@property (strong, atomic) GMSTopBrandImage *headerImg;
@property (nonatomic, weak) NSTimer *timerMessages;
@property (weak, nonatomic) IBOutlet UIView *tableViewHeader;
@property (strong, nonatomic) GMSMessageBoxProcessor *messageBoxMessage;
@property (weak, nonatomic) IBOutlet UILabel *thirdViewMessage;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UILabel *sliderValName;
@property (retain, nonatomic) IBOutlet UILabel *sliderVal;
@property (retain, nonatomic) IBOutlet UIView *settingSquare;
@property (nonatomic, retain) UISlider *editMaxDev;
@property int maxDeviation;
@property (strong, atomic) GMSBidsAsksDatas *asksDatas;
@property (retain, nonatomic) UILabel *headerTitleLeft;
@property (retain, nonatomic) UILabel *headerTitleRight;

@end
