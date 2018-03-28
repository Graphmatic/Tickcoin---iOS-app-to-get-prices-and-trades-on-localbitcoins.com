//
//  GMSmapDatas.m
//  tickCoin
//
//  Created by rio on 28/03/2018.
//  Copyright © 2018 ___GRAPHMATIC-STUDIO-2014___. All rights reserved.
//

#import "GMSmapDatas.h"
#import "GMSGlobals.h"

@implementation GMSmapDatas

@synthesize addList, apiSuccess, apiError, myLocationManager, currentUserPosition, isReady;

static GMSmapDatas * _sharedMapData = nil;

+(GMSmapDatas*)sharedMapData
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        if ( !_sharedMapData ) {
            [_sharedMapData resetSharedInstance];
            _sharedMapData = [[self alloc] init];
        }
    });
    return _sharedMapData;
}

+(id)alloc
{
    @synchronized([GMSmapDatas class])
    {
        NSAssert(_sharedMapData == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedMapData = [super alloc];
        return _sharedMapData;
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if ( self != nil ){
        // debug
        NSLog(@"initializing a _sharedMapData");
        //User Location
        //initialize the Location Manager
        self.myLocationManager = [[CLLocationManager alloc] init];
        //
        [self.myLocationManager requestWhenInUseAuthorization];
        [self.myLocationManager requestAlwaysAuthorization];
        
        [self.myLocationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.myLocationManager setDistanceFilter:kCLDistanceFilterNone];
        
        [self.myLocationManager startUpdatingLocation];

        self.currentUserPosition = [self getLocation];
        // start web query
        [self mapApiQuery];
    }
    return self;
}

- (void)resetSharedInstance {
    @synchronized(self) {
        _sharedMapData = nil;
    }
}

- (void)fullUpdate:(NSNotification*)theNotif
{
    [self resetSharedInstance];
    _sharedMapData = [self init];
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
             self.isReady = YES;
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
             self.isReady = YES;
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         self.apiSuccess = false;
         
     }];
    [operation start];
}
@end
