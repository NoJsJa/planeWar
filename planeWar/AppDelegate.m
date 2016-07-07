//
//  AppDelegate.m
//  planeWar
//
//  Created by Johnson on 16/7/5.
//  Copyright © 2016年 Johnson. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [[UIViewController alloc]init];
    
    //创建幕布
    UIImageView *imageView = [[UIImageView alloc] init];
    UIImageView *imageView2 = [[UIImageView alloc] init];
    //标志tag
    imageView.tag = 1;
    imageView2.tag = 2;
    //设置大小
    imageView.frame = CGRectMake(0, 0, 320, 480);
    imageView2.frame = CGRectMake(0, -480, 320, 480);
    //设置图片,不需要路径
    imageView2.image = [UIImage imageNamed:@"bg.png"];
    imageView.image = [UIImage imageNamed:@"bg.png"];
    
    [self.window addSubview:imageView];
    [self.window addSubview:imageView2];
    
    //创建飞机
    [self buildPlane];
    //创建敌机
    [self buildEnemyPlane];
    //初始化炮弹
    [self initBullet];
    //创建爆炸数组
    [self buildExplodeArr];
    //创建弹药的item
    [self shootItem];
    //设置定时器让背景图片循环滚动
    self.backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(scrollImage) userInfo:nil repeats:YES];
    
    
    //让飞机的火焰图片变换
    [self changePlane];
    
    //让飞机发射炮弹,敌机开始攻击
    self.planeActionTimer = [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(planeAction) userInfo:nil repeats:YES];
    
    [self changeItemDirection];
    
    return YES;
}


//背景图片滚动
-(void) scrollImage{
    
    static int y = 0;
    int y2 = y - 480;
    
    UIImageView *image = (UIImageView *)[self.window viewWithTag:1];
    UIImageView *image2 = (UIImageView *)[self.window viewWithTag:2];
    
    
    image.frame = CGRectMake(0, y, 320, 480);
    image2.frame = CGRectMake(0, y2, 320, 480);
    
    y += 5;
    if (y == 485) {
        y = 0;
        
    }
}

//创建一个自己的飞机
-(void)buildPlane{
    
    self.planeView = [[UIImageView alloc] init];
    self.planeView.tag = 3;
    self.planeView.frame = CGRectMake(160 - 15, 450 - 15, 30, 30);
    self.planeView.image = [UIImage imageNamed:@"plane1.png"];
    self.planeView.userInteractionEnabled = YES;
    
    //创建镭射子弹
    self.laserBullet = [[UIImageView alloc] init];
    self.laserBullet.frame = CGRectMake(160 - 1, 450 - 30 - 480, 2, 480);
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeLasterColor) userInfo:nil repeats:YES];
    
    [self.window addSubview:self.laserBullet];
    [self.window addSubview:self.planeView];
}

//变换镭射子弹的颜色
-(void)changeLasterColor{
    self.laserBullet.backgroundColor = [UIColor colorWithHue:arc4random()%256/255.0 saturation:arc4random()%256/255.0 brightness:arc4random()%256/255.0 alpha:1];
}

//变换飞机的图片
-(void)changePlane{
    
    //自己手动实现的图片变换
//    static BOOL fly = YES;
//    
//    UIImageView *planeView = (UIImageView *)[self.window viewWithTag:3];
//    
//    if (fly) {
//        planeView.image =[UIImage imageNamed:@"plane2.png"];
//        fly = NO;
//        return;
//    }
//    if (!fly){
//        planeView.image = [UIImage imageNamed:@"plane1.png"];
//        fly = YES;
//        return;
//    }
    
    NSMutableArray *bulletArr = [[NSMutableArray alloc] init];
    [bulletArr addObject:[UIImage imageNamed:@"plane1.png"]];
    [bulletArr addObject:[UIImage imageNamed:@"plane2.png"]];
    self.planeView.animationImages = bulletArr;
    self.planeView.animationDuration = 0.2;
    [self.planeView startAnimating];
}

//创建敌机
-(void)buildEnemyPlane{
    self.enemyArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < 100; i++) {
        UIImageView *enemy = [[UIImageView alloc] init];
        enemy.image = [UIImage imageNamed:@"diji.png"];
        //没开始进攻的敌机标志位0
        enemy.tag = 0;
        [self.enemyArr addObject:enemy];
    }
}

