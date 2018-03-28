//
//  GMSmapTabCell.h
//  tickCoin
//
//  Created by rio on 28/03/2018.
//  Copyright © 2018 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMSmapTabCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *sellButton;

@end
