//
//  RootViewController.m
//  FenceDemon
//
//  Created by kequ on 15/11/29.
//  Copyright © 2015年 ke. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()
@end

@implementation RootViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 100, 40);
    [button addTarget:self action:@selector(buttoonCLick:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
}

- (void)buttoonCLick:(UIButton *)button
{
    [self postLocalNotificationWithMsg:@"Heloo"];
}
- (void)postLocalNotificationWithMsg:(NSString *)msg
{
    
    // 初始化本地通知对象
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        // 设置通知的提醒时间
        notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:3];
        
        // 设置重复间隔
        notification.repeatInterval = kCFCalendarUnitDay;
        // 设置提醒的文字内容
        notification.alertBody   = msg;
        notification.soundName = UILocalNotificationDefaultSoundName;
        // 设置应用程序右上角的提醒个数
        notification.applicationIconBadgeNumber++;
        
        // 设定通知的userInfo，用来标识该通知
        NSMutableDictionary *aUserInfo = [[NSMutableDictionary alloc] init];
        notification.userInfo = aUserInfo;
        
        // 将通知添加到系统中
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

@end
