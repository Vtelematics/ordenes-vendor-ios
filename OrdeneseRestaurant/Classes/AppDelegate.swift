//
//  AppDelegate.swift
//  Foodesoft Vendor
//
//  Created by Apple on 22/11/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import CoreData
import OneSignal
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import FirebaseCore

var languageArr = NSArray()
var languageID:String = "1"
var languageCode:String = "en"
var userIDStr:String = ""
var storeIDStr : String = ""
var orderStatusArr = NSMutableArray()
var themeColor = UIColor()
var positiveBtnColor = UIColor()
var isUpdateTheApp = true
var pushOrderID = ""
var apiKey = "AIzaSyDrb4lQdX93xFN8emW6q1fdglaDSqTAzSI"
var isRTLenabled = false
enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        themeColor = UIColor(red: 186/255, green: 1/255, blue: 0/255, alpha: 1)
        positiveBtnColor = UIColor(red: 186/255, green: 1/255, blue: 0/255, alpha: 1)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarTintColor = themeColor
        GMSServices.provideAPIKey(apiKey)
        GMSPlacesClient.provideAPIKey(apiKey)
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = themeColor
            appearance.titleTextAttributes = [.font:
            UIFont.boldSystemFont(ofSize: 20.0),
                                          .foregroundColor: UIColor.white]
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().barTintColor = themeColor
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
            UINavigationBar.appearance().tintColor = UIColor.white
            UINavigationBar.appearance().isTranslucent = false
            if let statusbar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                statusbar.backgroundColor = themeColor
            }
        }
        
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0.0
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let storeKey = UserDefaults.standard.value(forKey: "SECRET_KEY"), "\(storeKey)" != "" {
            let viewController = storyboard.instantiateViewController(withIdentifier: "HomeVc")
            let navigationController = UINavigationController.init(rootViewController: viewController)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
            //return true
        }
        else
        {
            let viewController = storyboard.instantiateViewController(withIdentifier: "LoginVc")
            let navigationController = UINavigationController.init(rootViewController: viewController)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
            //return true
        }
        FirebaseApp.configure()
        // Onesignal
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: true]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "bc344476-b51e-4e0c-9b8f-a8291c0f76d5",
                                        handleNotificationReceived: { notification in
                                        
        },
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        if let id = status.subscriptionStatus.userId {
            print("\nOneSignal UserId:", id)
        }
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
//        if let id = UserDefaults.standard.string(forKey: "language_id")
//        {
//            if id != ""
//            {
//                languageID = id
//                languageCode = UserDefaults.standard.object(forKey: "language_code") as! String
//            }
//            else
//            {
//                languageID = "1"
//                languageCode = "en"
//            }
//        }
//        else
//        {
//            languageID = "1"
//            languageCode = "en"
//        }
        
        isRTLenabled = false
        languageID = "1"
        languageCode = "en"
        
        UserDefaults.standard.set(languageID, forKey: "language_id")
        UserDefaults.standard.set(languageCode, forKey: "language_code")
        let selectedLanguage:Languages = Int(languageID) == 1 ? .en : .ar

        // change the language
        if #available(iOS 9.0, *)
        {
            LanguageManger.shared.setLanguage(language: selectedLanguage)
        }
        else
        {
            // Fallback on earlier versions
        }
        UserDefaults.standard.set(languageID, forKey: "language_id")
        UserDefaults.standard.set(languageCode, forKey: "language_code")
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData)
        if application.applicationState == UIApplication.State.active {
            print("UIApplication.State.active")
        }else {
            if let value = userInfo["custom"] {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let storeKey = UserDefaults.standard.value(forKey: "SECRET_KEY"), "\(storeKey)" != "" {
                    let detailDic = value as! NSDictionary
                    if let orderIdDic = detailDic["a"] as? NSDictionary{
                        let orderStatusId = "\(orderIdDic["order_status_id"]!)"
                        if orderStatusId == "1" {
                            let viewController = storyboard.instantiateViewController(withIdentifier: "HomeVc")
                            let navigationController = UINavigationController.init(rootViewController: viewController)
                            self.window?.rootViewController = navigationController
                            self.window?.makeKeyAndVisible()
                        }
                    }
                }else{
                    let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
                    let navigationController = UINavigationController.init(rootViewController: viewController)
                    self.window?.rootViewController = navigationController
                    self.window?.makeKeyAndVisible()
                }
            }else {
                print("other notification / message")
            }
        }
    }
}

