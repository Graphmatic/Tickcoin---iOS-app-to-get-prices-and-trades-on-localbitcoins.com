//
//  GMSlocationService.m
//  tickCoin
//
//  Created by rio on 19/03/2018.
//  Copyright © 2018 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@interface GMSLocationServices : NSObject <CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

- (void)startLocationServices;
-(CLLocationCoordinate2D)getLocation;

@end
