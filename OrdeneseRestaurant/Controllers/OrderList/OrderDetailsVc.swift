//
//  OrderDetailsVc.swift
//  Foodesoft Vendor
//
//  Created by Adyas Infotech on 03/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class OrderDetailsVc: UIViewController, UITableViewDelegate,UITableViewDataSource{

    //Mark: Order Details
    @IBOutlet weak var lblCustomerName: UILabel!
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblOrderDate: UILabel!
    @IBOutlet weak var lblOrderType: UILabel!
    @IBOutlet weak var lblPaymentType: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    
    @IBOutlet weak var viewOrderDetails: UIView!
    @IBOutlet weak var tblOrderDetails: UITableView!
    @IBOutlet weak var tblStatusManagement: UITableView!
    @IBOutlet weak var viewStatusManagement: UIView!
    @IBOutlet weak var btnSaveStatus: UIButton!
    @IBOutlet weak var btnCancelStatus: UIButton!
    @IBOutlet weak var vwOrderDetail1: UIView!
    @IBOutlet weak var viewAddHistoryBlur: UIView!
    @IBOutlet weak var vwOrderDetail2: UIView!
    @IBOutlet weak var vwOrderDetail3: UIView!
    @IBOutlet weak var lblSchedule: UILabel!
    @IBOutlet weak var lblScheduleColon: UILabel!
    @IBOutlet weak var lblScheduleDate: UILabel!
    
    var viewHeight : CGFloat = 255
    var timeArr = NSArray()
    var cancelReasonArr = NSArray()
    var orderDetailsDict = NSDictionary()
    var orderId = ""
    var productsArr = NSMutableArray()
    var totalArr = NSMutableArray()
    var historyArr = NSMutableArray()
    var isNotify = false
    var orderStatusId = ""
    var statusType = ""
    var orderStatusArr = NSArray()
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.auto),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
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
        let image = UIImage(named: "ic_back")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let label = UILabel(frame: CGRect(x: 0, y: 25, width: 100, height: 20))
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.text = "Order info"
        let button = UIButton()
        button.frame = view.frame
        button.addTarget(self, action: #selector(clickBack(_ :)), for: .touchUpInside)
        view.addSubview(button)
        view.addSubview(imageView)
        view.addSubview(label)
        return view
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Order Details", comment: "")
        vwOrderDetail1.layer.shadowColor = UIColor.gray.cgColor
        vwOrderDetail1.layer.shadowOpacity = 1
        vwOrderDetail1.layer.shadowOffset = CGSize.zero
        vwOrderDetail1.layer.shadowRadius = 3
        let item = UIBarButtonItem(customView: menuIconView)
        self.navigationItem.setLeftBarButton(item, animated: false)
        navigationItem.titleView = navigationView
        OrderDetails()
        self.viewAddHistoryBlur.isHidden = true
    }
    
    // MARK: API Methods
    func OrderDetails()
    {
        SharedManager.showHUD(viewController: self)
        let params = [
            "order_id" : orderId
        ] as [String : Any]
        let urlStr = "\(ConfigUrl.baseUrl)order-info"
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
        let setTemp: [String : Any] = params
        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
            let jsonString = String(data: jsonData , encoding: .utf8)!
            request.httpBody = jsonData
        }
        if Connectivity.isConnectedToInternet()
        {
            Alamofire.request(request).responseJSON
                { (responseObject) -> Void in
                    if responseObject.result.isSuccess
                    {
                        if "\(String(describing: responseObject.response!.statusCode))" == "200"
                        {
                            let result = (responseObject.result.value! as AnyObject) as! NSDictionary
                            self.orderDetailsDict = result as NSDictionary
                            print(self.orderDetailsDict)
                            self.productsArr = (self.orderDetailsDict.value(forKeyPath: "info.products") as! NSArray).mutableCopy() as! NSMutableArray
                            self.totalArr = (self.orderDetailsDict.value(forKeyPath: "info.totals") as! NSArray).mutableCopy() as! NSMutableArray
                            self.historyArr = (self.orderDetailsDict.value(forKeyPath: "info.histories") as! NSArray).mutableCopy() as! NSMutableArray
                            self.lblCustomerName.text = "\(String(describing: self.orderDetailsDict.value(forKeyPath: "info.firstname")!))  \(String(describing: self.orderDetailsDict.value(forKeyPath: "info.lastname")!))"
                            self.lblOrderId.text = "\(String(describing: self.orderDetailsDict.value(forKey: "order_id")!))"
                            self.lblStatus.text = "\(String(describing: self.orderDetailsDict.value(forKeyPath: "info.status")!))"
                            self.lblOrderDate.text = "\(String(describing: self.orderDetailsDict.value(forKeyPath: "info.date_added")!))"
                            self.lblPaymentType.text = "\(String(describing: self.orderDetailsDict.value(forKeyPath: "info.payment_method")!))"
                            let orderType = "\(String(describing: self.orderDetailsDict.value(forKeyPath: "info.order_type")!))"
                            self.lblOrderType.text = orderType == "1" ? NSLocalizedString("Delivery", comment: "") : NSLocalizedString("Pickup", comment: "")
                            self.lblComment.frame.size.width = self.lblOrderType.frame.size.width
                            
                            if let scheduleStatus = self.orderDetailsDict.value(forKeyPath: "info.schedule_status"), scheduleStatus as! String == "1"{
                                self.vwOrderDetail2.frame.size.height = self.lblScheduleDate.frame.origin.y + self.lblScheduleDate.frame.height + 8
                                self.lblScheduleDate.text = "\(self.orderDetailsDict.value(forKeyPath: "info.schedule_date")!) \(self.orderDetailsDict.value(forKeyPath: "info.schedule_time")!)"
                            }else{
                                self.vwOrderDetail2.frame.size.height = self.lblOrderType.frame.origin.y + self.lblOrderType.frame.height + 8
                            }
                            let htmlText = "\(String(describing: self.orderDetailsDict.value(forKeyPath: "info.comment")!))"
                            if htmlText == "" {
                                let Height = self.lblComment.frame.origin.y + self.lblComment.frame.size.height + 10
                                self.vwOrderDetail3.frame = CGRect(x: 0, y: self.vwOrderDetail2.frame.origin.y + self.vwOrderDetail2.frame.height, width: self.vwOrderDetail2.frame.size.width, height: Height)
                                self.vwOrderDetail3.translatesAutoresizingMaskIntoConstraints = true
                                self.vwOrderDetail1.frame.size.height = self.vwOrderDetail3.frame.origin.y + self.vwOrderDetail3.frame.size.height + 8
                                self.viewHeight = self.vwOrderDetail1.frame.size.height
                            }else {
                                let trimmedStr = htmlText.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                self.lblComment.text = trimmedStr.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                self.lblComment.textAlignment = isRTLenabled == true ? .right : .left
                                self.lblComment.sizeToFit()
                                self.lblComment.translatesAutoresizingMaskIntoConstraints =  true
                                let Height = self.lblComment.frame.origin.y + self.lblComment.frame.size.height + 10
                                self.vwOrderDetail3.frame = CGRect(x: 0, y: self.vwOrderDetail2.frame.origin.y + self.vwOrderDetail2.frame.height, width: self.vwOrderDetail2.frame.size.width, height: Height)
                                self.vwOrderDetail3.translatesAutoresizingMaskIntoConstraints = true
                                self.vwOrderDetail1.frame.size.height = self.vwOrderDetail3.frame.origin.y + self.vwOrderDetail3.frame.size.height + 8
                                self.viewHeight = self.vwOrderDetail1.frame.size.height
                            }
                            self.tblOrderDetails.isHidden = false
                            self.tblOrderDetails.dataSource = self
                            self.tblOrderDetails.delegate = self
                            self.tblOrderDetails.reloadData()
                        }
                        else
                        {
                            SharedManager.showAlertWithMessage(title: "", alertMessage: ((responseObject.result.value) as AnyObject).value(forKeyPath: "error.message") as! String, viewController: self)
                        }
                        SharedManager.dismissHUD(viewController: self)
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
    
    func delayOrder(){
        SharedManager.showHUD(viewController: self)
        let urlStr = "\(ConfigUrl.baseUrl)delay-list"
        print(urlStr)
        print(storeIDStr)
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
                            let result = responseObject.result.value! as AnyObject
                            self.timeArr = result.value(forKey: "delay_list") as! NSArray
                            self.statusType = "delay"
                            self.orderStatusId = ""
                            self.tblStatusManagement.reloadData()
                            self.viewStatusManagement.isHidden = false
                            self.viewAddHistoryBlur.isHidden = false
                            SharedManager.dismissHUD(viewController: self)
                        }
                        else
                        {
                            SharedManager.dismissHUD(viewController: self)
                            SharedManager.showAlertWithMessage(title: "", alertMessage: ((responseObject.result.value) as AnyObject).value(forKeyPath: "error.message") as! String, viewController: self)
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
            SharedManager.dismissHUD(viewController: self)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    func cancelOrder(){
        SharedManager.showHUD(viewController: self)
        let urlStr = "\(ConfigUrl.baseUrl)cancel/reason-list"
        
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
        
        if Connectivity.isConnectedToInternet()
        {
            Alamofire.request(request).responseJSON
            { (responseObject) -> Void in
                
                if responseObject.result.isSuccess
                {
                    if "\(String(describing: responseObject.response!.statusCode))" == "200"
                    {
                        let result = responseObject.result.value! as AnyObject
                        self.cancelReasonArr = result.value(forKey: "cancel_reason") as! NSArray
                        print(self.cancelReasonArr)
                        if self.cancelReasonArr.count != 0{
                            self.statusType = "cancel"
                            self.orderStatusId = ""
                            self.tblStatusManagement.reloadData()
                            self.viewStatusManagement.isHidden = false
                            self.viewAddHistoryBlur.isHidden = false
                        }
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
    
    func updateOrderStatus(statusId: String, reason: String)
    {
        SharedManager.showHUD(viewController: self)
        view.endEditing(true)
        var params = [String : Any]()
        var urlStr = ""
        if statusId == ""{
            params = ["delay" : reason,
                      "order_id" : self.orderId,
                      "language_id" : languageID,
                      "language_code" : languageCode
                
                ] as [String : Any]
            
            urlStr = "\(ConfigUrl.baseUrl)delay-update"
        }else{
            params = ["order_id" : self.orderId,
                        "order_status_id" : statusId,
                          "comment" : reason,
                          "notify" : true,
                          "language_id" : languageID
                ] as [String : Any]
            urlStr = "\(ConfigUrl.baseUrl)order-status-update"
        }
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
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
                            SharedManager.showAlertWithMessage(title: "", alertMessage: NSLocalizedString("Order History updated Successfully", comment: ""), viewController: self)
                            self.viewStatusManagement.isHidden = true
                            self.viewAddHistoryBlur.isHidden = true
                            SharedManager.dismissHUD(viewController: self)
                            self.OrderDetails()
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
            SharedManager.dismissHUD(viewController: self)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    //Mark: TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if tableView == tblOrderDetails
        {
            return 4
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == tblOrderDetails
        {
            if section == 0 || section == 2
            {
                return 1
            }
            else if section == 1
            {
                return productsArr.count + totalArr.count
            }
            else
            {
                return historyArr.count
            }
        }else if tableView == tblStatusManagement{
            if statusType == "delay"{
                return timeArr.count
            }else if statusType == "cancel"{
                return cancelReasonArr.count
            }else{
                return 0
            }
        }
        else
        {
            return orderStatusArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == tblOrderDetails
        {
            if indexPath.section == 0
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                viewOrderDetails.frame = CGRect(x: 0, y: 0, width: self.tblOrderDetails.frame.size.width, height: viewHeight)
                viewOrderDetails.translatesAutoresizingMaskIntoConstraints = true
                cell.contentView.addSubview(viewOrderDetails)
                return cell
            }
            else if indexPath.section == 1
            {
                if indexPath.row < productsArr.count
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "productCell") as! OrderTblCell
                    
                    cell.lblTitle.text = "\(String(describing: (self.productsArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!))"
                    cell.lblProductQuantity.text = "\(String(describing: (self.productsArr.object(at: indexPath.row) as AnyObject).value(forKey: "quantity")!)) x \(String(describing: (self.productsArr.object(at: indexPath.row) as AnyObject).value(forKey: "price")!))"
                    cell.lblProductTotal.text = "\(String(describing: (self.productsArr.object(at: indexPath.row) as AnyObject).value(forKey: "total")!))"
                    if let options = (productsArr.object(at: indexPath.row) as AnyObject).value(forKey: "option")
                    {
                        let str = NSMutableString()
                        for i in 0..<(options as AnyObject).count
                        {
                            let string = "\(((options as AnyObject).object(at: i)as AnyObject).value(forKey: "option_value")!)"
                            str.append(" \(string),")
                        }
                        let alloptions = String((str as String).dropLast())
                        cell.lblOption.text = alloptions
                        cell.lblOption.frame.size.width = cell.lblTitle.frame.size.width
                        cell.lblOption.sizeToFit()
                        cell.lblOption.translatesAutoresizingMaskIntoConstraints =  true
                        cell.lblOption.textAlignment = isRTLenabled == true ? .right : .left
                        var totalHeight = CGFloat(0)
                        totalHeight = cell.lblOption.frame.origin.y + cell.lblOption.frame.size.height + 10
                        print("asd:\(totalHeight)")
                        print(cell.frame.size.height)
                        cell.viewShadow1.frame = CGRect(x: 8, y: 0, width: self.vwOrderDetail1.frame.size.width, height: cell.frame.size.height - 10)
                        cell.viewShadow1.translatesAutoresizingMaskIntoConstraints = true
                    }
                    
                    let imageUrl = "\((productsArr.object(at: indexPath.row) as AnyObject).value(forKey: "image")!)"

                    let trimmedUrl1 = imageUrl.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20")

                    var activityLoader = UIActivityIndicatorView()
                    activityLoader = UIActivityIndicatorView(style: .gray)
                    activityLoader.center = cell.imgProduct.center
                    activityLoader.startAnimating()
                    cell.imgProduct.addSubview(activityLoader)

                    cell.imgProduct.sd_setImage(with: URL(string: trimmedUrl1), completed: { (image, error, imageCacheType, imageUrl) in

                        if image != nil
                        {
                            activityLoader.stopAnimating()
                        }else
                        {
                            print("image not found")
                            cell.imgProduct.image = UIImage(named: "no_image")
                            activityLoader.stopAnimating()
                        }
                    })
                    
                    cell.imgProduct.contentMode = UIView.ContentMode.scaleAspectFit
                    
                    cell.viewShadow1.layer.shadowColor = UIColor.gray.cgColor
                    cell.viewShadow1.layer.shadowOpacity = 1
                    cell.viewShadow1.layer.shadowOffset = CGSize.zero
                    cell.viewShadow1.layer.shadowRadius = 3
                    
                    return cell
                }
                else
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "totalCell") as! OrderTblCell
                    
                    cell.lblTotalTitle.text = "\(String(describing: (self.totalArr.object(at: indexPath.row - (self.productsArr.count)) as AnyObject).value(forKey: "title")!))"
                    cell.lblTotalValue.text = "\(String(describing: (self.totalArr.object(at: indexPath.row - (self.productsArr.count)) as AnyObject).value(forKey: "text")!))"
                    
                    cell.viewShadow2.layer.shadowColor = UIColor.gray.cgColor
                    cell.viewShadow2.layer.shadowOpacity = 1
                    cell.viewShadow2.layer.shadowOffset = CGSize.zero
                    cell.viewShadow2.layer.shadowRadius = 3
                    
                    return cell
                }
            }else if indexPath.section == 2{
                
                if let vendorType = self.orderDetailsDict.value(forKeyPath: "info.vendor_type") as? String, vendorType == "2"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "manageCell") as! OrderTblCell
                    cell.btnAccept.addTarget(self, action: #selector(clickAccept(_:)), for: UIControl.Event.touchUpInside)
                    cell.btnDelay.addTarget(self, action: #selector(clickDelay(_:)), for: UIControl.Event.touchUpInside)
                    cell.btnReady.addTarget(self, action: #selector(clickReady(_:)), for: UIControl.Event.touchUpInside)
                    cell.btnComplete.addTarget(self, action: #selector(clickCompeleteOrder(_:)), for: UIControl.Event.touchUpInside)
                    cell.btnDelay2.addTarget(self, action: #selector(clickDelay(_:)), for: UIControl.Event.touchUpInside)
                    if let orderType = self.orderDetailsDict.value(forKeyPath: "info.order_type") as? String, orderType == "1"{
                        cell.btnDelay2.isHidden = false
                        cell.btnDelay.isHidden = true
                        cell.btnComplete.isHidden = true
                    }else{
                        cell.btnDelay2.isHidden = true
                        cell.btnDelay.isHidden = false
                        cell.btnComplete.isHidden = false
                    }
                    if self.orderDetailsDict.value(forKeyPath: "info.order_status_id") != nil{
                        let status = "\(String(describing: self.orderDetailsDict.value(forKeyPath: "info.order_status_id")!))"
                        if status == "1"{
                            cell.btnAccept.isEnabled = true
                            cell.btnReady.isEnabled = true
                        }else if status == "3" || status == "6" || status == "2"{
                            cell.btnReady.isEnabled = true
                            cell.btnReady.alpha = 1
                            cell.btnAccept.isEnabled = false
                            cell.btnAccept.alpha = 0.3
                        }else{
                            if let orderType = self.orderDetailsDict.value(forKeyPath: "info.order_type") as? String, orderType == "2" && status == "5"{
                                cell.btnAccept.isEnabled = false
                                cell.btnReady.isEnabled = false
                                cell.btnDelay.isEnabled = false
                                cell.btnDelay2.isEnabled = false
                                cell.btnAccept.alpha = 0.3
                                cell.btnReady.alpha = 0.3
                                cell.btnDelay.alpha = 0.3
                                cell.btnDelay2.alpha = 0.3
                            }else{
                                cell.btnAccept.isEnabled = false
                                cell.btnReady.isEnabled = false
                                cell.btnDelay.isEnabled = false
                                cell.btnDelay2.isEnabled = false
                                cell.btnComplete.isEnabled = false
                                
                                cell.btnAccept.alpha = 0.3
                                cell.btnReady.alpha = 0.3
                                cell.btnDelay2.alpha = 0.3
                                cell.btnComplete.alpha = 0.3
                                cell.btnDelay.alpha = 0.3
                            }
                        }
                    }
                    return cell
                }else{
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "manageCell2") as! OrderTblCell
                    cell.btnAccept.addTarget(self, action: #selector(clickAccept(_:)), for: UIControl.Event.touchUpInside)
                    cell.btnDelay.addTarget(self, action: #selector(clickDelay(_:)), for: UIControl.Event.touchUpInside)
                    cell.btnPreparing.addTarget(self, action: #selector(clickPrepare(_:)), for: UIControl.Event.touchUpInside)
                    cell.btnReady.addTarget(self, action: #selector(clickReady(_:)), for: UIControl.Event.touchUpInside)
                    cell.btnComplete.addTarget(self, action: #selector(clickCompeleteOrder(_:)), for: UIControl.Event.touchUpInside)
                    if let orderType = self.orderDetailsDict.value(forKeyPath: "info.order_type") as? String, orderType == "1"{
                        cell.btnComplete.isHidden = true
                    }else{
                        cell.btnComplete.isHidden = false
                    }
                    
                    if self.orderDetailsDict.value(forKeyPath: "info.order_status_id") != nil{
                        let status = "\(String(describing: self.orderDetailsDict.value(forKeyPath: "info.order_status_id")!))"
                        print(status)
                        if status == "1"{
                            cell.btnPreparing.isEnabled = true
                            cell.btnReady.isEnabled = true
                        }else if status == "6" || status == "2"{
                            cell.btnPreparing.isEnabled = true
                            cell.btnPreparing.alpha = 1
                            cell.btnReady.isEnabled = true
                            cell.btnReady.alpha = 1
                            cell.btnAccept.isEnabled = false
                            cell.btnAccept.alpha = 0.3
                        }else if status == "3"{
                            cell.btnReady.isEnabled = true
                            cell.btnReady.alpha = 1
                            cell.btnPreparing.isEnabled = false
                            cell.btnPreparing.alpha = 0.3
                            cell.btnAccept.isEnabled = false
                            cell.btnAccept.alpha = 0.3
                        }else{
                            print(self.orderDetailsDict.value(forKeyPath: "info.order_type") as? String)
                            if let orderType = self.orderDetailsDict.value(forKeyPath: "info.order_type") as? String, orderType == "2" && status == "5"{
                                cell.btnAccept.isEnabled = false
                                cell.btnPreparing.isEnabled = false
                                cell.btnReady.isEnabled = false
                                cell.btnDelay.isEnabled = false
                                
                                cell.btnAccept.alpha = 0.3
                                cell.btnPreparing.alpha = 0.3
                                cell.btnReady.alpha = 0.3
                                cell.btnDelay.alpha = 0.3
                            }else{
                                cell.btnAccept.isEnabled = false
                                cell.btnPreparing.isEnabled = false
                                cell.btnReady.isEnabled = false
                                cell.btnDelay.isEnabled = false
                                cell.btnComplete.isEnabled = false
                                
                                cell.btnAccept.alpha = 0.3
                                cell.btnPreparing.alpha = 0.3
                                cell.btnReady.alpha = 0.3
                                cell.btnComplete.alpha = 0.3
                                cell.btnDelay.alpha = 0.3
                            }
                        }
                    }
                    return cell
                }
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as! OrderTblCell
                
                cell.lblHistoryDateOrder.text = "\(String(describing: (self.historyArr.object(at: indexPath.row) as AnyObject).value(forKey: "date_added")!))"
                cell.lblHistoryStatus.text = "\(String(describing: (self.historyArr.object(at: indexPath.row) as AnyObject).value(forKey: "status")!))"
                
                cell.viewShadow3.layer.shadowColor = UIColor.gray.cgColor
                cell.viewShadow3.layer.shadowOpacity = 1
                cell.viewShadow3.layer.shadowOffset = CGSize.zero
                cell.viewShadow3.layer.shadowRadius = 3
                
                return cell
            }
        }else if tableView == tblStatusManagement{
            let cell = tableView.dequeueReusableCell(withIdentifier: "status")!
            if statusType == "delay"{
                cell.textLabel?.text = "\((self.timeArr.object(at: indexPath.row) as AnyObject).value(forKey: "value")!)  minutes"
                cell.textLabel?.textAlignment = .center
                return cell
            }else if statusType == "cancel"{
                cell.textLabel?.text = "\((self.cancelReasonArr.object(at: indexPath.row) as AnyObject).value(forKey: "reason")!)"
                cell.textLabel?.textAlignment = .center
                return cell
            }else{
                return cell
            }
        }
        else
        {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            
            for i in 0..<orderStatusArr.count
            {
                if indexPath.row == i
                {
                    cell.textLabel?.text = "\((orderStatusArr.object(at: i) as AnyObject).value(forKey: "name")!)"
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == tblOrderDetails
        {
            if indexPath.section == 0
            {
                 return max(255, viewHeight + 16)
            }
            else if indexPath.section == 1
            {
                if indexPath.row < productsArr.count
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "productCell") as! OrderTblCell
                    if let options = (productsArr.object(at: indexPath.row) as AnyObject).value(forKey: "option")
                    {
                        let str = NSMutableString()

                        for i in 0..<(options as AnyObject).count
                        {
                            let string = "\(((options as AnyObject).object(at: i)as AnyObject).value(forKey: "option_value")!)"
                            str.append(" \(string),")
                        }
                        let alloptions = String((str as String).dropLast())
                        cell.lblOption.text = alloptions
                        cell.lblOption.frame.size.width = cell.lblTitle.frame.size.width
                        cell.lblOption.sizeToFit()
                        cell.lblOption.translatesAutoresizingMaskIntoConstraints =  true
                        cell.lblOption.textAlignment = isRTLenabled == true ? .right : .left
                        var totalHeight = CGFloat(0)
                        totalHeight = cell.lblOption.frame.origin.y + cell.lblOption.frame.size.height + 10
                        cell.viewShadow1.frame = CGRect(x: 8, y: 0, width: self.vwOrderDetail1.frame.size.width, height: totalHeight)
                        cell.viewShadow1.translatesAutoresizingMaskIntoConstraints = true
                        return max(138, totalHeight)
                    }
                    return 138
                }
                else
                {
                    return 30
                }
            }else if indexPath.section == 2
            {
                if let vendorType = self.orderDetailsDict.value(forKeyPath: "info.vendor_type") as? String, vendorType == "2"{
                    return 85
                }else{
                    if let orderType = self.orderDetailsDict.value(forKeyPath: "info.order_type") as? String, orderType == "1"{
                        return 85
                    }else{
                        return 125
                    }
                }
            }
            else
            {
                return 75
            }
        }else if tableView == tblStatusManagement
        {
           return 40.0
        }
        else
        {
            return 45
        }
    }
    
    // Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if tableView == tblOrderDetails
        {
            if section == 1
            {
                let sectionView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.tblOrderDetails.frame.size.width, height: 40))
                sectionView.tag = section
                sectionView.backgroundColor = UIColor.groupTableViewBackground
                let viewLabel: UILabel = UILabel(frame: CGRect(x: 8, y: 0, width: self.tblOrderDetails.frame.size.width - 16, height: 40))
                viewLabel.backgroundColor = UIColor(named: "clr_light_red")
                let titleLabel: UILabel = UILabel(frame: CGRect(x: 8, y: 0, width: viewLabel.frame.size.width - 16, height: 40))
                titleLabel.backgroundColor = .clear
                titleLabel.textColor = UIColor.black
                titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
                titleLabel.text = NSLocalizedString("Product Details", comment: "")
                viewLabel.addSubview(titleLabel)
                sectionView.addSubview(viewLabel)
                return sectionView
            }
            else if section == 3
            {
                let sectionView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.tblOrderDetails.frame.size.width, height: 60))
                sectionView.tag = section
                sectionView.backgroundColor = UIColor.groupTableViewBackground
                
                let viewLabel: UILabel = UILabel(frame: CGRect(x: 8, y: 5, width: self.tblOrderDetails.frame.size.width - 16, height: 40))
                viewLabel.backgroundColor = UIColor(named: "clr_light_red")
                
                let titleLabel: UILabel = UILabel(frame: CGRect(x: 8, y: 0, width: viewLabel.frame.size.width - 16, height: 40))
                titleLabel.backgroundColor = .clear
                titleLabel.textColor = UIColor.black
                titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
                titleLabel.text = NSLocalizedString("Order History Details", comment: "")
                viewLabel.addSubview(titleLabel)
                sectionView.addSubview(viewLabel)
                return sectionView
            }
            else
            {
                let sectionView: UIView = UIView()
                return sectionView
            }
        }
        else if tableView == tblStatusManagement
        {
            let sectionView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.tblStatusManagement.frame.size.width, height: 40))
            sectionView.tag = section
            sectionView.backgroundColor = UIColor.groupTableViewBackground
            let viewLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tblStatusManagement.frame.size.width, height: 40))
            viewLabel.backgroundColor = themeColor
            viewLabel.textColor = UIColor.white
            viewLabel.textAlignment = .center
            viewLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            if statusType == "delay"{
                viewLabel.text = NSLocalizedString("Delay time", comment: "")
            }else{
                viewLabel.text = NSLocalizedString("Cancel reason", comment: "")
            }
            sectionView.addSubview(viewLabel)
            return sectionView
        }
        else
        {
            let sectionView: UIView = UIView()
            return sectionView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if tableView == tblOrderDetails
        {
            if section == 0 || section == 2
            {
                return 0
            }
            else if section == 1
            {
                return 40.0
            }
            else
            {
                return 40.0
            }
        }else if tableView == tblStatusManagement
        {
           return 40.0
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == tblOrderDetails
        {
            
        }
        else
        {
            if statusType == "delay"{
                self.orderStatusId = "\((self.timeArr.object(at: indexPath.row) as AnyObject).value(forKey: "key")!)"
            }else if statusType == "cancel"{
                self.orderStatusId = "\((self.cancelReasonArr.object(at: indexPath.row) as AnyObject).value(forKey: "reason")!)"
            }
        }
    }
    
    //MARK: Button Action
    @objc func clickBack(_ sender : UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func clickAccept(_ sender : UIButton)
    {
        updateOrderStatus(statusId: "2", reason: "")
    }
    
    @objc func clickPrepare(_ sender : UIButton)
    {
        updateOrderStatus(statusId: "3", reason: "")
    }
    
    @objc func clickReady(_ sender : UIButton)
    {
        updateOrderStatus(statusId: "5", reason: "")
    }
    
    @objc func clickDelay(_ sender : UIButton)
    {
        self.delayOrder()
    }
    
    @objc func clickCompeleteOrder(_ sender : UIButton)
    {
        if let orderType = self.orderDetailsDict.value(forKeyPath: "info.order_type") as? String, orderType == "2"{
            updateOrderStatus(statusId: "9", reason: "")
        }else{
            cancelOrder()
        }
    }
    
    @objc func clickCancelOrder(_ sender : UIButton)
    {
        cancelOrder()
    }
    
    @IBAction func clickStatusSave(_ sender: Any)
    {
        if self.orderStatusId != ""{
            if statusType == "delay"{
                updateOrderStatus(statusId: "", reason: orderStatusId)
            }else{
                updateOrderStatus(statusId: "4", reason: orderStatusId)
            }
            
        }else{
            if statusType == "delay"{
                SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: "Please select delay time", viewController: self)
            }else{
                SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: "Please select reason", viewController: self)
            }
        }
    }
    
    @IBAction func clickStatusCancel(_ sender: Any)
    {
        self.viewStatusManagement.isHidden = true
        self.viewAddHistoryBlur.isHidden = true

    }
    
    @objc func clickAddHistory(_ sender: UIButton)
    {
        self.viewAddHistoryBlur.isHidden = false
    }
}
