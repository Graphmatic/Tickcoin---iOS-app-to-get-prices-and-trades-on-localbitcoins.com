//
//  GMSSocialStack.h
//  tickCoin
//
//  Created by rio on 26/10/2017.
//  Copyright © 2017 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#ifndef GMSSocialStack_h
#define GMSSocialStack_h

#endif /* GMSSocialStack_h */


#import <UIKit/UIKit.h>

@interface GMSSocialStack : UIStackView
{
    UIButton     *facebookIco;
    UIButton     *tweeterIco;
    UIButton     *mailIco;
    UIButton     *messageIco;
}

+ (id)socialStack:(CGFloat)posY;

@property (strong, nonatomic) IBOutlet GMSSocialStack *socialStack;

@property (weak, nonatomic) IBOutlet UIButton *tweetIt;
@property (weak, nonatomic) IBOutlet UIButton *faceBookIt;
@property (weak, nonatomic) IBOutlet UIButton *emailIt;
@property (weak, nonatomic) IBOutlet UIButton *messageIt;
@end