//飞机的动作
-(void)planeAction{
    static int tag = 0;
    tag++;
    //碰撞检测
    [self collision_detection];
    if (tag % 4 == 0) {
        [self shoot];
    }
    
    [self bulletMove];
    
    if (tag % 4 == 0) {
        
        [self enemyStartAttack];
    }
    
    if (tag % 2 == 0) {
        [self enemyMove];
    }
    
    
    tag = tag >= 1000 ? 0 : tag;
    
}

//飞机和子弹的碰撞检测
-(void)collision_detection{
    [self detection:self.bulletArr];
    [self detection:self.bulletArr2];
}

//碰撞检测函数
-(void)detection : (NSMutableArray *)bulletArr{
    for (int i = 0; i < 50; i++) {
        UIImageView *bulletView = (UIImageView *)bulletArr[i];
        if (bulletView.tag == 0) {
            continue;
        }
        //检测每一颗子弹与敌机是否碰撞
        for (int j = 0; j < 100; j++) {
            
            UIImageView *enemyView = (UIImageView *)self.enemyArr[j];
            if (enemyView.tag == 0) {
                continue;
            }
            //检测激光
            if (CGRectIntersectsRect(self.laserBullet.frame, enemyView.frame)) {
                
                [self enemyExplode:enemyView.frame];
                [enemyView removeFromSuperview];
                enemyView.tag = 0;
                continue;
            }
            //检测子弹
            if (CGRectIntersectsRect(bulletView.frame, enemyView.frame)) {
                [bulletView removeFromSuperview];
                [self enemyExplode:enemyView.frame];
                [enemyView removeFromSuperview];
                
                bulletView.tag = 0;
                enemyView.tag = 0;
                continue;
                
            }
            //检测敌机与自己
            if (CGRectIntersectsRect(self.planeView.frame, enemyView.frame)){
                
                [self.planeView removeFromSuperview];
                [self.laserBullet removeFromSuperview];
                [self.backgroundTimer invalidate];
                [self.planeActionTimer invalidate];
                [self.item removeFromSuperview];
                //让屏幕上的子弹消失
                for (int i = 0; i < 50; i++) {
                    UIImageView *bulletView = self.bulletArr[i];
                    UIImageView *bulletView2 = self.bulletArr2[i];
                    if (bulletView.tag == 1) {
                        [bulletView removeFromSuperview];
                        bulletView.tag = 0;
                    }
                    if (bulletView2.tag == 1) {
                        [bulletView2 removeFromSuperview];
                        bulletView2.tag = 0;
                    }
                    
                }
            }
        }
        
        
    }
}

//敌机爆炸的函数
-(void)enemyExplode :(CGRect)enemy {
    
    for (int i= 0; i < 30; i++) {
        UIImageView *view = (UIImageView *)self.explodeArr[i];
        if ([view isAnimating]) {
            continue;
        }else{
            view.frame = enemy;
            [view startAnimating];
            [self.window addSubview:view];
            //出现火球
            if (view.tag == 1 && !isItemExit && !isItemAdded) {
                self.item.frame = view.frame;
                [self.window addSubview:self.item];
                self.itemMoveTimer = [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(itemAction) userInfo:nil repeats:YES];
                isItemExit = YES;
                
            }
            break;
        }
    }
}


//敌机的动作
-(void)enemyAction{

    [self enemyStartAttack];
    [self enemyMove];
}

//敌机开始进攻
-(void)enemyStartAttack{
    static int enemyNum = 0;
    
    UIImageView *image;
    while (YES) {
        image = (UIImageView *)self.enemyArr[enemyNum];
        if (image.tag == 0) {
            break;
        }
        enemyNum ++;
        if (enemyNum == 100) {
            enemyNum = 0;
        }
    }
    
    //敌机变换位置
    image.frame = CGRectMake(arc4random()%(310 - 10) + 10,10, 20, 20);
    [self.window addSubview:image];
    image.tag = 1;
    if (enemyNum == 100) {
        enemyNum = 0;
    }

}

//敌机移动
-(void)enemyMove{
    for (int i = 0; i < 100; i++) {
        UIImageView *image = (UIImageView *)self.enemyArr[i];
        if (image.tag == 1) {
            image.frame = CGRectMake(image.frame.origin.x, image.frame.origin.y + 4, 20, 20);
            if (image.frame.origin.y >= 480) {
                image.tag = 0;
                [image removeFromSuperview];
            }
        }
    }
}



/*-----------------弹药加成的道具--------------------*/

