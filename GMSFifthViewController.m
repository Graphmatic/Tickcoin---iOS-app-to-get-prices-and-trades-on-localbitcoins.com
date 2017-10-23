//
//  GMSFifthViewController.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 23/05/2014.
//  Copyright (c) 2014 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "GMSFifthViewController.h"
#import "GMSStripHtmlFromString.h"

@interface GMSFifthViewController ()
{
    NSString *getNewsFeed;
    int currentPost;
    NSXMLParser *rssParser;
	NSMutableArray *entries;
    NSMutableDictionary *post;
	NSString * currentElement;
	NSMutableString * currentTitle, * currentDate, *currentSummary;
}
@end

@implementation GMSFifthViewController
@synthesize tmpWebLoad, newsDate, newsTitle, newsContent, gsLink, previousPost, nextPost, newsTextview;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tmpWebLoad.hidden = YES;
    self.nextPost.hidden = YES;
    currentPost = 1;

    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        self.gsLink.textColor =  GMSColorWhite;
    }
     self.gsLink.text = [NSString stringWithFormat:NSLocalizedString(@"_GRAPHMATIC_MAIL", @"developed by Graphmatic Studio - graphmatic.studio@gmail.com")];
  
    //news view
    self.newsContent.layer.cornerRadius = 15;
    self.newsContent.layer.masksToBounds = YES;
    self.newsContent.backgroundColor = GMSColorBlue;
   
    self.newsTitle.textColor = GMSColorWhite;
    self.newsDate.textColor = GMSColorWhite;
    self.newsTitle.text = [NSString stringWithFormat:NSLocalizedString(@"_LOADING_NEWS", @"Loading news...:")];
    [self.newsContent addSubview:self.newsTitle];
    [self.newsContent addSubview:self.newsDate];
    [self.newsContent addSubview:self.newsTextview];
    [self.view addSubview:self.newsContent];
    [self.view addSubview:self.gsLink];
    if ([entries count] == 0) {
	//	NSString *path = @"https://www.blogger.com/feeds/1294428020443467286/posts/default";
	//	[self parseXMLFileAtURL:path];
	}
}
-(void)viewWillAppear:(BOOL)animated
{
    NSString *path = @"https://www.blogger.com/feeds/1294428020443467286/posts/default";

   [self parseXMLFileAtURL:path];
}
- (void)parseXMLFileAtURL:(NSString *)URL
{
	entries = [[NSMutableArray alloc] init];
	NSURL *xmlURL = [NSURL URLWithString:URL];

	rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    //[rssParser setDelegate:self];
    [rssParser setShouldProcessNamespaces:YES];
	[rssParser setShouldReportNamespacePrefixes:YES];
	[rssParser setShouldResolveExternalEntities:YES];
	[rssParser parse];
}
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %li )", (long)[parseError code]];
	NSLog(@"error parsing XML: %@", errorString);
    
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading blog content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	currentElement = [elementName copy];
    if ([elementName isEqualToString:@"title"]) {
		post = [[NSMutableDictionary alloc] init];
		currentTitle = [[NSMutableString alloc] init];
		currentDate = [[NSMutableString alloc] init];
        currentSummary = [[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"title"])
    {
        NSString *strippedCurrentTitle = [currentTitle stripHtml];
		[post setObject:strippedCurrentTitle forKey:@"title"];
        [post setObject:currentDate forKey:@"published"];
        [post setObject:currentSummary forKey:@"content"];
		[entries addObject:[post copy]];
    
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if ([currentElement isEqualToString:@"title"])
    {
		[currentTitle appendString:string];
	}
    else if ([currentElement isEqualToString:@"content"])
    {
		[currentSummary appendString:string];
	}
    else if ([currentElement isEqualToString:@"published"]) {
		[currentDate appendString:string];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self updateBlogPost:currentPost];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"alert memory");
}

- (void)updateBlogPost:(int)postRank
{
    NSString *tmpDate = [[entries objectAtIndex:currentPost]objectForKey:@"published"];
   tmpDate = [tmpDate substringToIndex: MIN(16, [tmpDate length])];
    NSString *cleanDate = [self userVisibleDateTimeStringForRFC3339DateTimeString:tmpDate];
    
    self.newsDate.text = cleanDate;
    self.newsTitle.text = [[entries objectAtIndex:currentPost]objectForKey:@"title"];
    NSString *contentRaw = @"<style type='text/css'>img{display:none}p,h1,h2,h3,h4,span{text-align:center,justified;background-color:transparent !important;}div{background-color:transparent !important;}</style><html><body>";
    contentRaw = [contentRaw stringByAppendingString:[[entries objectAtIndex:currentPost]objectForKey:@"content"]];
    contentRaw = [contentRaw stringByAppendingString:@"</body></html>"];
    contentRaw  = [contentRaw stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    [self.newsTextview setValue:contentRaw forKey:@"contentToHTMLString"];
  //  NSAttributedString *stringWithHTMLAttributes = [[NSAttributedString alloc]initWithString:contentRaw];
//  self.newsTextview.attributedText=stringWithHTMLAttributes;
 //   NSLog(@"%@",contentRaw);
  

     self.newsTextview.textColor = GMSColorWhite;
   // self.newsTextview.backgroundColor = GMSColorBlue;

}

- (NSString *)userVisibleDateTimeStringForRFC3339DateTimeString:(NSString *)rfc3339DateTimeString
{
    /*
     Returns a user-visible date time string that corresponds to the specified
     RFC 3339 date time string. Note that this does not handle all possible
     RFC 3339 date time strings, just one of the most common styles.
     */

    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    // Convert the RFC 3339 date time string to an NSDate.
    NSDate *date = [rfc3339DateFormatter dateFromString:rfc3339DateTimeString];
    NSString *userVisibleDateTimeString;
    if (date != nil) {
        // Convert the date object to a user-visible date string.
        NSDateFormatter *userVisibleDateFormatter = [[NSDateFormatter alloc] init];
        assert(userVisibleDateFormatter != nil);
        
        [userVisibleDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [userVisibleDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        userVisibleDateTimeString = [userVisibleDateFormatter stringFromDate:date];
    }

    return userVisibleDateTimeString;
}
- (IBAction)selectPreviousPost:(id)sender
{
    currentPost +=1;
    [self updateBlogPost:currentPost];
    if(currentPost > 0)
    {
        self.nextPost.hidden = NO;
    }
}
- (IBAction)selectNextPost:(id)sender
{
    currentPost -=1;
    [self updateBlogPost:currentPost];
    if(currentPost == 0)
    {
        self.nextPost.hidden = YES;
    }
}

@end
