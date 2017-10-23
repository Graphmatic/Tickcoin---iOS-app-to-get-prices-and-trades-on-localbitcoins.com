//
//  GMSChartListViewController.m
//  GMSChartViewDemo
//
//  Created by Terry Worona on 11/5/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "GMSChartListViewController.h"

// Controllers
#import "GMSBarChartViewController.h"
#import "GMSLineChartViewController.h"

// Views
#import "GMSChartTableCell.h"

typedef NS_ENUM(NSInteger, GMSChartListViewControllerRow){
	GMSChartListViewControllerRowLineChart,
    GMSChartListViewControllerRowBarChart,
    GMSChartListViewControllerRowCount
};

// Strings
NSString * const kGMSChartListViewControllerCellIdentifier = @"kGMSChartListViewControllerCellIdentifier";

// Numerics
NSInteger const kGMSChartListViewControllerCellHeight = 100;

@interface GMSChartListViewController ()

@end

@implementation GMSChartListViewController

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    [self.tableView registerClass:[GMSChartTableCell class] forCellReuseIdentifier:kGMSChartListViewControllerCellIdentifier];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return GMSChartListViewControllerRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GMSChartTableCell *cell = [tableView dequeueReusableCellWithIdentifier:kGMSChartListViewControllerCellIdentifier forIndexPath:indexPath];    
    cell.textLabel.text = indexPath.row == GMSChartListViewControllerRowLineChart ? kGMSStringLabelAverageDailyRainfall : kGMSStringLabelAverageMonthlyTemperature;
    cell.detailTextLabel.text = indexPath.row == GMSChartListViewControllerRowLineChart ? kGMSStringLabelSanFrancisco2013 : kGMSStringLabelWorldwide2012;
    cell.type = indexPath.row == GMSChartListViewControllerRowLineChart ? GMSChartTableCellTypeLineChart : GMSChartTableCellTypeBarChart;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kGMSChartListViewControllerCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == GMSChartListViewControllerRowLineChart)
    {
        GMSLineChartViewController *lineChartController = [[GMSLineChartViewController alloc] init];
        [self.navigationController pushViewController:lineChartController animated:YES];
    }
    else if (indexPath.row == GMSChartListViewControllerRowBarChart)
    {
        GMSBarChartViewController *barChartController = [[GMSBarChartViewController alloc] init];
        [self.navigationController pushViewController:barChartController animated:YES];
    }
}

@end
