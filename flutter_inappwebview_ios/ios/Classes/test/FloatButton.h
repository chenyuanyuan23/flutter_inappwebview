
#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>

typedef void(^floatButtonClickDelegate)(void);

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

