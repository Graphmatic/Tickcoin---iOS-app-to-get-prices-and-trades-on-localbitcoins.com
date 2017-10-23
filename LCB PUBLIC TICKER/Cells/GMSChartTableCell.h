//
//  GMSChartTableCell.h
//  GMSChartViewDemo
//
//  Created by Terry Worona on 11/8/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GMSChartTableCellType){
	GMSChartTableCellTypeLineChart,
    GMSChartTableCellTypeBarChart
};

@interface GMSChartTableCell : UITableViewCell

@property (nonatomic, assign) GMSChartTableCellType type;

@end
