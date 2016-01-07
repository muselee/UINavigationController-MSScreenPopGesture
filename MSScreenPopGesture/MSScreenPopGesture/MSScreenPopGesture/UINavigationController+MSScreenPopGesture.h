//
//  UINavigationController+MSScreenPopGesture.h
//  BestDoStadium
//
//  Created by liqian on 15/12/20.
//  Copyright © 2016年 Bestdo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (MSScreenPopGesture)
 /** 是否全屏返回 默认 左边缘返回*/
@property (nonatomic, assign) BOOL ms_fullScreenPopEnabled;
 /** 导航栏是否隐藏(全局设置)*/
@property (nonatomic, assign) BOOL ms_navigationBarGlobalHidden;
@end

@interface UIViewController(MSScreenPopGesture)
 /** 禁用滑动返回*/
@property (nonatomic, assign) BOOL ms_screenPopDisabled;
 /** 隐藏导航栏 YES隐藏*/
@property (nonatomic, assign) BOOL ms_navigationBarHidden;
@end
