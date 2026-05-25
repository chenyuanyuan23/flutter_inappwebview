//
//  InAppBrowserManager.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 18/12/2019.
//

import Flutter
import UIKit
import WebKit
import Foundation
import AVFoundation

public class InAppBrowserManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappbrowser"
    static let WEBVIEW_STORYBOARD = "WebView"
    static let WEBVIEW_STORYBOARD_CONTROLLER_ID = "viewController"
    static let NAV_STORYBOARD_CONTROLLER_ID = "navController"
    var plugin: SwiftFlutterPlugin?
    
    private var previousStatusBarStyle = -1
    
    init(plugin: SwiftFlutterPlugin) {
        super.init(channel: FlutterMethodChannel(name: InAppBrowserManager.METHOD_CHANNEL_NAME, binaryMessenger: plugin.registrar!.messenger()))
        self.plugin = plugin
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary

        switch call.method {
            case "open":
                open(arguments: arguments!)
                result(true)
                break
            case "openWithSystemBrowser":
                let url = arguments!["url"] as! String
                openWithSystemBrowser(url: url, result: result)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public func prepareInAppBrowserWebViewController(settings: [String: Any?]) -> InAppBrowserWebViewController {
        if previousStatusBarStyle == -1 {
            previousStatusBarStyle = UIApplication.shared.statusBarStyle.rawValue
        }
        
        let browserSettings = InAppBrowserSettings()
        let _ = browserSettings.parse(settings: settings)
        
        let webViewSettings = InAppWebViewSettings()
        let _ = webViewSettings.parse(settings: settings)
        
        let webViewController = InAppBrowserWebViewController()
        webViewController.plugin = plugin
        webViewController.browserSettings = browserSettings
        webViewController.isHidden = browserSettings.hidden
        webViewController.webViewSettings = webViewSettings
        webViewController.previousStatusBarStyle = previousStatusBarStyle
        return webViewController
    }
    
    public func open(arguments: NSDictionary) {
        let id = arguments["id"] as! String
        let urlRequest = arguments["urlRequest"] as? [String:Any?]
        let assetFilePath = arguments["assetFilePath"] as? String
        let data = arguments["data"] as? String
        let mimeType = arguments["mimeType"] as? String
        let encoding = arguments["encoding"] as? String
        let baseUrl = arguments["baseUrl"] as? String
        let settings = arguments["settings"] as! [String: Any?]
        let contextMenu = arguments["contextMenu"] as! [String: Any]
        let windowId = arguments["windowId"] as? Int64
        let initialUserScripts = arguments["initialUserScripts"] as? [[String: Any]]
        let pullToRefreshInitialSettings = arguments["pullToRefreshSettings"] as! [String: Any?]
        let menuItems = arguments["menuItems"] as! [[String: Any?]]
        let faceOrientation = settings["faceOrientation"] as! String
        let isCutTopButtom = settings["isCutTopButtom"] as! Bool
        
        let webViewController = prepareInAppBrowserWebViewController(settings: settings)
        
        webViewController.id = id
        webViewController.initialUrlRequest = urlRequest != nil ? URLRequest.init(fromPluginMap: urlRequest!) : nil
        webViewController.initialFile = assetFilePath
        webViewController.initialData = data
        webViewController.initialMimeType = mimeType
        webViewController.initialEncoding = encoding
        webViewController.initialBaseUrl = baseUrl
        webViewController.contextMenu = contextMenu
        webViewController.windowId = windowId
        webViewController.initialUserScripts = initialUserScripts ?? []
        webViewController.pullToRefreshInitialSettings = pullToRefreshInitialSettings
        webViewController.setUIInterfaceOrientation(ori: faceOrientation)
        webViewController.browserSettings?.isCutTopButtom = isCutTopButtom
        for menuItem in menuItems {
            webViewController.menuItems.append(InAppBrowserMenuItem.fromMap(map: menuItem)!)
        }
        
        presentViewController(webViewController: webViewController)
    }
    
    public func presentViewController(webViewController: InAppBrowserWebViewController) {
        // SPM 模式资源在 Bundle.module；CocoaPods 模式资源在 framework bundle。
        // 原代码 Bundle(for: InAppWebViewFlutterPlugin.self) 用了 @objc OC 名，
        // Swift 内部要用 Swift 真名 SwiftFlutterPlugin.
        #if SWIFT_PACKAGE
        let resourceBundle = Bundle.module
        #else
        let resourceBundle = Bundle(for: SwiftFlutterPlugin.self)
        #endif
        let storyboard = UIStoryboard(name: InAppBrowserManager.WEBVIEW_STORYBOARD, bundle: resourceBundle)
        let navController = storyboard.instantiateViewController(withIdentifier: InAppBrowserManager.NAV_STORYBOARD_CONTROLLER_ID) as! InAppBrowserNavigationController
        webViewController.edgesForExtendedLayout = []
        navController.tempOrienta = webViewController.faceOrientation
        navController.tempshouldAutorotate = webViewController.shouldAutorotate

        navController.pushViewController(webViewController, animated: false)
        webViewController.prepareNavigationControllerBeforeViewWillAppear()

        // 使用 UIWindowScene 创建 UIWindow (兼容 iOS 13+)
        let tmpWindow: UIWindow
        if #available(iOS 13.0, *),
           let windowScene = UIApplication.shared.connectedScenes
               .compactMap({ $0 as? UIWindowScene })
               .first(where: { $0.activationState == .foregroundActive }) ??
               UIApplication.shared.connectedScenes
               .compactMap({ $0 as? UIWindowScene }).first {
            tmpWindow = UIWindow(windowScene: windowScene)
        } else {
            let frame: CGRect = UIScreen.main.bounds
            tmpWindow = UIWindow(frame: frame)
        }

        let tmpController = UIViewController()

        // 安全获取 baseWindowLevel
        let baseWindowLevel: UIWindow.Level
        if #available(iOS 13.0, *) {
            baseWindowLevel = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })?.windowLevel ?? .normal
        } else {
            baseWindowLevel = UIApplication.shared.keyWindow?.windowLevel ?? .normal
        }

        tmpWindow.rootViewController = tmpController
        tmpWindow.windowLevel = UIWindow.Level(baseWindowLevel.rawValue + 1.0)
        tmpWindow.makeKeyAndVisible()
        navController.tmpWindow = tmpWindow

        var animated = true
        if let browserSettings = webViewController.browserSettings, browserSettings.hidden {
            tmpWindow.isHidden = true
            UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            animated = false
        }

       tmpWindow.rootViewController!.present(navController, animated: animated, completion: nil)
        
        
        
        // guard let visibleViewController = UIApplication.shared.visibleViewController else {
        //     assertionFailure("Failure init the visibleViewController!")
        //     return
        // }

        // if let popover = navController.popoverPresentationController {
        //     let sourceView = visibleViewController.view ?? UIView()

        //     popover.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
        //     popover.permittedArrowDirections = []
        //     popover.sourceView = sourceView
        // }

        // visibleViewController.present(navController, animated: animated)
       
       
        
    }
    
    public func openWithSystemBrowser(url: String, result: @escaping FlutterResult) {
        let absoluteUrl = URL(string: url)!.absoluteURL
        if !UIApplication.shared.canOpenURL(absoluteUrl) {
            result(FlutterError(code: "InAppBrowserManager", message: url + " cannot be opened!", details: nil))
            return
        }
        else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(absoluteUrl)
            } else {
                UIApplication.shared.openURL(absoluteUrl)
            }
        }
        result(true)
    }
    
    public override func dispose() {
        super.dispose()
        plugin = nil
    }
    
    deinit {
        dispose()
    }
}
