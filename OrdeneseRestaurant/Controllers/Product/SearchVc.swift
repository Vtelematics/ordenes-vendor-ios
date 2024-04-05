//
//  SearchVc.swift
//  OrdeneseRestaurant
//
//  Created by Exlcart Solutions on 20/09/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import UIKit
import Alamofire

class SearchVc: UIViewController {
    
    @IBOutlet weak var tblSearchList: UITableView!
    @IBOutlet weak var myViewSearchContainer: UIView!
    @IBOutlet weak var myViewSearchBox: UIView!
    @IBOutlet weak var myViewSearchClear: UIView!
    @IBOutlet weak var myTxtSearch: UITextField!
    
    var searchListArr = NSMutableArray()
    
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "15"
    var productId = ""
    var isScrolledOnce : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.myTxtSearch.becomeFirstResponder()
        self.title = NSLocalizedString("Search", comment: "")
        self.myViewSearchBox.layer.cornerRadius = 8
        self.myViewSearchBox.layer.borderColor = UIColor.lightGray.cgColor
        self.myViewSearchBox.layer.borderWidth = 0.8
        self.myTxtSearch.textAlignment = isRTLenabled == true ? .right : .left
    }
    
    @objc func getSearchApi(searchTextField: UITextField)
    {
        page = 1
        let params = [
            "page_per_unit" : limit,
            "page" : page,
            "search" : searchTextField.text!
            
        ] as [String : Any]
        
        let urlStr = "\(ConfigUrl.baseUrl)product-search"
        print(urlStr)
        print(storeIDStr)
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
                            let result = responseObject.result.value! as AnyObject
                            self.searchListArr = (result.value(forKey: "product") as! NSArray).mutableCopy() as! NSMutableArray
                            let total = "\(String(describing: result.value(forKey: "total")!))"
                            self.pageCount = Double(Int(total)!/Int(self.limit)!)
                            self.tblSearchList.reloadData()
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
            SharedManager.dismissHUD(viewController: self)
        }
        else
        {
            SharedManager.showAlertWithMessage(title: "Sorry", alertMessage: "The Internet connection appears to be offline", viewController: self)
        }
    }
    
    func updateProductStatus(productId : String)
    {
        let params = ["product_id" : productId
            ] as [String : Any]
        
        let urlStr = "\(ConfigUrl.baseUrl)product/status-update"
        
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
        
        let setTemp: [String : Any] = params as [String : Any]
        
        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
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
                    print(result)
                    if let status = (responseObject.result.value! as AnyObject).value(forKeyPath: "success.status")
                    {
                        if "\(status)" == "200" {
                            self.getSearchApi(searchTextField: self.myTxtSearch)
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
            
            let params = [
                "page_per_unit" : limit,
                "page" : page,
                "search" : self.myTxtSearch.text!
                
            ] as [String : Any]
            
            let urlStr = "\(ConfigUrl.baseUrl)product-search"
            print(urlStr)
            print(storeIDStr)
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
                Alamofire.request(request).responseJSON
                { (responseObject) -> Void in
                    
                    SharedManager.dismissHUD(viewController: self)
                    if responseObject.result.isSuccess
                    {
                        SharedManager.dismissHUD(viewController: self)
                        let result = responseObject.result.value! as AnyObject
                        print(result)
                        if let status = (responseObject.result.value! as AnyObject).value(forKeyPath: "success.status")
                        {
                            if "\(status)" == "200" {
                                let result = responseObject.result.value! as AnyObject
                                let array = (result.value(forKey: "product") as! NSArray).mutableCopy() as! NSMutableArray
                                self.searchListArr.addObjects(from: array as! [Any])
                                self.tblSearchList.reloadData()
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
            SharedManager.dismissHUD(viewController: self)
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
    
    @objc func changeProductStatus(_ sender : UIButton)
    {
        self.productId = "\((searchListArr.object(at: sender.tag) as AnyObject).value(forKey: "product_item_id")!)"
        updateProductStatus(productId: self.productId)
    }
    
    @IBAction func clickClearSearch(_ sender : Any){
        self.myTxtSearch.text = ""
        self.myViewSearchClear.isHidden = true
        self.searchListArr = []
        self.tblSearchList.reloadData()
    }
}

extension SearchVc: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchListArr.count > 0 {
            return searchListArr.count
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchListArr.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! ProductTblCell
            
            cell.lblSearchPdtName.text = "\((searchListArr.object(at: indexPath.row) as AnyObject).value(forKey: "item_name")!)"
            cell.lblSearchPdtPrice.text = "\((searchListArr.object(at: indexPath.row) as AnyObject).value(forKey: "price")!)"
            
            let productStatus = "\((searchListArr.object(at: indexPath.row) as AnyObject).value(forKey: "status")!)"
            
            if productStatus == "1" {
                cell.switchBtnSearch.isOn = true
            }else {
                cell.switchBtnSearch.isOn = false
            }
            
            cell.viewShadow.layer.shadowColor = UIColor.gray.cgColor
            cell.viewShadow.layer.shadowOpacity = 1
            cell.viewShadow.layer.shadowOffset = CGSize.zero
            cell.viewShadow.layer.shadowRadius = 3
            
            cell.switchBtnSearch.addTarget(self, action: #selector(changeProductStatus(_:)), for: UIControl.Event.touchUpInside)
            cell.switchBtnSearch.tag = (indexPath as NSIndexPath).row
            
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noResultCell") as! ProductTblCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchListArr.count > 0 {
            return 85
        }else {
            return 85
        }
    }
}

extension SearchVc : UITextFieldDelegate{
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            print(txtAfterUpdate)
            self.myViewSearchClear.isHidden = txtAfterUpdate == "" ? true : false
            if txtAfterUpdate.count > 2{
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.getSearchApi), object: textField)
                self.perform(#selector(self.getSearchApi), with: textField, afterDelay: 0.5)
            }else if txtAfterUpdate == ""{
                self.searchListArr = []
                self.tblSearchList.reloadData()
            }
        }
        return true
    }
}
