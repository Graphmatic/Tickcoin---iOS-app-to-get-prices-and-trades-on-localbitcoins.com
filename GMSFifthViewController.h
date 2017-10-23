//
//  GMSFifthViewController.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 23/05/2014.
//  Copyright (c) 2014 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMSFifthViewController : UIViewController <UIWebViewDelegate, NSXMLParserDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *tmpWebLoad;
@property (strong, nonatomic) IBOutlet UILabel *newsTitle;
@property (strong, nonatomic) IBOutlet UILabel *newsDate;
@property (strong, nonatomic) IBOutlet UIView *newsContent;
@property (strong, nonatomic) IBOutlet UITextView *newsTextview;


@property (strong, nonatomic) IBOutlet UIButton *previousPost;
@property (strong, nonatomic) IBOutlet UIButton *nextPost;
@property (strong, nonatomic) IBOutlet UILabel *gsLink;

@end