//创建弹药加成的宝贝
-(void)shootItem{
    //创建对象
    self.item = [[UIImageView alloc] init];
    self.item.frame = CGRectMake(160 - 10, 240 - 10, 20, 20);
    self.item.image = [UIImage imageNamed:@"fireball.png"];
    
}

//弹药道具运行的方向差
static int dx;
static int dy;
//标记火球是否在屏幕上
static BOOL isItemExit = NO;
//标记是否是加成状态
static BOOL isItemAdded = NO;

//弹药道具的动作
-(void)itemAction{
    [self itemMove];
    [self itemEffect];
    [self isKnock];
    [self item_detection];
}

//弹药加成的道具在屏幕上来回弹动
-(void)itemMove{
    
    self.item.frame = CGRectMake(self.item.frame.origin.x + dx , self.item.frame.origin.y + dy, 20, 20);
}

//判断是否和四个边界相碰
-(void)isKnock{
    
    if ((self.item.frame.origin.x - 10 <= 0) || (self.item.frame.origin.x + 10 >= 320)){
        dx = -dx;
    }else if((self.item.frame.origin.y - 10 <= 0) || (self.item.frame.origin.y + 10 >= 480)){
        dy = -dy;
    }
}

//改变弹药道具的运行方向
-(void)changeItemDirection{
    
    dx = 5;
    dy = 3.5;
}

//弹药道具碰撞检测
-(void)item_detection{
    //判断是否和自己的飞机碰撞
    if (CGRectIntersectsRect(self.planeView.frame, self.item.frame) && (isItemExit)) {
        [self.item removeFromSuperview];
        [self.itemMoveTimer invalidate];
        
        self.bulletUpgradeTimer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(bullet_upgrade) userInfo:nil repeats:YES];
        isItemExit = NO;
        isItemAdded = YES;
    }
}

//镭射弹药更新
-(void)bullet_upgrade{
    static int i = 0;
    i++;
    if (i >= 200) {
        self.laserBullet.frame = CGRectMake(self.planeView.frame.origin.x + 15 - 1, self.planeView.frame.origin.y - 15 - 480, 2, 480);
        [self.bulletUpgradeTimer invalidate];
        isItemAdded = NO;
        i = 0;
    }else{
        self.laserBullet.frame = CGRectMake(self.planeView.frame.origin.x + 15 - 20, self.planeView.frame.origin.y - 15 - 480, 40, 480);
    }
    
}

//弹药道具的尾巴效果
-(void)itemEffect{

    UIImageView *fireBall = [[UIImageView alloc] init];
    fireBall.image = [UIImage imageNamed:@"fireball"];
    fireBall.frame = CGRectMake(self.item.frame.origin.x, self.item.frame.origin.y, 20, 20);
        [self.window addSubview:fireBall];
    
    [UIView beginAnimations:nil context:(__bridge void * _Nullable)(fireBall)];
    [UIView setAnimationDuration:1];
    [UIView setAnimationBeginsFromCurrentState:YES];

    //把播放动画的方法委托给主线程,因为要调用主线程的函数
    [UIView setAnimationDelegate:self];
    //iOS的委托类似回调函数
    //[UIView setAnimationDidStopSelector:@selector(afterAnimation :)];
    
    //提交动画，动画线程和主线程不同,可以找到非主线程分支
    fireBall.frame = CGRectMake(self.item.frame.origin.x, self.item.frame.origin.y, 0, 0);
    [UIView commitAnimations];

}

//从屏幕上移除那个动画
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    UIImageView *fir=(__bridge UIImageView *)(context);
    [fir removeFromSuperview];
}

/*------------------道具的移动-------------------*/

//创建炮弹的数组，炮弹的tag状态0和1表示炮弹是否在屏幕上，0表示炮弹不在屏幕上，1表示炮弹在屏幕上
-(void)initBullet{
    self.bulletArr = [[NSMutableArray alloc] init];
    self.bulletArr2 = [[NSMutableArray alloc] init];
    for (int i = 0; i < 50; i++) {
        UIImageView *ziDan = [[UIImageView alloc] init];
        ziDan.image = [UIImage imageNamed:@"zidan.png"];
        ziDan.tag = 0;
        [self.bulletArr addObject:ziDan];
    }
    for (int i = 0; i < 50; i++) {
        UIImageView * ziDan = [[UIImageView alloc] init];
        ziDan.tag = 0;
        ziDan.image = [UIImage imageNamed:@"zidan.png"];
        [self.bulletArr2 addObject:ziDan];
    }
}

