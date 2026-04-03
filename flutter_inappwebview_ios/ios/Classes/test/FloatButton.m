#import <flutter_inappwebview_ios/flutter_inappwebview_ios-Swift.h>
#import "FloatButton.h"
#import "FanweDeviceMacro.h"
#import "FWColorMacro.h"
#import "OrientationListener.h"
#import "UIViewController+webviewViewControl.h"
#import "UIAlertController+viewc.h"


@implementation FloatButton {
    InAppBrowserWebViewController *_webCtrl;
    UIView *rootView;
    
    //-------------------拖拽按钮---------------------
    UIView *_viewPot;
    UIButton *_btn;
    CGPoint beginPoint;
    CGFloat rightMargin;
    CGFloat leftMargin;
    CGFloat topMargin;
    CGFloat bottomMargin;
    CGMutablePathRef pathRef;
    UIPanGestureRecognizer * pan;
    
    //是否横屏
    BOOL isRotationRight;
    OrientationListener *listener;
}

- (CGFloat)resolvedTopSafeInset {
    CGFloat topInset = 0;

    if (@available(iOS 11.0, *)) {
        topInset = rootView.safeAreaInsets.top;
        if (topInset <= 0 && rootView.window != nil) {
            topInset = rootView.window.safeAreaInsets.top;
        }
    }

    if (topInset <= 0) {
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
                if (![scene isKindOfClass:[UIWindowScene class]]) {
                    continue;
                }
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                if (windowScene.activationState != UISceneActivationStateForegroundActive) {
                    continue;
                }
                topInset = windowScene.statusBarManager.statusBarFrame.size.height;
                if (topInset > 0) {
                    break;
                }
            }
        } else {
            topInset = UIApplication.sharedApplication.statusBarFrame.size.height;
        }
    }

    return topInset;
}

- (CGFloat)portraitButtonY {
    // Keep the button below status/notch area plus a small touch-friendly gap.
    return [self resolvedTopSafeInset] + 12.0;
}

- (CGFloat)resolvedLeftSafeInset {
    CGFloat leftInset = 0;

    if (@available(iOS 11.0, *)) {
        leftInset = rootView.safeAreaInsets.left;
        if (leftInset <= 0 && rootView.window != nil) {
            leftInset = rootView.window.safeAreaInsets.left;
        }
    }

    return leftInset;
}

- (CGFloat)resolvedRightSafeInset {
    CGFloat rightInset = 0;

    if (@available(iOS 11.0, *)) {
        rightInset = rootView.safeAreaInsets.right;
        if (rightInset <= 0 && rootView.window != nil) {
            rightInset = rootView.window.safeAreaInsets.right;
        }
    }

    return rightInset;
}

- (CGFloat)resolvedBottomSafeInset {
    CGFloat bottomInset = 0;

    if (@available(iOS 11.0, *)) {
        bottomInset = rootView.safeAreaInsets.bottom;
        if (bottomInset <= 0 && rootView.window != nil) {
            bottomInset = rootView.window.safeAreaInsets.bottom;
        }
    }

    return bottomInset;
}

- (CGRect)resolvedRootBounds {
    CGRect bounds = rootView.bounds;
    if (CGRectIsEmpty(bounds) || CGRectGetWidth(bounds) <= 0 || CGRectGetHeight(bounds) <= 0) {
        bounds = [UIScreen mainScreen].bounds;
    }
    return bounds;
}

- (CGFloat)landscapeLeftButtonX {
    // Keep the button away from left-side notch/safe area in landscape.
    return MAX(22.0, [self resolvedLeftSafeInset] + 12.0);
}

- (CGPoint)clampedCenterPoint:(CGPoint)point {
    CGFloat x = MIN(MAX(point.x, leftMargin), rightMargin);
    CGFloat y = MIN(MAX(point.y, topMargin), bottomMargin);
    return CGPointMake(x, y);
}

- (void)clampFloatButtonToVisibleArea {
    if (!_viewPot) {
        return;
    }
    _viewPot.center = [self clampedCenterPoint:_viewPot.center];
}

- (instancetype)initWithController:(InAppBrowserWebViewController*)webCtrl{
    //是否横屏
    if (self == [super init])
    {
        _webCtrl = webCtrl;
        rootView = webCtrl.view;
        isRotationRight = FALSE;
        listener = [[OrientationListener alloc]init];
    }
    return self;
}

