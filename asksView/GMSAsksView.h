//
//  GMSAsksView.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMSMessageBoxProcessor.h"
#import "GMSSecondViewTableData.h"
#import "GMSStartView.h"

extern NSMutableString *currentCurrency;
extern BOOL firstLaunchAsks;
extern BOOL test;
@interface GMSAsksView : UIViewController<UITableViewDelegate,UITableViewDataSource>
{

}



@property (strong, nonatomic) GMSMessageBox *messageBox;
@property (strong, atomic) GMSTopBrandImage *headerImg;
@property (nonatomic, weak) NSTimer *timerMessages;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) GMSMessageBoxProcessor *messageBoxMessage;
//@property (nonatomic, retain) IBOutlet JBChartView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *thirdViewMessage;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UILabel *sliderValName;
@property (retain, nonatomic) IBOutlet UILabel *sliderVal;
@property (retain, nonatomic) IBOutlet UIView *settingSquare;
@property (nonatomic, retain) UISlider *editMaxDev;
@property (strong, atomic) GMSSecondViewTableData *secondViewDatas;
@property (retain, nonatomic) IBOutlet UILabel *headerTitleLeft;
@property (weak, nonatomic)GMSStartView *firstViewC;


@end
