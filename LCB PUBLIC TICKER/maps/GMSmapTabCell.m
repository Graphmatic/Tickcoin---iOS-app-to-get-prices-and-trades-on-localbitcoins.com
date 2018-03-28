//
//  GMSmapTabCell.m
//  tickCoin
//
//  Created by rio on 28/03/2018.
//  Copyright © 2018 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#import "GMSmapTabCell.h"

@implementation GMSmapTabCell

@synthesize locationLabel, sellButton, buyButton;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)buyButtonAction:(id)sender {
    
}

- (IBAction)sellButtonAction:(id)sender {
    
}
@end
