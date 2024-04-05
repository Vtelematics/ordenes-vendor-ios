//
//  CouponReportVc.swift
//  GroceryStore
//
//  Created by Adyas Infotech on 10/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import Alamofire

class CouponReportVc: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblCouponReports: UITableView!
    @IBOutlet weak var viewBlur: UIView!
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var txtStartDate: UITextField!
    @IBOutlet weak var txtEndDate: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var viewDatePicker: UIView!
    
    var couponReportArr = NSMutableArray()
    var dateType = ""
    
    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "10"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Coupon Reports", comment: "")
        
        self.viewBlur.isHidden = true
        self.viewFilter.isHidden = true
        self.viewDatePicker.isHidden = true
        
        couponReportAPI()
        if #available(iOS 13.4, *) {
            datePicker?.preferredDatePickerStyle = .wheels
        }
    }
    

    func couponReportAPI()
    {
        SharedManager.showHUD(viewController: self)
        page = 1
        let urlStr = "\(ConfigUrl.baseUrl)store/report/coupons&page=\(page)&limit=\(limit)"
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
                            self.couponReportArr = (result.value(forKey: "coupons") as! NSArray).mutableCopy() as! NSMutableArray
                            if self.couponReportArr.count == 0
                            {
                                let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Coupon report list is empty", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
                                    self.navigationController?.popViewController(animated: true)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                            let total = "\(result.value(forKey: "total")!)"
                            
                            self.pageCount = Double(Int(total)!/Int(self.limit)!)
                            
                            self.tblCouponReports.reloadData()
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
            
            
            let urlStr = "\(ConfigUrl.baseUrl)store/report/coupons&filter_date_start=\(self.txtStartDate.text!)&filter_date_end=\(self.txtEndDate.text!)&page=\(page)&limit=\(limit)"
            
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
                                let array = (result.value(forKey: "coupons") as! NSArray).mutableCopy() as! NSMutableArray
                                self.couponReportArr.addObjects(from: array as! [Any])
                                self.tblCouponReports.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == tblCouponReports
        {
            return couponReportArr.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == tblCouponReports
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "couponCell") as! ReportViewCell
            
            cell.lblCouponName.text = ":  \((couponReportArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
            cell.lblCouponCode.text = ":  \((couponReportArr.object(at: indexPath.row) as AnyObject).value(forKey: "code")!)"
            cell.lblCouponOrders.text = ":  \((couponReportArr.object(at: indexPath.row) as AnyObject).value(forKey: "orders")!)"
            cell.lblCouponTotal.text = ":  \((couponReportArr.object(at: indexPath.row) as AnyObject).value(forKey: "total")!)"
            
            cell.viewShadowCoupon.layer.shadowColor = UIColor.gray.cgColor
            cell.viewShadowCoupon.layer.shadowOpacity = 1
            cell.viewShadowCoupon.layer.shadowOffset = CGSize.zero
            cell.viewShadowCoupon.layer.shadowRadius = 3
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderReportCell") as! ReportViewCell
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == tblCouponReports
        {
            return 130
        }
        else
        {
            return 0
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
    
    @IBAction func clickFilterDone(_ sender: Any)
    {
        SharedManager.showHUD(viewController: self)
        page = 1
        let urlStr = "\(ConfigUrl.baseUrl)store/report/coupons&filter_date_start=\(self.txtStartDate.text!)&filter_date_end=\(self.txtEndDate.text!)&page=\(page)&limit=\(limit)"
        
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
                            self.couponReportArr = (result.value(forKey: "coupons") as! NSArray).mutableCopy() as! NSMutableArray
                            if self.couponReportArr.count == 0
                            {
                                let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Coupon report list is empty", comment: ""), preferredStyle: UIAlertController.Style.alert)
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
                            
                            self.tblCouponReports.reloadData()
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
