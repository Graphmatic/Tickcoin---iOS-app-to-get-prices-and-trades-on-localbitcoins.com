//
//  GMSTopBrandImage.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMSTopBrandImage : UIImageView
{    
  UIImage *topBrand;
}
+ (id)topImage:(NSInteger)viewIndex;

@property (atomic, strong) UIImage *topBrand;

@end
