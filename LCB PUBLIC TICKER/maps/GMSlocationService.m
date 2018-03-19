//
//  GMSlocationService.m
//  tickCoin
//
//  Created by rio on 19/03/2018.
//  Copyright © 2018 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//


#import "GMSlocationService.h"


@implementation GMSLocationServices

@synthesize locationManager, currentLocation;

- (void)startLocationServices {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        NSLog(@"updating Location");
        [locationManager startUpdatingLocation];
//        CLLocation *location = [locationManager location];
//        CLLocationCoordinate2D coordinate = [location coordinate];
    } else {
        NSLog(@"Location services is not enabled");
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    self.currentLocation = newLocation;
    
    NSLog(@"Latidude %f Longitude: %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [locationManager stopUpdatingLocation];
    NSLog(@"Update failed with error: %@", error);
}

-(CLLocationCoordinate2D)getLocation
{
//    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
//    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    NSLog(@"Latidude %f Longitude: %f", coordinate.latitude, coordinate.longitude);
    return coordinate;
}

@end
