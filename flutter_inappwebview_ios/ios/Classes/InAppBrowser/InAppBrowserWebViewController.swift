//
//  InAppBrowserWebViewController.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 17/09/18.
//

import Flutter
import UIKit
import WebKit
import Foundation

public class InAppBrowserWebViewController: UIViewController, InAppBrowserDelegate, UIScrollViewDelegate, UISearchBarDelegate, Disposable {
    static let METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappbrowser_"
    
    var closeButton: UIBarButtonItem!
    var reloadButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem!
    var searchBar: UISearchBar!
    var progressBar: UIProgressView!
    var menuButton: UIBarButtonItem?
    // 可拖拽关闭按钮
    var floatBtn:FloatButton?
    var view22:UIView!
    //朝向
    var faceOrientation:UIInterfaceOrientationMask = UIInterfaceOrientationMask.portrait
    private var _menu: Any?
    @available(iOS 13.0, *)
    var menu: UIMenu? {
        set {
            _menu = newValue
        }
        get {
            return _menu as? UIMenu
        }
    }
    
    var tmpWindow: UIWindow?
    var id: String = ""
    var plugin: SwiftFlutterPlugin?
    var windowId: Int64?
    var webView: InAppWebView?
    var channelDelegate: InAppBrowserChannelDelegate?
    var initialUrlRequest: URLRequest?
    var initialFile: String?
    var contextMenu: [String: Any]?
    var browserSettings: InAppBrowserSettings?
    var webViewSettings: InAppWebViewSettings?
    var initialData: String?
    var initialMimeType: String?
    var initialEncoding: String?
    var initialBaseUrl: String?
    var previousStatusBarStyle = -1
    var initialUserScripts: [[String: Any]] = []
    var pullToRefreshInitialSettings: [String: Any?] = [:]
    var isHidden = false
    var menuItems: [InAppBrowserMenuItem] = []

    public override func loadView() {
        guard let plugin = plugin, let registrar = plugin.registrar else {
            return
        }
        
        let channel = FlutterMethodChannel(name: InAppBrowserWebViewController.METHOD_CHANNEL_NAME_PREFIX + id, binaryMessenger: registrar.messenger())
        channelDelegate = InAppBrowserChannelDelegate(channel: channel)
        
        var userScripts: [UserScript] = []
        for initialUserScript in initialUserScripts {
            userScripts.append(UserScript.fromMap(map: initialUserScript, windowId: windowId)!)
        }
        
        let preWebviewConfiguration = InAppWebView.preWKWebViewConfiguration(settings: webViewSettings)
        if let wId = windowId, let webViewTransport = plugin.inAppWebViewManager?.windowWebViews[wId] {
            webView = webViewTransport.webView
            webView!.contextMenu = contextMenu
            webView!.initialUserScripts = userScripts
        } else {
            webView = InAppWebView(id: nil,
                                   plugin: nil,
                                   frame: .zero,
                                   configuration: preWebviewConfiguration,
                                   contextMenu: contextMenu,
                                   userScripts: userScripts)
        }
        
        guard let webView = webView else {
            return
        }
        
        webView.inAppBrowserDelegate = self
        webView.id = id
        webView.plugin = plugin
        webView.channelDelegate = WebViewChannelDelegate(webView: webView, channel: channel)
        
        let pullToRefreshSettings = PullToRefreshSettings()
        let _ = pullToRefreshSettings.parse(settings: pullToRefreshInitialSettings)
        let pullToRefreshControl = PullToRefreshControl(plugin: plugin, id: id, settings: pullToRefreshSettings)
        webView.pullToRefreshControl = pullToRefreshControl
        pullToRefreshControl.delegate = webView
        pullToRefreshControl.prepare()
        
        let findInteractionController = FindInteractionController(
            plugin: plugin,
            id: id, webView: webView, settings: nil)
        webView.findInteractionController = findInteractionController
        findInteractionController.prepare()
        
        prepareWebView()
        let statusHeight: Double
        if #available(iOS 13.0, *), keywindows() != nil {
            statusHeight = InAppBrowserWebViewController.isFullScreen ? 44 : 0
        } else {
            statusHeight = Double(UIApplication.shared.statusBarFrame.size.height)
        }
        webView.windowCreated = true
        
        progressBar = UIProgressView(progressViewStyle: .bar)
        progressBar.isHidden = true
        