/// 客服按钮拖拽事件
- (void)panGestureRecognizer:(UIPanGestureRecognizer *) pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        beginPoint = [pan locationInView:self->rootView];
    }
    
    else if (pan.state == UIGestureRecognizerStateChanged){
        
        CGPoint nowPoint = [pan locationInView:self->rootView];
        
        float offsetX = nowPoint.x - beginPoint.x;
        float offsetY = nowPoint.y - beginPoint.y;
        CGPoint centerPoint = CGPointMake(beginPoint.x + offsetX, beginPoint.y + offsetY);
        _viewPot.center = [self clampedCenterPoint:centerPoint];
    }else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateFailed){
        [self clampFloatButtonToVisibleArea];
    }
}

/// 设置客服按钮拖拽范围
- (void) updatePangestureRect {
    CGRect bounds = [self resolvedRootBounds];
    CGFloat viewWidth = CGRectGetWidth(_viewPot.bounds) > 0 ? CGRectGetWidth(_viewPot.bounds) : 32.0;
    CGFloat viewHeight = CGRectGetHeight(_viewPot.bounds) > 0 ? CGRectGetHeight(_viewPot.bounds) : 32.0;
    CGFloat halfW = viewWidth / 2.0;
    CGFloat halfH = viewHeight / 2.0;
    CGFloat edgePadding = 8.0;

    //防止越界，控制移动范围
    leftMargin = halfW + MAX([self resolvedLeftSafeInset], edgePadding);
    rightMargin = CGRectGetWidth(bounds) - halfW - MAX([self resolvedRightSafeInset], edgePadding);
    topMargin = MAX(halfH + edgePadding, [self portraitButtonY] + halfH);

    CGFloat reservedBottom = MAX([self resolvedBottomSafeInset], edgePadding);
    if (!isRotationRight) {
        reservedBottom = MAX(reservedBottom, (CGFloat)kTabBarHeight(_webCtrl));
    }
    bottomMargin = CGRectGetHeight(bounds) - halfH - reservedBottom;

    if (rightMargin < leftMargin) {
        CGFloat centerX = CGRectGetMidX(bounds);
        leftMargin = centerX;
        rightMargin = centerX;
    }
    if (bottomMargin < topMargin) {
        CGFloat centerY = CGRectGetMidY(bounds);
        topMargin = centerY;
        bottomMargin = centerY;
    }

    if (pathRef) {
        CGPathRelease(pathRef);
        pathRef = NULL;
    }

    pathRef=CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, NULL, leftMargin, topMargin);
    CGPathAddLineToPoint(pathRef, NULL, rightMargin, topMargin);
    CGPathAddLineToPoint(pathRef, NULL, rightMargin, bottomMargin);
    CGPathAddLineToPoint(pathRef, NULL, leftMargin, bottomMargin);
    CGPathAddLineToPoint(pathRef, NULL, leftMargin, topMargin);
    CGPathCloseSubpath(pathRef);
}

- (void)floatButtonAction
{
    if (_onFloatButtonClick) {
        _onFloatButtonClick();
    }
}

- (BOOL)isDeviceNotchScreen {
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        UIEdgeInsets safeAreaInsets = mainWindow.safeAreaInsets;
        if (safeAreaInsets.top > 20 || safeAreaInsets.bottom > 20 || safeAreaInsets.left > 0 || safeAreaInsets.right > 0) {
            return YES;
        }
    }
    return NO;
}


