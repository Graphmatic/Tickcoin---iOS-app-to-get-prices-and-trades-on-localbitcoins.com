//
//  GMSlabelFromJson.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 30/03/2014.
//  Copyright (c) 2014 frup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMSlabelFromJson : NSObject {
    NSArray *labelsArrayOfDict;
}
@property (nonatomic, retain) NSArray *labelsArrayOfDict;
+ (void)initialize;
+ (GMSlabelFromJson *)labels;
@end
