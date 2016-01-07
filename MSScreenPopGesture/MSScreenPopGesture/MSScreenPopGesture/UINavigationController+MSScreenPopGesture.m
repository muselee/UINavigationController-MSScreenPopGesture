//
//  UINavigationController+MSScreenPopGesture.m
//  BestDoStadium
//
//  Created by liqian on 16/1/4.
//  Copyright © 2016年 Bestdo. All rights reserved.
//

#import "UINavigationController+MSScreenPopGesture.h"
#import <objc/runtime.h>
@interface UINavigationController(_MSScreenPopGesture)

@end
@implementation UINavigationController (MSScreenPopGesture)

void (^method_swizzling)(Class , SEL , SEL ) = ^(Class class, SEL originalSelector, SEL swizzledSelector){
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL addSuccess = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (addSuccess) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
};
+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //重写 interactivePopGestureRecognizer 的代理,限制滑动
        [UINavigationController gestureRecognizerShouldBegin];
        [UINavigationController gestureRecognizerShouldReceiveTouch];
        [UINavigationController gestureRecognizerShouldBeRequiredToFailByGestureRecognizer];
        //交换push 和pop 方法
        method_swizzling(self,@selector(pushViewController:animated:),@selector(ms_pushViewController:animated:));
        method_swizzling(self,@selector(popViewControllerAnimated:),@selector(ms_popViewControllerAnimated:));
        
    });
}

+ (void)gestureRecognizerShouldReceiveTouch{
    
    Class _navigationInteractiveTransition = NSClassFromString(@"_UINavigationInteractiveTransition");
    
    Method gestureShouldReceiveTouch = class_getInstanceMethod(_navigationInteractiveTransition, @selector(gestureRecognizer:shouldReceiveTouch:));
    method_setImplementation(gestureShouldReceiveTouch, imp_implementationWithBlock(^(UIPercentDrivenInteractiveTransition *navTransition,UIGestureRecognizer *gestureRecognizer, UITouch *touch){
        UINavigationController *navigationController = (UINavigationController *)[navTransition valueForKey:@"_parent"];
        UIViewController *topViewController = navigationController.viewControllers.lastObject;
        BOOL disabled = topViewController.ms_screenPopDisabled;
        return navigationController.viewControllers.count != 1 &&!disabled;
    }));
}
+ (void)gestureRecognizerShouldBegin{
    
     Class _navigationInteractiveTransition = NSClassFromString(@"_UINavigationInteractiveTransition");
    
    Method gestureRecognizerShouldBegin = class_getInstanceMethod(_navigationInteractiveTransition, @selector(gestureRecognizerShouldBegin:));
    method_setImplementation(gestureRecognizerShouldBegin, imp_implementationWithBlock(^(UIPercentDrivenInteractiveTransition *navTransition, UIPanGestureRecognizer *gestureRecognizer){
        CGPoint velocityInview = [gestureRecognizer velocityInView:gestureRecognizer.view];
        return velocityInview.x >= 0.0f;
    }));

}

+ (void)gestureRecognizerShouldBeRequiredToFailByGestureRecognizer{
    Class _navigationInteractiveTransition = NSClassFromString(@"_UINavigationInteractiveTransition");
    NSString *selectorString = [NSString stringWithFormat:@"_%@",NSStringFromSelector(@selector(gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:))];
    Method gestureShouldSimultaneouslyGesture = class_getInstanceMethod(_navigationInteractiveTransition, NSSelectorFromString(selectorString));
    method_setImplementation(gestureShouldSimultaneouslyGesture, imp_implementationWithBlock(^{
        return NO;
    }));
}

#pragma mark private funcs
- (void)ms_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {

    [self ms_pushViewController:viewController animated:animated];
    if (self.ms_navigationBarGlobalHidden) {
        return;
    }
    [self setNavigationBarHidden:viewController.ms_navigationBarHidden animated:animated];

}
-(UIViewController *)ms_popViewControllerAnimated:(BOOL)animated {
    UIViewController *viewController = [self ms_popViewControllerAnimated:animated];
    if (self.ms_navigationBarGlobalHidden) {
        return viewController;
    }
    UIViewController *visibleViewController = [self visibleViewController];
    [self setNavigationBarHidden:visibleViewController.ms_navigationBarHidden animated:animated];
    return viewController;
}
#pragma mark set get

- (BOOL)ms_fullScreenPopEnabled {
    return [self.interactivePopGestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]];
}

- (void)setMs_fullScreenPopEnabled:(BOOL)ms_fullScreenPopEnabled {
    if (ms_fullScreenPopEnabled) {
        if ([self.interactivePopGestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]]) return;
        object_setClass(self.interactivePopGestureRecognizer, [UIPanGestureRecognizer class]);
    } else {
        if ([self.interactivePopGestureRecognizer isMemberOfClass:[UIScreenEdgePanGestureRecognizer class]]) return;
        object_setClass(self.interactivePopGestureRecognizer, [UIScreenEdgePanGestureRecognizer class]);
    }
}

- (BOOL)ms_navigationBarGlobalHidden{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) {
        return number.boolValue;
    }
    //默认不隐藏
    self.ms_navigationBarGlobalHidden = NO;
    return NO;
}
- (void)setMs_navigationBarGlobalHidden:(BOOL)ms_navigationBarGlobalHidden{
    objc_setAssociatedObject(self, @selector(ms_navigationBarGlobalHidden), @(ms_navigationBarGlobalHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //设置导航栏
    self.navigationBarHidden = ms_navigationBarGlobalHidden;
}
@end


@implementation UIViewController(MSScreenPopGesture)

- (BOOL)ms_screenPopDisabled
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setMs_screenPopDisabled:(BOOL)ms_screenPopDisabled
{
    objc_setAssociatedObject(self, @selector(ms_screenPopDisabled), @(ms_screenPopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)setMs_navigationBarHidden:(BOOL)ms_navigationBarHidden {
    objc_setAssociatedObject(self, @selector(ms_navigationBarHidden), @(ms_navigationBarHidden), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)ms_navigationBarHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
@end