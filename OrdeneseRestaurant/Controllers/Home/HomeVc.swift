//
//  HomeVc.swift
//  eGroceryStore
//
//  Created by Adyas Infotech on 23/11/18.
//  Copyright © 2018 Adyas Infotech. All rights reserved.
//

import UIKit
import Alamofire
import LCSlideMenu
import LabelSwitch
import Firebase
import OneSignal
import SwiftUI

struct Order {
    var orderId:String!
    var name:String!
    var orderDate:String!
    var orderTime:String!
    var total:String!
    var status:String!
    var deliveryType:String!
    var orderType:String!
    var scheduleDate:String!
    var scheduleStatus:String!
    var scheduleTime:String!
    var orderStatusId:Int!
    
    init(orderDetails:[String:AnyObject]) {
        if let id = orderDetails["order_id"] { self.orderId = id as? String } else {self.orderId = ""}
        if let name = orderDetails["name"] { self.name = name as? String } else {self.name = ""}
        if let orderDate = orderDetails["order_date"] { self.orderDate = orderDate as? String }else {self.orderDate = ""}
        if let orderTime = orderDetails["order_time"] { self.orderTime = orderTime as? String }else {self.orderTime = ""}
        if let total = orderDetails["total"] { self.total = total as? String }else {self.total = ""}
        if let status = orderDetails["status"] { self.status = status as? String }else {self.status = ""}
        if let deliveryType = orderDetails["delivery_type"] { self.deliveryType = deliveryType as? String }else {self.deliveryType = ""}
        if let orderStatusId = orderDetails["order_status_id"] { self.orderStatusId = orderStatusId as? Int }else {self.orderStatusId = 0}
        if let orderType = orderDetails["order_type"] { self.orderType = orderType as? String }else {self.orderType = ""}
        if let orderType = orderDetails["schedule_date"] { self.scheduleDate = orderType as? String }else {self.scheduleDate = ""}
        if let orderType = orderDetails["schedule_time"] { self.scheduleTime = orderType as? String }else {self.scheduleTime = ""}
        if let orderType = orderDetails["schedule_status"] { self.scheduleStatus = orderType as? String }else {self.scheduleStatus = ""}
    }
}

class HomeVc: UIViewController{
    @IBOutlet weak var tblOrderList: UITableView!
    @IBOutlet weak var viewLanguage: UIView!
    @IBOutlet weak var tblLanguage: UITableView!
    @IBOutlet weak var btnCancelLanugae: UIButton!
    @IBOutlet weak var btnChangeLanguage: UIButton!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var viewChangePass: UIView!
    @IBOutlet weak var viewBlur: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var imgNoOrder: UIView!
    @IBOutlet weak var lblNoOrder: UIView!
    @IBOutlet weak var btnSwitch: LabelSwitch!
    var tblSidemenu = UITableView()
    var menuArrProduct = [NSLocalizedString("Home", comment: ""), NSLocalizedString("Products", comment: ""), NSLocalizedString("Order Reports", comment: ""), NSLocalizedString("Change Password", comment: ""), NSLocalizedString("Logout", comment: "")]
    var selectedLanguage = ""
    var appStoreVersion = ""
    var ordersArray:[Order] = []
    private var navigationView: UIView {
        let bannerWidth = (self.navigationController?.navigationBar.frame.size.width ?? 0) * 0.5 // 0.5 its multiplier to get correct image width
        let bannerHeight = self.navigationController?.navigationBar.frame.size.height ?? 0
        let view = UIView()
        view.backgroundColor = .clear
        view.frame = CGRect(x: 0, y: 0, width: 170, height: bannerHeight)
        let image = UIImage(named: "ic_navigation")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(imageView)
        return view
    }
    
