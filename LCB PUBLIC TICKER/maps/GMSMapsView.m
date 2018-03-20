//
//  GMSBidsView.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//
// 44,836019, -0,565586

#import "GMSMapsView.h"
#import "GMSGlobals.h"

@interface GMSMapsView ()
{
    CLLocationManager *myLocationManager;
}
@end

@implementation GMSMapsView

@synthesize headerImg, myLocationManager, mapView, currentUserPosition, addList;

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
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, mapOrigY, viewWidth, viewHeight / 2) ];
    
    //init map
    [self.mapView setMapType: MKMapTypeStandard];
    [self.mapView setShowsUserLocation:true]; //show the user's location on the map, requires CoreLocation
    [self.mapView setScrollEnabled:true];//the default anyway
    [self.mapView setZoomEnabled:true];//the default anyway
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setShowsCompass:false];
    [self.mapView setShowsScale:true];
    [self.mapView setZoomEnabled:true];
    
    // ZOOM ON ACTUAL USER POSITION
    self.currentUserPosition = [self getLocation];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.currentUserPosition, 2*METERS_PER_KM, 2*METERS_PER_KM);
    [self.mapView setRegion:viewRegion animated:YES];
    
    [self.view addSubview:self.mapView];
}

- (void)viewWillAppear:(BOOL)animated {
    // ZOOM ON ACTUAL USER POSITION
    self.currentUserPosition = [self getLocation];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.currentUserPosition, 2*METERS_PER_KM, 2*METERS_PER_KM);
    [self.mapView setRegion:viewRegion animated:YES];
    [self mapApiQuery];
}


-(CLLocationCoordinate2D)getLocation
{
    CLLocation *location = [self.myLocationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    NSLog(@"Latidude %f Longitude: %f", coordinate.latitude, coordinate.longitude);
    return coordinate;
}

- (void)mapApiQuery
{
    Globals *glob = [Globals globals];
    NSString *url = [glob mapURL:self.currentUserPosition];
    NSLog(@"URL : %@", url);
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"%@", responseObject);
         self.addList = [[NSMutableDictionary alloc]initWithDictionary: responseObject];
         NSLog(@"datas: %@", [self.addList objectForKey:@"data"]);
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         
     }];
    [operation start];
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

