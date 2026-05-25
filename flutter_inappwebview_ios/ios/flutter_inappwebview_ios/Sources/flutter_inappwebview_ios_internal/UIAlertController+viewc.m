#import <UIKit/UIKit.h>
//
//  UIAlertController+viewc.m
//  flutter_inappwebview
//
//  Created by baby on 16/10/2022.
//

#import "UIAlertController+viewc.h"
#import <objc/runtime.h>

//static NSString *nameWithSetterGetterKey = @"nameWithSetterGetterKey";
static NSString * nameKey;
@implementation UIAlertController (viewc)


// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscapeRight;
    if([nameKey isEqualToString:@"1"]){
        return UIInterfaceOrientationMaskLandscapeRight;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)shouldAutorotate {
    NSLog(@"%s",__FUNCTION__);
    return true;
}

//- (void)setnnnn:(NSString *)nameWithSetterGetter {
//    nameKey =nameWithSetterGetter;
//        objc_setAssociatedObject(self, &nameWithSetterGetterKey, nameWithSetterGetter, OBJC_ASSOCIATION_COPY);
//}
//- (NSString *)nameWithSetterGetter {
//    return objc_getAssociatedObject(self, &nameWithSetterGetterKey);
//}

-(void)setLandscape:(NSString *)label{
    nameKey =label;
}

// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationLandscapeRight;
//    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    if([nameKey isEqualToString:@"1"]){
        return UIInterfaceOrientationLandscapeRight;
    }else{
        return UIInterfaceOrientationPortrait;
    }
}
@end
