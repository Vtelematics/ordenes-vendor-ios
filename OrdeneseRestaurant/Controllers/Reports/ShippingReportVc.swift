//
//  ShippingVcViewController.swift
//  GroceryStore
//
//  Created by Adyas Infotech on 07/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import Alamofire

class ShippingReportVc: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblShippingReports: UITableView!
    @IBOutlet weak var viewOrderStatus: UIView!
    @IBOutlet weak var viewGroupBy: UIView!
    @IBOutlet weak var viewBlur: UIView!
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var txtStartDate: UITextField!
    @IBOutlet weak var txtEndDate: UITextField!
    @IBOutlet weak var txtOrderStatus: UITextField!
    @IBOutlet weak var txtGroupBy: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var viewDatePicker: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    
    var shippingReportArr = NSMutableArray()
    var dateType = ""
    var orderStatusId = ""
    var typeStr = ""
    
    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "10"
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.auto),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.title = NSLocalizedString("Shipping Reports", comment: "")
        
        viewOrderStatus.layer.borderColor = UIColor.black.cgColor
        viewOrderStatus.layer.borderWidth = 1
        
        viewGroupBy.layer.borderColor = UIColor.black.cgColor
        viewGroupBy.layer.borderWidth = 1
        
        self.viewBlur.isHidden = true
        self.viewFilter.isHidden = true
        self.viewDatePicker.isHidden = true
        self.txtStartDate.textAlignment = isRTLenabled == true ? .left : .right
        self.txtEndDate.textAlignment = isRTLenabled == true ? .left : .right
        self.txtGroupBy.textAlignment = isRTLenabled == true ? .left : .right
        self.txtOrderStatus.textAlignment = isRTLenabled == true ? .left : .right
        shippingReportAPI()
        if #available(iOS 13.4, *) {
            datePicker?.preferredDatePickerStyle = .wheels
        }
    }
    
    func shippingReportAPI()
    {
        SharedManager.showHUD(viewController: self)
        page = 1
        let urlStr = "\(ConfigUrl.baseUrl)store/report/shipping&page=\(page)&limit=\(limit)"
        //&filter_order_id=&filter_customer=&filter_start_date=&filter_end_date=&filter_order_status=&filter_total=&filter_date_delivery=&filter_order_type=&filter_payment_method="
        
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
        
        if Connectivity.isConnectedToInternet()
        {
            Alamofire.request(request).responseJSON
                { (responseObject) -> Void in
                    
                    if responseObject.result.isSuccess
                    {
                        SharedManager.dismissHUD(viewController: self)
                        
                        if "\(String(describing: responseObject.response!.statusCode))" == "200"
                        {
                            let result = responseObject.result.value! as AnyObject
                            self.shippingReportArr = (result.value(forKey: "orders") as! NSArray).mutableCopy() as! NSMutableArray
                            print(self.shippingReportArr)
                            
                            if self.shippingReportArr.count == 0
                            {
                                let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Shipping report list is empty", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
                                    self.navigationController?.popViewController(animated: true)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                            let total = "\(result.value(forKey: "total")!)"
                            
                            self.pageCount = Double(Int(total)!/Int(self.limit)!)
                            
                            self.tblShippingReports.reloadData()
                        }
                        else
                        {
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
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }

    //MARK: Pagination
    
    func pullToRefresh()
    {
        if (self.isScrolledOnce == true)
        {
            return
        }
        self.isScrolledOnce = true
        
        if page <= Int(self.pageCount)
        {
            page += 1
            
            SharedManager.showHUD(viewController: self)
            
            
            let urlStr = "\(ConfigUrl.baseUrl)store/report/shipping&filter_date_start=\(self.txtStartDate.text!)&filter_date_end=\(self.txtEndDate.text!)&filter_group=\(self.txtGroupBy.text!)&filter_order_status_id=\(self.txtOrderStatus.text!)&page=\(page)&limit=\(limit)"
            
            let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
            var request = URLRequest(url: URL(string: setFinalURl)!)
            request.httpMethod = HTTPMethod.get.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
            
            if Connectivity.isConnectedToInternet()
            {
                Alamofire.request(request).responseJSON
                    { (responseObject) -> Void in
                        
                        SharedManager.dismissHUD(viewController: self)
                        if responseObject.result.isSuccess
                        {
                            SharedManager.dismissHUD(viewController: self)
                            if "\(String(describing: responseObject.response!.statusCode))" == "200"
                            {
                                let result = responseObject.result.value! as AnyObject
                                
                                let array = (result.value(forKey: "orders") as! NSArray).mutableCopy() as! NSMutableArray
                                
                                self.shippingReportArr.addObjects(from: array as! [Any])
                                self.tblShippingReports.reloadData()
                            }
                            else
                            {
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
                        SharedManager.dismissHUD(viewController: self)
                        self.isScrolledOnce = false
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
        else
        {
            SharedManager.dismissHUD(viewController: self)
            self.isScrolledOnce = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let offset: CGPoint = scrollView.contentOffset
        let bounds: CGRect = scrollView.bounds
        let size: CGSize = scrollView.contentSize
        let inset: UIEdgeInsets = scrollView.contentInset
        let y = Float(offset.y + bounds.size.height - inset.bottom)
        let h = Float(size.height)
        let reload_distance: Float = 10
        if y > h + reload_distance
        {
            if isScrolledOnce == false
            {
                self.pullToRefresh()
            }
        }
    }
    
    //Mark: TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == tblShippingReports
        {
            return self.shippingReportArr.count
        }
        else
        {
            if typeStr == "group"
            {
                return 4
            }
            else
            {
                return orderStatusArr.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == tblShippingReports
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "shippingCell") as! ReportViewCell
            
            cell.lblShippingDateStart.text = "\((shippingReportArr.object(at: indexPath.row) as AnyObject).value(forKey: "date_start")!)"
            cell.lblShippingDateEnd.text = "\((shippingReportArr.object(at: indexPath.row) as AnyObject).value(forKey: "date_end")!)"
            cell.lblShippingTitle.text = "\((shippingReportArr.object(at: indexPath.row) as AnyObject).value(forKey: "title")!)"
            cell.lblShippingOrdersCount.text = "\((shippingReportArr.object(at: indexPath.row) as AnyObject).value(forKey: "orders")!)"
            cell.lblShippingTotal.text = "\((shippingReportArr.object(at: indexPath.row) as AnyObject).value(forKey: "total")!)"
            
            cell.viewShadowShipping.layer.shadowColor = UIColor.gray.cgColor
            cell.viewShadowShipping.layer.shadowOpacity = 1
            cell.viewShadowShipping.layer.shadowOffset = CGSize.zero
            cell.viewShadowShipping.layer.shadowRadius = 3
            
            return cell
        }
        else
        {
            if typeStr == "group"
            {
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                
                if indexPath.row == 0
                {
                    cell.textLabel?.text = NSLocalizedString("Years", comment: "")
                }
                else if indexPath.row == 1
                {
                    cell.textLabel?.text = NSLocalizedString("Months", comment: "")
                }
                else if indexPath.row == 2
                {
                    cell.textLabel?.text = NSLocalizedString("Weeks", comment: "")
                }
                else
                {
                    cell.textLabel?.text = NSLocalizedString("Days", comment: "")
                }
                return cell
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
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == tblShippingReports
        {
            
        }
        else
        {
            if typeStr == "group"
            {
                if indexPath.row == 0
                {
                    self.txtGroupBy.text = NSLocalizedString("Years", comment: "")
                }
                else if indexPath.row == 1
                {
                    self.txtGroupBy.text = NSLocalizedString("Months", comment: "")
                }
                else if indexPath.row == 2
                {
                    self.txtGroupBy.text = NSLocalizedString("Weeks", comment: "")
                }
                else
                {
                    self.txtGroupBy.text = NSLocalizedString("Days", comment: "")
                }
                self.popover.dismiss()
            }
            else
            {
                self.txtOrderStatus.text = "\((orderStatusArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
                self.orderStatusId = "\((orderStatusArr.object(at: indexPath.row) as AnyObject).value(forKey: "order_status_id")!)"
                self.popover.dismiss()
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == tblShippingReports
        {
            return 162
        }
        else
        {
            return 45
        }
    }
    
    //Mark: Button Action
    @IBAction func clickFilter(_ sender: Any)
    {
        self.viewBlur.isHidden = false
        self.viewFilter.isHidden = false
    }
    @IBAction func clickStartDate(_ sender: Any)
    {
        self.viewDatePicker.isHidden = false
        dateType = "start"
    }
    
    @IBAction func clickEndDate(_ sender: Any)
    {
        self.viewDatePicker.isHidden = false
        dateType = "end"
    }
    
    @IBAction func clickDateDone(_ sender: Any)
    {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-d"
        
        let todaysDate = dateFormatterGet.string(from: datePicker.date)
        
        if dateType == "start"
        {
            self.txtStartDate.text = todaysDate
        }
        else
        {
            self.txtEndDate.text = todaysDate
        }
        self.viewDatePicker.isHidden = true
    }
    
    @IBAction func clickDateCancel(_ sender: Any)
    {
        self.viewDatePicker.isHidden = true
    }
    
    @IBAction func clickOrderStatus(_ sender: Any)
    {
        self.typeStr = "status"
        
        let tableViewStatus = UITableView(frame: CGRect(x: self.txtStartDate.frame.origin.x, y: 0, width: self.txtStartDate.frame.size.width, height: CGFloat(orderStatusArr.count * 45)))
        
        tableViewStatus.delegate = self
        tableViewStatus.dataSource = self
        tableViewStatus.isScrollEnabled = false
        tableViewStatus.reloadData()
        self.popover = Popover(options: self.popoverOptions)
        self.popover.willShowHandler = {
            print("willShowHandler")
        }
        self.popover.didShowHandler = {
            print("didDismissHandler")
        }
        self.popover.willDismissHandler = {
            print("willDismissHandler")
        }
        self.popover.didDismissHandler = {
            print("didDismissHandler")
        }
        self.popover.arrowSize = CGSize(width: 0, height: 0)
        self.popover.show(tableViewStatus, fromView: self.btnCancel)
    }
    
    @IBAction func clickGroupBy(_ sender: Any)
    {
        self.typeStr = "group"
        
        let tableViewStatus = UITableView(frame: CGRect(x: self.viewGroupBy.frame.origin.x, y: 0, width: self.viewGroupBy.frame.size.width, height: 4*45))
        tableViewStatus.delegate = self
        tableViewStatus.dataSource = self
        tableViewStatus.isScrollEnabled = false
        tableViewStatus.reloadData()
        self.popover = Popover(options: self.popoverOptions)
        self.popover.willShowHandler = {
            print("willShowHandler")
        }
        self.popover.didShowHandler = {
            print("didDismissHandler")
        }
        self.popover.willDismissHandler = {
            print("willDismissHandler")
        }
        self.popover.didDismissHandler = {
            print("didDismissHandler")
        }
        self.popover.show(tableViewStatus, fromView: self.txtGroupBy)
    }
    
    @IBAction func clickFilterDone(_ sender: Any)
    {
        SharedManager.showHUD(viewController: self)
        self.viewDatePicker.isHidden = true
        page = 1
        let urlStr = "\(ConfigUrl.baseUrl)store/report/shipping&filter_date_start=\(self.txtStartDate.text!)&filter_date_end=\(self.txtEndDate.text!)&filter_group=\(self.txtGroupBy.text!)&filter_order_status_id=\(self.txtOrderStatus.text!)&page=\(page)&limit=\(limit)"
        
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
        
        if Connectivity.isConnectedToInternet()
        {
            Alamofire.request(request).responseJSON
                { (responseObject) -> Void in
                    
                    if responseObject.result.isSuccess
                    {
                        SharedManager.dismissHUD(viewController: self)
                        
                        if "\(String(describing: responseObject.response!.statusCode))" == "200"
                        {
                            let result = responseObject.result.value! as AnyObject
                            self.shippingReportArr = (result.value(forKey: "orders") as! NSArray).mutableCopy() as! NSMutableArray
                            if self.shippingReportArr.count == 0
                            {
                                let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Shipping report list is empty", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
                                    self.navigationController?.popViewController(animated: true)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                            self.viewBlur.isHidden = true
                            self.viewFilter.isHidden = true
                            self.viewDatePicker.isHidden = true
                            let total = "\(result.value(forKey: "total")!)"
                            self.pageCount = Double(Int(total)!/Int(self.limit)!)
                            self.tblShippingReports.reloadData()
                        }
                        else
                        {
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
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    @IBAction func clickFilterCancel(_ sender: Any)
    {
        self.viewDatePicker.isHidden = true
        self.viewBlur.isHidden = true
        self.viewFilter.isHidden = true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
