//
//  GMSAppDelegate.m
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "GMSAppDelegate.h"
#import "GMSUtilitiesFunction.h"


@implementation GMSAppDelegate

@synthesize persistantDatas;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    int cacheSizeMemory = 2*1024*1024;
    int cacheSizeDisk = 8*1024*1024;
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];

    // Override point for customization after application launch.
    self.window.backgroundColor = GMSColorWhite;
    if(!IS_IPAD)
    {
        // setup tabbar
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        UITabBar *tabBar = tabBarController.tabBar;
        UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
        UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
        UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
        UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
        UITabBarItem *tabBarItem5 = [tabBar.items objectAtIndex:4];

        tabBarItem1.selectedImage = [[UIImage imageNamed:@"change"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem1.image = [[UIImage imageNamed:@"change"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem1.title = @"exchange";
        
        tabBarItem2.selectedImage = [[UIImage imageNamed:@"charts"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem2.image = [[UIImage imageNamed:@"charts"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem2.title = @"charts";
        
        tabBarItem3.selectedImage = [[UIImage imageNamed:@"second"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem3.image = [[UIImage imageNamed:@"second"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem3.title = @"bids";
        
        tabBarItem4.selectedImage = [[UIImage imageNamed:@"second"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem4.image = [[UIImage imageNamed:@"second"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem4.title = @"asks";
        
        tabBarItem5.selectedImage = [[UIImage imageNamed:@"maps"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem5.image = [[UIImage imageNamed:@"maps"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem5.title = @"find";
    }
    [[UITabBar appearance] setBarTintColor:GMSColorBlueGrey];
    [[UITabBar appearance] setTintColor:GMSColorWhite];
    
    Globals *glob = [Globals globals];
    
    // Network
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    // Monitoring connection availability
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
    {
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi)
        {
            NSLog(@"is connection");
            [glob setNetworkAvailable:YES];
        }
        else
        {
            NSLog(@"is NO connection");
            [glob setNetworkAvailable:NO];
        }
    }];
    
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
    if([[[storage dictionaryRepresentation] allKeys] containsObject:@"currency"] && [storage objectForKey:@"currency"] != nil )
    {
        NSLog(@"not the first launch");
        [glob setCurrency:[storage objectForKey:@"currency"]];
//        if([[[storage dictionaryRepresentation] allKeys] containsObject:@"lastRecordDate"])
//        {
//            [glob setLastRecordDate:[storage objectForKey:@"lastRecordDate"]];
//        }
    }
    else
    {
        
        // setup my affiliate Tag
        NSString *affilTag = [NSString stringWithFormat:@"?ch=bms"];
        [[NSUserDefaults standardUserDefaults] setObject:affilTag forKey:@"affiliateTag"];
        // setup a default currency
        [glob setCurrency:[NSString stringWithFormat:@"USD"]];
//
//        // backup it up!
//        [[NSUserDefaults standardUserDefaults] setObject:[glob currency] forKey:@"currency"];
//         NSLog(@"first launch: default: %@", [glob currency]);
    }

    NSDate *queryStartDate = [[NSDate alloc]init];
    queryStartDate = [GMSUtilitiesFunction roundDateToHour:queryStartDate];
    [glob setQueryStartDate:queryStartDate];

    return YES;
}


- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{


}
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.graphmatic.lcbTicker.lcbTicker" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"lcbTicker" withExtension:@"mom"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"lcbTicker.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    
    // since iOS 9
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}
#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
