//
//  GMSChartTableCell.m
//  GMSChartViewDemo
//
//  Created by Terry Worona on 11/8/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "GMSChartTableCell.h"

@implementation GMSChartTableCell

#pragma mark - Alloc/Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

#pragma mark - Setters

- (void)setType:(GMSChartTableCellType)type
{
    _type = type;
    self.accessoryView = [[UIImageView alloc] initWithImage:_type == GMSChartTableCellTypeBarChart ? [UIImage imageNamed:GMSImageIconBarChart] : [UIImage imageNamed:GMSImageIconLineChart]];
}

@end
