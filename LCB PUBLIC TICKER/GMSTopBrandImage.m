//
//  GMSTopBrandImage.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import "GMSTopBrandImage.h"
#import <sys/sysctl.h>
#import <sys/utsname.h>

@implementation GMSTopBrandImage


@synthesize topBrand;

+ (id)topImage:(NSInteger)viewIndex {
    GMSTopBrandImage *topImage = nil;
    topImage = [[self alloc] initForView:(NSInteger)viewIndex];
    
    return topImage;
}
- (id)initForView:(NSInteger)viewIndex
{

    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *currentDevice = [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
    NSString *currentSimulatorDevice = [NSString stringWithCString:getenv("SIMULATOR_MODEL_IDENTIFIER")
                                                 encoding:NSUTF8StringEncoding];
 

    if (self = [super init])
        {
         self.topBrand = [[UIImage alloc]init];
            if ( IS_IPAD )
            {
                NSLog(@"ipad");
                switch (viewIndex)
                 {
                    case 0:
                        self.topBrand = [UIImage imageNamed:@"header_exchange_ipad"];
                         [self setFrame:CGRectMake(1.0, 0.0, self.topBrand.size.width, self.topBrand.size.height)];
                        
                        break;
                    case 1:
                         self.topBrand = [UIImage imageNamed:@"header_bids_half"];
                         [self setFrame:CGRectMake(1.0, 0.0, self.topBrand.size.width, self.topBrand.size.height)];
                         
                         break;
                     case 2:
                         self.topBrand = [UIImage imageNamed:@"header_asks_half"];
                         [self setFrame:CGRectMake(0.0, 0.0, self.topBrand.size.width, self.topBrand.size.height)];
                         
                         break;
                     case 3:
                         self.topBrand = [UIImage imageNamed:@"header_charts"];
                         [self setFrame:CGRectMake(1.0, 0.0, self.topBrand.size.width, self.topBrand.size.height)];
                         break;
//                     default:
//                         self.topBrand = [UIImage imageNamed:@"LCB_headerImgIpadBig.png"];
//                         [self setFrame:CGRectMake(1.0, 0.0, self.topBrand.size.width, self.topBrand.size.height)];
//                         break;
                 }
                self = [super initWithImage:self.topBrand];
              
            }
            else
            {
            switch (viewIndex) {
                case 0:
                    NSLog(@"%@ ---- %@", currentDevice, currentSimulatorDevice);
                    if ( IS_IPHONE_6_7_8 )
                    {
                        self.topBrand = [UIImage imageNamed:@"header_exchange_750"];
                    }
                    else if ( IS_IPHONE_PLUS )
                    {
                        self.topBrand = [UIImage imageNamed:@"header_exchange_1242"];
                    }
                    else if ( IS_IPHONE_X )
                    {
                        self.topBrand = [UIImage imageNamed:@"header_exchange_1125"];
                    }
                    else   // ( IS_IPHONE_4_5 )
                    {
                        self.topBrand = [UIImage imageNamed:@"header_exchange"];
                    }
                
                    break;
                case 1:
                    self.topBrand = [UIImage imageNamed:@"header_bids"];
                    break;
                case 2:
                    self.topBrand = [UIImage imageNamed:@"header_asks"];
                    break;
                case 3:
                    self.topBrand = [UIImage imageNamed:@"header_charts"];
                    break;
                default:
                    self.topBrand = [UIImage imageNamed:@"LCB_headerImg.png"];
                    break;
            }
           
         [self setFrame:CGRectMake(0.0, 0.0, self.topBrand.size.width, self.topBrand.size.height)];
         self = [super initWithImage:self.topBrand];
            }
        }
    return self;
   
}

//@"iPhone5,1" on iPhone 5 (model A1428, AT&T/Canada)
//@"iPhone5,2" on iPhone 5 (model A1429, everything else)
//@"iPhone5,3" on iPhone 5c (model A1456, A1532 | GSM)
//@"iPhone5,4" on iPhone 5c (model A1507, A1516, A1526 (China), A1529 | Global)
//@"iPhone6,1" on iPhone 5s (model A1433, A1533 | GSM)
//@"iPhone6,2" on iPhone 5s (model A1457, A1518, A1528 (China), A1530 | Global)
//@"iPhone8,4" on iPhone SE

//@"iPhone7,2" on iPhone 6
//@"iPhone8,1" on iPhone 6S
//@"iPhone9,1" on iPhone 7 (CDMA)
//@"iPhone9,3" on iPhone 7 (GSM)
//@"iPhone10,1" on iPhone 8 (CDMA)
//@"iPhone10,4" on iPhone 8 (GSM)

//@"iPhone8,2" on iPhone 6S Plus
//@"iPhone7,1" on iPhone 6 Plus
//@"iPhone9,2" on iPhone 7 Plus (CDMA)
//@"iPhone9,4" on iPhone 7 Plus (GSM)
//@"iPhone10,2" on iPhone 8 Plus (CDMA)
//@"iPhone10,5" on iPhone 8 Plus (GSM)

//@"iPhone10,3" on iPhone X (CDMA)
//@"iPhone10,6" on iPhone X (GSM)
@end
