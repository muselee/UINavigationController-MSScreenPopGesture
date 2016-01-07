//
//  ViewController.m
//  MSScreenPopGesture
//
//  Created by liqian on 16/1/4.
//  Copyright © 2016年 Bestdo. All rights reserved.
//

#import "ViewController.h"
#import "MSPopGestureViewController.h"
#import "UINavigationController+MSScreenPopGesture.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:tap];
}
- (void)tap{
    MSPopGestureViewController * pop =[[MSPopGestureViewController alloc]init];
    //关闭滑动返回
//    pop.popDisabled = YES;
    //隐藏导航栏
//    pop.ms_navigationBarHidden = YES;
    [self.navigationController pushViewController:pop animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