    private var menuIconView: UIView {
        let bannerHeight = self.navigationController?.navigationBar.frame.size.height ?? 0
        let view = UIView()
        view.backgroundColor = .clear
        view.frame = CGRect(x: 0, y: 0, width: 100, height: bannerHeight)
        let image = UIImage(named: "ico-menu")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 5, width: 30, height: 20)
        let label = UILabel(frame: CGRect(x: 0, y: 25, width: 100, height: 20))
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.text = "New orders"
        let button = UIButton()
        button.frame = view.frame
        button.addTarget(self, action: #selector(clickMenu(sender:)), for: .touchUpInside)
        view.addSubview(button)
        view.addSubview(imageView)
        view.addSubview(label)
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let id = UserDefaults.standard.string(forKey: "SECRET_KEY")
        {
            storeIDStr = id
        }
        
        self.tblOrderList.register(UINib(nibName: "OrderCell", bundle: nil), forCellReuseIdentifier: "OrderTblCell")
        NotificationCenter.default.addObserver(self, selector: #selector(self.addChangePasswordView(_:)), name: .changePassword, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.addChangeLanguageView(_:)), name: .changeLanguage, object: nil)
        self.setNavigationButtonHome()
        btnSwitch.delegate = self
        btnSwitch.circleShadow = false
        btnSwitch.fullSizeTapEnabled = true
        getTask()
        if UserDefaults.standard.value(forKey: "is_first") == nil{
            let alertController = UIAlertController (title: "", message: NSLocalizedString("Please change the notification banner style in Notification -> Banner style -> Persistent", comment: ""), preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        
                    })
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            UserDefaults.standard.set("false", forKey: "is_first")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tblSidemenu.dataSource = self
        tblSidemenu.delegate = self
        tblSidemenu.register(SideMenuTableViewCell.self, forCellReuseIdentifier: "userProfileCell")
        tblSidemenu.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tblSidemenu.separatorInset = .zero
        tblSidemenu.tableFooterView = UIView()
        tblSidemenu.register(UINib(nibName: "SideMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "userProfileCell")
        tblSidemenu.register(SideMenuTableViewCell.self, forCellReuseIdentifier: "sideMenuTitleCell")
        tblSidemenu.register(UITableViewCell.self, forCellReuseIdentifier: "cellTitle")
        tblSidemenu.separatorInset = .zero
        tblSidemenu.tableFooterView = UIView()
        tblSidemenu.register(UINib(nibName: "sideMenuSetting", bundle: nil), forCellReuseIdentifier: "sideMenuTitleCell")
        if isRTLenabled
        {
            self.tblSidemenu.frame = CGRect(x: UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width-100, height: self.menuView.frame.height)
        }
        else
        {
            self.tblSidemenu.frame = CGRect(x: -(UIScreen.main.bounds.size.width - 100), y: 0, width: UIScreen.main.bounds.size.width-100, height: self.menuView.frame.height)
        }
        tblSidemenu.register(UINib(nibName: "SideMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "userProfileCell")
        getBusyStatus()
    }
    
    //MARK: Functions
    func setNavigationButtonHome()
    {
        setupSwipeGestureRecognizer()
        let item = UIBarButtonItem(customView: menuIconView)
        self.navigationItem.setLeftBarButton(item, animated: false)
        navigationItem.titleView = navigationView
    }
    
    @objc func clickMenu(sender:UIBarButtonItem)
    {
        if (self.tblSidemenu.isDescendant(of: menuView))
        {
            self.closeMenu()
        }else{
            menuView.addSubview(self.tblSidemenu)
            self.tblSidemenu.reloadData()
            
            if isRTLenabled
            {
                UIView.animate(withDuration: 0.50, animations: {
                    self.tblSidemenu.frame = CGRect(x: UIScreen.main.bounds.size.width - (UIScreen.main.bounds.size.width-100) , y: 0, width: UIScreen.main.bounds.size.width-100, height: self.menuView.frame.height)
                })
            }
            else
            {
                UIView.animate(withDuration: 0.50, animations: {
                    self.tblSidemenu.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-100, height: self.menuView.frame.height)
                })
            }
            self.menuView.isHidden = false
        }
    }
    
    @objc func closeMenu()
    {
        UIView.animate(withDuration: 0.50, animations: { () -> Void in
            if isRTLenabled
            {
                self.tblSidemenu.frame = CGRect(x: UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width-120, height: self.menuView.frame.height)
            }else{
                self.tblSidemenu.frame = CGRect(x: -(UIScreen.main.bounds.size.width-120), y: 0, width: UIScreen.main.bounds.size.width-120, height: self.menuView.frame.height)
            }
        }, completion: { (bol) -> Void in
            self.tblSidemenu.removeFromSuperview()
            self.menuView.isHidden = true
        })
    }
    
    func setupSwipeGestureRecognizer()
    {
        //For left swipe
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedScreen))
        swipeGestureLeft.direction = .left
        self.view.addGestureRecognizer(swipeGestureLeft)
        
        //For right swipe
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedScreen))
        swipeGestureRight.direction = .right
        self.view.addGestureRecognizer(swipeGestureRight)
        
    }
    
