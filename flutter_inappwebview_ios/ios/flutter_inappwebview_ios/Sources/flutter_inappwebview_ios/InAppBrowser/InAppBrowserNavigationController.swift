//
//  InAppBrowserNavigationController.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 14/02/21.
//

import UIKit
import Foundation

public class InAppBrowserNavigationController: UINavigationController {
    var tmpWindow: UIWindow?
    var tempshouldAutorotate:Bool?
    var tempOrienta:UIInterfaceOrientationMask?

    deinit {
        debugPrint("InAppBrowserNavigationController - dealloc")
        tmpWindow?.windowLevel = UIWindow.Level(rawValue: 0.0)
        tmpWindow = nil
        if #available(iOS 13.0, *) {
            if let keyWindow = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) {
                keyWindow.makeKeyAndVisible()
            } else {
                UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            }
        } else {
            UIApplication.shared.delegate?.window??.makeKeyAndVisible()
        }
    }
    
   #if swift(>=4.2)



    override public var shouldAutorotate: Bool{
//        return faceOrientation == UIInterfaceOrientationMask.all
        return tempshouldAutorotate!
    }




    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return tempOrienta!
    }


    #else

    override func shouldAutorotate() -> Bool {
        return tempshouldAutorotate!
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return tempOrienta!
    }

    #endif
}
