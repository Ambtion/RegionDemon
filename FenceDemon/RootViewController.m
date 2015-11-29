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
        // 1. 实例化定位管理器
        _locationManager = [[CLLocationManager alloc] init];
        // 2. 设置代理
        _locationManager.delegate = self;
        // 3. 定位精度
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        // 4.请求用户权限：分为：⓵只在前台开启定位⓶在后台也可定位，
        //注意：建议只请求⓵和⓶中的一个，如果两个权限都需要，只请求⓶即可，
        //⓵⓶这样的顺序，将导致bug：第一次启动程序后，系统将只请求⓵的权限，⓶的权限系统不会请求，只会在下一次启动应用时请求⓶
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
            //[_locationManager requestWhenInUseAuthorization];//⓵只在前台开启定位
            [_locationManager requestAlwaysAuthorization];//⓶在后台也可定位
        }
        // 5.iOS9新特性：将允许出现这种场景：同一app中多个location manager：一些只能在前台定位，另一些可在后台定位（并可随时禁止其后台定位）。
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
            _locationManager.allowsBackgroundLocationUpdates = YES;
        }
    }
    // 6. 更新用户位置
    [_locationManager startUpdatingLocation];
  
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (locations.count) {
        self.curlocation =[locations firstObject];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [_locationManager requestWhenInUseAuthorization];
            }
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >=9){
                _locationManager.allowsBackgroundLocationUpdates = YES;
            }
            break;
        case kCLAuthorizationStatusDenied:
        {
            
        }
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
