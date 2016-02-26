//
//  RootViewController.m
//  FenceDemon
//
//  Created by kequ on 15/11/29.
//  Copyright © 2015年 ke. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"


@interface RootViewController ()
@end

@implementation RootViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100, 100, 100, 40);
    [button addTarget:self action:@selector(buttoonCLick:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
}

- (void)buttoonCLick:(UIButton *)button
{
    CLLocationManager * loc = [(AppDelegate *)[[UIApplication sharedApplication] delegate] locationManager];
    NSMutableArray *regions = [[NSMutableArray alloc] initWithCapacity:0];
    for (CLRegion *monitored in [loc monitoredRegions])
    {
        [loc stopMonitoringForRegion:monitored];
    }
}

@end
