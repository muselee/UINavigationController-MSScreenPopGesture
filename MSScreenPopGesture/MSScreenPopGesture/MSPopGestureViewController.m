//
//  MSPopGestureViewController.m
//  MSScreenPopGesture
//
//  Created by liqian on 16/1/6.
//  Copyright © 2016年 Bestdo. All rights reserved.
//

#import "MSPopGestureViewController.h"
#import "UINavigationController+MSScreenPopGesture.h"

@implementation MSPopGestureViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
    self.ms_screenPopDisabled = _popDisabled;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