        view = UIView()
        let isCutTopButtom:Bool = (browserSettings?.isCutTopButtom)! // 是否裁切
        let isHengPing:Bool = getIsHengPing(ori: browserSettings!.faceOrientation)   // 是否横屏
        setupWebViewLayout(isCutTopButtom: isCutTopButtom, isHengPing: isHengPing, statusHeight: statusHeight)
        
        view.insertSubview(progressBar, aboveSubview: webView)
    }

    private func setupWebViewLayout(isCutTopButtom: Bool, isHengPing: Bool, statusHeight: Double) {
        var adjustedStatusHeight = statusHeight
//        webView!.removeConstraints(webView!.constraints)

        view.addSubview(webView!)
        webView!.removeConstraints(webView!.constraints)
        webView!.translatesAutoresizingMaskIntoConstraints = false
        
        if isCutTopButtom {
//            webView!.translatesAutoresizingMaskIntoConstraints = true
//            view22 = UIView()
            view.backgroundColor = .black
            if isHengPing {
                adjustedStatusHeight = (statusHeight == 20 || statusHeight == 0) ? 0.0 : 30.0
                setupView22AndWebViewFrames(statusHeight: adjustedStatusHeight, isHengPing: isHengPing)
            } else {
                adjustedStatusHeight = (statusHeight == 20) ? 0.0 : statusHeight
                setupView22AndWebViewFrames(statusHeight: adjustedStatusHeight, isHengPing: isHengPing)
            }
        } else {
            view.addSubview(webView!)
        }
    }
    
    private func setupView22AndWebViewFrames(statusHeight: Double, isHengPing: Bool) {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view22.translatesAutoresizingMaskIntoConstraints = false
//        view22.frame = CGRect(x: 0, y: statusHeight, width: screenWidth, height: statusHeight)
        
        if isHengPing {
//            webView!.frame = CGRect(x: statusHeight, y: 0, width: screenWidth - statusHeight, height: screenHeight)
            // 获取当前视图的 safe area
            NSLayoutConstraint.activate([
                webView!.topAnchor.constraint(equalTo: view.topAnchor), // 顶部对齐父视图顶部
                webView!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: statusHeight), // 左边距离父视图左边100点
                webView!.bottomAnchor.constraint(equalTo: view.bottomAnchor), // 底部对齐父视图底部
                webView!.trailingAnchor.constraint(equalTo: view.trailingAnchor)  // 右边对齐父视图右边
            ])
        } else {
//            view.translatesAutoresizingMaskIntoConstraints = false
//            webView!.translatesAutoresizingMaskIntoConstraints = false
//            webView!.frame = CGRect(x: 0, y: statusHeight, width: screenWidth, height: screenHeight - statusHeight - 20)
            NSLayoutConstraint.activate([
                webView!.topAnchor.constraint(equalTo: view.topAnchor,constant: statusHeight), // 顶部对齐父视图顶部
                webView!.leftAnchor.constraint(equalTo: view.leftAnchor), // 左边距离父视图左边100点
                webView!.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: screenHeight - statusHeight - 20), // 底部对齐父视图底部
                webView!.rightAnchor.constraint(equalTo: view.rightAnchor)  // 右边对齐父视图右边
            ])
        }
    }
    
    func keywindows() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first(where: { $0.activationState == .foregroundActive })?
                .windows.first
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    // 是否横屏
    private func getIsHengPing(ori: String) -> Bool {
        return ori == "LandscapeLeft" || ori == "LandscapeRight"
    }
    
    static var isFullScreen: Bool {
        if #available(iOS 11, *) {
            guard let window = UIApplication.shared.delegate?.window,
                  let unwrapedWindow = window else {
                return false
            }
            
            if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
                print(unwrapedWindow.safeAreaInsets)
                return true
            }
        }
        return false
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        webView!.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        
        if #available(iOS 9.0, *) {
            let isCutTopButtom:Bool = (browserSettings?.isCutTopButtom)! // 是否裁切
            let statusHeight: Double
            if #available(iOS 13.0, *), keywindows() != nil {
                statusHeight = InAppBrowserWebViewController.isFullScreen ? 44 : 0
            } else {
                statusHeight = Double(UIApplication.shared.statusBarFrame.size.height)
            }
            let num = isCutTopButtom ? statusHeight:0.0
            //可以在这边修改webview的 显示区域
            webView?.topAnchor.constraint(equalTo: self.view.topAnchor, constant: num).isActive = true
            webView?.bottomAnchor.constraint(
                equalTo: self.view.bottomAnchor,
                constant: isCutTopButtom ? -20.0 : 0.0 
            ).isActive = true
            webView?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0).isActive = true
            webView?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0).isActive = true

            progressBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0).isActive = true
            progressBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0).isActive = true
            progressBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0).isActive = true
        } else {
            if let webView = webView {
                view.addConstraints([
                    NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: webView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: webView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
                ])
            }
            if let progressBar = progressBar {
                view.addConstraints([
                    NSLayoutConstraint(item: progressBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: progressBar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: progressBar, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
                ])
            }
        }
        
        if windowId != nil {
            if let wId = windowId, let webViewTransport = plugin?.inAppWebViewManager?.windowWebViews[wId] {
                webView?.load(webViewTransport.request)
            }
            channelDelegate?.onBrowserCreated()
            webView?.runWindowBeforeCreatedCallbacks()
        } else {
            if #available(iOS 11.0, *) {
                if let contentBlockers = webView?.settings?.contentBlockers, contentBlockers.count > 0 {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: contentBlockers, options: [])
                        let blockRules = String(data: jsonData, encoding: .utf8)
                        WKContentRuleListStore.default().compileContentRuleList(
                            forIdentifier: "ContentBlockingRules",
                            encodedContentRuleList: blockRules) { (contentRuleList, error) in

                                if let error = error {
                                    print(error.localizedDescription)
                                    return
                                }

                                let configuration = self.webView!.configuration
                                configuration.userContentController.add(contentRuleList!)

                                self.initLoad()
                        }
                        return
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            
            initLoad()
        }
        showCloseButton(closeButtonOptions: closeOption)
        //状态重刷
        setNeedsStatusBarAppearanceUpdate()
    }
    
    public func initLoad() {
        if let initialFile = initialFile {
            do {
                try webView?.loadFile(assetFilePath: initialFile)
            }
            catch let error as NSError {
                dump(error)
            }
        }
        else if let initialData = initialData {
            let baseUrl = URL(string: initialBaseUrl ?? "about:blank")!
            var allowingReadAccessToURL: URL? = nil
            if let allowingReadAccessTo = webView?.settings?.allowingReadAccessTo, baseUrl.scheme == "file" {
                allowingReadAccessToURL = URL(string: allowingReadAccessTo)
                if allowingReadAccessToURL?.scheme != "file" {
                    allowingReadAccessToURL = nil
                }
            }
            webView?.loadData(data: initialData, mimeType: initialMimeType!, encoding: initialEncoding!, baseUrl: baseUrl, allowingReadAccessTo: allowingReadAccessToURL)
        }
        else if let initialUrlRequest = initialUrlRequest {
            var allowingReadAccessToURL: URL? = nil
            if let allowingReadAccessTo = webView?.settings?.allowingReadAccessTo, let url = initialUrlRequest.url, url.scheme == "file" {
                allowingReadAccessToURL = URL(string: allowingReadAccessTo)
                if allowingReadAccessToURL?.scheme != "file" {
                    allowingReadAccessToURL = nil
                }
            }
            webView?.loadUrl(urlRequest: initialUrlRequest, allowingReadAccessTo: allowingReadAccessToURL)
        }
        
        channelDelegate?.onBrowserCreated()
    }
    
    // 设备朝向
    public func setUIInterfaceOrientation(ori: String) {
        faceOrientation = {
            switch ori {
            case "PortraitUp":
                return .portrait
            case "PortraitDown":
                return .portraitUpsideDown
            case "LandscapeLeft", "LandscapeRight":
                return .landscape
            default:
                return .all
            }
        }()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        dispose()
        super.viewDidDisappear(animated)
    }
    
    public override func viewWillDisappear (_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public func prepareNavigationControllerBeforeViewWillAppear() {
        if let browserOptions = browserSettings {
            navigationController?.modalPresentationStyle = UIModalPresentationStyle(rawValue: browserOptions.presentationStyle)!
            navigationController?.modalTransitionStyle = UIModalTransitionStyle(rawValue: browserOptions.transitionStyle)!
        }
    }
    
    public func prepareWebView() {
        webView?.settings = webViewSettings
        webView?.prepare()
              
        searchBar = UISearchBar()
        searchBar.keyboardType = .URL
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        reloadButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        forwardButton = UIBarButtonItem(title: "\u{203A}", style: .plain, target: self, action: #selector(goForward))
        forwardButton.isEnabled = false
        backButton = UIBarButtonItem(title: "\u{2039}", style: .plain, target: self, action: #selector(goBack))
        backButton.isEnabled = false
        
        toolbarItems = [backButton, spacer, forwardButton, spacer, shareButton, spacer, reloadButton]
        
        for state: UIControl.State in [.normal, .disabled, .highlighted, .selected] {
            forwardButton.setTitleTextAttributes([
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 50.0),
                NSAttributedString.Key.baselineOffset: 2.5
            ], for: state)
            backButton.setTitleTextAttributes([
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 50.0),
                NSAttributedString.Key.baselineOffset: 2.5
            ], for: state)
        }
        
        if let browserSettings = browserSettings {
            if !browserSettings.hideToolbarTop {
                navigationController?.navigationBar.isHidden = false
                if browserSettings.hideUrlBar {
                    searchBar.isHidden = true
                }
                if let bgColor = browserSettings.toolbarTopBackgroundColor, !bgColor.isEmpty {
                    navigationController?.navigationBar.backgroundColor = UIColor(hexString: bgColor)
                }
                if let barTintColor = browserSettings.toolbarTopBarTintColor, !barTintColor.isEmpty {
                    navigationController?.navigationBar.barTintColor = UIColor(hexString: barTintColor)
                }
                if let tintColor = browserSettings.toolbarTopTintColor, !tintColor.isEmpty {
                    navigationController?.navigationBar.tintColor = UIColor(hexString: tintColor)
                }
                navigationController?.navigationBar.isTranslucent = browserSettings.toolbarTopTranslucent
            }
            else {
                navigationController?.navigationBar.isHidden = true
            }
            
            if !browserSettings.hideToolbarBottom {
                navigationController?.isToolbarHidden = false
                if let bgColor = browserSettings.toolbarBottomBackgroundColor, !bgColor.isEmpty {
                    navigationController?.toolbar.barTintColor = UIColor(hexString: bgColor)
                }
                if let tintColor = browserSettings.toolbarBottomTintColor, !tintColor.isEmpty {
                    navigationController?.toolbar.tintColor = UIColor(hexString: tintColor)
                }
                navigationController?.toolbar.isTranslucent = false
            }
            else {
                navigationController?.isToolbarHidden = true
            }
            
            if let closeButtonCaption = browserSettings.closeButtonCaption, !closeButtonCaption.isEmpty {
                closeButton = UIBarButtonItem(title: closeButtonCaption, style: .plain, target: self, action: #selector(close))
            } else {
                setDefaultCloseButton()
            }
            
            if let closeButtonColor = browserSettings.closeButtonColor, !closeButtonColor.isEmpty {
                closeButton.tintColor = UIColor(hexString: closeButtonColor)
            }
            
            if browserSettings.hideProgressBar {
                progressBar.isHidden = true
            }
            
            navigationItem.rightBarButtonItems = []
            
            if !browserSettings.hideCloseButton {
                navigationItem.rightBarButtonItems = [closeButton]
            }
            
            if #available(iOS 14.0, *), !menuItems.isEmpty {
                var uiActions: [UIAction] = []
                menuItems = menuItems.sorted(by: {$0.order ?? 0 < $1.order ?? 0})
                for menuItem in menuItems {
                    let uiAction = UIAction(title: menuItem.title, image: menuItem.icon, handler: {_ in
                        self.channelDelegate?.onMenuItemClicked(menuItem: menuItem)
                    })
                    if !menuItem.showAsAction {
                        uiActions.append(uiAction)
                    } else {
                        let buttonItem = UIBarButtonItem(primaryAction: uiAction)
                        buttonItem.tintColor = menuItem.iconColor
                        navigationItem.rightBarButtonItems?.append(buttonItem)
                    }
                }
                if !uiActions.isEmpty {
                    menu = UIMenu(title: "", options: .displayInline, children: uiActions)
                    menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
                    if let menuButtonColor = browserSettings.menuButtonColor, !menuButtonColor.isEmpty {
                        menuButton?.tintColor = UIColor(hexString: menuButtonColor)
                    }
                    let index = browserSettings.hideCloseButton ? 0 : 1
                    navigationItem.rightBarButtonItems?.insert(menuButton!, at: index)
                }
            }
        }
        navigationItem.rightBarButtonItem = closeButton
        //在这里设置根本来不及了
        if browserSettings?.faceOrientation != "" {
            setUIInterfaceOrientation(ori: browserSettings!.faceOrientation)
        }
    }
    
    func setDefaultCloseButton() {
        if closeButton != nil {
            closeButton.target = nil
            closeButton.action = nil
        }
        var barButtonSystemItem = UIBarButtonItem.SystemItem.cancel
        if #available(iOS 13.0, *) {
            barButtonSystemItem = UIBarButtonItem.SystemItem.close
        }
        closeButton = UIBarButtonItem(barButtonSystemItem: barButtonSystemItem, target: self, action: #selector(close))
    }
    
    @objc public func updateOrientation(){
       faceOrientation = UIInterfaceOrientationMask.portrait
       print("===========()",faceOrientation)
       if #available(iOS 16.0, *) {
           self.setNeedsUpdateOfSupportedInterfaceOrientations()
           // 根据需要更新接口方向
       }
       if let navController = navigationController as? InAppBrowserNavigationController {
           navController.tempOrienta = UIInterfaceOrientationMask.portrait
           if #available(iOS 16.0, *) {
               navController.setNeedsUpdateOfSupportedInterfaceOrientations()
           }
       }
    }
    
