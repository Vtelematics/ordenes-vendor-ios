//
//  OptionVc.swift
//  GroceryStore
//
//  Created by Adyas Infotech on 17/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import Alamofire

class OptionVc: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tblOption: UITableView!
    @IBOutlet weak var tblOptionValue: UITableView!
    
    @IBOutlet weak var viewSorting: UIView!
    @IBOutlet weak var imgSort: UIImageView!
    @IBOutlet weak var mainSortView: UIView!
    @IBOutlet weak var viewBlurSort: UIView!
    
    @IBOutlet weak var viewFiltering: UIView!
    @IBOutlet weak var imgFilter: UIImageView!
    @IBOutlet weak var mainFilterView: UIView!
    @IBOutlet weak var txtFilter: UITextField!
    
    @IBOutlet weak var viewLanguage: UIView!
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var lblHeader: UILabel!
    
    //Option Add
    @IBOutlet weak var viewOption: UIView!
    @IBOutlet weak var viewOptionBlur: UIView!
    @IBOutlet weak var txtOptionName: UITextField!
    @IBOutlet weak var txtType: UITextField!
    @IBOutlet weak var txtSortOrder: UITextField!
    
    //Option Value
    @IBOutlet weak var viewOptionValue: UIView!
    @IBOutlet weak var viewOptionValueBlur: UIView!
    @IBOutlet weak var txtOptionValueName: UITextField!
    @IBOutlet weak var txtOptionValueSortOrder: UITextField!
    @IBOutlet weak var btnOptionValueSave: UIButton!
    
    var optionArr = NSMutableArray()
    
    var typeTbl = ""
    var isCompleted = true
    var isEdit = false
    var optionId = ""
    var selectedLanguageId = ""
    var optionType = ""
    var optionValueType = ""
    var lineCount = Int()
    var sortKey = ""
    var orderKey = ""
    var optionValueArr = NSMutableArray()
    var optionHasValue : Bool = false
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

        self.title = NSLocalizedString("Options", comment: "")
        
        self.txtOptionName.delegate = self
        self.txtSortOrder.delegate = self
        self.txtType.delegate = self
        
        viewSorting.layer.borderColor = positiveBtnColor.cgColor
        viewFiltering.layer.borderColor = positiveBtnColor.cgColor
        
        imgSort.image = UIImage (named: "ic_sort")
        imgSort.image = imgSort.image!.withRenderingMode(.alwaysTemplate)
        imgSort.tintColor = positiveBtnColor
        
        imgFilter.image = UIImage (named: "ic_filter")
        imgFilter.image = imgFilter.image!.withRenderingMode(.alwaysTemplate)
        imgFilter.tintColor = positiveBtnColor
        
        self.txtOptionValueName.textAlignment = isRTLenabled == true ? .right : .left
        self.txtOptionValueSortOrder.textAlignment = isRTLenabled == true ? .right : .left
        self.txtOptionName.textAlignment = isRTLenabled == true ? .right : .left
        self.txtType.textAlignment = isRTLenabled == true ? .right : .left
        self.txtSortOrder.textAlignment = isRTLenabled == true ? .right : .left
        self.txtFilter.textAlignment = isRTLenabled == true ? .right : .left
        self.viewBlurSort.isHidden = true
        self.mainSortView.isHidden = true
        self.mainFilterView.isHidden = true
        self.viewOption.isHidden = true
        self.viewOptionValueBlur.isHidden = true
        self.viewOptionValue.isHidden = true
        
        viewLanguage.layer.shadowColor = UIColor.gray.cgColor
        viewLanguage.layer.shadowOpacity = 1
        viewLanguage.layer.shadowOffset = CGSize.zero
        viewLanguage.layer.shadowRadius = 3
        self.viewLanguage.isHidden = true
        
        self.selectedLanguageId = languageID
        
        optionListingAPI()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: API
    func optionListingAPI()
    {
        page = 1
        let urlStr = "\(ConfigUrl.baseUrl)store/option/options&sort=\(sortKey)&order=\(orderKey)&page=\(page)&limit=\(limit)"
        
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
                            let result = responseObject.result.value as AnyObject
                            self.optionArr = (result.value(forKey: "options") as! NSArray).mutableCopy() as! NSMutableArray
                            
                            if self.optionArr.count == 0
                            {
                                let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Option list is empty. Do you want to add new Option?", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
                                    
                                    self.optionType = NSLocalizedString("add", comment: "")
                                    self.txtOptionName.text = ""
                                    self.txtSortOrder.text = ""
                                    self.txtType.text = NSLocalizedString("Single Selection", comment: "")
                                    self.optionValueArr.removeAllObjects()
                                    self.tblOptionValue.reloadData()
                                    self.optionId = ""
                                    self.viewOption.isHidden = false
                                    self.viewBlurSort.isHidden = false
                                    self.lblHeader.text = NSLocalizedString("Add Option", comment: "")
                                }))
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                            let total = "\(String(describing: result.value(forKey: "total")!))"
                            self.pageCount = Double(Int(total)!/Int(self.limit)!)
                            
                            self.tblOption.reloadData()
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
            SharedManager.dismissHUD(viewController: self)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
        
    }
    
    func optionAdd()
    {
        self.view.endEditing(true)
        
        var selectionType = ""
        if txtType.text == NSLocalizedString("Single Selection", comment: "")
        {
            selectionType = "radio"
        }
        else
        {
            selectionType = "checkbox"
        }
       
        let params = ["name" : self.txtOptionName.text!,
                      "type" : selectionType,
                      "sort_order" : self.txtSortOrder.text!
            
            ] as [String : Any]
        
        let urlStr = "\(ConfigUrl.baseUrl)store/option/add"
        
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
                        self.optionId = "\(result.value(forKey: "option_id")!)"
                        
                        self.optionValuesActions()
                        
                        SharedManager.showAlertWithMessage(title: NSLocalizedString("", comment: ""), alertMessage: NSLocalizedString("Option Added Successfully", comment: ""), viewController: self)
                        self.optionListingAPI()
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
    
    func optionInfoAPI()
    {
        SharedManager.showHUD(viewController: self)
        
        let urlStr = "\(ConfigUrl.baseUrl)store/option/info&option_id=\(optionId)&language_id=\(selectedLanguageId)"
        
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
                            let result = responseObject.result.value as AnyObject
                            
                            self.viewOption.isHidden = false
                            self.viewBlurSort.isHidden = false
                            self.viewLanguage.isHidden = false
                            
                            self.txtOptionName.text = "\(result.value(forKeyPath: "option_info.name")!)"
                            self.txtType.text = "\(result.value(forKeyPath: "option_info.type")!)"
                            self.txtSortOrder.text = "\(result.value(forKeyPath: "option_info.sort_order")!)"
                            self.selectedLanguageId = "\(result.value(forKeyPath: "option_info.language_id")!)"
                            self.optionId = "\(result.value(forKeyPath: "option_info.option_id")!)"
                            
                            let typeStr = "\(result.value(forKeyPath: "option_info.type")!)"
                            
                            if typeStr == "radio"
                            {
                                self.txtType.text = NSLocalizedString("Single Selection", comment: "")
                            }
                            else
                            {
                                self.txtType.text = NSLocalizedString("Multiple Selection", comment: "")
                            }
                            
                            self.selectedLanguageId = "\(result.value(forKeyPath: "option_info.language_id")!)"
                            for i in 0..<languageArr.count
                            {
                                let id = "\((languageArr.object(at: i) as AnyObject).value(forKey: "language_id")!)"
                                if id == self.selectedLanguageId
                                {
                                    self.lblLanguage.text = "\((languageArr.object(at: i) as AnyObject).value(forKey: "name")!)"
                                }
                            }
                            
                            self.lblHeader.text = NSLocalizedString("Edit Option", comment: "")
                            self.optionValueListingAPI()
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
    
    func optionEdit()
    {
        self.view.endEditing(true)
        
        var selectionType = ""
        if txtType.text == NSLocalizedString("Single Selection", comment: "")
        {
            selectionType = "radio"
        }
        else
        {
            selectionType = "checkbox"
        }
        
        let params = ["name" : self.txtOptionName.text!,
                      "type" : selectionType,
                      "sort_order" : self.txtSortOrder.text!,
                      "option_id" : self.optionId,
                      "language_id" : self.selectedLanguageId
            
            ] as [String : Any]
        

        let urlStr = "\(ConfigUrl.baseUrl)store/option/edit"
        
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
                        self.optionValuesActions()
                        SharedManager.showAlertWithMessage(title: NSLocalizedString("", comment: ""), alertMessage: NSLocalizedString("Option Edited Successfully", comment: ""), viewController: self)
                        
                        self.optionListingAPI()
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
    
    func optionValueListingAPI()
    {
        SharedManager.showHUD(viewController: self)
        
        let urlStr = "\(ConfigUrl.baseUrl)store/ovalue/ovalues&option_id=\(optionId)"
        
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
                            let result = responseObject.result.value as AnyObject
                            self.optionValueArr = (result.value(forKey: "option_values") as! NSArray).mutableCopy() as! NSMutableArray
                            self.tblOptionValue.reloadData()
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
    
    func optionValueAdd(params: [String : Any])
    {
        self.view.endEditing(true)

        let urlStr = "\(ConfigUrl.baseUrl)store/ovalue/add"
        
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
    
    func optionValueEdit(params: [String : Any])
    {
        
        self.view.endEditing(true)

        let urlStr = "\(ConfigUrl.baseUrl)store/ovalue/edit"
        
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
    
    func optionValueDelete(params: [String : Any])
    {
        self.view.endEditing(true)
        let urlStr = "\(ConfigUrl.baseUrl)store/ovalue/delete"
        
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
    
    func optionValuesActions()
    {
        for i in 0..<self.optionValueArr.count
        {
            if let type = (optionValueArr.object(at: i) as AnyObject).value(forKey: "type")
            {
                if "\(type)" == "delete"
                {
                    // delete api
                    let optionValueId = "\((self.optionValueArr.object(at: i) as AnyObject).value(forKey: "option_value_id")!)"
                    let optionId = "\((self.optionValueArr.object(at: i) as AnyObject).value(forKey: "option_id")!)"
                    
                    let tempDict = NSMutableDictionary()
                    
                    tempDict.setObject(optionId, forKey: "option_id" as NSCopying)
                    tempDict.setObject(optionValueId, forKey: "option_value_id" as NSCopying)
                    
                    self.optionValueDelete(params: tempDict as! [String : Any])
                }
                else if "\(type)" == "add"
                {
                    // add api
                    let temp = (self.optionValueArr.object(at: i) as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    let optionID = "\((self.optionValueArr.object(at: i) as AnyObject).value(forKey: "option_id")!)"
                    if optionID == ""
                    {
                        temp.setValue(optionId, forKey: "option_id")
                    }
                    temp.removeObject(forKey: "type")
                    self.optionValueAdd(params: temp as! [String : Any])
                }
                else if "\(type)" == "edit"
                {
                    let temp = (self.optionValueArr.object(at: i) as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    
                    temp.removeObject(forKey: "type")
                    self.optionValueEdit(params: temp as! [String : Any])
                }
            }
        }
        SharedManager.dismissHUD(viewController: self)
    }
    
    //MARK: Textfield Delegates
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == txtOptionName || textField == txtSortOrder || textField == txtType
        {
            isEdit = true
        }

        return true
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
            
            let urlStr = "\(ConfigUrl.baseUrl)store/option/options&sort=\(sortKey)&order=\(orderKey)&page=\(page)&limit=\(limit)"
            
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
                                
                                let array = (result.value(forKey: "options") as! NSArray).mutableCopy() as! NSMutableArray
                                
                                self.optionArr.addObjects(from: array as! [Any])
                                self.tblOption.reloadData()
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
    
    //MARK: UITableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == tblOption
        {
            return self.optionArr.count
        }
        else if tableView == tblOptionValue
        {
            let tempArr = NSMutableArray()
            optionHasValue = false
            for i in 0..<self.optionValueArr.count
            {
                if let type = (optionValueArr.object(at: i) as AnyObject).value(forKey: "type")
                {
                    if "\(type)" != "delete"
                    {
                       tempArr.add(optionValueArr.object(at: i))
                        optionHasValue = true
                    }
                }
                else
                {
                    tempArr.add(optionValueArr.object(at: i))
                    optionHasValue = true
                }
            }
            
            return tempArr.count
        }
        else
        {
            if typeTbl == "language"
            {
                return languageArr.count
            }
            else
            {
                return 2
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == tblOption
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "optionListCell") as! ProductTblCell
            
            cell.lblOptionName.text = "\((self.optionArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
            
            
            cell.lblOptionSortOrder.text = "\((self.optionArr.object(at: indexPath.row) as AnyObject).value(forKey: "sort_order")!)"
            
            let maxSize = CGSize(width: cell.lblOptionName.frame.size.width, height: CGFloat(Float.infinity))
            let charSize = cell.lblOptionName.font.lineHeight
            let text = (cell.lblOptionName.text!) as NSString
            let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: cell.lblOptionName.font], context: nil)
            let linesRoundedUp = Int(ceil(textSize.height/charSize))
            self.lineCount = linesRoundedUp
            
            if lineCount >= 3
            {
                cell.lblOptionName.sizeToFit()
                cell.viewShadowOption.frame.size.height = cell.lblOptionName.frame.size.height + 43
                cell.viewShadowOption.translatesAutoresizingMaskIntoConstraints = true
            }
            
            cell.imgEditOption.image = UIImage (named: "ic_edit")
            cell.imgEditOption.image = cell.imgEditOption.image!.withRenderingMode(.alwaysTemplate)
            cell.imgEditOption.tintColor = UIColor.lightGray
            
            cell.imgDeleteOption.image = UIImage (named: "ic_delete")
            cell.imgDeleteOption.image = cell.imgDeleteOption.image!.withRenderingMode(.alwaysTemplate)
            cell.imgDeleteOption.tintColor = UIColor.red
            
            cell.btnEditOption.addTarget(self, action: #selector(clickEdit(_:)), for: UIControl.Event.touchUpInside)
            cell.btnEditOption.tag = (indexPath as NSIndexPath).row
            
            cell.btnDeleteOption.addTarget(self, action: #selector(clickDelete(_:)), for: UIControl.Event.touchUpInside)
            cell.btnDeleteOption.tag = (indexPath as NSIndexPath).row
            
            cell.viewShadowOption.layer.shadowColor = UIColor.gray.cgColor
            cell.viewShadowOption.layer.shadowOpacity = 1
            cell.viewShadowOption.layer.shadowOffset = CGSize.zero
            cell.viewShadowOption.layer.shadowRadius = 3
            
            return cell
        }
        else if tableView == tblOptionValue
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "optionValueCell") as! ProductTblCell
            
            let tempArr = NSMutableArray()
            
            for i in 0..<self.optionValueArr.count
            {
                if let type = (optionValueArr.object(at: i) as AnyObject).value(forKey: "type")
                {
                    if "\(type)" != "delete"
                    {
                        tempArr.add(optionValueArr.object(at: i))
                    }
                }
                else
                {
                    tempArr.add(optionValueArr.object(at: i))
                }
            }
            
            cell.lblOptionValueName.text = "\((tempArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
            cell.lblOptionValueSortOrder.text = "\((tempArr.object(at: indexPath.row) as AnyObject).value(forKey: "sort_order")!)"
            
            cell.imgEditOptionValue.image = UIImage (named: "ic_edit")
            cell.imgEditOptionValue.image = cell.imgEditOptionValue.image!.withRenderingMode(.alwaysTemplate)
            cell.imgEditOptionValue.tintColor = UIColor.lightGray
            
            cell.imgDeleteOptionValue.image = UIImage (named: "ic_delete")
            cell.imgDeleteOptionValue.image = cell.imgDeleteOptionValue.image!.withRenderingMode(.alwaysTemplate)
            cell.imgDeleteOptionValue.tintColor = UIColor.red
            
            cell.btnEditOptionValue.addTarget(self, action: #selector(clickEditOptionValue(_:)), for: UIControl.Event.touchUpInside)
            cell.btnEditOptionValue.tag = (indexPath as NSIndexPath).row
            
            cell.btnDeleteOptionValue.addTarget(self, action: #selector(clickDeleteOptionValue(_:)), for: UIControl.Event.touchUpInside)
            cell.btnDeleteOptionValue.tag = (indexPath as NSIndexPath).row
            
            cell.viewShadowOptionValue.layer.shadowColor = UIColor.gray.cgColor
            cell.viewShadowOptionValue.layer.shadowOpacity = 1
            cell.viewShadowOptionValue.layer.shadowOffset = CGSize.zero
            cell.viewShadowOptionValue.layer.shadowRadius = 3
            
            return cell
        }
        else
        {
            if typeTbl == "language"
            {
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                
                for i in 0..<languageArr.count
                {
                    if indexPath.row == i
                    {
                        cell.textLabel?.text = "\((languageArr.object(at: i) as AnyObject).value(forKey: "name")!)"
                    }
                }
                return cell
            }
            else
            {
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                
                if indexPath.row == 0
                {
                    cell.textLabel?.text = NSLocalizedString("Single Selection", comment: "")
                }
                else
                {
                    cell.textLabel?.text = NSLocalizedString("Multiple Selection", comment: "")
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == tblOption
        {
            if lineCount < 3
            {
                return 87
            }
            else
            {
                return CGFloat((lineCount * 15) + 51)
            }
        }
        else if tableView == tblOptionValue
        {
            return 87
        }
        else
        {
            return 45
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == tblOption
        {
            
        }
        else
        {
            if typeTbl == "language"
            {
                self.lblLanguage.text = "\((languageArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
                self.selectedLanguageId = "\((languageArr.object(at: indexPath.row) as AnyObject).value(forKey: "language_id")!)"
                optionInfoAPI()
                self.popover.dismiss()
            }
            else
            {
                if indexPath.row == 0
                {
                    self.txtType.text = NSLocalizedString("Single Selection", comment: "")
                    isEdit = true
                }
                else
                {
                    self.txtType.text = NSLocalizedString("Multiple Selection", comment: "")
                    isEdit = true
                }
                self.popover.dismiss()
            }
        }
    }
    
    //MARK: Button Action
    
    @objc func clickEdit(_ sender: UIButton)
    {
        self.optionType = "edit"
        self.optionId = "\((optionArr.object(at: sender.tag) as AnyObject).value(forKey: "option_id")!)"
        
        optionInfoAPI()
    }
    
    @objc func clickDelete(_ sender: UIButton)
    {
        let alert = UIAlertController(title: NSLocalizedString("Are you sure?", comment: ""), message: NSLocalizedString("Do you want to remove this Option", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
           
            
            let optionId = "\((self.optionArr.object(at: sender.tag) as AnyObject).value(forKey: "option_id")!)"
            
            let params = ["option_id" : optionId
                
                ] as [String : Any]
            
            let urlStr = "\(ConfigUrl.baseUrl)store/option/delete"
            
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
                            SharedManager.showAlertWithMessage(title: "", alertMessage: NSLocalizedString("Option Deleted Successfully", comment: ""), viewController: self)
                            self.optionListingAPI()
                            
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
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func clickAddNew(_ sender: Any)
    {
        self.optionType = "add"
        self.txtOptionName.text = ""
        self.txtSortOrder.text = ""
        self.txtType.text = NSLocalizedString("Single Selection", comment: "")
        self.optionValueArr.removeAllObjects()
        self.tblOptionValue.reloadData()
        self.optionId = ""
        self.viewOption.isHidden = false
        self.viewBlurSort.isHidden = false
        self.lblHeader.text = NSLocalizedString("Add Option", comment: "")
    }
    
    @IBAction func clickAddOptionValue(_ sender: Any)
    {
        view.endEditing(true)
        self.optionValueType = "add"
        self.txtOptionValueName.text = ""
        self.txtOptionValueSortOrder.text = ""
        self.viewOptionValueBlur.isHidden = false
        self.viewOptionValue.isHidden = false
    }
    
    @IBAction func clickSaveOptionvalue(_ sender: UIButton)
    {
        view.endEditing(true)
        if txtOptionValueName.text != ""
        {
            if optionValueType == "add"
            {
                let params = ["name" : self.txtOptionValueName.text!,
                              "sort_order" : self.txtOptionValueSortOrder.text!,
                              "option_id" : optionId,
                              "language_id" : self.selectedLanguageId,
                              "type" : "add"
                    ] as [String : Any]
                
                optionValueArr.add(params)
            }
            else
            {

                let tempDict = (optionValueArr.object(at: sender.tag) as! NSDictionary).mutableCopy() as! NSMutableDictionary
                tempDict.setValue(self.txtOptionValueName.text!, forKey: "name")
                tempDict.setValue(self.txtOptionValueSortOrder.text!, forKey: "sort_order")
                
                if let type = tempDict.value(forKey: "type")
                {
                    if "\(type)" != "add"
                    {
                        tempDict.setObject("edit", forKey: "type" as NSCopying)
                        tempDict.setObject(optionId, forKey: "option_id" as NSCopying)
                        tempDict.setObject(selectedLanguageId, forKey: "language_id" as NSCopying)
                    }
                }
                else
                {
                    tempDict.setObject("edit", forKey: "type" as NSCopying)
                    tempDict.setObject(optionId, forKey: "option_id" as NSCopying)
                    tempDict.setObject(selectedLanguageId, forKey: "language_id" as NSCopying)
                }
                
                
                optionValueArr.replaceObject(at: sender.tag, with: tempDict)
            }
            
            self.viewOptionValue.isHidden = true
            self.viewOptionValueBlur.isHidden = true
            self.tblOptionValue.reloadData()
        }
        else
        {
            SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please Enter Option Value Name", comment: ""), viewController: self)

        }
    }
    
    @IBAction func clickCancelOptionvalue(_ sender: Any)
    {
        view.endEditing(true)
        self.viewOptionValueBlur.isHidden = true
        self.viewOptionValue.isHidden = true
    }
    
    @objc func clickEditOptionValue(_ sender: UIButton)
    {
        self.optionValueType = "edit"
        let name = "\((self.optionValueArr.object(at: sender.tag) as AnyObject).value(forKey: "name")!)"
        let order = "\((self.optionValueArr.object(at: sender.tag) as AnyObject).value(forKey: "sort_order")!)"
        
        self.btnOptionValueSave.tag = sender.tag
        
        self.txtOptionValueName.text = name
        self.txtOptionValueSortOrder.text = order
        self.viewOptionValueBlur.isHidden = false
        self.viewOptionValue.isHidden = false
        
    }
    
    @objc func clickDeleteOptionValue(_ sender: UIButton)
    {
        
        let tempDict = (optionValueArr.object(at: sender.tag) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        
        if let type = tempDict.value(forKey: "type")
        {
            if "\(type)" != "add"
            {
                tempDict.setObject(optionId, forKey: "option_id" as NSCopying)
                tempDict.setObject("delete", forKey: "type" as NSCopying)
                optionValueArr.removeObject(at: sender.tag)
                optionValueArr.add(tempDict)
            }else{
                optionValueArr.removeObject(at: sender.tag)
            }
        }
        else
        {
            tempDict.setObject(optionId, forKey: "option_id" as NSCopying)
            tempDict.setObject("delete", forKey: "type" as NSCopying)
            optionValueArr.removeObject(at: sender.tag)
            optionValueArr.add(tempDict)
        }
        //tempDict.setObject(optionId, forKey: "option_id" as NSCopying)
        //tempDict.setObject("delete", forKey: "type" as NSCopying)
        
        self.tblOptionValue.reloadData()
        
    }
    
    @IBAction func clickSaveOption(_ sender: Any)
    {
        if txtOptionName.text != ""
        {
            if optionHasValue == true
            {
                self.viewOption.isHidden = true
                self.viewBlurSort.isHidden = true
                self.viewLanguage.isHidden = true
                
                if optionType == "add"
                {
                    optionAdd()
                }
                else
                {
                    if isEdit == true
                    {
                        optionEdit()
                    }
                    else
                    {
                        optionValuesActions()
                    }
                }
            }
            else
            {
                SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please add atleast one option value", comment: ""), viewController: self)
                
            }
        }
        else
        {
            SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please Enter Option Name", comment: ""), viewController: self)
        }
    }
    
    @IBAction func clickCancelOption(_ sender: Any)
    {
        self.viewOption.isHidden = true
        self.viewBlurSort.isHidden = true
        self.viewLanguage.isHidden = true
    }
    
    @IBAction func clickType(_ sender: Any)
    {
        typeTbl = "type"
        let tableView = UITableView(frame: CGRect(x: self.txtType.frame.origin.x, y: 0, width: self.txtType.frame.size.width, height: 2*45))
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
        self.popover.show(tableView, fromView: self.txtType)
    }
    
    @IBAction func clickLanguage(_ sender: Any)
    {
        typeTbl = "language"
        let tableViewStatus = UITableView(frame: CGRect(x: self.lblLanguage.frame.origin.x, y: 0, width: self.viewLanguage.frame.size.width, height: CGFloat(languageArr.count * 45)))
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
        self.popover.show(tableViewStatus, fromView: self.lblLanguage)
    }
    
    
    //MARK: Filter
    
    @IBAction func clickFilter(_ sender: Any)
    {
        self.view.endEditing(true)
        self.mainFilterView.isHidden = false
        self.viewBlurSort.isHidden = false
    }
    
    @IBAction func clickFilterApply(_ sender: Any)
    {
        self.view.endEditing(true)
        SharedManager.showHUD(viewController: self)
        page = 1
        let urlStr = "\(ConfigUrl.baseUrl)store/option/options&sort=\(sortKey)&order=\(orderKey)&filter_name=\(self.txtFilter.text!)&page=\(page)&limit=\(limit)"
        
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
                            let result = responseObject.result.value as AnyObject
                            self.optionArr = (result.value(forKey: "options") as! NSArray).mutableCopy() as! NSMutableArray
                            
                            if self.optionArr.count == 0
                            {
                                let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Option list is empty", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                            let total = "\(String(describing: result.value(forKey: "total")!))"
                            self.pageCount = Double(Int(total)!/Int(self.limit)!)
                            self.mainFilterView.isHidden = true
                            self.viewBlurSort.isHidden = true
                            self.tblOption.reloadData()
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
        self.view.endEditing(true)
        self.mainFilterView.isHidden = true
        self.viewBlurSort.isHidden = true
    }
    
    @IBAction func clickSort(_ sender: Any)
    {
        self.view.endEditing(true)
        self.viewBlurSort.isHidden = false
        self.mainSortView.isHidden = false
    }
    
    @IBAction func clickCancelSort(_ sender: Any)
    {
        self.view.endEditing(true)
        self.viewBlurSort.isHidden = true
        self.mainSortView.isHidden = true
        self.mainFilterView.isHidden = true
        self.viewOption.isHidden = true
    }
    
    @IBAction func clickSortOption(_ sender: UIButton)
    {
        self.view.endEditing(true)
        if sender.tag == 0
        {
            self.sortKey = "name"
            self.orderKey = "ASC"
        }
        else if sender.tag == 1
        {
            self.sortKey = "name"
            self.orderKey = "DESC"
        }
        else if sender.tag == 2
        {
            self.sortKey = "sort_order"
            self.orderKey = "ASC"
        }
        else if sender.tag == 3
        {
            self.sortKey = "sort_order"
            self.orderKey = "DESC"
        }
        
        optionListingAPI()
        self.viewBlurSort.isHidden = true
        self.mainSortView.isHidden = true
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
