//
//  GMSConstant.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#ifndef LCB_PUBLIC_TICKER_GMSConstant_h
#define LCB_PUBLIC_TICKER_GMSConstant_h


#pragma mark - Font

#define GMSHeaderFont [UIFont fontWithName:@"Avenir-BookOblique" size:14]
#define GMSFontMessage [UIFont fontWithName:@"Optima-Italic" size:16]
#define GMSAvenirNextCondensedMediumSmall [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:11]
#define GMSAvenirNextCondensedMedium [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:14]
#define GMSFontBigBgMessage [UIFont fontWithName:@"Futura-Medium" size:80]

#pragma mark color

#define GMSSColorBlueSoft [UIColor colorWithRed:0.383 green:0.412 blue:0.499 alpha:1.0]
#define GMSColorOrange [UIColor colorWithRed:0.957 green:0.443 blue:0.082 alpha:1.0]
#define GMSColorBlue [UIColor colorWithRed:0 green:0.333 blue:0.502 alpha:1.0]
#define GMSColorBlueLight [UIColor colorWithRed:0 green:0.433 blue:0.405 alpha:1.0]
#define GMSColorPurpleLight [UIColor colorWithRed:0.49 green:0.40 blue:0.56 alpha:1.0]
#define GMSColorPurpleDark [UIColor colorWithRed:0.31 green:0.25 blue:0.35 alpha:1.0]
#define GMSColorBlueGrey [UIColor colorWithRed:0.40 green:0.47 blue:0.56 alpha:1.0]
#define GMSColorBlueGreyDark [UIColor colorWithRed:0.23 green:0.25 blue:0.29 alpha:1.0]
#define GMSColorWhiteBlue [UIColor colorWithRed:0.82 green:0.83 blue:0.87 alpha:1.0]
#define GMSColorRed [UIColor colorWithRed:0.75 green:0.18 blue:0.18 alpha:1.0]
#define GMSColorYellow [UIColor colorWithRed:0.93 green:0.84 blue:0.23 alpha:1.0]
#define GMSColorCoolBlue [UIColor colorWithRed:0.25 green:0.45 blue:0.67 alpha:1.0]
#define GMSColorDarkGrey [UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0]
#define GMSColorWhite [UIColor whiteColor]
#define GMSColorBlack [UIColor blackColor]

#pragma mark - Device

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define IS_ZOOMED (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


#define IS_IPHONE_4_5 ([currentDevice isEqualToString:@"iPhone5,1"] || [currentDevice isEqualToString:@"iPhone5,2"] || [currentDevice isEqualToString:@"iPhone5,3"] || [currentDevice isEqualToString:@"iPhone5,4"] || [currentDevice isEqualToString:@"iPhone6,1"] || [currentDevice isEqualToString:@"iPhone6,2"] || [currentDevice isEqualToString:@"iPhone8,4"] || [currentSimulatorDevice isEqualToString:@"iPhone5,1"] || [currentSimulatorDevice isEqualToString:@"iPhone5,2"] || [currentSimulatorDevice isEqualToString:@"iPhone5,3"] || [currentSimulatorDevice isEqualToString:@"iPhone5,4"] || [currentSimulatorDevice isEqualToString:@"iPhone6,1"] || [currentSimulatorDevice isEqualToString:@"iPhone6,2"] || [currentSimulatorDevice isEqualToString:@"iPhone8,4"])

#define IS_IPHONE_6_7_8 ([currentDevice isEqualToString:@"iPhone7,2"] || [currentDevice isEqualToString:@"iPhone8,1"] || [currentDevice isEqualToString:@"iPhone9,1"] || [currentDevice isEqualToString:@"iPhone9,3"] || [currentDevice isEqualToString:@"iPhone10,1"] || [currentDevice isEqualToString:@"iPhone10,4"] || [currentSimulatorDevice isEqualToString:@"iPhone7,2"] || [currentSimulatorDevice isEqualToString:@"iPhone8,1"] || [currentSimulatorDevice isEqualToString:@"iPhone9,1"] || [currentSimulatorDevice isEqualToString:@"iPhone9,3"] || [currentSimulatorDevice isEqualToString:@"iPhone10,1"] || [currentSimulatorDevice isEqualToString:@"iPhone10,4"])

#define IS_IPHONE_PLUS ([currentDevice isEqualToString:@"iPhone8,2"] || [currentDevice isEqualToString:@"iPhone7,1"] || [currentDevice isEqualToString:@"iPhone9,2"] || [currentDevice isEqualToString:@"iPhone9,4"] || [currentDevice isEqualToString:@"iPhone10,2"] || [currentDevice isEqualToString:@"iPhone10,5"] || [currentSimulatorDevice isEqualToString:@"iPhone8,2"] || [currentSimulatorDevice isEqualToString:@"iPhone7,1"] || [currentSimulatorDevice isEqualToString:@"iPhone9,2"] || [currentSimulatorDevice isEqualToString:@"iPhone9,4"] || [currentSimulatorDevice isEqualToString:@"iPhone10,2"] || [currentSimulatorDevice isEqualToString:@"iPhone10,5"])

#define IS_IPHONE_X_XR_XS ([currentDevice isEqualToString:@"iPhone10,3"] || [currentDevice isEqualToString:@"iPhone10,6"] || [currentDevice isEqualToString:@"iPhone11,8"] || [currentDevice isEqualToString:@"iPhone11,2"] || [currentSimulatorDevice isEqualToString:@"iPhone10,3"] || [currentSimulatorDevice isEqualToString:@"iPhone10,6"] || [currentSimulatorDevice isEqualToString:@"iPhone11,8"] || [currentSimulatorDevice isEqualToString:@"iPhone11,2"])

#define IS_IPHONE_XS_MAX ([currentDevice isEqualToString:@"iPhone11,4"] || [currentDevice isEqualToString:@"iPhone11,6"] || [currentSimulatorDevice isEqualToString:@"iPhone11,4"] || [currentSimulatorDevice isEqualToString:@"iPhone11,6"] )

#endif

#define METERS_PER_KM 1000
