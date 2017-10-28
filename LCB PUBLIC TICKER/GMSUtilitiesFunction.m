//
//  GMSUtilitiesFunction.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 30/03/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import "GMSUtilitiesFunction.h"

@implementation GMSUtilitiesFunction

//format with currency symbol
+ (NSString*) currencyFormatThat:(NSString *)theStringVal
{
    NSDecimalNumber *toNumber = [NSDecimalNumber decimalNumberWithString:theStringVal];
    NSNumberFormatter *numFormatterCur = [[NSNumberFormatter alloc] init];
    [numFormatterCur setNumberStyle:NSNumberFormatterDecimalStyle];
    numFormatterCur.locale = [NSLocale currentLocale];
    //currency formatting
    [numFormatterCur setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numFormatterCur setCurrencyCode:currentCurrency];
    [numFormatterCur setMaximumFractionDigits:2];
    NSString* stringCurrencyFormat = [numFormatterCur stringFromNumber:toNumber];
    return stringCurrencyFormat;
}
//round to two decimal
+ (NSString*)roundTwoDecimal:(NSString *)theNumb
{
    NSDecimalNumber *tmpN = [NSDecimalNumber decimalNumberWithString:theNumb];
    NSNumberFormatter *numFormatterTwoDec = [[NSNumberFormatter alloc] init];
    [numFormatterTwoDec setNumberStyle:NSNumberFormatterDecimalStyle];
    numFormatterTwoDec.locale = [NSLocale currentLocale];
    [numFormatterTwoDec setMaximumFractionDigits:2];
    NSString* numbTwoDec = [numFormatterTwoDec stringFromNumber:tmpN];
    return numbTwoDec;
}
//return last price variation string
+ (int) getVariation: (NSString *)newDayPrice oldDayPrice:(NSString *)oldDayPrice
{
    int newLP = [newDayPrice integerValue];
    int oldLP = [oldDayPrice integerValue];
    return oldLP - newLP;
}


