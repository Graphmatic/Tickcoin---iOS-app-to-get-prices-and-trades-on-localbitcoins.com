//
//  GMSAppDelegate.h
//  LCB PUBLIC TICKER
//
//  Created by frup on 29/03/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMSfirstViewTableData.h"
extern NSMutableString *currentCurrency;
extern NSMutableString *lastRecordDate;
extern BOOL firstLaunch;
extern BOOL firstLaunchChart;
extern BOOL firstLaunchBids;
extern BOOL firstLaunchAsks;
extern NSDate *graphRequestStart;
extern BOOL test;
extern BOOL startingApp;
@interface GMSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, atomic) NSUserDefaults *persistantDatas;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end