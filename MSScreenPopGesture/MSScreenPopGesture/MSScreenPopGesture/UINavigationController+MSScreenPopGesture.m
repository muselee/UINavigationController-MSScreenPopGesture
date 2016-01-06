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

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //重写 interactivePopGestureRecognizer 的代理,限制滑动
        [UINavigationController gestureRecognizerShouldBegin];
        [UINavigationController gestureRecognizerShouldReceiveTouch];
        [UINavigationController gestureRecognizerShouldBeRequiredToFailByGestureRecognizer];
    });
}

+ (void)gestureRecognizerShouldReceiveTouch{
    
    Class _navigationInteractiveTransition = NSClassFromString(@"_UINavigationInteractiveTransition");
    
    Method gestureShouldReceiveTouch = class_getInstanceMethod(_navigationInteractiveTransition, @selector(gestureRecognizer:shouldReceiveTouch:));
    method_setImplementation(gestureShouldReceiveTouch, imp_implementationWithBlock(^(UIPercentDrivenInteractiveTransition *navTransition,UIGestureRecognizer *gestureRecognizer, UITouch *touch){
        UINavigationController *navigationController = (UINavigationController *)[navTransition valueForKey:@"_parent"];
        UIViewController *topViewController = navigationController.viewControllers.lastObject;
        BOOL disabled = topViewController.ms_interactivePopDisabled;
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
#pragma mark set get

- (BOOL)fullScreenInteractivePopGestureRecognizer {
    return [self.interactivePopGestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]];
}

- (void)setFullScreenInteractivePopGestureRecognizer:(BOOL)fullScreenInteractivePopGestureRecognizer {
    if (fullScreenInteractivePopGestureRecognizer) {
        if ([self.interactivePopGestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]]) return;
        object_setClass(self.interactivePopGestureRecognizer, [UIPanGestureRecognizer class]);
        [self.interactivePopGestureRecognizer setValue:@NO forKey:@"canPanVertically"];
    } else {
        if ([self.interactivePopGestureRecognizer isMemberOfClass:[UIScreenEdgePanGestureRecognizer class]]) return;
        object_setClass(self.interactivePopGestureRecognizer, [UIScreenEdgePanGestureRecognizer class]);
    }
}

@end


@implementation UIViewController(MSScreenPopGesture)

- (BOOL)ms_interactivePopDisabled
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setMs_interactivePopDisabled:(BOOL)disabled
{
    objc_setAssociatedObject(self, @selector(ms_interactivePopDisabled), @(disabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end