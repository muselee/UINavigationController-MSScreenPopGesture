//
//  UINavigationController+MSScreenPopGesture.h
//  BestDoStadium
//
//  Created by liqian on 15/12/20.
//  Copyright © 2016年 Bestdo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (MSScreenPopGesture)
//是否全屏返回 默认 左边缘返回
@property (nonatomic, assign) BOOL fullScreenInteractivePopGestureRecognizer;

@end

@interface UIViewController(MSScreenPopGesture)

//禁用滑动返回
@property (nonatomic, assign) BOOL ms_interactivePopDisabled;

@end
