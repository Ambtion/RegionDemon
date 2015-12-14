//
//  RootViewController.m
//  FenceDemon
//
//  Created by kequ on 15/11/29.
//  Copyright © 2015年 ke. All rights reserved.
//

#import "RootViewController.h"
#import <MapKit/MapKit.h>

@interface RootViewController ()<CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)CLLocationManager * locationManager;
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)CLLocation * curlocation;
@property(nonatomic,strong)NSMutableArray * fences;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fences = [NSMutableArray arrayWithCapacity:0];
    [self startLocation];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addFecnes)];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fences.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
    }
    CLRegion * region = [[self fences] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"la:%f , lo:%f",region.center.latitude,region.center.longitude];
    return cell;
    
}

- (void)startLocation
{
    if (!_locationManager) {

        _locationManager = [[CLLocationManager alloc] init];

        _locationManager.delegate = self;

        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
            [self.locationManager requestWhenInUseAuthorization]; //
        }
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
            _locationManager.allowsBackgroundLocationUpdates = YES;
        }
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (locations.count) {
        self.curlocation =[locations firstObject];
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

#pragma mark GEOFence
- (void)addFecnes
{
    
    CLLocationCoordinate2D companyCenter;
    
    if (self.curlocation) {
        companyCenter.latitude = self.curlocation.coordinate.latitude;
        companyCenter.longitude = self.curlocation.coordinate.longitude;
    }else{
        companyCenter.latitude = 23.126272;
        companyCenter.longitude = 113.395568;
    }
  
    CLRegion* fkit = [[CLCircularRegion alloc] initWithCenter:companyCenter
                                                       radius:100 identifier:@"fkit"];
    
//    for (NSSet * fk in self.monitoredRegions) {
//        [self.locationManager stopMonitoringForRegion:fk];
//        [self.fences addObject:fkit];
//    }
    NSSet * set = self.locationManager.monitoredRegions;
    [set enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.locationManager stopMonitoringForRegion:obj];
    }];
    
    NSLog(@"%@",self.locationManager.monitoredRegions);
    NSLog(@"%f",self.locationManager.maximumRegionMonitoringDistance);
    NSLog(@"%@",fkit);
    [self.locationManager startMonitoringForRegion:fkit];
    [self.fences removeAllObjects];
    [self.fences addObject:fkit];
//    [self.locationManager requestStateForRegion:fkit];
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error : %@",error);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Region monitoring failed with error: %@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(nonnull CLRegion *)region
{
    NSLog(@"Entered Region - %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(nonnull CLRegion *)region
{
    NSLog(@"Entered Enter Region - %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Started monitoring %@ region", region.identifier);
}
@end