- (void)addFloatButton
{
    CGFloat y = [self portraitButtonY];
    CGRect bounds = [self resolvedRootBounds];
    CGFloat screenW = CGRectGetWidth(bounds);
    CGFloat screenH = CGRectGetHeight(bounds);
    //    if (iPhoneX || iPhoneX_R || iPhoneX_Max)
    //    {
    //        y = 44;
    //    }
    if(!_viewPot)
        _viewPot = [[UIView alloc] initWithFrame:CGRectMake(screenW-98, y, 32, 32)];
    _viewPot.backgroundColor = kGrayTransparentColor1;
    _viewPot.layer.cornerRadius = 16;
    _viewPot.layer.masksToBounds = YES;
    if(!_btn)
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _btn.frame = CGRectMake(-5, 0, 43, 32);
    
    if (!pan) {
        pan = [[UIPanGestureRecognizer alloc] initWithTarget: self action: @selector(panGestureRecognizer:)];
    }
    
    [_viewPot addGestureRecognizer: pan];
    [self updatePangestureRect];
    NSData *tongueData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ic_sp_web_close@2x.png" ofType:nil]];
    UIImage *img = [UIImage imageWithData:tongueData scale:2];
    [_btn setImage:img forState:UIControlStateNormal];
    [_btn setImage:img forState:UIControlStateHighlighted];
    [_btn addTarget:self action:@selector(floatButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_viewPot addSubview:_btn];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(43.5, 5, 1, 22)];
    label.backgroundColor = kWhiteColor;
    label.hidden = YES;
    [_viewPot addSubview:label];
    
    //    NSLog(@"++++=====+++++++getOrientation:%@ 使用传入配置", [UIApplication sharedApplication].statusBarOrientation);
    if (@available(iOS 16.0, *)) {
        //    switch ([UIApplication sharedApplication].statusBarOrientation) {
        //        case UIInterfaceOrientationLandscapeRight:
        //        case UIInterfaceOrientationLandscapeLeft:
        // 真横屏
        if (isRotationRight)
        {
            _viewPot.frame = CGRectMake([self landscapeLeftButtonX], (screenH/2) - 16, 32, 32);
            [_viewPot setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        }
        else
        {
            _viewPot.frame = CGRectMake(screenW-70, y, 32, 32);
            _viewPot.transform = CGAffineTransformIdentity;
        }
        //            break;
        //        case UIInterfaceOrientationPortrait:
        //        default:
        //            // 真竖屏
        //            if (isRotationRight)
        //            {
        //                _viewPot.frame = CGRectMake((kScreenW/2)-16, y - 20, 32, 32);
        //            }
        //            else
        //            {
        //                _viewPot.frame = CGRectMake(kScreenW-70, y - 20, 32, 32);
        //            }
        //            _viewPot.transform = CGAffineTransformIdentity;
        //            break;
        //   }
    }else{
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationLandscapeRight:
            case UIInterfaceOrientationLandscapeLeft:
                // 真横屏
                if (isRotationRight)
                {
                    _viewPot.frame = CGRectMake([self landscapeLeftButtonX], (screenH/2) - 16, 32, 32);
                    [_viewPot setTransform:CGAffineTransformMakeRotation(M_PI_2)];
                }
                else
                {
                    _viewPot.frame = CGRectMake(screenW-70, y, 32, 32);
                    _viewPot.transform = CGAffineTransformIdentity;
                }
                break;
            case UIInterfaceOrientationPortrait:
            default:
                // 真竖屏
                if (isRotationRight)
                {
                    _viewPot.frame = CGRectMake((screenW/2)-16, y, 32, 32);
                }
                else
                {
                    _viewPot.frame = CGRectMake(screenW-70, y, 32, 32);
                }
                _viewPot.transform = CGAffineTransformIdentity;
                break;
        }
    }
    
    [self->rootView addSubview:_viewPot];
    [self updatePangestureRect];
    [self clampFloatButtonToVisibleArea];
    //    self.titleView = view;
}

- (void)createCloseButton:(NSDictionary*)dict {
    id callbackIndex = dict[@"callback"];
    NSString *title = [dict objectForKey:@"title"];
    NSString *text = [dict objectForKey:@"text"];
    NSString *confirmText = [dict objectForKey:@"confirmText"];
    NSString *cancleText = [dict objectForKey:@"cancleText"];
    
    __weak typeof(self) weakSelf = self;
    _onFloatButtonClick = ^(){
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        
        //弹出确认框
        if([text isEqual:[NSNull null]]){
            [strongSelf doCallback:callbackIndex args:@"1"];
        }else{
            [strongSelf showConfirmDialog:title text:text cancleText:cancleText confirmText:confirmText callbackIndex:callbackIndex cancleValue:nil otherValue:@"1"];
        }
    };
    
    [listener getOrientation:^(NSString* orientation){
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        // 如果有配置则使用配置的
        if ([dict objectForKey:@"isRotationRight"])
            strongSelf->isRotationRight = ([[dict objectForKey:@"isRotationRight"] isEqual:@"1"]);
        else if ([LANDSCAPE_RIGHT isEqual:orientation]) {
            // 不然就使用目前横竖屏的情况
            strongSelf->isRotationRight = TRUE;
        }
        
        NSLog(@"+++++++++++++++++++listener getOrientation:%@ 使用传入配置:%@", orientation, strongSelf->isRotationRight ? @"横屏":@"竖屏");
        
        //创建浮动窗口
        [self addFloatButton];
    }];
}

