//
//  AppDelegate.h
//  planeWar
//
//  Created by Johnson on 16/7/5.
//  Copyright © 2016年 Johnson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//自己的飞机
@property UIImageView *planeView;
//敌人的飞机
@property NSMutableArray *enemyArr;
//两束子弹
@property NSMutableArray *bulletArr;
@property NSMutableArray *bulletArr2;
//镭射子弹
@property UIImageView *laserBullet;

@end

