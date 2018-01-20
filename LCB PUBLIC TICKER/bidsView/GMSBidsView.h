//
//  GMSBidsView.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMSMessageHandler.h"
#import "GMSBidsAsksDatas.h"
#import "GMSGlobals.h"

@interface GMSBidsView : UIViewController<UITableViewDelegate,UITableViewDataSource>
{

}

@property (strong, atomic) GMSTopBrandImage *headerImg;
@property (strong, nonatomic)UIActivityIndicatorView *waitingSpin;
@property (nonatomic, weak) NSTimer *timerMessages;
@property (weak, nonatomic) IBOutlet UIView *tableViewHeader;
@property (strong, nonatomic) GMSMessageHandler *messageBoxMessage;
@property (weak, nonatomic) IBOutlet UILabel *dynamicMessage;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UILabel *sliderInfoTxt;
@property (retain, nonatomic) IBOutlet UILabel *sliderVal;
@property (retain, nonatomic) IBOutlet UIView *settingSquare;
@property (nonatomic, retain) UISlider *editMaxDev;
@property int maxDeviation;
@property (strong, atomic) GMSBidsAsksDatas *bidsDatas;
@property (retain, nonatomic) UILabel *headerTitleLeft;
@property (retain, nonatomic) UILabel *headerTitleRight;
@property BOOL sliderOn;
@property BOOL sortedAsc;

@end
