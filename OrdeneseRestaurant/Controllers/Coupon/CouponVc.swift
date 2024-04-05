//
//  CouponVc.swift
//  Foodesoft Vendor
//
//  Created by Adyas Infotech on 04/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import Alamofire

class CouponVc: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblCouponList: UITableView!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var viewContain: UIView!
    @IBOutlet weak var viewEdit: UIView!
    @IBOutlet weak var viewEdit1: UIView!
    @IBOutlet weak var viewEdit2: UIView!
    @IBOutlet weak var viewBlur: UIView!
    @IBOutlet weak var scrollViewEdit: UIScrollView!
    
    @IBOutlet weak var txtCouponName: UITextField!
    @IBOutlet weak var txtCouponCode: UITextField!
    @IBOutlet weak var txtCouponType: UITextField!
    @IBOutlet weak var txtDiscount: UITextField!
    @IBOutlet weak var txtTotalAmount: UITextField!
    @IBOutlet weak var lblCouponProducts: UILabel!
    @IBOutlet weak var lblLine: UILabel!
    @IBOutlet weak var btnProduct: UIButton!
    @IBOutlet weak var txtStartDate: UITextField!
    @IBOutlet weak var txtEndDate: UITextField!
    @IBOutlet weak var txtUsesPerCoupon: UITextField!
    @IBOutlet weak var txtUsesPerCustomer: UITextField!
    @IBOutlet weak var txtCouponStatus: UITextField!
    @IBOutlet weak var viewDatePicker: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var viewProducts: UIView!
    @IBOutlet weak var tblProducts: UITableView!
    @IBOutlet weak var viewBlurProducts: UIView!
    
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    var couponArr = NSMutableArray()
    var productArr = NSMutableArray()
    var selectedValuesArrProduct = NSMutableArray()
    var selectedValuesArrProductTemp = NSMutableArray()
    
    var dateType = ""
    var date = ""
    var popoverType = ""
    
    var typeStr: String = "new"
    var couponID = ""
    
    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "10"
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.auto),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Coupon", comment: "")
        self.viewProducts.isHidden = true
        self.viewBlurProducts.isHidden = true
        self.viewBlur.isHidden = true
        self.scrollViewEdit.isHidden = true
        
        UserDefaults.standard.removeObject(forKey: "COUPON_PRODUCTS")
        
        viewShadow.layer.shadowColor = UIColor.gray.cgColor
        viewShadow.layer.shadowOpacity = 1
        viewShadow.layer.shadowOffset = CGSize.zero
        viewShadow.layer.shadowRadius = 3
        
        self.viewProducts.layer.cornerRadius = 3
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let todaysDate = dateFormatterGet.string(from: Date())
        self.txtStartDate.text = todaysDate
        self.txtCouponName.textAlignment = isRTLenabled == true ? .right : .left
        self.txtCouponCode.textAlignment = isRTLenabled == true ? .right : .left
        self.txtCouponType.textAlignment = isRTLenabled == true ? .right : .left
        self.txtDiscount.textAlignment = isRTLenabled == true ? .right : .left
        self.txtTotalAmount.textAlignment = isRTLenabled == true ? .right : .left
        self.txtEndDate.textAlignment = isRTLenabled == true ? .right : .left
        self.txtStartDate.textAlignment = isRTLenabled == true ? .right : .left
        self.txtUsesPerCoupon.textAlignment = isRTLenabled == true ? .right : .left
        self.txtUsesPerCustomer.textAlignment = isRTLenabled == true ? .right : .left
        self.txtCouponStatus.textAlignment = isRTLenabled == true ? .right : .left
        couponListAPI()
        if #available(iOS 13.4, *) {
            datePicker?.preferredDatePickerStyle = .wheels
        }
    }
    
    func couponListAPI()
    {
        page = 1
        let urlStr = "\(ConfigUrl.baseUrl)store/coupon&page=\(page)&limit=\(limit)"
        
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
        
        if Connectivity.isConnectedToInternet()
        {
            SharedManager.showHUD(viewController: self)
            
            Alamofire.request(request).responseJSON
                { (responseObject) -> Void in
                    
                    if responseObject.result.isSuccess
                    {
                        SharedManager.dismissHUD(viewController: self)
                        
                        if "\(String(describing: responseObject.response!.statusCode))" == "200"
                        {
                            let result = responseObject.result.value! as AnyObject
                            self.couponArr = (result.value(forKey: "coupons") as! NSArray).mutableCopy() as! NSMutableArray
                            if self.couponArr.count == 0
                            {
                                let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Coupon list is empty. Do you want add new Coupon?", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                    
                                    self.typeStr = "new"
                                    self.lblHeader.text = NSLocalizedString("Add Coupon", comment: "")
                                    self.viewBlur.isHidden = false
                                    self.scrollViewEdit.isHidden = false
                                    self.selectedValuesArrProduct.removeAllObjects()
                                    
                                    self.txtCouponName.text! = ""
                                    self.txtCouponCode.text! = ""
                                    self.txtCouponType.text! = "P"
                                    self.txtDiscount.text! = ""
                                    self.txtTotalAmount.text! = ""
                                    self.lblCouponProducts.text! = ""
                                    self.txtStartDate.text! = ""
                                    self.txtEndDate.text! = ""
                                    self.txtUsesPerCoupon.text! = ""
                                    self.txtUsesPerCustomer.text! = ""
                                    self.txtCouponStatus.text! = NSLocalizedString("Enabled", comment: "")
                                    
                                    self.frames()
                                }))
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil))
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                            let total = "\(String(describing: result.value(forKey: "total_coupons")!))"
                            self.pageCount = Double(Int(total)!/Int(self.limit)!)
                            
                            self.tblCouponList.reloadData()
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

    func couponAdd()
    {
        self.view.endEditing(true)
        
        var selectedStatus = ""
        
        if self.txtCouponStatus.text! == NSLocalizedString("Enabled", comment: "")
        {
            selectedStatus = "1"
        }
        else
        {
            selectedStatus = "0"
        }
        
        let productDict = NSMutableDictionary()
        
        if selectedValuesArrProduct.count != 0
        {
            let tempArr = NSMutableArray()
            tempArr.addObjects(from: selectedValuesArrProduct as! [Any])
            for i in 0..<tempArr.count
            {
                let str = "\(String(describing: (tempArr.object(at: i) as AnyObject).value(forKey: "product_id")!))"
                productDict.setObject(str, forKey: "\(i)" as NSCopying)
            }
        }
        
        let params = ["name" : self.txtCouponName.text!,
                      "code" : self.txtCouponCode.text!,
                      "type" : self.txtCouponType.text!,
                      "discount" : self.txtDiscount.text!,
                      "total" : self.txtTotalAmount.text!,
                      "date_start" : self.txtStartDate.text!,
                      "date_end" : self.txtEndDate.text!,
                      "uses_total" : self.txtUsesPerCoupon.text!,
                      "uses_customer" : self.txtUsesPerCustomer.text!,
                      "coupon_product" : productDict,
                      "status" : selectedStatus
            
            ] as [String : Any]
        
        let urlStr = "\(ConfigUrl.baseUrl)store/coupon/add"
        
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
        
        let setTemp: [String : Any] = params as [String : Any]
        
        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
            let jsonString = String(data: jsonData , encoding: .utf8)!
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
                        
                        self.viewBlur.isHidden = true
                        self.scrollViewEdit.isHidden = true
                        
                        SharedManager.showAlertWithMessage(title: NSLocalizedString("", comment: ""), alertMessage: NSLocalizedString("Coupon Added Successfully", comment: ""), viewController: self)
                        
                        self.couponListAPI()
                        
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
        SharedManager.dismissHUD(viewController: self)
    }
    
    func couponEdit()
    {
        self.view.endEditing(true)
        
        var selectedStatus = ""
        
        if self.txtCouponStatus.text! == NSLocalizedString("Enabled", comment: "")
        {
            selectedStatus = "1"
        }
        else
        {
            selectedStatus = "0"
        }
        
        if selectedValuesArrProduct.count != 0
        {
            
        }
        
        //Products
        let productDict = NSMutableDictionary()
        
        if selectedValuesArrProduct.count != 0
        {
            let tempArr = NSMutableArray()
            tempArr.addObjects(from: selectedValuesArrProduct as! [Any])
            //products.removeAllObjects()
            
            for i in 0..<tempArr.count
            {
                let str = "\(String(describing: (tempArr.object(at: i) as AnyObject).value(forKey: "product_id")!))"
                productDict.setObject(str, forKey: "\(i)" as NSCopying)
            }
        }
        
        let params = ["name" : self.txtCouponName.text!,
                      "code" : self.txtCouponCode.text!,
                      "coupon_id" : self.couponID,
                      "type" : self.txtCouponType.text!,
                      "discount" : self.txtDiscount.text!,
                      "total" : self.txtTotalAmount.text!,
                      "coupon_product" : productDict,
                      "date_start" : self.txtStartDate.text!,
                      "date_end" : self.txtEndDate.text!,
                      "uses_total" : self.txtUsesPerCoupon.text!,
                      "uses_customer" : self.txtUsesPerCustomer.text!,
                      "status" : selectedStatus,
                      "language_id" : languageID
            
            ] as [String : Any]
        
        let urlStr = "\(ConfigUrl.baseUrl)store/coupon/edit"
        
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
        
        let setTemp: [String : Any] = params as [String : Any]
        
        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
            let jsonString = String(data: jsonData , encoding: .utf8)!
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
                        SharedManager.showAlertWithMessage(title: "", alertMessage: NSLocalizedString("Coupon Edited Successfully", comment: ""), viewController: self)
                        self.viewBlur.isHidden = true
                        self.scrollViewEdit.isHidden = true
                        self.couponListAPI()
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
        SharedManager.dismissHUD(viewController: self)
    }
    
    func productAPI()
    {
        let urlStr = "\(ConfigUrl.baseUrl)store/coupon/products"
        
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
        
        if Connectivity.isConnectedToInternet()
        {
            SharedManager.showHUD(viewController: self)
            Alamofire.request(request).responseJSON
                { (responseObject) -> Void in
                    
                    if responseObject.result.isSuccess
                    {
                        SharedManager.dismissHUD(viewController: self)
                        if "\(String(describing: responseObject.response!.statusCode))" == "200"
                        {
                            let result = responseObject.result.value! as AnyObject
                            self.productArr = (result.value(forKey: "products") as! NSArray).mutableCopy() as! NSMutableArray
                            if self.productArr.count == 0
                            {
                                SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Product list is empty", comment: ""), viewController: self)
                            }
                            
                            self.viewProducts.isHidden = false
                            self.viewBlurProducts.isHidden = false
                            self.tblProducts.reloadData()
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
    
    func checkProduct(_ productId:String) -> Bool
    {
        var isAleadyHave:Bool = false
        
        if selectedValuesArrProductTemp.count != 0
        {
            for tempDic in selectedValuesArrProductTemp
            {
                let tempCart:NSDictionary = tempDic as! NSDictionary
                
                let str1 = "\(tempCart.value(forKey: "product_id")!)"
                
                if str1 == productId
                {
                    isAleadyHave = true
                }
            }
        }
        
        return isAleadyHave
    }
    
    func frames()
    {
        if lblCouponProducts.text != ""
        {
            self.lblCouponProducts.sizeToFit()
            self.lblCouponProducts.frame.size.width = self.txtCouponType.frame.size.width
            let height = self.lblCouponProducts.frame.size.height
            if height < 40
            {
                self.lblCouponProducts.frame.size.height = self.txtTotalAmount.frame.size.height
            }
        }
        else
        {
            self.lblCouponProducts.frame.size.height = self.txtTotalAmount.frame.size.height
        }
        self.lblCouponProducts.translatesAutoresizingMaskIntoConstraints = true
        self.lblLine.frame.origin.y = self.lblCouponProducts.frame.origin.y + self.lblCouponProducts.frame.size.height + 5
        self.lblLine.translatesAutoresizingMaskIntoConstraints = true
        self.btnProduct.frame.size.height = self.lblCouponProducts.frame.size.height
        self.btnProduct.translatesAutoresizingMaskIntoConstraints = true
        self.viewEdit1.frame.size.height = self.lblLine.frame.origin.y + 10
        self.viewEdit2.frame.origin.y = self.viewEdit1.frame.origin.y + self.viewEdit1.frame.size.height
        self.viewEdit1.translatesAutoresizingMaskIntoConstraints = true
        self.viewEdit2.translatesAutoresizingMaskIntoConstraints = true
        self.viewBlurProducts.frame.size.height = self.viewEdit2.frame.origin.y + self.viewEdit2.frame.size.height - 2
        self.viewBlurProducts.translatesAutoresizingMaskIntoConstraints = true
        self.btnSave.frame.origin.y = self.viewEdit2.frame.origin.y + self.viewEdit2.frame.size.height + 10
        self.btnCancel.frame.origin.y = self.viewEdit2.frame.origin.y + self.viewEdit2.frame.size.height + 10
        self.btnSave.translatesAutoresizingMaskIntoConstraints = true
        self.btnCancel.translatesAutoresizingMaskIntoConstraints = true
        self.viewContain.frame.size.height = self.btnSave.frame.origin.y + self.btnSave.frame.size.height + 10
        self.viewContain.translatesAutoresizingMaskIntoConstraints = true
        self.viewShadow.frame.size.height = self.viewEdit2.frame.origin.y + self.viewEdit2.frame.size.height - 6
        self.viewShadow.translatesAutoresizingMaskIntoConstraints = true
        self.scrollViewEdit.contentSize = CGSize(width: self.view.bounds.width - 39, height: self.viewContain.frame.size.height)
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
            
            
            
            let urlStr = "\(ConfigUrl.baseUrl)store/coupon&page=\(page)&limit=\(limit)"
            
            let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
            var request = URLRequest(url: URL(string: setFinalURl)!)
            request.httpMethod = HTTPMethod.get.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
            
            if Connectivity.isConnectedToInternet()
            {
                SharedManager.showHUD(viewController: self)
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
                                
                                self.couponArr.addObjects(from: array as! [Any])
                                
                                self.tblCouponList.reloadData()
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
        if tableView == tblCouponList
        {
            return couponArr.count
        }
        else if tableView == tblProducts
        {
            return productArr.count
        }
        else
        {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == tblCouponList
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "couponCell") as! OrderTblCell
            
            cell.lblCouponName.text = "\((couponArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
            cell.lblCouponCode.text = "\((couponArr.object(at: indexPath.row) as AnyObject).value(forKey: "code")!)"
            cell.lblCouponDiscount.text = "\((couponArr.object(at: indexPath.row) as AnyObject).value(forKey: "discount")!)"
            cell.lblCouponStatus.text = "\((couponArr.object(at: indexPath.row) as AnyObject).value(forKey: "status")!)"
            
            cell.btnEditCoupon.addTarget(self, action: #selector(editCoupon(_:)), for: UIControl.Event.touchUpInside)
             
             cell.btnEditCoupon.tag = (indexPath as NSIndexPath).row
             
             cell.btnDeleteCoupon.addTarget(self, action: #selector(deleteCoupon(_:)), for: UIControl.Event.touchUpInside)
             cell.btnDeleteCoupon.tag = (indexPath as NSIndexPath).row
             
             cell.imgEditCoupon.image = UIImage (named: "ic_edit")
             cell.imgEditCoupon.image = cell.imgEditCoupon.image!.withRenderingMode(.alwaysTemplate)
             cell.imgEditCoupon.tintColor = UIColor.lightGray
             
             cell.imgDeleteCoupon.image = UIImage (named: "ic_delete")
             cell.imgDeleteCoupon.image = cell.imgDeleteCoupon.image!.withRenderingMode(.alwaysTemplate)
             cell.imgDeleteCoupon.tintColor = UIColor.lightGray
            
            cell.viewShadowCoupon.layer.shadowColor = UIColor.gray.cgColor
            cell.viewShadowCoupon.layer.shadowOpacity = 1
            cell.viewShadowCoupon.layer.shadowOffset = CGSize.zero
            cell.viewShadowCoupon.layer.shadowRadius = 3
            
            return cell
        }
        else if tableView == tblProducts
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCell") as! OrderTblCell
            
            cell.lblProductName.text = "\((productArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
            
            let str2 = "\((productArr.object(at: indexPath.row) as AnyObject).value(forKey: "product_id")!)"
            
            if self.checkProduct(str2) == true
            {
                cell.imgCheckBox.image = UIImage(named: "ic_checkbox")
            }
            else
            {
                cell.imgCheckBox.image = UIImage(named: "ic_uncheckbox")
            }
            
            return cell
        }
        else
        {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            
            var lable1 = ""
            var lable2 = ""
            
            if popoverType == "coupontype"
            {
                lable1 = "P"
                lable2 = "F"
            }
            else
            {
                lable1 = "Enabled"
                lable2 = "Disabled"
            }
            if indexPath.row == 0
            {
                cell.textLabel?.text = lable1
            }
            else
            {
                cell.textLabel?.text = lable2
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == tblCouponList
        {
            return 133
        }
        else if tableView == tblProducts
        {
            return 45
        }
        else
        {
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == tblCouponList
        {
            
        }
        else if tableView == tblProducts
        {
            let selectedId = "\((productArr.object(at: indexPath.row) as AnyObject).value(forKey: "product_id")!)"
            let isHave:Bool = self.checkProduct(selectedId)
            
            if isHave == true
            {
                let tempArr = NSMutableArray()
                tempArr.addObjects(from: selectedValuesArrProductTemp as! [Any])
                
                if isHave
                {
                    for i in 0..<tempArr.count
                    {
                        let str1 = "\((tempArr[i] as AnyObject).value(forKey: "product_id")!)"
                        
                        if str1 == selectedId
                        {
                            selectedValuesArrProductTemp.removeObject(at: i)
                        }
                    }
                }
            }
            else
            {
                let currentArr : NSDictionary  = productArr.object(at: indexPath.row) as! NSDictionary
                selectedValuesArrProductTemp.add(currentArr)
            }
            self.tblProducts.reloadData()
        }
        else
        {
            if popoverType == "coupontype"
            {
                if indexPath.row == 0
                {
                    self.txtCouponType.text = "P"
                }
                else
                {
                    self.txtCouponType.text = "F"
                }
            }
            else
            {
                if indexPath.row == 0
                {
                    self.txtCouponStatus.text = NSLocalizedString("Enabled", comment: "")
                }
                else
                {
                    self.txtCouponStatus.text = NSLocalizedString("Disabled", comment: "")
                }
            }
            self.popover.dismiss()
        }
    }
    
    @objc func editCoupon(_ sender : UIButton)
    {
        
        self.couponID = "\((couponArr.object(at: sender.tag) as AnyObject).value(forKey: "coupon_id")!)"
        
        let urlStr = "\(ConfigUrl.baseUrl)store/coupon/info&coupon_id=\(couponID)"
        
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
        
        if Connectivity.isConnectedToInternet()
        {
            SharedManager.showHUD(viewController: self)
            
            Alamofire.request(request).responseJSON
                { (responseObject) -> Void in
                    
                    if responseObject.result.isSuccess
                    {
                        SharedManager.dismissHUD(viewController: self)
                        
                        if "\(String(describing: responseObject.response!.statusCode))" == "200"
                        {
                            let result = responseObject.result.value as! NSDictionary
                            self.txtCouponName.text! = "\(result.value(forKeyPath: "coupon_info.name")!)"
                            self.txtCouponCode.text! = "\(result.value(forKeyPath: "coupon_info.code")!)"
                            self.txtCouponType.text! = "\(result.value(forKeyPath: "coupon_info.type")!)"
                            self.txtDiscount.text! = "\(result.value(forKeyPath: "coupon_info.discount")!)"
                            self.txtTotalAmount.text! = "\(result.value(forKeyPath: "coupon_info.total")!)"
                            
                            self.selectedValuesArrProduct = (result.value(forKey: "coupon_product") as! NSArray).mutableCopy() as! NSMutableArray
                            
                            var product = String()
                            
                            if self.selectedValuesArrProduct.count != 0
                            {
                                for i in 0..<self.selectedValuesArrProduct.count
                                {
                                    product = product + "\((self.selectedValuesArrProduct.object(at: i) as AnyObject).value(forKey: "name")!),"
                                }
                                product.removeLast()
                            }
                            self.lblCouponProducts.text = product
                            
                            self.txtStartDate.text! = "\(result.value(forKeyPath: "coupon_info.date_added")!)"
                            self.txtEndDate.text! = "\(result.value(forKeyPath: "coupon_info.date_end")!)"
                            self.txtUsesPerCoupon.text! = "\(result.value(forKeyPath: "coupon_info.uses_total")!)"
                            self.txtUsesPerCustomer.text! = "\(result.value(forKeyPath: "coupon_info.uses_customer")!)"
                            
                            let selectedStatus = "\(result.value(forKeyPath: "coupon_info.status")!)"
                            
                            if selectedStatus == "1"
                            {
                                self.txtCouponStatus.text! = NSLocalizedString("Enabled", comment: "")
                            }
                            else
                            {
                                self.txtCouponStatus.text! = NSLocalizedString("Disabled", comment: "")
                            }
                            
                            self.typeStr = "edit"
                            self.lblHeader.text = NSLocalizedString("Edit Coupon", comment: "")
                            
                            self.viewBlur.isHidden = false
                            self.scrollViewEdit.isHidden = false
                            self.frames()
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
        SharedManager.dismissHUD(viewController: self)
    }
    
    @objc func deleteCoupon(_ sender : UIButton)
    {
        let alert = UIAlertController(title: NSLocalizedString("Are you sure?", comment: ""), message: NSLocalizedString("Do you want to remove this Coupon", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            self.couponID = "\((self.couponArr.object(at: sender.tag) as AnyObject).value(forKey: "coupon_id")!)"
            
            let urlStr = "\(ConfigUrl.baseUrl)store/coupon/delete&coupon_id=\(self.couponID)"
            
            let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
            var request = URLRequest(url: URL(string: setFinalURl)!)
            request.httpMethod = HTTPMethod.get.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
            
            if Connectivity.isConnectedToInternet()
            {
                SharedManager.showHUD(viewController: self)
                Alamofire.request(request).responseJSON
                    { (responseObject) -> Void in
                        
                        if responseObject.result.isSuccess
                        {
                            SharedManager.dismissHUD(viewController: self)
                            
                            if "\(String(describing: responseObject.response!.statusCode))" == "200"
                            {
                                let result = responseObject.result.value! as AnyObject
                                SharedManager.showAlertWithMessage(title: "", alertMessage: NSLocalizedString("Successfully Deleted", comment: ""), viewController: self)
                                self.couponListAPI()
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
            
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: Button Action
    
    @IBAction func clickAddNew(_ sender: Any)
    {
        self.typeStr = "new"
        self.lblHeader.text =  NSLocalizedString("Add Coupon", comment: "")
        self.viewBlur.isHidden = false
        self.scrollViewEdit.isHidden = false
        self.selectedValuesArrProduct.removeAllObjects()
        
        self.txtCouponName.text! = ""
        self.txtCouponCode.text! = ""
        self.txtCouponType.text! = "P"
        self.txtDiscount.text! = ""
        self.txtTotalAmount.text! = ""
        self.lblCouponProducts.text! = ""
        self.txtStartDate.text! = ""
        self.txtEndDate.text! = ""
        self.txtUsesPerCoupon.text! = ""
        self.txtUsesPerCustomer.text! = ""
        self.txtCouponStatus.text! = NSLocalizedString("Enabled", comment: "")
        
        frames()
    }
    
    @IBAction func clickCouponType(_ sender: Any)
    {
        self.view.endEditing(true)
        popoverType = "coupontype"
        let tableView = UITableView(frame: CGRect(x: self.txtCouponType.frame.origin.x, y: 0, width: self.txtCouponName.frame.size.width, height: 2*45))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.reloadData()
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
        self.popover.show(tableView, fromView: self.txtCouponType)
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
    
    @IBAction func clickDateDone(_ sender: Any)
    {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
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
    
    @IBAction func clickStatus(_ sender: Any)
    {
        self.view.endEditing(true)
        popoverType = "couponstatus"
        let tableViewStatus = UITableView(frame: CGRect(x: self.txtCouponStatus.frame.origin.x, y: 0, width: self.txtCouponName.frame.size.width, height: 2*45))
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
        self.popover.show(tableViewStatus, fromView: self.txtCouponStatus)
    }
    
    @IBAction func clickSave(_ sender: Any)
    {
        view.endEditing(true)
        if self.txtCouponName.text == ""
        {
            SharedManager.showAlertWithMessage(title: NSLocalizedString("", comment: "Sorry"), alertMessage: NSLocalizedString("Please Enter Coupon Name", comment: ""), viewController: self)
        }
        else if self.txtCouponCode.text == ""
        {
            SharedManager.showAlertWithMessage(title: NSLocalizedString("", comment: "Sorry"), alertMessage: NSLocalizedString("Please Enter Coupon code", comment: ""), viewController: self)
        }
        else
        {
            if typeStr == "new"
            {
                self.couponAdd()
            }
            else
            {
                self.couponEdit()
            }
        }
    }
    
    @IBAction func clickCancelEdit(_ sender: Any)
    {
        view.endEditing(true)
        self.viewBlur.isHidden = true
        self.scrollViewEdit.isHidden = true
        
        self.txtCouponName.text = ""
        self.txtCouponCode.text = ""
        self.txtCouponType.text = ""
        self.txtDiscount.text = ""
        self.txtTotalAmount.text = ""
        self.txtStartDate.text = ""
        self.txtEndDate.text = ""
        self.txtUsesPerCoupon.text = ""
        self.txtUsesPerCustomer.text = ""
        self.txtCouponStatus.text = ""
        
        self.selectedValuesArrProduct.removeAllObjects()
    }
    
    @IBAction func clickProducts(_ sender: Any)
    {
        self.view.endEditing(true)
        if productArr.count != 0
        {
            self.viewProducts.isHidden = false
            self.viewBlurProducts.isHidden = false
            self.selectedValuesArrProductTemp = []
            self.selectedValuesArrProductTemp.addObjects(from: selectedValuesArrProduct as! [Any])
            self.tblProducts.reloadData()
        }
        else
        {
            self.selectedValuesArrProductTemp = []
            self.selectedValuesArrProductTemp.addObjects(from: selectedValuesArrProduct as! [Any])
            productAPI()
        }
    }
    
    @IBAction func clickSaveProducts(_ sender: Any)
    {
        var productStr = String()
        
        if selectedValuesArrProductTemp.count != 0
        {
            for i in 0..<selectedValuesArrProductTemp.count
            {
                productStr = productStr + "\(String(describing: (selectedValuesArrProductTemp.object(at: i) as AnyObject).value(forKey: "name")!)), "
            }
            productStr.removeLast(2)
            self.selectedValuesArrProduct = []
            self.selectedValuesArrProduct.addObjects(from: selectedValuesArrProductTemp as! [Any])
            self.lblCouponProducts.text = productStr
            self.viewBlurProducts.isHidden = true
            self.viewProducts.isHidden = true
            
            frames()
        }
        else
        {
            self.lblCouponProducts.text = ""
            self.selectedValuesArrProduct.removeAllObjects()
            self.viewBlurProducts.isHidden = true
            self.viewProducts.isHidden = true
            frames()
        }
        
    }
    
    @IBAction func clickCancelProducts(_ sender: Any)
    {
        self.viewProducts.isHidden = true
        self.viewBlurProducts.isHidden = true
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
