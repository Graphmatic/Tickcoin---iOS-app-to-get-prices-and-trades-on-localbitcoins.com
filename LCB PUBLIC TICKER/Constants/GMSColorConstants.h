//
//  GMSColorConstants.h
//  GMSChartViewDemo
//
//  Created by Terry Worona on 11/7/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#define UIColorFromHex(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]

#pragma mark - Navigation

#define kGMSColorNavigationBarTint UIColorFromHex(0xFFFFFF)
#define kGMSColorNavigationTint UIColorFromHex(0x000000)

#pragma mark - Bar Chart

#define kGMSColorBarChartControllerBackground UIColorFromHex(0x313131)
#define kGMSColorBarChartBackground [UIColor whiteColor]
#define kGMSColorBarChartBarBlue [UIColor colorWithRed:0 green:0.333 blue:0.502 alpha:1.0]
#define kGMSColorBarChartBarGreen [UIColor colorWithRed:0.957 green:0.443 blue:0.082 alpha:1.0]
#define kGMSColorBarChartHeaderSeparatorColor UIColorFromHex(0x686868)

#pragma mark - Tooltips

#define GMSColorTooltipColor [UIColor colorWithWhite:1.0 alpha:0.9]
#define GMSColorTooltipTextColor UIColorFromHex(0x313131)
