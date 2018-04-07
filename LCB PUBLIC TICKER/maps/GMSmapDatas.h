//
//  GMSmapDatas.h
//  tickCoin
//
//  Created by rio on 28/03/2018.
//  Copyright © 2018 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GMSmapDatas : NSObject
+(GMSmapDatas*)sharedMapData;
@property  (retain, nonatomic) NSMutableDictionary *addList;
@property (atomic) BOOL apiSuccess;
@property (atomic, retain) NSString *apiError;
@property (nonatomic, retain) CLLocationManager *myLocationManager;
@property (nonatomic) CLLocationCoordinate2D currentUserPosition;
@property (readwrite) BOOL isReady;
@property (readwrite) BOOL isTest;
@end
