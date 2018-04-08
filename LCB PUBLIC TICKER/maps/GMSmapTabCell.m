//
//  GMSmapTabCell.m
//  tickCoin
//
//  Created by rio on 28/03/2018.
//  Copyright © 2018 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#import "GMSmapTabCell.h"

@implementation GMSmapTabCell

@synthesize locationLabel, sellButton, buyButton, mapDatas;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.mapDatas = [GMSmapDatas sharedMapData];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)buyButtonAction:(id)sender {
    NSLog(@"BUY URL : %@", [[[[self.mapDatas.addList objectForKey:@"data"]objectForKey:@"places"]objectAtIndex:sellButton.tag]objectForKey:@"sell_local_url"] );
    [self queryJsonAddInfos:[[[[self.mapDatas.addList objectForKey:@"data"]objectForKey:@"places"]objectAtIndex:sellButton.tag]objectForKey:@"sell_local_url"]];
}

- (IBAction)sellButtonAction:(id)sender {
    NSLog(@"BUY URL : %@", [[[[self.mapDatas.addList objectForKey:@"data"]objectForKey:@"places"]objectAtIndex:buyButton.tag]objectForKey:@"buy_local_url"] );

    [self queryJsonAddInfos:[[[[self.mapDatas.addList objectForKey:@"data"]objectForKey:@"places"]objectAtIndex:buyButton.tag]objectForKey:@"buy_local_url"]];

}

- (void)queryJsonAddInfos:(NSString *)url {
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"add as json : %@", responseObject);
         NSMutableDictionary *jsonRep = [[NSMutableDictionary alloc]initWithDictionary: responseObject];
         
         NSLog(@"human url add: %@", [[[[[jsonRep objectForKey:@"data"] objectForKey:@"ad_list"]objectAtIndex:0] objectForKey:@"actions"] objectForKey:@"public_view"]);
         [self openWebAddPage:[[[[[jsonRep objectForKey:@"data"] objectForKey:@"ad_list"]objectAtIndex:0] objectForKey:@"actions"] objectForKey:@"public_view"]];
         
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"human url add failure");
         
     }];
    [operation start];
}

- (void)openWebAddPage:(NSString *)url {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:url];
    
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:URL options:@{}
           completionHandler:^(BOOL success) {
               NSLog(@"Open %@: %d",url,success);
           }];
    } else { // back compatibility with iOs9
        BOOL success = [application openURL:URL];
        NSLog(@"Open %@: %d",url,success);
    }
}
@end
