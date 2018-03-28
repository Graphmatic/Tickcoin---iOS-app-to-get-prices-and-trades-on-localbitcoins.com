//
//  GMSMapsView.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 19/03/2018.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GMSmapDatas.h"

//#import "GMSlocationService.h"

#import "GMSGlobals.h"

@interface GMSMapsView : UIViewController <MKMapViewDelegate, UITableViewDelegate,UITableViewDataSource>
{


}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (strong, atomic) GMSTopBrandImage *headerImg;
@property (nonatomic, retain) CLLocationManager *myLocationManager;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic) CLLocationCoordinate2D currentUserPosition;

@property (strong, atomic) GMSmapDatas *mapDatas;

@end


