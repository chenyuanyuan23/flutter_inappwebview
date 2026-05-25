//
//  FanweDeviceMacro.h
//  FanweApp
//
//
//
//

#ifndef FanweDeviceMacro_h
#define FanweDeviceMacro_h


// 屏幕frame,bounds,size,scale
#define kScreenFrame            [UIScreen mainScreen].bounds
#define kScreenBounds           [UIScreen mainScreen].bounds
#define kScreenSize             [UIScreen mainScreen].bounds.size
#define kScreenScale            [UIScreen mainScreen].scale
#define kScreenW                [[UIScreen mainScreen] bounds].size.width
#define kScreenH                [[UIScreen mainScreen] bounds].size.height
#define kScaleW                 (kScreenW)*(kScreenScale)
#define kScaleH                 (kScreenH)*(kScreenScale)

#define kScaleWidth             [[UIScreen mainScreen] bounds].size.width/375.00
#define kScaleHeight            [[UIScreen mainScreen] bounds].size.height/667.00


// 主窗口的宽、高
#define kMainScreenWidth        MainScreenWidth()
#define kMainScreenHeight       MainScreenHeight()
static __inline__ CGFloat MainScreenWidth()
{
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height;
}

static __inline__ CGFloat MainScreenHeight()
{
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width;
}


//--------------------------------------------------------

// 获取屏幕 宽度、高度 bounds就是屏幕的全部区域
#define SCREEN_FRAME ([UIScreen mainScreen].bounds)
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

//按宽度适配 不适用于
#define ytt_fit(value) ((value)*SCREEN_WIDTH/375.0)
// row 的高度随着手机屏幕高度的比例
#define kAppRowHScale        AppRowHScale()
static __inline__ CGFloat AppRowHScale()
{
    if (([UIScreen mainScreen].bounds.size.height==568.0f))
    {
        return 0.88f;
    }
    else if ([UIScreen mainScreen].bounds.size.height==667.0f)
    {
        return 1.00f;
    }
    else if ([UIScreen mainScreen].bounds.size.height==736.0f)
    {
        return 1.12f;
    }
    else
    {
        return [UIScreen mainScreen].bounds.size.width/375;
    }
}


//---------------------------------------------------------------
// 状态栏、导航栏、标签栏高度
#define kStatusBarHeight        ([UIApplication sharedApplication].statusBarFrame.size.height)
#define kNavigationBarHeight    (self.navigationController.navigationBar.frame.size.height)
#define kTabBarHeight(ctrl)           ((ctrl).tabBarController.tabBar.frame.size.height)
#define KgetRectNavAndStatusHeight  self.navigationController.navigationBar.frame.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height

#define scale_hight1            kScreenH < 600 ? 50 : 55
#define scale_hight             kScreenH > 667 ? 60 : scale_hight1


/// 判断是否是ipad
#define isPads ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

// 当前所在window
#define kCurrentWindow          [FWAppDelegate sharedAppDelegate].sus_window.rootViewController ? [FWAppDelegate sharedAppDelegate].sus_window : [FWAppDelegate sharedAppDelegate].window


//---------------------------------------------------------------

#define isIPad()                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define isIPhone()              (!isIPad())

#define isIPhoneX()             (([[UIScreen mainScreen] bounds].size.height-812) ? NO : YES)

#define isIPhone5()             ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define isIPhone4()             ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)


#define iPhone4s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6_Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhoneX_R ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size)  : NO)

#define iPhoneX_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone12_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1284, 2778), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone13_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1170, 2532), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone14_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1290, 2796), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone14 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1179, 2556), [[UIScreen mainScreen] currentMode].size) : NO)

#define kIsiPhoneX_series (iPhoneX==YES || iPhoneX_R ==YES || iPhoneX_Max==YES || iPhone12_Max || iPhone13_Max || iPhone14_Max || iPhone14)



#define kDefaultNavBarHeight (kIsiPhoneX_series ? 88.0 : 64.0)
#define kDefaultTabBarHeight (kIsiPhoneX_series ? 83.0 : 49.0)
#define kDefaultStatusBarHeight (kIsiPhoneX_series ? 44.0 : 20.0)

#define isIOS11Above()               ([[UIDevice currentDevice].systemVersion doubleValue]>= 11.0)

#define isIOS11()               ([[UIDevice currentDevice].systemVersion doubleValue]>= 11.0 && [[UIDevice currentDevice].systemVersion doubleValue] < 12.0)

#define isIOS10()               ([[UIDevice currentDevice].systemVersion doubleValue]>= 10.0 && [[UIDevice currentDevice].systemVersion doubleValue] < 11.0)

#define isIOS9()                ([[UIDevice currentDevice].systemVersion doubleValue]>= 9.0 && [[UIDevice currentDevice].systemVersion doubleValue] < 10.0)

#define isIOS8()                ([[UIDevice currentDevice].systemVersion doubleValue]>= 8.0 && [[UIDevice currentDevice].systemVersion doubleValue] < 9.0)

#define isIOS7()                ([[UIDevice currentDevice].systemVersion doubleValue]>= 7.0 && [[UIDevice currentDevice].systemVersion doubleValue] < 8.0)

#define isIOS6()                ([[UIDevice currentDevice].systemVersion doubleValue]>= 6.0 && [[UIDevice currentDevice].systemVersion doubleValue] < 7.0)

#define IsiPhone11 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)
#define IsiPhone11Pro ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define IsiPhone11ProMax ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)



// ====================================取色值相关的方法==========================================

#define RGB(r,g,b)          [UIColor colorWithRed:(r)/255.f \
                            green:(g)/255.f \
                            blue:(b)/255.f \
                            alpha:1.f]

#define RGBA(r,g,b,a)       [UIColor colorWithRed:(r)/255.f \
                            green:(g)/255.f \
                            blue:(b)/255.f \
                            alpha:(a)]

#define RGBOF(rgbValue)     [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                            green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
                            blue:((float)(rgbValue & 0xFF))/255.0 \
                            alpha:1.0]

#define RGBA_OF(rgbValue)   [UIColor colorWithRed:((float)(((rgbValue) & 0xFF000000) >> 24))/255.0 \
                            green:((float)(((rgbValue) & 0x00FF0000) >> 16))/255.0 \
                            blue:((float)(rgbValue & 0x0000FF00) >> 8)/255.0 \
                            alpha:((float)(rgbValue & 0x000000FF))/255.0]

#define RGBAOF(v, a)        [UIColor colorWithRed:((float)(((v) & 0xFF0000) >> 16))/255.0 \
                            green:((float)(((v) & 0x00FF00) >> 8))/255.0 \
                            blue:((float)(v & 0x0000FF))/255.0 \
                            alpha:a]
#define kColorWithStr(colorStr)      [UIColor colorWithHexString:colorStr]


#endif /* FanweDeviceMacro_h */