//Reorder and merge orderbook
+(NSMutableArray*)listingCleaned:(NSMutableArray*)rawArray maxDev:(float)maxDeviation maxPhigh:(float)maxPhigh maxPlow:(float)maxPlow
{

    NSMutableArray *listingCleaned = [[NSMutableArray alloc]init];
    NSMutableArray *listingPriceList = [[NSMutableArray alloc]init];
    for(int x = 0; x < [rawArray count]; x++)
    {
        NSString *priceA = [[rawArray objectAtIndex:x]objectAtIndex:0];
        if (![listingPriceList containsObject:priceA])
        {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", priceA];
            NSArray *results = [rawArray filteredArrayUsingPredicate:predicate];
            int sumThemAll = 0;
            for(int y = 0; y < [results count]; y++)
            {
                sumThemAll += [[[results objectAtIndex:y]objectAtIndex:1]integerValue];
            }
            if (maxDeviation != 301)
            {
                int testPriceDeviation = [priceA integerValue];
                if((testPriceDeviation > maxPlow ) && (testPriceDeviation < maxPhigh))
                {
                    NSString *amount = [NSString stringWithFormat:@"%d",sumThemAll];
                    NSMutableArray *batched = [[NSMutableArray alloc]init];
                    [batched addObject:priceA];
                    [batched addObject:amount];
                    [listingCleaned addObject:batched];
                }
            }
            else
            {
                NSString *amount = [NSString stringWithFormat:@"%d",sumThemAll];
                NSMutableArray *batched = [[NSMutableArray alloc]init];
                [batched addObject:priceA];
                [batched addObject:amount];
                [listingCleaned addObject:batched];
            }
            [listingPriceList addObject:priceA];
        }
    }
    return listingCleaned;
}
+(NSDate *)roundDateToHour:(NSDate *)date
{
    NSDateComponents *time = [[NSCalendar currentCalendar]
    						  components:NSCalendarUnitHour | NSCalendarUnitMinute
    						  fromDate:date];
    NSInteger minutes = [time minute];
    int remain = minutes % 60;
    // if less then 3 then round down
 
    	// Add the remainder of time to the date to round it up evenly
    	date = [date dateByAddingTimeInterval:60*(60-remain)];
    NSTimeInterval rnd = floor([date timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    NSDate *theRoundedDate = [NSDate dateWithTimeIntervalSinceReferenceDate:rnd];
    return theRoundedDate;
}
//build orderBookUrl
+ (NSString*)orderBookUrl
{
    NSMutableString* startURL = [[NSMutableString alloc] initWithString:[tickerURLstart stringByAppendingString:currentCurrency]];
    NSString *fullURL = [[NSString alloc] initWithString:[startURL stringByAppendingString:tickerURLOrderBookEnd]];
    return fullURL;
}
//build url for chart
+ (NSString*)graphUrl
{
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    graphRequestStart = [today dateByAddingTimeInterval: -secondsPerDay];
    graphRequestStart = [self roundDateToHour:graphRequestStart];
    NSTimeInterval since = ([graphRequestStart timeIntervalSince1970]);
    
    NSInteger sinceInt = since;
    NSString *sinceString = [[NSString alloc]init];
    sinceString = [NSString stringWithFormat:@"%ld", (long)sinceInt ];
    
   

    NSMutableString* startURL = [[NSMutableString alloc] initWithString:[graphURLStart stringByAppendingString:currentCurrency]];
    NSString *tmpUrl = [[NSString alloc] initWithString:[startURL stringByAppendingString:graphURLEnd]];
    NSString *fullURL = [[NSString alloc] initWithString:[tmpUrl stringByAppendingString:sinceString]];
    return fullURL;
}

+ (NSString*)verifyAndForceCastToString:(id)theVar
{
    if(!theVar || [theVar isKindOfClass:[NSNull class]])
    {
        NSString  *toString = NSLocalizedString(@"_NO_DATAS", @"no data");
        return toString;
    }
    else
    {
        if([theVar isKindOfClass:[NSNumber class]])
        {
            NSString  *toString = [theVar stringValue];
            return toString;
        }
        else if ([theVar isKindOfClass:[NSString class]])
        {
            return theVar;
        }
        else
        {
            NSString  *toString = NSLocalizedString(@"_INVALID_DATAS", @"invalid data");
            return toString;
        }
        
    }
}

// use that to spread button equally in their parent view
// Source : https://stackoverflow.com/questions/18706444/simplest-way-to-evenly-distribute-uibuttons-horizontally-across-width-of-view-co

+ (void) evenlySpaceTheseButtonsInThisView : (NSArray *) buttonArray : (UIView *) thisView {
    int widthOfAllButtons = 0;
    for (int i = 0; i < buttonArray.count; i++) {
        UIButton *thisButton = [buttonArray objectAtIndex:i];
        [thisButton setCenter:CGPointMake(0, thisView.frame.size.height / 2.0)];
        widthOfAllButtons = widthOfAllButtons + thisButton.frame.size.width;
    }
    
    int spaceBetweenButtons = (thisView.frame.size.width - widthOfAllButtons) / (buttonArray.count + 1);
    
    UIButton *lastButton = nil;
    for (int i = 0; i < buttonArray.count; i++) {
        UIButton *thisButton = [buttonArray objectAtIndex:i];
        if (lastButton == nil) {
            [thisButton setFrame:CGRectMake(spaceBetweenButtons, thisButton.frame.origin.y, thisButton.frame.size.width, thisButton.frame.size.height)];
        } else {
            [thisButton setFrame:CGRectMake(spaceBetweenButtons + lastButton.frame.origin.x + lastButton.frame.size.width, thisButton.frame.origin.y, thisButton.frame.size.width, thisButton.frame.size.height)];
        }
        
        lastButton = thisButton;
    }
}

@end
