//
//  GSutilitiesFunc.m
//  localbitcoins
//
//  Created by frup on 27/03/2014.
//  Copyright (c) 2014 Graphmatic.Studio. All rights reserved.
//

#import "GMSutilitiesFunc.h"

@implementation GMSutilitiesFunc

//format with currency symbol
+ (NSString*) currencyFormatThat: (NSString *) theStringVal
{
    NSDecimalNumber *toNumber = [NSDecimalNumber decimalNumberWithString:theStringVal];

    NSLog(@"cellval normal : %@",toNumber);
    NSNumberFormatter *numFormatterCur = [[NSNumberFormatter alloc] init];
    [numFormatterCur setNumberStyle:NSNumberFormatterDecimalStyle];
//    NSNumber *cellNumber = [numFormatterCur numberStyle toNumber];
//    NSLog(@"cellval normal : %@",cellNumber);
    //currency formatting
    [numFormatterCur setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numFormatterCur setCurrencyCode:devise];
    [numFormatterCur setMaximumFractionDigits:2];
    NSString* stringCurrencyFormat = [numFormatterCur stringFromNumber:toNumber];
    return stringCurrencyFormat;
}
//return last price variation string
+ (int) getVariation: (NSString *)newDayPrice oldDayPrice:(NSString *)oldDayPrice
{
    NSNumberFormatter *numFormatterVar = [[NSNumberFormatter alloc] init];
    [numFormatterVar setNumberStyle:NSNumberFormatterNoStyle];
    int newLP = [[numFormatterVar numberFromString:newDayPrice] intValue];
    int oldLP = [[numFormatterVar numberFromString:oldDayPrice] intValue];
    return oldLP - newLP;
}


//Reorder and merge
+(NSMutableArray*)listingCleaned:(NSMutableArray*)rawArray maxDev:(float)maxDeviation maxPhigh:(float)maxPhigh maxPlow:(float)maxPlow
{
    NSLog(@"orderbids start = %@", rawArray);
     NSLog(@"maxDeviation return = %f", maxDeviation);
     NSLog(@"maxPhigh return = %f", maxPhigh);
     NSLog(@"maxPlow return = %f", maxPlow);
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
//build orderBookUrl
+ (NSString*)orderBookUrl
{
    NSMutableString* startURL = [[NSMutableString alloc] initWithString:[urlStart stringByAppendingString:devise]];
    NSString *fullURL = [[NSString alloc] initWithString:[startURL stringByAppendingString:tickerURLOrderBookEnd]];
    return fullURL;
}
@end
