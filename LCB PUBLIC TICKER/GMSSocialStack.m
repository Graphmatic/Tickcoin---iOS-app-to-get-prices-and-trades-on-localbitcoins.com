//
//  GMSSocialStack.m
//  tickCoin
//
//  Created by rio on 26/10/2017.
//  Copyright © 2017 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMSSocialStack.h"

@implementation GMSSocialStack;

@synthesize faceBookIt, tweetIt, emailIt, messageIt;


+ (id)socialStack:(CGFloat)posY {
    
    GMSSocialStack *socialStack = nil;
    
    socialStack = [[self alloc] initWithPosY:posY];
    
    return socialStack;
}

- (id)initWithPosY:(CGFloat)posY
{
    self = [super init];
    
    if (self != nil)
    {
        CGRect frame = CGRectMake(0.0, posY, self.window.bounds.size.width, 50.0);
        self = [super initWithFrame:frame];

        self.backgroundColor = GMSColorBlack;
        self.axis = UILayoutConstraintAxisHorizontal;
        self.distribution = UIStackViewDistributionEqualSpacing;
        self.alignment = UIStackViewAlignmentCenter;
//        self.spacing = 10;
        
        [self addArrangedSubview:faceBookIt];
        [self addArrangedSubview:tweetIt];
        [self addArrangedSubview:emailIt];
        [self addArrangedSubview:messageIt];

    }
    return self;
}
@end


