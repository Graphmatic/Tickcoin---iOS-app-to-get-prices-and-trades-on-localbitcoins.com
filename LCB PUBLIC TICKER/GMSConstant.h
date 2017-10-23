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
#define GMSFontBigBgMessage [UIFont fontWithName:@"Futura-Medium" size:80]
#pragma mark color

#define GMSColorOrange [UIColor colorWithRed:0.957 green:0.443 blue:0.082 alpha:1.0]
#define GMSColorBlue [UIColor colorWithRed:0 green:0.333 blue:0.502 alpha:1.0]
#define GMSColorBlueLight [UIColor colorWithRed:0 green:0.433 blue:0.405 alpha:1.0]
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

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#endif