    @objc func swipedScreen(gesture: UISwipeGestureRecognizer)
    {
        if isRTLenabled == false
        {
            if gesture.direction == .left
            {
                self.closeMenu()
            }
            else if gesture.direction == .right
            {
                menuView.addSubview(self.tblSidemenu)
                self.tblSidemenu.reloadData()
                UIView.animate(withDuration: 0.50, animations: {
                    self.tblSidemenu.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-100, height: self.menuView.frame.height)
                })
                self.menuView.isHidden = false
            }
        }
        else
        {
            if gesture.direction == .right
            {
                self.closeMenu()
            }
            else if gesture.direction == .left
            {
                menuView.addSubview(self.tblSidemenu)
                self.tblSidemenu.reloadData()
                
                UIView.animate(withDuration: 0.50, animations: {
                    self.tblSidemenu.frame = CGRect(x: UIScreen.main.bounds.size.width - (UIScreen.main.bounds.size.width-120) , y: 0, width: UIScreen.main.bounds.size.width-120, height: self.menuView.frame.height)
                })
                self.menuView.isHidden = false
            }
        }
    }
    
    func isUpdateAvailable() throws -> Bool {
        guard let info = Bundle.main.infoDictionary,
              let currentVersion = info["CFBundleShortVersionString"] as? String,
              let identifier = info["CFBundleIdentifier"] as? String,
              let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
            throw VersionError.invalidBundleInfo
        }
        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
            throw VersionError.invalidResponse
        }
        if let result = (json["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String {
            appStoreVersion = version
            return version != currentVersion
        }
        throw VersionError.invalidResponse
    }
    
    func popupUpdateDialogue(){
        
        let alertMessage = NSLocalizedString("A new version of Ordenese Restaurant Application is available,Please update to version ", comment: "")+appStoreVersion;
        let alert = UIAlertController(title: NSLocalizedString("New Version Available", comment: ""), message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        
        let okBtn = UIAlertAction(title: NSLocalizedString("Update", comment: ""), style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let url = URL(string: "itms-apps://itunes.apple.com/us/app/id1518236067"),
               UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        })
        let noBtn = UIAlertAction(title: NSLocalizedString("Skip this Version", comment: "") , style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
        })
        alert.addAction(okBtn)
        alert.addAction(noBtn)
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateBusyStatus(status : String)
    {
        let params = [
            "status" : status
            
        ] as [String : Any]
        print(params)
        let urlStr = "\(ConfigUrl.baseUrl)busy-status"
        print(storeIDStr)
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
        
        let setTemp: [String : Any] = params
        
        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
            let jsonString = String(data: jsonData , encoding: .utf8)!
            print(jsonString)
            request.httpBody = jsonData
        }
        
        if Connectivity.isConnectedToInternet()
        {
            SharedManager.showHUD(viewController: self)
            Alamofire.request(request).responseJSON
            { (responseObject) -> Void in
                if responseObject.result.isSuccess
                {
                    SharedManager.dismissHUD(viewController: self)
                    let result = responseObject.result.value! as AnyObject
                    print(result)
                    if let status = (responseObject.result.value! as AnyObject).value(forKeyPath: "success.status")
                    {
                        if "\(status)" == "200" {
                            SharedManager.showAlertWithMessage(title: "Information", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "success.message") as! String, viewController: self)
                        }
                        else
                        {
                            SharedManager.showAlertWithMessage(title: "Sorry", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "success.message") as! String, viewController: self)
                        }
                    }
                    else
                    {
                        SharedManager.showAlertWithMessage(title: "Sorry", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "error.message") as! String, viewController: self)
                    }
                }
                if responseObject.result.isFailure
                {
                    SharedManager.dismissHUD(viewController: self)
                    let error : Error = responseObject.result.error!
                    print(error.localizedDescription)
                    if "\(error.localizedDescription))" == "The Internet connection appears to be offline"
                    {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                        as! ErrorViewController
                        self.present(viewController, animated: true, completion: { () -> Void in
                        })
                    }
                }
            }
        }
        else
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
            as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    func getBusyStatus()
    {
        let urlStr = "\(ConfigUrl.baseUrl)busy"
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
        if Connectivity.isConnectedToInternet()
        {
            Alamofire.request(request).responseJSON
            { (responseObject) -> Void in
                if responseObject.result.isSuccess
                {
                    let result = responseObject.result.value! as AnyObject
                    print(result)
                    if let status = (responseObject.result.value! as AnyObject).value(forKeyPath: "success.status")
                    {
                        if "\(status)" == "200" {
                            
                            let busyStatus = "\(result.value(forKey: "busy_status")!)"
                            
                            if busyStatus == "1" {
                                //self.switchView.isOn = true
                                print("UISwitch state is now busy")
                                self.btnSwitch.curState = .R
                            }else{
//                                self.switchView.isOn = false
//                                self.switchView.subviews[0].subviews[0].backgroundColor = UIColor.lightGray
                                print("UISwitch state is now open")
                                self.btnSwitch.curState = .L
                            }
                        }
                        else
                        {
                            SharedManager.showAlertWithMessage(title: "Sorry", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "success.message") as! String, viewController: self)
                        }
                    }
                    else
                    {
                        SharedManager.showAlertWithMessage(title: "Sorry", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "error.message") as! String, viewController: self)
                    }
                }
                if responseObject.result.isFailure
                {
                    let error : Error = responseObject.result.error!
                    print(error.localizedDescription)
                    if "\(error.localizedDescription))" == "The Internet connection appears to be offline"
                    {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                        as! ErrorViewController
                        self.present(viewController, animated: true, completion: { () -> Void in
                        })
                    }
                }
            }
        }
        else
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
            as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    func getLanguage(){
        let reachability = Reachability()
        if (reachability?.connection)! != .none
        {
            SharedManager.showHUD(viewController: self)
            let urlStr = "\(ConfigUrl.baseUrl)delivery/local/language"
            
            let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
            var request = URLRequest(url: URL(string: setFinalURl)!)
            request.httpMethod = HTTPMethod.get.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            Alamofire.request(request).responseJSON
            { (responseObject) -> Void in
                
                if responseObject.result.isSuccess
                {
                    print(responseObject.result.value!)
                    
                    if "\(String(describing: responseObject.response!.statusCode))" == "200"
                    {
                        let result = responseObject.result.value! as AnyObject
                        languageArr = result.value(forKey: "languages") as! NSArray
                        self.viewLanguage.frame = CGRect(x: ((self.view.bounds.size.width/2) - self.viewLanguage.frame.size.width/2), y: ((self.view.bounds.size.height/2) - self.viewLanguage.frame.size.height/2), width: self.viewLanguage.frame.size.width, height: self.viewLanguage.frame.size.height)
                        self.tblLanguage.reloadData()
                        self.tblLanguage.frame.size.height = CGFloat(languageArr.count * 45)
                        self.tblLanguage.translatesAutoresizingMaskIntoConstraints = true
                        self.btnCancelLanugae.frame.origin.y = self.tblLanguage.frame.origin.y + self.tblLanguage.frame.size.height + 8
                        self.btnChangeLanguage.frame.origin.y = self.tblLanguage.frame.origin.y + self.tblLanguage.frame.size.height + 8
                        self.btnChangeLanguage.translatesAutoresizingMaskIntoConstraints = true
                        self.btnCancelLanugae.translatesAutoresizingMaskIntoConstraints = true
                        self.viewLanguage.frame.size.height = self.btnChangeLanguage.frame.origin.y + self.btnChangeLanguage.frame.size.height + 8
                        self.viewLanguage.translatesAutoresizingMaskIntoConstraints = true
                        self.view.addSubview(self.viewLanguage)
                        self.viewBlur.isHidden = false
                        self.selectedLanguage = languageID
                        self.tblLanguage.reloadData()
                        SharedManager.dismissHUD(viewController: self)
                    }
                    else
                    {
                        SharedManager.dismissHUD(viewController: self)
                        SharedManager.showAlertWithMessage(title: "", alertMessage: ((responseObject.result.value) as AnyObject).value(forKeyPath: "error.message") as! String, viewController: self)
                    }
                }
                if responseObject.result.isFailure
                {
                    SharedManager.dismissHUD(viewController: self)
                    let error : Error = responseObject.result.error!
                    print(error.localizedDescription)
                    if "\(error.localizedDescription))" == "The Internet connection appears to be offline"
                    {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                        as! ErrorViewController
                        self.present(viewController, animated: true, completion: { () -> Void in
                        })
                    }
                }
            }
        }
        else
        {
            SharedManager.dismissHUD(viewController: self)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
            as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    func getTask(){
        SharedManager.showHUD(viewController: self)
        self.tblOrderList.delegate = self
        self.tblOrderList.dataSource = self
        var ref: DatabaseReference!
        ref = Database.database().reference()
        if let restaurantId = UserDefaults.standard.string(forKey: "STORE_ID"), restaurantId != "" {
            
            ref.child("new_order").child(restaurantId).observe(.childAdded, with: {(snapshot) in
                let result = snapshot.value as? [String: AnyObject]
                let order = Order.init(orderDetails: result ?? [:])
                if order.orderStatusId == 1{
                    self.ordersArray.append(order)
                }
                self.tblOrderList.reloadData()
                if self.ordersArray.count != 0{
                    self.imgNoOrder.isHidden = true
                    self.lblNoOrder.isHidden = true
                }else{
                    self.imgNoOrder.isHidden = false
                    self.lblNoOrder.isHidden = false
                }
            })
            ref.child("new_order").child(restaurantId).observe(.childChanged, with: {(snapshot) in
                let result = snapshot.value as? [String: AnyObject]
                let keyVal = snapshot.key as String
                var tempArr = [[String: AnyObject]]()
                tempArr.append(result ?? [:])
                for i in 0..<self.ordersArray.count{
                    let orderId = (self.ordersArray[i].orderId)
                    if keyVal == orderId{
                        self.ordersArray.remove(at: i)
                    }
                }
                let order = Order.init(orderDetails: result ?? [:])
                if order.orderStatusId == 1{
                    self.ordersArray.append(order)
                }
                self.tblOrderList.reloadData()
                if self.ordersArray.count != 0{
                    self.imgNoOrder.isHidden = true
                    self.lblNoOrder.isHidden = true
                }else{
                    self.imgNoOrder.isHidden = false
                    self.lblNoOrder.isHidden = false
                }
            })
            
            ref.child("new_order").child(restaurantId).observe(.childRemoved, with: {(snapshot) in
                let keyVal = snapshot.key as String
                for i in 0..<self.ordersArray.count{
                    let orderId = self.ordersArray[i].orderId
                    if keyVal == orderId{
                        self.ordersArray.remove(at: i)
                        break
                    }
                }
                self.tblOrderList.reloadData()
                if self.ordersArray.count != 0{
                    self.imgNoOrder.isHidden = true
                    self.lblNoOrder.isHidden = true
                }else{
                    self.imgNoOrder.isHidden = false
                    self.lblNoOrder.isHidden = false
                }
            })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.ordersArray.count != 0{
                self.imgNoOrder.isHidden = true
                self.lblNoOrder.isHidden = true
            }else{
                self.imgNoOrder.isHidden = false
                self.lblNoOrder.isHidden = false
            }
        }
        SharedManager.dismissHUD(viewController: self)
    }
    
    func callLogout()
    {
        self.view.endEditing(true)
        var deviceIDStr = ""
        if let userId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId{
            deviceIDStr = userId
        }
        let params = [
            "push_id" : deviceIDStr,
            ] as [String : Any]
        let urlStr = "\(ConfigUrl.baseUrl)logout"
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
        
        let setTemp: [String : Any] = params as [String : Any]
        
        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
            let jsonString = String(data: jsonData , encoding: .utf8)!
            print(jsonString)
            request.httpBody = jsonData
        }
        
        if Connectivity.isConnectedToInternet()
        {
            SharedManager.showHUD(viewController: self)
            
            Alamofire.request(request).responseJSON { (responseObject) -> Void in
                
                if responseObject.result.isSuccess
                {
                    SharedManager.dismissHUD(viewController: self)
                    let result = responseObject.result.value! as AnyObject
                    
                    if "\(String(describing: responseObject.response!.statusCode))" == "200"
                    {
                        UserDefaults.standard.removeObject(forKey: "USER_DETAILS")
                        UserDefaults.standard.removeObject(forKey: "SECRET_KEY")
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "LoginVc") as! LoginVc
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                    else
                    {
                        SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: result.value(forKeyPath: "error.message") as! String, viewController: self)
                    }
                }
                if responseObject.result.isFailure
                {
                    SharedManager.dismissHUD(viewController: self)
                    let error : Error = responseObject.result.error!
                    print(error.localizedDescription)
                    if "\(error.localizedDescription))" == "The Internet connection appears to be offline"
                    {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                            as! ErrorViewController
                        self.present(viewController, animated: true, completion: { () -> Void in
                        })
                    }
                }
            }
        }
        else
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    //MARK: Button action
     @objc func editAccount(_ sender : UIButton)
     {
         let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
         let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ProfileVc") as! ProfileVc
         navigationController?.pushViewController(viewController, animated: true)
     }
     
    @objc func addChangePasswordView(_ notification: Notification)
    {
        self.viewChangePass.frame = CGRect(x: ((self.view.bounds.size.width/2) - self.viewChangePass.frame.size.width/2), y: ((self.view.bounds.size.height/2) - self.viewChangePass.frame.size.height/2), width: self.viewChangePass.frame.size.width, height: self.viewChangePass.frame.size.height)
        self.viewChangePass.translatesAutoresizingMaskIntoConstraints = true
        self.viewBlur.isHidden = false
        self.view.addSubview(self.viewChangePass)
    }
    
    @objc func addChangeLanguageView(_ notification: Notification)
    {
        self.getLanguage()
    }
    
    @IBAction func clickCancelMenu(_ sender: Any)
    {
        self.closeMenu()
    }
    
    @IBAction func clickCancelChangePass(_ sender: Any)
    {
        self.viewBlur.isHidden = true
        self.txtNewPassword.text = ""
        self.txtConfirmPassword.text = ""
        viewChangePass.removeFromSuperview()
    }
    
    @IBAction func clickDoneChangePass(_ sender: Any)
    {
        if !txtNewPassword.hasText
        {
            SharedManager.showAlertWithMessage(title: "Sorry!", alertMessage: "Please Enter New Password", viewController: self)
        }
        else if !txtConfirmPassword.hasText
        {
            SharedManager.showAlertWithMessage(title: "Sorry!", alertMessage: "Please Re-Enter your New Password", viewController: self)
        }
        else if txtNewPassword.text != txtConfirmPassword.text
        {
            SharedManager.showAlertWithMessage(title: "Sorry!", alertMessage: "Passwords does not matched", viewController: self)
        }
        else
        {
            self.view.endEditing(true)
            SharedManager.showHUD(viewController: self)
            
            let params = [
                "password" : self.txtNewPassword.text!,
                "confirm_password" : self.txtConfirmPassword.text!
            ] as [String : Any]
            
            let urlStr = "\(ConfigUrl.baseUrl)change-password"
            print(urlStr)
            let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
            var request = URLRequest(url: URL(string: setFinalURl)!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let setTemp: [String : Any] = params
            
            if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
                let jsonString = String(data: jsonData , encoding: .utf8)!
                print(jsonString)
                request.httpBody = jsonData
            }
            
            if Connectivity.isConnectedToInternet()
            {
                Alamofire.request(request).responseJSON { (responseObject) -> Void in
                    
                    if responseObject.result.isSuccess
                    {
                        SharedManager.dismissHUD(viewController: self)
                        let result = responseObject.result.value! as AnyObject
                        print(result)
                        if let status = (responseObject.result.value! as AnyObject).value(forKeyPath: "success.status")
                        {
                            if "\(status)" == "200" {
                                let alt: UIAlertController = UIAlertController(title: "Information", message: result.value(forKeyPath: "success.message") as? String, preferredStyle: UIAlertController.Style.alert)
                                alt.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                                    self.viewBlur.isHidden = true
                                    self.viewChangePass.removeFromSuperview()
                                }))
                                self.present(alt, animated: true, completion: nil)
                                
                                self.txtNewPassword.text = ""
                                self.txtConfirmPassword.text = ""
                                
                            }
                            else
                            {
                                SharedManager.showAlertWithMessage(title: "Sorry", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "success.message") as! String, viewController: self)
                            }
                        }
                        else
                        {
                            SharedManager.showAlertWithMessage(title: "Sorry", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "error.message") as! String, viewController: self)
                        }
                    }
                    if responseObject.result.isFailure
                    {
                        SharedManager.dismissHUD(viewController: self)
                        let error : Error = responseObject.result.error!
                        print(error.localizedDescription)
                        if "\(error.localizedDescription))" == "The Internet connection appears to be offline"
                        {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                            as! ErrorViewController
                            self.present(viewController, animated: true, completion: { () -> Void in
                            })
                        }
                    }
                }
            }
            else
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                as! ErrorViewController
                self.present(viewController, animated: true, completion: { () -> Void in
                })
            }
        }
    }
    
    @IBAction func clickCancelLang(_ sender: Any)
    {
        self.viewBlur.isHidden = true
        self.viewLanguage.removeFromSuperview()
    }
    
    @IBAction func clickSaveLang(_ sender: Any)
    {
        languageID = self.selectedLanguage
        if languageID == "1"{
            languageCode = "en"
            isRTLenabled = false
        }else{
            languageCode = "ar"
            isRTLenabled = true
        }
        UserDefaults.standard.set(languageID, forKey: "language_id")
        UserDefaults.standard.set(languageCode, forKey: "language_code")
        let selectedLanguage:Languages = Int(languageID) == 1 ? .en : .ar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
        // change the language
        if #available(iOS 9.0, *)
        {
            LanguageManger.shared.setLanguage(language: selectedLanguage)
        }
        else
        {
            // Fallback on earlier versions
        }
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "HomeVc") as! HomeVc
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController.init(rootViewController: viewController)
        appDelegate.window?.rootViewController = navigationController
        appDelegate.window?.makeKeyAndVisible()
    }
}

