//
//  GMSBidsView.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//
// 44,836019, -0,565586

#import "GMSMapsView.h"


@interface GMSMapsView ()
{
    CLLocationManager *myLocationManager;
}
@end

@implementation GMSMapsView

@synthesize headerImg, myLocationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // layout
    // get parent view size
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = (self.view.bounds.size.height / 100) * 94;
    
    Globals *glob = [Globals globals];
    
    //add header
    self.headerImg = [GMSTopBrandImage topImage:4];
    [self.view addSubview:self.headerImg];
    
    //User Location
    //initialize the Location Manager
    self.myLocationManager = [[CLLocationManager alloc] init];
    //
    [self.myLocationManager requestWhenInUseAuthorization];
    [self.myLocationManager requestAlwaysAuthorization];
    
    [self.myLocationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.myLocationManager setDistanceFilter:kCLDistanceFilterNone];
    
    [self.myLocationManager startUpdatingLocation];

    CGFloat mapOrigY = self.headerImg.topBrand.size.height;
    
    //create a map that is the size of the screen
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, mapOrigY, viewWidth, viewHeight / 2) ];
    
    //init map
    [mapView setMapType: MKMapTypeStandard];
    [mapView setShowsUserLocation:true]; //show the user's location on the map, requires CoreLocation
    [mapView setScrollEnabled:true];//the default anyway
    [mapView setZoomEnabled:true];//the default anyway
    [mapView setMapType:MKMapTypeStandard];
    [mapView setShowsCompass:false];
    [mapView setShowsScale:true];
    [mapView setZoomEnabled:true];
    
    // ZOOM ON ACTUAL USER POSITION
    CLLocationCoordinate2D actualPos = [self getLocation];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(actualPos, 0.5*METERS_PER_KM, 0.5*METERS_PER_KM);
    [mapView setRegion:viewRegion animated:YES];
    
    [self.view addSubview:mapView];
}

- (void)viewWillAppear:(BOOL)animated {

}


-(CLLocationCoordinate2D)getLocation
{
    CLLocation *location = [self.myLocationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    NSLog(@"Latidude %f Longitude: %f", coordinate.latitude, coordinate.longitude);
    return coordinate;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload
{
    
}

- (void) viewWillDisappear:(BOOL)animated
{
   
}

- (void) applicationDidEnterBackground:(NSNotification*)notification
{
    
}

@end

