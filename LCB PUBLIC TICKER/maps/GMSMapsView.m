//
//  GMSBidsView.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2018.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//
// 44,836019, -0,565586

#import "GMSMapsView.h"
#import "GMSGlobals.h"
#import "GMSmapTabCell.h"


@interface GMSMapsView ()
{
    CLLocationManager *myLocationManager;
}
@end

@implementation GMSMapsView

@synthesize headerImg, myLocationManager, mapView, currentUserPosition, tableView, mapDatas;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // layout
    // get parent view size
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = (self.view.bounds.size.height / 100) * 94;
    
    // Globals *glob = [Globals globals];

    
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
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, mapOrigY, viewWidth, viewHeight) ];
    
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
    
    CGFloat tableViewOrigin = mapOrigY + self.mapView.frame.size.height; // tableView so is not visible
    
    //Table view
    [self.tableView setFrame:CGRectMake(0, tableViewOrigin, viewWidth, (viewHeight - tableViewOrigin))];
    [self.view addSubview:self.tableView];
    CGPoint newOffset = CGPointMake(0, -[self.tableView contentInset].top);
    [self.tableView setContentOffset:newOffset animated:YES];
    
    //fetch datas
    self.mapDatas = [GMSmapDatas sharedMapData];
    [self.mapDatas addObserver:self forKeyPath:@"isReady" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    // ZOOM ON ACTUAL USER POSITION
    self.currentUserPosition = [self getLocation];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.currentUserPosition, 2*METERS_PER_KM, 2*METERS_PER_KM);
    [self.mapView setRegion:viewRegion animated:YES];
    self.mapDatas = [GMSmapDatas sharedMapData];
    // add observer
    [self.mapDatas addObserver:self forKeyPath:@"isReady" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
}


-(CLLocationCoordinate2D)getLocation
{
    CLLocation *location = [self.myLocationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    NSLog(@"Latidude %f Longitude: %f", coordinate.latitude, coordinate.longitude);
    return coordinate;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ( [keyPath isEqualToString:@"isReady"] && [[change objectForKey:@"new"]intValue] == 1 ) //  are datas ready to use ?
    {
        dispatch_async(dispatch_get_main_queue(), ^{  // we are in an block op, so ensure that UI update is done on the main thread
            [self updateAddsList];
        });
    }
}


- (void) updateAddsList
{
    long placesCount = [[[self.mapDatas.addList objectForKey:@"data"]objectForKey:@"place_count"]intValue];
    NSLog(@"refresh now tableView, row count = %lu", placesCount);
    
    [self.tableView reloadData];
    
    // adapt tableView depending on places count
    CGFloat mapOrigY = self.headerImg.topBrand.size.height;
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = (self.view.bounds.size.height / 100) * 94;
    
    if ( placesCount <= 3 ) {
        [self.mapView setFrame:CGRectMake(0, mapOrigY, viewWidth, (viewHeight - mapOrigY - (placesCount * 82) ))];
        CGFloat tableViewOrigin = mapOrigY + self.mapView.frame.size.height;
        [self.tableView setFrame:CGRectMake(0, tableViewOrigin, viewWidth, (placesCount * 82))];
    }
    else {
        [self.mapView setFrame:CGRectMake(0, mapOrigY, viewWidth, (viewHeight - mapOrigY - (3 * 82) ))];
        CGFloat tableViewOrigin = mapOrigY + self.mapView.frame.size.height;
        [self.tableView setFrame:CGRectMake(0, tableViewOrigin, viewWidth, (3 * 82))];
    }
    
    // placing marker on the map
    for(id place in [[self.mapDatas.addList objectForKey:@"data"]objectForKey:@"places"]) {
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[place objectForKey:@"lat"]doubleValue], [[place objectForKey:@"lon"]doubleValue]);
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:coordinate];
        [annotation setTitle:[place objectForKey:@"location_string"]]; //You can set the subtitle too
        [self.mapView addAnnotation:annotation];
    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tabCellIdentifier = @"GMSmapTabCell";
    GMSmapTabCell *cell = (GMSmapTabCell*)[tableView dequeueReusableCellWithIdentifier:tabCellIdentifier];
    
    if( cell == nil ) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"mapTabCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.locationLabel.text = [[[[self.mapDatas.addList objectForKey:@"data"]objectForKey:@"places"]objectAtIndex:indexPath.row]objectForKey:@"location_string"];
    cell.sellButton.tag = indexPath.row;
    cell.buyButton.tag = indexPath.row;

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    // NSLog(@"RowCount: %d", ([[[self.addList objectForKey:@"data"]objectForKey:@"place_count"]intValue] || 0));
    // return 1; // [[[self.addList objectForKey:@"data"]objectForKey:@"place_count"]intValue];
    return [[[self.mapDatas.addList objectForKey:@"data"]objectForKey:@"place_count"] intValue];
}

// rows height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
}

// buy Button
- (IBAction)buyButton:(id)sender
{
    
}
@end

