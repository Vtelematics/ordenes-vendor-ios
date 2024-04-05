//
//  OrdersReportVc.swift
//  GroceryStore
//
//  Created by Adyas Infotech on 07/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import Alamofire

class OrdersReportVc: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var lblTotalProdutcts: UILabel!
    @IBOutlet weak var tblOrderReports: UITableView!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var lblTodayCost: UILabel!
    @IBOutlet weak var lblTodayOrders: UILabel!
    @IBOutlet weak var lblWeekCost: UILabel!
    @IBOutlet weak var lblWeekOrders: UILabel!
    @IBOutlet weak var lblMonthCost: UILabel!
    @IBOutlet weak var lblMonthOrders: UILabel!
    @IBOutlet weak var lblTotalOrders: UILabel!
    @IBOutlet weak var lblTotalAmount: UILabel!
    
    @IBOutlet weak var viewOrderStatus: UIView!
    @IBOutlet weak var viewBlur: UIView!
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var txtOrderId: UITextField!
    @IBOutlet weak var txtCustomer: UITextField!
    @IBOutlet weak var txtOrderAmount: UITextField!
    @IBOutlet weak var txtStartDate: UITextField!
    @IBOutlet weak var txtEndDate: UITextField!
    @IBOutlet weak var txtOrderStatus: UITextField!
    @IBOutlet weak var txtDeliveryDate: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var viewDatePicker: UIView!
    
    var OrderReportArr = NSMutableArray()
    var dateType = ""
    var orderStatusId = ""
    var filterId = String()
    
    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "8"
    var reportInfoArr = NSMutableArray()
    var selectedReportIndex = 0
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.auto),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    let listColors = [
        UIColor(red: 48/255, green: 176/255, blue: 199/255, alpha: 1),
        UIColor(red: 148/255, green: 23/255, blue: 81/255, alpha: 1),
        UIColor(red: 255/255, green: 195/255, blue: 20/255, alpha: 1),
        UIColor(red: 0/255, green: 145/255, blue: 147/255, alpha: 1),
        
        UIColor(red: 48/255, green: 176/255, blue: 199/255, alpha: 1),
        UIColor(red: 148/255, green: 23/255, blue: 81/255, alpha: 1),
        UIColor(red: 255/255, green: 195/255, blue: 20/255, alpha: 1),
        UIColor(red: 0/255, green: 145/255, blue: 147/255, alpha: 1),
        
        UIColor(red: 48/255, green: 176/255, blue: 199/255, alpha: 1),
        UIColor(red: 148/255, green: 23/255, blue: 81/255, alpha: 1),
        UIColor(red: 255/255, green: 195/255, blue: 20/255, alpha: 1),
        UIColor(red: 0/255, green: 145/255, blue: 147/255, alpha: 1),
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Order Reports", comment: "")
        
        viewShadow.layer.shadowColor = UIColor.gray.cgColor
        viewShadow.layer.shadowOpacity = 1
        viewShadow.layer.shadowOffset = CGSize.zero
        viewShadow.layer.shadowRadius = 3
        
        viewOrderStatus.layer.borderColor = UIColor.black.cgColor
        viewOrderStatus.layer.borderWidth = 1
        
        self.viewBlur.isHidden = true
        self.viewFilter.isHidden = true
        self.viewDatePicker.isHidden = true
        self.txtOrderId.textAlignment = isRTLenabled == true ? .left : .right
        self.txtCustomer.textAlignment = isRTLenabled == true ? .left : .right
        self.txtOrderAmount.textAlignment = isRTLenabled == true ? .left : .right
        self.txtStartDate.textAlignment = isRTLenabled == true ? .left : .right
        self.txtEndDate.textAlignment = isRTLenabled == true ? .left : .right
        self.txtDeliveryDate.textAlignment = isRTLenabled == true ? .left : .right
        self.txtOrderStatus.textAlignment = isRTLenabled == true ? .left : .right
        self.txtOrderId.textAlignment = isRTLenabled == true ? .left : .right
        
        reportInfoAPI()
        if #available(iOS 13.4, *) {
            datePicker?.preferredDatePickerStyle = .wheels
        }
    }
    
    func reportInfoAPI()
    {
        SharedManager.showHUD(viewController: self)
        let urlStr = "\(ConfigUrl.baseUrl)report-filter"
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
                            SharedManager.dismissHUD(viewController: self)
                            self.reportInfoArr = (result.value(forKey: "filter") as! NSArray).mutableCopy() as! NSMutableArray
                            self.tblOrderReports.reloadData()
                            self.filterId = "\((self.reportInfoArr.object(at: self.selectedReportIndex) as AnyObject).value(forKey: "id")!)"
                            self.orderReportAPI(filterId: self.filterId)
                        }
                        
                    }
                    else
                    {
                        SharedManager.dismissHUD(viewController: self)
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
    
    func orderReportAPI(filterId : String)
    {
        SharedManager.showHUD(viewController: self)
        page = 1
        let params = [
            "page_per_unit" : limit,
            "page" : page,
            "filter" :filterId
        ] as [String : Any]
        let urlStr = "\(ConfigUrl.baseUrl)report-list"
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
            Alamofire.request(request).responseJSON
            { (responseObject) -> Void in
                if responseObject.result.isSuccess
                {
                    if let status = (responseObject.result.value! as AnyObject).value(forKeyPath: "success.status")
                    {
                        if "\(status)" == "200" {
                            let result = (responseObject.result.value! as AnyObject) as! NSDictionary
                            self.OrderReportArr = (result.value(forKey: "product") as! NSArray).mutableCopy() as! NSMutableArray
                            self.tblOrderReports.isHidden = false
                            let total = "\(String(describing: result.value(forKey: "total")!))"
                            self.pageCount = Double(Int(total)!/Int(self.limit)!)
                            self.tblOrderReports.reloadData()
                        }
                        SharedManager.dismissHUD(viewController: self)
                    }
                    else
                    {
                        SharedManager.dismissHUD(viewController: self)
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
            let params = [
                "page_per_unit" : limit,
                "page" : page,
                "filter" :filterId
            ] as [String : Any]
            
            let urlStr = "\(ConfigUrl.baseUrl)report-list"
            print(urlStr)
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
                Alamofire.request(request).responseJSON
                { (responseObject) -> Void in
                    if responseObject.result.isSuccess
                    {
                        if let status = (responseObject.result.value! as AnyObject).value(forKeyPath: "success.status")
                        {
                            if "\(status)" == "200" {
                                let result = (responseObject.result.value! as AnyObject) as! NSDictionary
                                let array = (result.value(forKey: "product") as! NSArray).mutableCopy() as! NSMutableArray
                                self.OrderReportArr.addObjects(from: array as! [Any])
                                self.tblOrderReports.reloadData()
                            }
                        }
                        else
                        {
                            SharedManager.showAlertWithMessage(title: "Sorry", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "error.message") as! String, viewController: self)
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
                    self.isScrolledOnce = false
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == tblOrderReports
        {
            if OrderReportArr.count > 0
            {
                return OrderReportArr.count + reportInfoArr.count
            }
            else
            {
                return reportInfoArr.count +  1
            }
            
        }
        else
        {
            return orderStatusArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == tblOrderReports
        {
            if OrderReportArr.count > 0
            {
                if indexPath.row < reportInfoArr.count {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! ReportViewCell
                    
                    cell.viewContainer.backgroundColor = listColors[indexPath.row]
                    
                    cell.lblReportName.text = "\((self.reportInfoArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
                    
                    cell.lblReportAmount.text = "\(NSLocalizedString("Cost :", comment: "")) \((self.reportInfoArr.object(at: indexPath.row) as AnyObject).value(forKey: "amount")!)"
                    cell.lblReportCount.text = "\(NSLocalizedString("No. of Orders :", comment: "")) \((self.reportInfoArr.object(at: indexPath.row) as AnyObject).value(forKey: "count")!)"
                    
                    if selectedReportIndex == indexPath.row {
                        cell.imgSelect.isHidden = false
                    }else {
                        cell.imgSelect.isHidden = true
                    }
                    
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "orderReportCell") as! ReportViewCell
                    
                    cell.lblOrderNo.text = "\((OrderReportArr.object(at: indexPath.row - 4) as AnyObject).value(forKey: "order_id")!)"
                    cell.lblOrderCustomer.text = "\((OrderReportArr.object(at: indexPath.row - 4) as AnyObject).value(forKey: "customer")!)"
//                    cell.lblOrderStore.text = "\((OrderReportArr.object(at: indexPath.row - 1) as AnyObject).value(forKey: "restaurant")!)"
                    cell.lblOrderProducts.text = "\((OrderReportArr.object(at: indexPath.row - 4) as AnyObject).value(forKey: "products")!)"
                    cell.lblOrderType.text = "\((OrderReportArr.object(at: indexPath.row - 4) as AnyObject).value(forKey: "order_type")!)"
                    cell.lblOrderPaymentType.text = "\((OrderReportArr.object(at: indexPath.row - 4) as AnyObject).value(forKey: "payment_method")!)"
                    cell.lblOrderAmount.text = "\((OrderReportArr.object(at: indexPath.row - 4) as AnyObject).value(forKey: "total")!)"
                    cell.viewShadowOrder.layer.shadowColor = UIColor.gray.cgColor
                    cell.viewShadowOrder.layer.shadowOpacity = 1
                    cell.viewShadowOrder.layer.shadowOffset = CGSize.zero
                    cell.viewShadowOrder.layer.shadowRadius = 3
                    
                    return cell
                }
            }
            else
            {
                if indexPath.row < reportInfoArr.count {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! ReportViewCell
                    
                    cell.viewContainer.backgroundColor = listColors[indexPath.row]
                    
                    cell.lblReportName.text = "\((self.reportInfoArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
                    
                    cell.lblReportAmount.text = "\(NSLocalizedString("Cost :", comment: "")) \((self.reportInfoArr.object(at: indexPath.row) as AnyObject).value(forKey: "amount")!)"
                    cell.lblReportCount.text = "\(NSLocalizedString("No. of Orders :", comment: "")) \((self.reportInfoArr.object(at: indexPath.row) as AnyObject).value(forKey: "count")!)"
                    
                    if selectedReportIndex == indexPath.row {
                        cell.imgSelect.isHidden = false
                    }else {
                        cell.imgSelect.isHidden = true
                    }
                    
                    return cell
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "noOrderReportCell") as! ReportViewCell
                    cell.viewEmpty.isHidden = false
                    return cell
                }
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
        if tableView == tblOrderReports
        {
            if OrderReportArr.count > 0
            {
                if indexPath.row < reportInfoArr.count {
                    return 100
                }else{
                    return 180
                }
            }
            else
            {
                if indexPath.row < reportInfoArr.count {
                    return 100
                }else{
                    return 300
                }
            }
           
        }
        else
        {
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == tblOrderReports
        {
            if indexPath.row < reportInfoArr.count
            {
                selectedReportIndex = indexPath.row
                self.filterId = "\((self.reportInfoArr.object(at: self.selectedReportIndex) as AnyObject).value(forKey: "id")!)"
                self.orderReportAPI(filterId: self.filterId)
            }
        }
        else
        {
            self.txtOrderStatus.text = "\((orderStatusArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
            self.orderStatusId = "\((orderStatusArr.object(at: indexPath.row) as AnyObject).value(forKey: "order_status_id")!)"
            self.popover.dismiss()
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
        view.endEditing(true)
        self.viewDatePicker.isHidden = false
        dateType = "start"
    }
    
    @IBAction func clickEndDate(_ sender: Any)
    {
        view.endEditing(true)
        self.viewDatePicker.isHidden = false
        dateType = "end"
    }
    
    @IBAction func clickDeliveryDate(_ sender: Any)
    {
        view.endEditing(true)
        self.viewDatePicker.isHidden = false
        dateType = "delivery"
    }
    
    @IBAction func clickDateDone(_ sender: Any)
    {
        view.endEditing(true)
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-d"
        
        let todaysDate = dateFormatterGet.string(from: datePicker.date)
        
        if dateType == "start"
        {
            self.txtStartDate.text = todaysDate
        }
        else if dateType == "end"
        {
            self.txtEndDate.text = todaysDate
        }
        else
        {
            self.txtDeliveryDate.text = todaysDate
        }
        self.viewDatePicker.isHidden = true
    }
    
    @IBAction func clickDateCancel(_ sender: Any)
    {
        self.viewDatePicker.isHidden = true
    }
    
    @IBAction func clickOrderStatus(_ sender: Any)
    {
        view.endEditing(true)
        let tableViewStatus = UITableView(frame: CGRect(x: self.txtOrderId.frame.origin.x, y: 0, width: self.txtOrderId.frame.size.width, height: CGFloat(orderStatusArr.count * 45)))
        
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
        self.popover.show(tableViewStatus, fromView: self.txtOrderStatus)
    }
    
    @IBAction func clickFilterDone(_ sender: Any)
    {
        view.endEditing(true)
        SharedManager.showHUD(viewController: self)
        
        //let urlStr = "\(ConfigUrl.baseUrl)store/report/orders&filter_order_id=\(self.txtOrderId.text!)&filter_customer=\(self.txtCustomer.text!)&filter_start_date=\(self.txtStartDate.text!)&filter_end_date=\(self.txtEndDate.text!)&filter_order_status=\(orderStatusId)&filter_total=\(self.txtOrderAmount.text!)&filter_date_delivery=\(self.txtDeliveryDate.text!)&filter_payment_method=cod&page=1&limit=6"
        var urlStr = "\(ConfigUrl.baseUrl)store/report/orders"
        if self.txtOrderId.hasText{
            urlStr = urlStr + "&filter_order_id=\(self.txtOrderId.text!)"
        }
        if self.txtCustomer.hasText{
            urlStr = urlStr + "&filter_customer=\(self.txtCustomer.text!)"
        }
        if self.txtStartDate.hasText{
            urlStr = urlStr + "&filter_start_date=\(self.txtStartDate.text!)"
        }
        if self.txtEndDate.hasText{
            urlStr = urlStr + "&filter_end_date=\(self.txtEndDate.text!)"
        }
        if self.txtOrderStatus.hasText{
            urlStr = urlStr + "&filter_order_status=\(orderStatusId)"
        }
        if self.txtOrderAmount.hasText{
            urlStr = urlStr + "&filter_total=\(self.txtOrderAmount.text!)"
        }
        if self.txtDeliveryDate.hasText{
            urlStr = urlStr +  "&filter_date_delivery=\(self.txtDeliveryDate.text!)"
        }
        page = 1
        urlStr = urlStr + "&page=\(page)&limit=\(limit)&language_id=\(languageID)&language_code=\(languageCode)"
        
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
                            self.OrderReportArr = (result.value(forKey: "orders") as! NSArray).mutableCopy() as! NSMutableArray
                            if self.OrderReportArr.count == 0
                            {
                                let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Order report list is empty", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
                                    self.navigationController?.popViewController(animated: true)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                            self.viewBlur.isHidden = true
                            self.viewFilter.isHidden = true
                            self.viewDatePicker.isHidden = true
                            self.lblTotalOrders.text = "\(NSLocalizedString("No. of Orders :", comment: "")) \(result.value(forKey: "total")!)"
                            self.lblTotalAmount.text = "\(NSLocalizedString("Cost :", comment: "")) \(result.value(forKey: "total_order_amount")!)"
                            self.lblTodayCost.text = "\(NSLocalizedString("Cost :", comment: "")) \(result.value(forKey: "today_sale")!)"
                            self.lblTodayOrders.text = "\(NSLocalizedString("No. of Orders :", comment: "")) \(result.value(forKey: "today_total")!)"
                            self.lblWeekCost.text = "\(NSLocalizedString("Cost :", comment: "")) \(result.value(forKey: "weekly_sale")!)"
                            self.lblWeekOrders.text = "\(NSLocalizedString("No. of Orders :", comment: "")) \(result.value(forKey: "weekly_total")!)"
                            self.lblMonthCost.text = "\(NSLocalizedString("Cost :", comment: "")) \(result.value(forKey: "monthly_sale")!)"
                            self.lblMonthOrders.text = "\(NSLocalizedString("No. of Orders :", comment: "")) \(result.value(forKey: "monthly_total")!)"
                            
                            let total = "\(result.value(forKey: "total")!)"
                            
                            self.pageCount = Double(Int(total)!/Int(self.limit)!)
                            
                            self.tblOrderReports.reloadData()
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
        view.endEditing(true)
        self.viewBlur.isHidden = true
        self.viewFilter.isHidden = true
        self.viewDatePicker.isHidden = true
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
