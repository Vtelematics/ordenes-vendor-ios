//
//  SharedManager.swift
//  IraqiMart
//
//  Created by Adyas on 29/11/16.
//  Copyright © 2016 IraqiMart. All rights reserved.
//

import UIKit
import MBProgressHUD
//import ReachabilitySwift

class SharedManager: NSObject {
    
   class func showHUD(viewController: UIViewController)
    {
        let hud = MBProgressHUD.showAdded(to: viewController.view, animated: true)
        hud.label.text = NSLocalizedString("Loading", comment: "")
        hud.contentColor = themeColor
    }
    
   class func dismissHUD(viewController: UIViewController)
    {
        MBProgressHUD.hide(for: viewController.view, animated: true)
    }
    
    class func checkForInternetConnection() -> Bool
    {
       // let reachabilityObj = Reachability()
        //let status = reachabilityObj?.currentReachabilityStatus
        
      //  if (reachabilityObj?.isReachable)!
      //  {
      //      return false
      //  }
      //  else
      //  {
            return true
      //  }
    }
    
    class func showErrorConnectionViewController()
    {
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "NoConnectionVC") as! ErrorVC
//        let navController = UINavigationController.init(rootViewController: viewController)
//        self.present(navController, animated: true, completion: nil)
    }
    
    
    class func showAlertWithMessage(title: String, alertMessage: String, viewController: UIViewController)
    {
        let alert = UIAlertController(title: title, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
        
    }
    
    struct ScreenSize
    {
        static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
        static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
        static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    }
    
    struct DeviceType
    {
        static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
        static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
        static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
        static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    }
}