extension HomeVc: LabelSwitchDelegate {
    func switchChangToState(sender: LabelSwitch) {
        switch sender.curState {
        case .L: updateBusyStatus(status: "0")
        case .R: updateBusyStatus(status: "1")
        }
    }
}

extension HomeVc: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if tableView == tblOrderList
        {
            return nil
        }else if tableView == tblLanguage
        {
            return nil
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "userProfileCell") as! SideMenuTableViewCell
            
            cell.tag = 2000
            if UserDefaults.standard.object(forKey: "USER_DETAILS") != nil
            {
                let data = UserDefaults.standard.object(forKey: "USER_DETAILS") as! Data
                let userDic = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
                print(userDic)
                cell.lblUserName.text = "\(userDic.value(forKeyPath: "vendor_info.vendor_name")!)"
                cell.lbluserEmail.text = "\(userDic.value(forKeyPath: "vendor_info.email")!)"
                cell.lblUserMobile.text = "\(userDic.value(forKeyPath: "vendor_info.mobile")!)"                
                cell.selectionStyle = .none
                cell.btnEditAccount.addTarget(self, action: #selector(editAccount(_:)), for: .touchUpInside)
                
            }
            return cell as UIView
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == tblOrderList
        {
            return ordersArray.count
        }else if tableView == tblLanguage
        {
            return languageArr.count
        }else{
            return menuArrProduct.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == tblOrderList
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTblCell") as! OrderTblCell
            let type = "\(String(describing: (ordersArray[indexPath.row].orderType)!))"
            let orderTime = "\(String(describing: (ordersArray[indexPath.row].orderTime)!))"
            let orderDate = "\(String(describing: (ordersArray[indexPath.row].orderDate)!))"
            if isRTLenabled{
                cell.lblOrderId.text = "\(String(describing: (ordersArray[indexPath.row].orderId)!))" + NSLocalizedString("Order ID:", comment: "")
                cell.lblOrderDate.text = orderTime + " | " + orderDate
                cell.lblDeliveryType.textAlignment = .left
            }else{
                cell.lblOrderId.text = NSLocalizedString("Order ID:", comment: "") + "\(String(describing: (ordersArray[indexPath.row].orderId)!))"
                cell.lblOrderDate.text = orderDate + " | " + orderTime
                cell.lblDeliveryType.textAlignment = .right
            }
            cell.lblDeliveryType.text = type == "1" ? NSLocalizedString("Order type: Delivery", comment: "") : NSLocalizedString("Order type: Pickup", comment: "")
            cell.lblCustomerName.text = "\(String(describing: (ordersArray[indexPath.row].name)!))"
            cell.lblTotal.text = "\(String(describing: (ordersArray[indexPath.row].total)!))"
            cell.lblStatus.text = "\(String(describing: (ordersArray[indexPath.row].status)!))"
            cell.imgProductEdit.image = UIImage (named: "ic_edit")
            cell.imgProductEdit.image = cell.imgProductEdit.image!.withRenderingMode(.alwaysTemplate)
            cell.imgProductEdit.tintColor = UIColor.lightGray
            cell.viewShadow.layer.shadowColor = UIColor.gray.cgColor
            cell.viewShadow.layer.shadowOpacity = 0.5
            cell.viewShadow.layer.shadowOffset = CGSize.zero
            cell.viewShadow.layer.shadowRadius = 2
            if let scheduleStatus = ordersArray[indexPath.row].scheduleStatus, scheduleStatus == "1"{
                cell.lblScheduleDate.text = "\(String(describing: (ordersArray[indexPath.row].scheduleDate)!)) | \(String(describing: (ordersArray[indexPath.row].scheduleTime)!))"
                cell.lblScheduleDate.isHidden = false
                cell.lblSchedule.isHidden = false
                cell.lblScheduleColon.isHidden = false
            }else{
                cell.lblScheduleDate.isHidden = true
                cell.lblSchedule.isHidden = true
                cell.lblScheduleColon.isHidden = true
            }
            cell.btnViewDetails.addTarget(self, action: #selector(clickViewDetails(_ :)), for: .touchUpInside)
            cell.btnViewDetails.tag = indexPath.row
            return cell
        }else if tableView == tblLanguage
        {
            let cell:OrderTblCell = self.tblLanguage.dequeueReusableCell(withIdentifier: "languageCell") as! OrderTblCell
            cell.lblLanguage.text = "\((languageArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
            let id = "\((languageArr.object(at: indexPath.row) as AnyObject).value(forKey: "language_id")!)"
            if selectedLanguage == id{
                cell.imgLanguage.image = UIImage (named: "ic_radio_check")
            }else{
                cell.imgLanguage.image = UIImage (named: "ic_radio_uncheck")
            }
            return cell
        }
        else
        {
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as UITableViewCell
            cell.selectionStyle = .none
            cell.textLabel!.text = "\(menuArrProduct[indexPath.row])"
            let font = UIFont(name: "System", size: 16.0)
            cell.textLabel?.font = font
            cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            if isRTLenabled
            {
                cell.textLabel!.textAlignment = .right
            }
            else
            {
                cell.textLabel!.textAlignment = .left
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if tableView == tblSidemenu
        {
            if section == 0
            {
                return 93
            }
            else
            {
                return 0
            }
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == tblOrderList
        {
            if let scheduleStatus = ordersArray[indexPath.row].scheduleStatus, scheduleStatus == "1"{
                return 235
            }else{
                return 210
            }
        }else if tableView == tblLanguage
        {
            return 44
        }
        else
        {
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == tblOrderList
        {
            
        }else if tableView == tblLanguage
        {
            selectedLanguage = (languageArr.object(at: indexPath.row) as AnyObject).value(forKey: "language_id") as! String
            tblLanguage.reloadData()
        }
        else
        {
            if indexPath.row == 0
            {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "OrdersVc") as! OrdersVc
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if indexPath.row == 1
            {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ProductsVc") as! ProductsVc
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if indexPath.row == 2
            {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "OrdersReportVc") as! OrdersReportVc
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if indexPath.row == 3
            {
                NotificationCenter.default.post(name: .changePassword, object: nil)
                
                UIView.animate(withDuration: 0.50, animations: { () -> Void in
                    
                    self.tblSidemenu.frame = CGRect(x: -(UIScreen.main.bounds.size.width-120), y: 0, width: UIScreen.main.bounds.size.width-120, height: self.menuView.frame.height)
                }, completion: { (bol) -> Void in
                    self.menuView.isHidden = true
                    self.tblSidemenu.removeFromSuperview()
                })
            }else if indexPath.row == 4
            {
                callLogout()
                
            }
            self.closeMenu()
        }
    }
    
    @objc func clickViewDetails(_ sender: UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "OrderDetailsVc") as! OrderDetailsVc
        let orderID = "\(String(describing: (ordersArray[sender.tag].orderId)!))"
        viewController.orderId = orderID
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
