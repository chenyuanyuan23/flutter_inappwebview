
#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>

typedef void(^floatButtonClickDelegate)(void);

// FloatButton 的宿主 ViewController 协议。Swift 端
// InAppBrowserWebViewController 通过 extension 声明 conformance，
// 让 FloatButton 不直接引用 Swift 类（避免 OC↔Swift 循环依赖，
// 解锁 SPM target 拆分）。
@protocol FloatButtonHost <NSObject>
- (void)close;
- (void)updateOrientation;
@end

@interface FloatButton : NSObject

@property (nonatomic, copy) floatButtonClickDelegate onFloatButtonClick;

- (instancetype)initWithController:(UIViewController*)webCtrl;

- (void)createCloseButton:(NSDictionary*)dict ;

- (void)dispose;

// 创建关闭按钮
- (void)handleCreateCloseButton:(FlutterMethodCall*)call result:(FlutterResult)result;

// 更新按钮位置（根据方向）
- (void)updatePosition:(BOOL)isLandscape;

//显示确认框
- (void)showConfirmDialog:(NSString*)title
                     text:(NSString*)text
               cancleText:(NSString*)cancleText
              confirmText:(NSString*)confirmText
            callbackIndex:(id)callbackIndex
              cancleValue:(id)cancleValue
               otherValue:(id)otherValue;
@end