- (void)dispose {
    if (_btn) {
        [_btn removeTarget:self action:@selector(floatButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _btn = nil;
    }
    if (pan) {
        [pan removeTarget:self action:@selector(panGestureRecognizer:)];
        pan = nil;
    }
    if (pathRef) {
        CGPathRelease(pathRef);
        pathRef = NULL;
    }
    _onFloatButtonClick = nil;
}

/// 更新按钮位置（根据方向变化）
- (void)updatePosition:(BOOL)isLandscape {
    if (!_viewPot) return;

    isRotationRight = isLandscape;
    [self updatePangestureRect];

    CGFloat y = [self portraitButtonY];
    CGRect bounds = [self resolvedRootBounds];
    CGFloat screenW = CGRectGetWidth(bounds);
    CGFloat screenH = CGRectGetHeight(bounds);

    if (isLandscape) {
        // 横屏布局：左侧垂直居中
        _viewPot.frame = CGRectMake([self landscapeLeftButtonX], (screenH/2) - 16, 32, 32);
        [_viewPot setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    } else {
        // 竖屏布局：右上角
        _viewPot.frame = CGRectMake(screenW - 70, y, 32, 32);
        _viewPot.transform = CGAffineTransformIdentity;
    }
    [self updatePangestureRect];
    [self clampFloatButtonToVisibleArea];

    NSLog(@"[FloatButton] updatePosition: %@", isLandscape ? @"横屏" : @"竖屏");
}

// 显示关闭小窗口
- (void)handleCreateCloseButton:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *dict = call.arguments;
    [self createCloseButton:dict];
    result(nil);
}


- (void)doCallback:(id)callback args:(id)args {
    //    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    //    [dict setValue:callback forKey:@"callback"];
    //    [dict setValue:args forKey:@"args"];
    //    [_methodChannel invokeMethod:@"doCallback" arguments:dict];
    [_webCtrl close];
}

- (UIViewController *) topMostController {
    UIViewController* topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while(topController.presentedViewController){
        topController = topController.presentedViewController;
    }
    //    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeRight) forKey:@"orientation"];
    return topController;
}

////是否允许旋转
//- (BOOL)shouldAutorotate {
//    NSLog(@"%s",__FUNCTION__);
//    return YES;
//}
////present时可支持的旋转方向（present时在supportedInterfaceOrientations前执行）
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    NSLog(@"%s",__FUNCTION__);
////    if (_orientationMask & UIInterfaceOrientationMaskLandscapeLeft) {
////        return UIInterfaceOrientationLandscapeLeft;
////    }
////    return UIInterfaceOrientationPortrait;
//    return UIInterfaceOrientationLandscapeRight;
//}
////支持的旋转方向
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    NSLog(@"%s",__FUNCTION__);
////    if ([AppDelegate sharedInstance].supportLandscape) {
////        return _orientationMask | UIInterfaceOrientationMaskLandscapeLeft;
////    } else {
////        return UIInterfaceOrientationMaskPortrait;
////    }
//    return UIInterfaceOrientationLandscapeRight;
//}

// 弹出确认窗口
- (void)showConfirmDialog:(NSString*)title
                     text:(NSString*)text
               cancleText:(NSString*)cancleText
              confirmText:(NSString*)confirmText
            callbackIndex:(id)callbackIndex
              cancleValue:(id)cancleValue
               otherValue:(id)otherValue
{
    // 初始化对话框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
    //    alert.isHeng = isRotationRight;
    //    alert.nameWithSetterGetter = isRotationRight ? @"1" : @"0";
    //    [alert setLandscape:@"0"];
    [alert setLandscape:isRotationRight ? @"1" : @"0"];
    
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:confirmText style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf && otherValue) {
            [strongSelf->_webCtrl updateOrientation];
            [alert setLandscape:@"0"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [strongSelf->_viewPot removeFromSuperview];
                [strongSelf doCallback:callbackIndex args:otherValue];
            });
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:cancleText style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf && cancleValue) {
            [strongSelf doCallback:callbackIndex args:cancleValue];
            [strongSelf->_viewPot removeFromSuperview];
        }
    }]];
    // 弹出对话框
    [[self topMostController] presentViewController:alert animated:true completion:nil];
}

@end
