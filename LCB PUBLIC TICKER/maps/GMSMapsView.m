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

@synthesize headerImg, myLocationManager, mapView, currentUserPosition, addList, apiSuccess, apiError, tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // layout
    // get parent view size
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = (self.view.bounds.size.height / 100) * 94;
    
    Globals *glob = [Globals globals];
    self.apiSuccess = false;
    
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
    
    CGFloat tableViewOrigin = mapOrigY + self.mapView.frame.size.height;
    
    //Table view
    [self.tableView setFrame:CGRectMake(0, tableViewOrigin, viewWidth, (viewHeight - tableViewOrigin))];
    [self.view addSubview:self.tableView];
    CGPoint newOffset = CGPointMake(0, -[self.tableView contentInset].top);
    [self.tableView setContentOffset:newOffset animated:YES];
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
         if( [self.addList objectForKey:@"error"] != nil )
         {
             NSLog(@"map adds query error: %@", [self.addList objectForKey:@"error"]);
             self.apiSuccess = false;
             self.apiError = [[self.addList objectForKey:@"error"]objectForKey:@"message"];
             [self updateAddsList];
         }
         else
         {
             if ( [[self.addList objectForKey:@"data"]objectForKey:@"place_count"] != 0 )
             {
                 self.apiSuccess = true;
             }
             else
             {
                 self.apiError = [NSMutableString  stringWithFormat:NSLocalizedString(@"_API_ERROR_NO_ADD" , "no add around")];
                 self.apiSuccess = false;
             }
             [self updateAddsList];
        }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         self.apiSuccess = false;
         
     }];
    [operation start];
}

- (void) updateAddsList
{
    NSLog(@"refresh now tableView, row count = %lu", [[[self.addList objectForKey:@"data"]objectForKey:@"places"] count]);
    [self.tableView reloadData];

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

//-----------------------------------------------------------------------------------------------------------------------------//
//                                                    //tableView//
//-----------------------------------------------------------------------------------------------------------------------------//

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tableHeaderBG=[[UIView alloc]initWithFrame:CGRectMake(0,0,320,1)];
    tableHeaderBG.backgroundColor =  [UIColor clearColor];
    return tableHeaderBG;
}

- (nonnull UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //local var to hold value
    NSString *cellVal = [[[[self.addList objectForKey:@"data"]objectForKey:@"places"]objectAtIndex:indexPath.row]objectForKey:@"location_string"];
    //get title for the cell
//    NSString *key = [self.tickerDatas.cellTitles objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"Item";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = GMSColorDarkGrey;
    
    //populate cell
    cell.detailTextLabel.text = cellVal;

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    // NSLog(@"RowCount: %d", ([[[self.addList objectForKey:@"data"]objectForKey:@"place_count"]intValue] || 0));
    // return 1; // [[[self.addList objectForKey:@"data"]objectForKey:@"place_count"]intValue];
    return [[[self.addList objectForKey:@"data"]objectForKey:@"places"] count];
}

// rows height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
}


@end