#if swift(>=4.2)
    @available(iOS 11.0, *)
    override public var prefersHomeIndicatorAutoHidden: Bool {
        return false
    }

    override public var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        // 所有的角落都不要激活下横线
        return UIRectEdge(rawValue: 15)
    }

    override public var prefersStatusBarHidden: Bool {
       return true
    }
    

    override public var shouldAutorotate: Bool{
        return false
    }
    
    
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return faceOrientation
    }

    #else
    @available(iOS 11.0, *)
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    override func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge {
        return UIRectEdge(rawValue: 15)
    }
    
    override func prefersStatusBarHidden() -> Bool {
       return true
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return orientation
    }

    #endif
    
    public func didChangeTitle(title: String?) {
        guard let _ = title else {
            return
        }
    }
    
    public func didStartNavigation(url: URL?) {
        forwardButton.isEnabled = webView?.canGoForward ?? false
        backButton.isEnabled = webView?.canGoBack ?? false
        progressBar.setProgress(0.0, animated: false)
        guard let url = url else {
            return
        }
        searchBar.text = url.absoluteString
    }
    
    public func didUpdateVisitedHistory(url: URL?) {
        forwardButton.isEnabled = webView?.canGoForward ?? false
        backButton.isEnabled = webView?.canGoBack ?? false
        guard let url = url else {
            return
        }
        searchBar.text = url.absoluteString
    }
    
    public func didFinishNavigation(url: URL?) {
        forwardButton.isEnabled = webView?.canGoForward ?? false
        backButton.isEnabled = webView?.canGoBack ?? false
        progressBar.setProgress(0.0, animated: false)
        guard let url = url else {
            return
        }
        searchBar.text = url.absoluteString
    }
    
    public func didFailNavigation(url: URL?, error: Error) {
        forwardButton.isEnabled = webView?.canGoForward ?? false
        backButton.isEnabled = webView?.canGoBack ?? false
        progressBar.setProgress(0.0, animated: false)
    }
    
    public func didChangeProgress(progress: Double) {
        progressBar.setProgress(Float(progress), animated: true)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text,
              let urlEncoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: urlEncoded) else {
            return
        }
        let request = URLRequest(url: url)
        webView?.load(request)
    }
    
    public func show(completion: (() -> Void)? = nil) {
        if let navController = navigationController as? InAppBrowserNavigationController, let window = navController.tmpWindow {
            isHidden = false
            window.alpha = 0.0
            window.isHidden = false
            window.makeKeyAndVisible()
            UIView.animate(withDuration: 0.2) {
                window.alpha = 1.0
                completion?()
            }
        }
    }

    public func hide(completion: (() -> Void)? = nil) {
        if let navController = navigationController as? InAppBrowserNavigationController, let window = navController.tmpWindow {
            isHidden = true
            window.alpha = 1.0
            UIView.animate(withDuration: 0.2) {
                window.alpha = 0.0
            } completion: { (finished) in
                if finished {
                    window.isHidden = true
                    if #available(iOS 13.0, *) {
                        if let keyWindow = UIApplication.shared.connectedScenes
                            .compactMap({ $0 as? UIWindowScene })
                            .flatMap({ $0.windows })
                            .first(where: { $0.isKeyWindow && $0 !== window }) {
                            keyWindow.makeKeyAndVisible()
                        } else {
                            UIApplication.shared.delegate?.window??.makeKeyAndVisible()
                        }
                    } else {
                        UIApplication.shared.delegate?.window??.makeKeyAndVisible()
                    }
                    completion?()
                }
            }
        }
    }
    var closeOption: [String: String] = [:]

    public func showCloseButton(closeButtonOptions: [String: String]) {
        closeOption = closeButtonOptions
        guard !closeButtonOptions.isEmpty else { return }

        floatBtn = floatBtn ?? FloatButton(controller: self)
        floatBtn?.createClose(closeButtonOptions as [AnyHashable: Any])
    }

    /// 更新关闭按钮位置（根据屏幕方向）
    public func updateCloseButtonPosition(isLandscape: Bool) {
        floatBtn?.updatePosition(isLandscape)
    }

    /// 更新 WebView 布局和小球位置（根据屏幕方向变化）
    public func updateWebViewLayout(isLandscape: Bool) {
        guard let webView = webView else { return }
        let isCutTopButtom = browserSettings?.isCutTopButtom ?? false

        // 只有 isCutTopButtom 为 true 时才需要更新布局
        if isCutTopButtom {
            // 获取状态栏高度
            let statusHeight: Double
            if #available(iOS 13.0, *), keywindows() != nil {
                statusHeight = Double(keywindows()!.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)
            } else {
                statusHeight = Double(UIApplication.shared.statusBarFrame.size.height)
            }

            // 移除旧的约束
            webView.removeConstraints(webView.constraints)
            // 移除 webView 相关的父视图约束
            for constraint in view.constraints {
                if constraint.firstItem as? UIView == webView || constraint.secondItem as? UIView == webView {
                    view.removeConstraint(constraint)
                }
            }

            // 计算调整后的状态栏高度
            var adjustedStatusHeight: Double
            if isLandscape {
                adjustedStatusHeight = (statusHeight == 20 || statusHeight == 0) ? 0.0 : 30.0
            } else {
                adjustedStatusHeight = (statusHeight == 20) ? 0.0 : statusHeight
            }

            // 重新设置约束
            webView.translatesAutoresizingMaskIntoConstraints = false
            if isLandscape {
                // 横屏布局：左边留出 statusHeight
                NSLayoutConstraint.activate([
                    webView.topAnchor.constraint(equalTo: view.topAnchor),
                    webView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: adjustedStatusHeight),
                    webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
            } else {
                // 竖屏布局：顶部留出 statusHeight，底部对齐
                NSLayoutConstraint.activate([
                    webView.topAnchor.constraint(equalTo: view.topAnchor, constant: adjustedStatusHeight),
                    webView.leftAnchor.constraint(equalTo: view.leftAnchor),
                    webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    webView.rightAnchor.constraint(equalTo: view.rightAnchor)
                ])
            }

            // 强制更新布局
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }

        // 更新小球位置
        floatBtn?.updatePosition(isLandscape)

        NSLog("[InAppBrowser] updateWebViewLayout: %@, isCut: %@", isLandscape ? "横屏" : "竖屏", isCutTopButtom ? "是" : "否")
    }

    @objc public func reload() {
        webView?.reload()
        didUpdateVisitedHistory(url: webView?.url)
    }
    
    @objc public func share() {
        let vc = UIActivityViewController(activityItems: [webView?.url?.absoluteString ?? ""], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    public func close(completion: (() -> Void)? = nil) {
        guard let navController = navigationController else {
            // navigationController 已经为 nil，直接调用 completion
            completion?()
            return
        }

        if navController.presentingViewController != nil {
            navController.presentingViewController?.dismiss(animated: false, completion: {() -> Void in
                completion?()
            })
        }
        else {
            navController.parent?.dismiss(animated: true, completion: {() -> Void in
                completion?()
            })
        }
    }

    // @objc public func close() {
    //     guard let navController = navigationController else {
    //         // navigationController 已经为 nil，无需处理
    //         return
    //     }

    //     if navController.presentingViewController != nil {
    //         navController.presentingViewController?.dismiss(animated: false, completion: nil)
    //     }
    //     else {
    //         navController.parent?.dismiss(animated: true, completion: nil)
    //     }     
    // }
    @objc public func close() {
        // 取得導覽控制器與它持有的臨時視窗
        guard let navController = navigationController as? InAppBrowserNavigationController else {
            self.dismiss(animated: true, completion: nil)
            return
        }

        // 執行 Dismiss 關閉視圖控制器
        // 使用 presentingViewController?.dismiss 是最穩定的做法
        let presenter = navController.presentingViewController ?? navController.parent
        
        presenter?.dismiss(animated: true) { [weak navController] in
            // 當動畫完成後，徹底清理 tmpWindow
            if let window = navController?.tmpWindow {
                // 隱藏視窗並解除根控制器
                window.isHidden = true
                window.rootViewController = nil
                
                // 強制將控制權還給原本的主視窗 (Flutter 視窗)
                if #available(iOS 13.0, *) {
                    UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .flatMap { $0.windows }
                        .first { !$0.isHidden && $0 != window }?
                        .makeKeyAndVisible()
                } else {
                    UIApplication.shared.delegate?.window??.makeKeyAndVisible()
                }
                
                // 斷開引用，釋放記憶體
                navController?.tmpWindow = nil
                print("🚀 DEBUG: tmpWindow has been destroyed and KeyWindow restored.")
            }
        }
    }
 
    @objc public func goBack() {
        if let webView = webView, webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc public func goForward() {
        if let webView = webView, webView.canGoForward {
            webView.goForward()
        }
    }
    
    @objc public func goBackOrForward(steps: Int) {
        webView?.goBackOrForward(steps: steps)
    }

    public func setSettings(newSettings: InAppBrowserSettings, newSettingsMap: [String: Any]) {
        let newInAppWebViewSettings = InAppWebViewSettings()
        let _ = newInAppWebViewSettings.parse(settings: newSettingsMap)
        webView?.setSettings(newSettings: newInAppWebViewSettings, newSettingsMap: newSettingsMap)
        
        if newSettingsMap["hidden"] != nil, browserSettings?.hidden != newSettings.hidden {
            if newSettings.hidden {
                hide()
            }
            else {
                show()
            }
        }

        if newSettingsMap["hideUrlBar"] != nil, browserSettings?.hideUrlBar != newSettings.hideUrlBar {
            searchBar.isHidden = newSettings.hideUrlBar
        }

        if newSettingsMap["hideToolbarTop"] != nil, browserSettings?.hideToolbarTop != newSettings.hideToolbarTop {
            navigationController?.navigationBar.isHidden = newSettings.hideToolbarTop
        }

        if newSettingsMap["toolbarTopBackgroundColor"] != nil, browserSettings?.toolbarTopBackgroundColor != newSettings.toolbarTopBackgroundColor {
            if let bgColor = newSettings.toolbarTopBackgroundColor, !bgColor.isEmpty {
                navigationController?.navigationBar.backgroundColor = UIColor(hexString: bgColor)
            } else {
                navigationController?.navigationBar.backgroundColor = nil
            }
        }
        
        if newSettingsMap["toolbarTopBarTintColor"] != nil, browserSettings?.toolbarTopBarTintColor != newSettings.toolbarTopBarTintColor {
            if let barTintColor = newSettings.toolbarTopBarTintColor, !barTintColor.isEmpty {
                navigationController?.navigationBar.barTintColor = UIColor(hexString: barTintColor)
            } else {
                navigationController?.navigationBar.barTintColor = nil
            }
        }
        
        if newSettingsMap["toolbarTopTintColor"] != nil, browserSettings?.toolbarTopTintColor != newSettings.toolbarTopTintColor {
            if let tintColor = newSettings.toolbarTopTintColor, !tintColor.isEmpty {
                navigationController?.navigationBar.tintColor = UIColor(hexString: tintColor)
            } else {
                navigationController?.navigationBar.tintColor = nil
            }
        }

        if newSettingsMap["hideToolbarBottom"] != nil, browserSettings?.hideToolbarBottom != newSettings.hideToolbarBottom {
            navigationController?.isToolbarHidden = !newSettings.hideToolbarBottom
        }

        if newSettingsMap["toolbarBottomBackgroundColor"] != nil, browserSettings?.toolbarBottomBackgroundColor != newSettings.toolbarBottomBackgroundColor {
            if let bgColor = newSettings.toolbarBottomBackgroundColor, !bgColor.isEmpty {
                navigationController?.toolbar.barTintColor = UIColor(hexString: bgColor)
            } else {
                navigationController?.toolbar.barTintColor = nil
            }
        }
        
        if newSettingsMap["toolbarBottomTintColor"] != nil, browserSettings?.toolbarBottomTintColor != newSettings.toolbarBottomTintColor {
            if let tintColor = newSettings.toolbarBottomTintColor, !tintColor.isEmpty {
                navigationController?.toolbar.tintColor = UIColor(hexString: tintColor)
            } else {
                navigationController?.toolbar.tintColor = nil
            }
        }

        if newSettingsMap["toolbarTopTranslucent"] != nil, browserSettings?.toolbarTopTranslucent != newSettings.toolbarTopTranslucent {
            navigationController?.navigationBar.isTranslucent = newSettings.toolbarTopTranslucent
        }
        
        if newSettingsMap["toolbarBottomTranslucent"] != nil, browserSettings?.toolbarBottomTranslucent != newSettings.toolbarBottomTranslucent {
            navigationController?.toolbar.isTranslucent = newSettings.toolbarBottomTranslucent
        }

        if newSettingsMap["closeButtonCaption"] != nil, browserSettings?.closeButtonCaption != newSettings.closeButtonCaption {
            if let closeButtonCaption = newSettings.closeButtonCaption, !closeButtonCaption.isEmpty {
                if let oldTitle = closeButton.title, !oldTitle.isEmpty {
                    closeButton.title = closeButtonCaption
                } else {
                    closeButton.target = nil
                    closeButton.action = nil
                    closeButton = UIBarButtonItem(title: closeButtonCaption, style: .plain, target: self, action: #selector(close))
                }
            } else {
                setDefaultCloseButton()
            }
        }

        if newSettingsMap["closeButtonColor"] != nil, browserSettings?.closeButtonColor != newSettings.closeButtonColor {
            if let tintColor = newSettings.closeButtonColor, !tintColor.isEmpty {
                closeButton.tintColor = UIColor(hexString: tintColor)
            } else {
                closeButton.tintColor = nil
            }
        }
        
        if newSettingsMap["hideCloseButton"] != nil, browserSettings?.hideCloseButton != newSettings.hideCloseButton {
            if !newSettings.hideCloseButton {
                navigationItem.rightBarButtonItems = [closeButton]
            } else {
                navigationItem.rightBarButtonItems = []
            }
        }
        
        if newSettingsMap["presentationStyle"] != nil, browserSettings?.presentationStyle != newSettings.presentationStyle {
            navigationController?.modalPresentationStyle = UIModalPresentationStyle(rawValue: newSettings.presentationStyle)!
        }
        
        if newSettingsMap["transitionStyle"] != nil, browserSettings?.transitionStyle != newSettings.transitionStyle {
            navigationController?.modalTransitionStyle = UIModalTransitionStyle(rawValue: newSettings.transitionStyle)!
        }
        
        if newSettingsMap["hideProgressBar"] != nil, browserSettings?.hideProgressBar != newSettings.hideProgressBar {
            progressBar.isHidden = newSettings.hideProgressBar
        }
        
        if newSettingsMap["menuButtonColor"] != nil, browserSettings?.menuButtonColor != newSettings.menuButtonColor {
            if let tintColor = newSettings.menuButtonColor, !tintColor.isEmpty {
                menuButton?.tintColor = UIColor(hexString: tintColor)
            } else {
                menuButton?.tintColor = nil
            }
        }
        
        browserSettings = newSettings
        webViewSettings = newInAppWebViewSettings
    }
    
    public func getSettings() -> [String: Any?]? {
        let webViewSettingsMap = webView?.getSettings()
        if (self.browserSettings == nil || webViewSettingsMap == nil) {
            return nil
        }
        var settingsMap = self.browserSettings!.getRealSettings(obj: self)
        settingsMap.merge(webViewSettingsMap!, uniquingKeysWith: { (current, _) in current })
        return settingsMap
    }
    
    public func dispose() {
        channelDelegate?.onExit()
        channelDelegate?.dispose()
        channelDelegate = nil
        webView?.dispose()
        webView?.removeFromSuperview()
        webView = nil
        view = nil
        if previousStatusBarStyle != -1, let statusBarStyle = UIStatusBarStyle(rawValue: previousStatusBarStyle) {
            UIApplication.shared.statusBarStyle = statusBarStyle
        }
        transitioningDelegate = nil
        searchBar?.delegate = nil
        closeButton?.target = nil
        forwardButton?.target = nil
        backButton?.target = nil
        reloadButton?.target = nil
        shareButton?.target = nil
        menuButton?.target = nil
        plugin = nil
    }
    
    deinit {
        debugPrint("InAppBrowserWebViewController - dealloc")
        dispose()
    }
}
