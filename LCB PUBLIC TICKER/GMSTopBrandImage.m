//
//  GMSTopBrandImage.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import "GMSTopBrandImage.h"

@implementation GMSTopBrandImage


@synthesize topBrand;

+ (id)topImage:(NSInteger)viewIndex {
    GMSTopBrandImage *topImage = nil;
    topImage = [[self alloc] initForView:(NSInteger)viewIndex];
    
    return topImage;
}
- (id)initForView:(NSInteger)viewIndex
{

       NSLog(@"int header: %ld", (long)viewIndex);
    if (self = [super init])
        {
         self.topBrand = [[UIImage alloc]init];
            if ( IS_IPAD )
            {
                NSLog(@"ipad");
                switch (viewIndex)
                 {
                    case 0:
                        self.topBrand = [UIImage imageNamed:@"LCB_headerImgIpadBig@x2"];
                         [self setFrame:CGRectMake(1.0, 0.0, self.topBrand.size.width, self.topBrand.size.height)];
                        
                        break;
                    case 1:
                         self.topBrand = [UIImage imageNamed:@"LCB_headerImgBidsIpadBig.png"];
                         [self setFrame:CGRectMake(1.0, 0.0, self.topBrand.size.width, self.topBrand.size.height)];
                         
                         break;
                     case 2:
                         self.topBrand = [UIImage imageNamed:@"LCB_headerImgAsksIpadBig.png"];
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
                   self.topBrand = [UIImage imageNamed:@"header_exchange"];
                    break;
                case 1:
                    self.topBrand = [UIImage imageNamed:@"header_bids"];
                    break;
                case 2:
                    self.topBrand = [UIImage imageNamed:@"LCB-headerImgAsks.png"];
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

@end
