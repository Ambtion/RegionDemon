//
//  AppDelegate.m
//  FenceDemon
//
//  Created by kequ on 15/11/29.
//  Copyright © 2015年 ke. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"

@interface AppDelegate ()<CLLocationManagerDelegate>
@property(nonatomic,strong)CLLocation * curlocation;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[RootViewController alloc] init]];
    [self.window makeKeyAndVisible];
    [self postLocalNotificationWithMsg:@"didFinishLaunchingWithOptions"];
    [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound  categories:nil]];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self startLocation];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    UIAlertController * alerC = [UIAlertController alertControllerWithTitle:[[notification userInfo] objectForKey:@"Msg"]  message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alerC addAction:action];
    
    [self.window.rootViewController presentViewController:alerC animated:YES completion:NULL];
}

- (void)startLocation
{
    if (!_locationManager) {
        
        _locationManager = [[CLLocationManager alloc] init];
        
        _locationManager.delegate = self;
        
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
            [self.locationManager requestAlwaysAuthorization]; //
        }
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
            _locationManager.allowsBackgroundLocationUpdates = YES;
        }
    }
    [_locationManager startMonitoringSignificantLocationChanges];
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (locations.count) {
        if (!self.curlocation) {
            self.curlocation = [locations firstObject];
            [self addFecnes];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [_locationManager requestWhenInUseAuthorization];
            }
            break;
        default:
            break;
    }
}


- (void)addFecnes
{
    
    CLLocationCoordinate2D companyCenter;
    
    if (self.curlocation) {
        companyCenter.latitude = self.curlocation.coordinate.latitude;
        companyCenter.longitude = self.curlocation.coordinate.longitude;
    }
    
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:self.curlocation.coordinate radius:30.f identifier:@"fences"];
    [self startMonitoringForRegion:region];
}

- (void)startMonitoringForRegion:(CLRegion *)region
{
    
    NSMutableArray *regions = [[NSMutableArray alloc] initWithCapacity:0];
    for (CLRegion *monitored in [self.locationManager monitoredRegions])
    {
        [self.locationManager stopMonitoringForRegion:monitored];
        [regions addObject:monitored];
    }
    [regions addObject:region];
    
    if([CLLocationManager regionMonitoringEnabled])
    {
        for (CLRegion *region in regions)
        {
            [self.locationManager startMonitoringForRegion:region];
        }
    }else
    {
        
    }
}

- (void)startMonitoringForRegions:(NSArray *)regions
{
    
    for (CLRegion *monitored in [self.locationManager monitoredRegions])
    {
        [self.locationManager stopMonitoringForRegion:monitored];
    }
    
    if([CLLocationManager regionMonitoringEnabled])
    {
        for (CLRegion *region in regions)
        {
            [self.locationManager startMonitoringForRegion:region];
        }
    }else{
        
        //#ifdef _DEBUG
        //        NSString *sencondLog = [NSString stringWithFormat:@"This app requires region monitoring features which are unavailable on this device"];
        //        saveLogToDevice(sencondLog)
        //#endif
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self postLocalNotificationWithMsg:@"didFailWithError"];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [self postLocalNotificationWithMsg:@"monitoringDidFailForRegion"];
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(nonnull CLRegion *)region
{
    [self postLocalNotificationWithMsg:@"didExitRegion"];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(nonnull CLRegion *)region
{
    [self postLocalNotificationWithMsg:@"didEnterRegion"];
    
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self postLocalNotificationWithMsg:@"didStartMonitoringForRegion"];
}

- (void)postLocalNotificationWithMsg:(NSString *)msg
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        
        notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
        notification.fireDate = [NSDate date];
        
        notification.repeatInterval = kCFCalendarUnitDay;
        notification.alertBody   = msg;
        notification.soundName = UILocalNotificationDefaultSoundName;
        //        notification.applicationIconBadgeNumber++;
        NSMutableDictionary *aUserInfo = [[NSMutableDictionary alloc] init];
        aUserInfo[@"Msg"] = msg;
        notification.userInfo = aUserInfo;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}


@end