//创建爆炸数组
-(void)buildExplodeArr{
    self.explodeArr = [[NSMutableArray alloc] init];
    NSMutableArray *bzImgArr = [[NSMutableArray alloc]init];
    [bzImgArr addObject:[UIImage imageNamed:@"bz1.png"]];
    [bzImgArr addObject:[UIImage imageNamed:@"bz2.png"]];
    [bzImgArr addObject:[UIImage imageNamed:@"bz3.png"]];
    [bzImgArr addObject:[UIImage imageNamed:@"bz4.png"]];
    [bzImgArr addObject:[UIImage imageNamed:@"bz5.png"]];
    for (int i = 0; i < 30; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        //弹药的标记参数，几率为1/6
        if((arc4random()%100 + 1) <= 20){
            imageView.tag = 1;
        }else{
            imageView.tag = 0;
        }
        
        imageView.animationImages = bzImgArr;
        imageView.animationDuration = 0.5;
        imageView.animationRepeatCount = 1;

        [self.explodeArr addObject:imageView];

    }
}

//发射炮弹
-(void)shoot{
    static int bulletNum = 0;
    static int bulletNum2 = 0;
    
    UIImageView *image, *image2;
    while (YES) {
        image = (UIImageView *)self.bulletArr[bulletNum];
        if (image.tag == 0) {
            break;
        }
        bulletNum ++;
        if (bulletNum == 50) {
            bulletNum = 0;
        }
    }
    while (YES) {
        image2 =(UIImageView *)self.bulletArr2[bulletNum2];
        if (image2.tag == 0) {
            break;
        }
        bulletNum2++;
        if (bulletNum2 == 50) {
            bulletNum2 = 2;
        }
    }
    //子弹变换位置
    image.frame = CGRectMake(self.planeView.frame.origin.x - 2.5, self.planeView.frame.origin.y - 15, 5, 7);
    [self.window addSubview:image];
    image.tag = 1;
    if (bulletNum == 50) {
        bulletNum = 0;
    }
    //子弹变换位置
    image2.frame = CGRectMake(self.planeView.frame.origin.x + 30 - 2.5, self.planeView.frame.origin.y - 15, 5, 7);
    [self.window addSubview:image2];
    image2.tag = 1;
    if (bulletNum2 == 50) {
        bulletNum2 = 0;
    }
    
}

//炮弹循环移动
-(void)bulletMove{
    
    for (int i = 0; i < 50; i++) {
        UIImageView *image = (UIImageView *)self.bulletArr[i];
        UIImageView *image2 = (UIImageView *)self.bulletArr2[i];
        if (image.tag == 1) {
            image.frame = CGRectMake(image.frame.origin.x - 7.5, image.frame.origin.y - 15, 5, 7);
            if (image.frame.origin.y <= 0 || image.frame.origin.x <= 0) {
                image.tag = 0;
                [image removeFromSuperview];
            }
        }
        if (image2.tag == 1) {
            image2.frame = CGRectMake(image2.frame.origin.x + 7.5, image2.frame.origin.y - 15, 5, 7);
            if (image2.frame.origin.y <= 0 || image2.frame.origin.x >= 320) {
                image2.tag = 0;
                [image2 removeFromSuperview];
            }
        }
    }
}

//手指触摸的触发事件
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //触摸屏幕
    
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //手指离开屏幕
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //手指在屏幕上移动
    //获取点击屏幕对象,多点触控
    //手指点击的时候，系统会创建一个触摸对象，将触摸对象存在touches中，系统默认是单点触控，所以通过touches 调用anyObject获取当前的触摸对象
    UITouch *touch = [touches anyObject];
    //判断触摸对象是否是飞机
    if ([touch view] == self.planeView) {
        //获取前一个点和当前点
        CGPoint lastPoint = [touch previousLocationInView:self.planeView];
        CGPoint currentPoint = [touch locationInView:self.planeView];
        float dx = currentPoint.x - lastPoint.x;
        float dy = currentPoint.y - lastPoint.y;
        //让飞机的左边偏移相应的值
        self.planeView.frame = CGRectMake(self.planeView.frame.origin.x + dx, self.planeView.frame.origin.y + dy, 30, 30);
        self.laserBullet.frame = CGRectMake(self.planeView.frame.origin.x + dx + 15 - 1, self.planeView.frame.origin.y + dy - 15 - 480, 2, 480);
    }
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //手指从屏幕上移出
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
