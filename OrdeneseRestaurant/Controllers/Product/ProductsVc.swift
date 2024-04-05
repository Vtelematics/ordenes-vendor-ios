//
//  ProductsVc.swift
//  GroceryStore
//
//  Created by Adyas Infotech on 11/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import Alamofire
import OpalImagePicker
import Photos
import WebKit

extension UIImage {
    
    func updateImageOrientionUpSide() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        }
        UIGraphicsEndImageContext()
        return nil
    }
}

class ProductsVc: UIViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tblProductList: UITableView!
    @IBOutlet weak var tblSection: UITableView!
    @IBOutlet weak var viewProductDetail: UIView!
    @IBOutlet weak var viewBlurSection: UIView!
    @IBOutlet weak var viewSection: UIView!
    @IBOutlet weak var viewOrderStatus: UIView!
    @IBOutlet weak var viewBg: UIView!
    
    var productID : String = ""
    var storeID : String = ""
    
    @IBOutlet weak var viewSorting: UIView!
    @IBOutlet weak var imgSort: UIImageView!
    @IBOutlet weak var mainSortView: UIView!
    @IBOutlet weak var viewBlurSort: UIView!
    
    @IBOutlet weak var viewFiltering: UIView!
    @IBOutlet weak var imgFilter: UIImageView!
    @IBOutlet weak var mainFilterView: UIView!
    @IBOutlet weak var txtFilterName: UITextField!
    @IBOutlet weak var txtFilterStatus: UITextField!
    
    //Product Detail
    @IBOutlet weak var viewContain: UIView!
    @IBOutlet weak var mainScroll: UIScrollView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var txtDeliveryNote: UITextView!
    @IBOutlet weak var txtItemNote: UITextView!
    @IBOutlet weak var txtPriceOnSelection: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtDiscountPrice: UITextField!
    @IBOutlet weak var txtStartDate: UITextField!
    @IBOutlet weak var btnStartDate: UIButton!
    @IBOutlet weak var btnEndDate: UIButton!
    @IBOutlet weak var txtEndDate: UITextField!
    @IBOutlet weak var viewQuantity: UIView!
    @IBOutlet weak var txtQuantity: UITextField!
    @IBOutlet weak var txtQuantityValue: UITextField!
    @IBOutlet weak var txtStatus: UITextField!
    @IBOutlet weak var txtSortOrder: UITextField!
    @IBOutlet weak var imgProductImage: UIImageView!
    @IBOutlet weak var lblSection: UILabel!
    @IBOutlet weak var viewLanguage: UIView!
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var viewDatePicker: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var lblline: UILabel!
    @IBOutlet weak var imgDownArrow: UIImageView!
    @IBOutlet weak var btnSection: UIButton!
    @IBOutlet weak var btnVeg: UIButton!
    @IBOutlet weak var lblVeg: UILabel!
    @IBOutlet weak var lblNonVeg: UILabel!
    @IBOutlet weak var btnNonVeg: UIButton!
    @IBOutlet weak var vwAddCategory: UIView!
    @IBOutlet weak var txtCategoryName: UITextField!
    @IBOutlet weak var txtCategorySortOrder: UITextField!
    @IBOutlet weak var txtCategoryStatus: UITextField!
    
    @IBOutlet weak var viewDateStart: UIView!
    @IBOutlet weak var viewDateEnd: UIView!
    
    @IBOutlet var myCollCategory: UICollectionView!
    @IBOutlet var myCollSubCategory: UICollectionView!
    @IBOutlet weak var myViewCategory: UIView!
    @IBOutlet weak var myViewSubCategory: UIView!
    
    @IBOutlet weak var myViewSearchContainer: UIView!
    @IBOutlet weak var myViewSearchBox: UIView!
    @IBOutlet weak var myViewSearchClear: UIView!
    @IBOutlet weak var myTxtSearch: UITextField!
    
    var vendorType = String()
    let imagePicker = UIImagePickerController()
    var imageType = String()
    var imageIndex = Int()
    var productListArr = NSMutableArray()
    var optionValue = NSMutableArray()
    var productInfo = NSDictionary()
    var sectionType = ""
    var dateType = ""
    var saveType = ""
    var selectedLanguageId = ""
    var selectedValuesArrSection = NSMutableArray()
    var selectedValuesArrSectionTemp = NSMutableArray()
    var sortKey = ""
    var orderKey = ""
    var productImageStr = ""
    var imgCount = 0
    var statusStr = ""
    var typeTable = ""
    var productId = ""
    var sectionArr = NSMutableArray()
    var statusType = ""
    private var wkwebView: WKWebView!
    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "8"
    var isScrolledOnceSection : Bool = false
    var pageSection:Int = 1
    var pageCountSection = Double()
    var limitSection:String = "20"
    var pagenationType = ""
    var categorySelectedIndex = 0
    var subCategorySelectedIndex = 0
    var categoryArr = NSMutableArray()
    var subCategoryArr = NSMutableArray()
    var categoryId = String()
    var subCategoryId = String()
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.auto),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainScroll.contentSize = CGSize(width: self.view.bounds.width, height: 1100)
        self.title = NSLocalizedString("Product", comment: "")
        self.viewBlurSection.isHidden = true
        self.viewSection.isHidden = true
        imgSort.image = UIImage (named: "ic_sort")
        imgSort.image = imgSort.image!.withRenderingMode(.alwaysTemplate)
        imgSort.tintColor = positiveBtnColor
        imgFilter.image = UIImage (named: "ic_filter")
        imgFilter.image = imgFilter.image!.withRenderingMode(.alwaysTemplate)
        imgFilter.tintColor = positiveBtnColor
        self.mainFilterView.isHidden = true
        self.mainSortView.isHidden = true
        self.viewBlurSort.isHidden = true
        self.viewProductDetail.isHidden = true
        self.vwAddCategory.isHidden = true
        viewLanguage.layer.shadowColor = UIColor.gray.cgColor
        viewLanguage.layer.shadowOpacity = 1
        viewLanguage.layer.shadowOffset = CGSize.zero
        viewLanguage.layer.shadowRadius = 3
        viewContain.layer.shadowColor = UIColor.gray.cgColor
        viewContain.layer.shadowOpacity = 1
        viewContain.layer.shadowOffset = CGSize.zero
        viewContain.layer.shadowRadius = 3
        self.viewQuantity.layer.borderWidth = 1
        self.viewQuantity.layer.borderColor = UIColor.black.cgColor
        self.viewDateStart.layer.borderWidth = 1
        self.viewDateStart.layer.borderColor = UIColor.black.cgColor
        self.viewDateEnd.layer.borderWidth = 1
        self.viewDateEnd.layer.borderColor = UIColor.black.cgColor
        self.viewDatePicker.isHidden = true
        self.txtName.textAlignment = isRTLenabled == true ? .right : .left
        self.txtDescription.textAlignment = isRTLenabled == true ? .right : .left
        self.txtItemNote.textAlignment = isRTLenabled == true ? .right : .left
        self.txtPrice.textAlignment = isRTLenabled == true ? .right : .left
        self.txtPriceOnSelection.textAlignment = isRTLenabled == true ? .right : .left
        self.txtDiscountPrice.textAlignment = isRTLenabled == true ? .right : .left
        self.txtEndDate.textAlignment = isRTLenabled == true ? .right : .left
        self.txtStartDate.textAlignment = isRTLenabled == true ? .right : .left
        self.txtStatus.textAlignment = isRTLenabled == true ? .right : .left
        self.txtSortOrder.textAlignment = isRTLenabled == true ? .right : .left
        self.lblSection.textAlignment = isRTLenabled == true ? .right : .left
        self.txtCategoryName.textAlignment = isRTLenabled == true ? .right : .left
        self.txtCategorySortOrder.textAlignment = isRTLenabled == true ? .right : .left
        self.txtCategoryStatus.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtSearch.textAlignment = isRTLenabled == true ? .right : .left
        self.selectedLanguageId = languageID
        
        self.myCollCategory.register(UINib(nibName: "ProductCategoryCollCell", bundle: nil), forCellWithReuseIdentifier: "productCatCell")
        self.myCollSubCategory.register(UINib(nibName: "ProductCategoryCollCell", bundle: nil), forCellWithReuseIdentifier: "productCatCell")
        
        self.myViewSearchBox.layer.cornerRadius = 8
        self.myViewSearchBox.layer.borderColor = UIColor.lightGray.cgColor
        self.myViewSearchBox.layer.borderWidth = 0.8
        
        if #available(iOS 13.4, *) {
            datePicker?.preferredDatePickerStyle = .wheels
        }
        if UserDefaults.standard.object(forKey: "USER_DETAILS") != nil
        {
            let data = UserDefaults.standard.object(forKey: "USER_DETAILS") as! Data
            let userDic = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
            vendorType = "\(userDic.value(forKeyPath: "vendor_info.vendor_type")!)"
            if vendorType == "1" {
                self.myViewSubCategory.isHidden = true
                self.myViewSubCategory.frame.size.height = 0
                self.myViewSubCategory.translatesAutoresizingMaskIntoConstraints = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getCategoryList()
    }
    
    //MARK: API Methods
    func productListAPI()
    {
        page = 1
        let params = [
            "page_per_unit" : limit,
            "page" : page,
            "category_id" :categoryId,
            "sub_category_id" :subCategoryId
            
        ] as [String : Any]
        
        let urlStr = "\(ConfigUrl.baseUrl)product-list"
        
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
                        
                        if "\(String(describing: responseObject.response!.statusCode))" == "200"
                        {
                            let result = responseObject.result.value as AnyObject
                            
                            self.productListArr = (result.value(forKey: "product") as! NSArray).mutableCopy() as! NSMutableArray
                            if self.productListArr.count == 0
                            {
                                let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Product list is empty. Do you want to add new Product?", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                    
                                    self.saveType = "new"
                                    self.mainScroll.scrollsToTop = true
                                    self.clearFields()
                                    
                                }))
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil))
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                            let total = "\(String(describing: result.value(forKey: "total")!))"
                            self.pageCount = Double(Int(total)!/Int(self.limit)!)
                            
                            self.tblProductList.reloadData()
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
    
    func productInfoAPI()
    {
        let urlStr = "\(ConfigUrl.baseUrl)store/product/info&product_id=\(productId)&language_id=\(selectedLanguageId)"
        
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
                            self.productInfo = result.value(forKey: "product") as! NSDictionary
                            self.productId = "\(self.productInfo.value(forKey: "product_id")!)"
                            self.txtName.text = "\(self.productInfo.value(forKey: "name")!)"
                            self.txtDescription.text = "\(self.productInfo.value(forKey: "description")!)"
                            //self.txtDeliveryNote.text = "\(self.productInfo.value(forKey: "delivery_note")!)"
                            self.txtItemNote.text = "\(self.productInfo.value(forKey: "item_note")!)"
                            
                            self.selectedLanguageId = "\(self.productInfo.value(forKey: "language_id")!)"
                            for i in 0..<languageArr.count
                            {
                                let id = "\((languageArr.object(at: i) as AnyObject).value(forKey: "language_id")!)"
                                if id == self.selectedLanguageId
                                {
                                    self.lblLanguage.text = "\((languageArr.object(at: i) as AnyObject).value(forKey: "name")!)"
                                }
                            }
                            
                            let priceSelection = "\(self.productInfo.value(forKey: "price_selection")!)"
                            
                            if priceSelection != "0"
                            {
                                self.txtPriceOnSelection.text = "YES"
                                self.txtPrice.isUserInteractionEnabled = false
                                self.txtDiscountPrice.isUserInteractionEnabled = false
                                self.txtPrice.text = ""
                                self.txtDiscountPrice.text = ""
                                self.btnStartDate.isEnabled = false
                                self.btnEndDate.isEnabled = false
                                self.txtStartDate.isHidden = true
                                self.txtEndDate.isHidden = true
                                self.txtStartDate.text = ""
                                self.txtEndDate.text = ""
                            }
                            else
                            {
                                self.txtPriceOnSelection.text = "NO"
                                self.txtPrice.isUserInteractionEnabled = true
                                self.txtDiscountPrice.isUserInteractionEnabled = true
                                self.txtStartDate.isHidden = false
                                self.txtEndDate.isHidden = false
                                self.btnStartDate.isEnabled = true
                                self.btnEndDate.isEnabled = true
                                self.txtPrice.text = "\(self.productInfo.value(forKey: "price")!)"
                                let productSection = (self.productInfo.value(forKey: "product_special") as! AnyObject)
                                if productSection.count != 0
                                {
                                    
                                    self.txtDiscountPrice.text = "\(self.productInfo.value(forKeyPath: "product_special.price")!)"
                                    self.txtStartDate.text = "\(self.productInfo.value(forKeyPath: "product_special.date_start")!)"
                                    self.txtEndDate.text = "\(self.productInfo.value(forKeyPath: "product_special.date_end")!)"
                                }
                               
                            }
                            
                            let quantity = "\(self.productInfo.value(forKey: "quantity_required")!)"
                            
                            if quantity == "0"
                            {
                                self.txtQuantity.text = "NO"
                                self.txtQuantityValue.isHidden = true
                            }
                            else
                            {
                                self.txtQuantity.text = "YES"
                                self.txtQuantityValue.text = "\(self.productInfo.value(forKey: "quantity")!)"
                                self.txtQuantityValue.isHidden = false
                            }
                            
                            let productType = "\(self.productInfo.value(forKey: "product_type")!)"
                            if productType == "0"{
                                var image = UIImage(named: "ic_radio_uncheck")
                                self.btnVeg.setImage(image, for: .normal)
                                image = UIImage(named: "ic_radio_uncheck")
                                self.btnNonVeg.setImage(image, for: .normal)
                            }else if productType == "1"{
                                if self.btnVeg.isHidden == false{
                                    var image = UIImage(named: "ic_radio_check")
                                    self.btnVeg.setImage(image, for: .normal)
                                    image = UIImage(named: "ic_radio_uncheck")
                                    self.btnNonVeg.setImage(image, for: .normal)
                                }
                            }else if productType == "2"{
                                if self.btnNonVeg.isHidden == false{
                                    var image = UIImage(named: "ic_radio_uncheck")
                                    self.btnVeg.setImage(image, for: .normal)
                                    image = UIImage(named: "ic_radio_check")
                                    self.btnNonVeg.setImage(image, for: .normal)
                                }
                            }
                            
                            let status = "\(self.productInfo.value(forKey: "status")!)"
                            if status == "1"
                            {
                                self.txtStatus.text = "Enabled"
                            }
                            else
                            {
                                self.txtStatus.text = "Disabled"
                            }
                            self.txtSortOrder.text = "\(self.productInfo.value(forKey: "sort_order")!)"
                            
                            self.productImageStr = "\(self.productInfo.value(forKey: "image")!)"
                            let imageUrl = "\(self.productInfo.value(forKey: "image_thumb")!)"
                            
                            let trimmedUrl1 = imageUrl.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20")
                            
                            var activityLoader = UIActivityIndicatorView()
                            activityLoader = UIActivityIndicatorView(style: .gray)
                            activityLoader.center = self.imgProductImage.center
                            activityLoader.startAnimating()
                            self.imgProductImage.addSubview(activityLoader)
                            
                            self.imgProductImage.sd_setImage(with: URL(string: trimmedUrl1), completed: { (image, error, imageCacheType, imageUrl) in
                                
                                if image != nil
                                {
                                    activityLoader.stopAnimating()
                                }else
                                {
                                    print("image not found")
                                    self.imgProductImage.image = nil
                                    activityLoader.stopAnimating()
                                }
                            })
                            
                            self.imgProductImage.contentMode = UIView.ContentMode.scaleAspectFit
                            
                            self.selectedValuesArrSection = (self.productInfo.value(forKey: "product_category") as! NSArray).mutableCopy() as! NSMutableArray
                            var section = String()
                            
                            if self.selectedValuesArrSection.count != 0
                            {
                                for i in 0..<self.selectedValuesArrSection.count
                                {
                                    let selectedID = "\((self.selectedValuesArrSection.object(at: i) as AnyObject).value(forKey: "category_id")!)"
                                    
                                    for j in 0..<self.sectionArr.count
                                    {
                                        let id = "\((self.sectionArr.object(at: j) as AnyObject).value(forKey: "category_id")!)"
                                        if selectedID == id
                                        {
                                            section = section + "\((self.sectionArr.object(at: j) as AnyObject).value(forKey: "name")!),"
                                        }
                                    }
                                    
                                }
                                if section != ""
                                {
                                    section.removeLast()
                                }
                                
                            }
                            
                            self.lblSection.text = section
                            self.setFrames()
                            
                            self.viewProductDetail.isHidden = false
                            
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
    
    func getCategoryList()
    {
        let urlStr = "\(ConfigUrl.baseUrl)category-list"
        
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
                        let result = responseObject.result.value! as AnyObject
                        print(result)
                        if let status = (responseObject.result.value! as AnyObject).value(forKeyPath: "success.status")
                        {
                            if "\(status)" == "200" {
                                let result = responseObject.result.value! as AnyObject
                                self.categoryArr = (result.value(forKey: "category") as! NSArray).mutableCopy() as! NSMutableArray
                                self.myCollCategory.dataSource = self
                                self.myCollCategory.delegate = self
                                self.myCollCategory.reloadData()
                                
                                if isRTLenabled {
                                    self.myCollCategory.scrollToItem(at: [0, 0], at: .right, animated: true)
                                }else {
                                    self.myCollCategory.setContentOffset(.zero, animated: false)
                                }
                                
                                self.categoryId = "\((self.categoryArr.object(at: self.categorySelectedIndex) as AnyObject).value(forKey: "category_id")!)"
                                if self.vendorType == "2" {
                                    self.getSubCategoryList(categoryId: self.categoryId)
                                }else {
                                    self.productListAPI()
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
    
    func getSubCategoryList(categoryId : String)
    {
        let params = ["category_id" : categoryId
            ] as [String : Any]
        
        let urlStr = "\(ConfigUrl.baseUrl)sub-category-list"
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
                                self.subCategoryArr = (result.value(forKey: "sub_category") as! NSArray).mutableCopy() as! NSMutableArray
                                self.myCollSubCategory.dataSource = self
                                self.myCollSubCategory.delegate = self
                                self.myCollSubCategory.reloadData()
                                
                                if isRTLenabled {
                                    self.myCollSubCategory.scrollToItem(at: [0, 0], at: .right, animated: true)
                                }else {
                                    self.myCollSubCategory.setContentOffset(.zero, animated: false)
                                }
                                
                                self.subCategoryId = "\((self.subCategoryArr.object(at: self.subCategorySelectedIndex) as AnyObject).value(forKey: "sub_category_id")!)"
                                print(self.subCategoryId)
                                
                                self.productListAPI()
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
    
    func callGetSearchRestaurantApi(searchKey: String)
    {
        let params = [
            "page_per_unit" : limit,
            "page" : page,
            "search" :searchKey
            
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
                                self.productListArr.removeAllObjects()
                                self.productListArr = (result.value(forKey: "product") as! NSArray).mutableCopy() as! NSMutableArray
                                self.tblProductList.reloadData()
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
    
    func checkSection(_ productId:String) -> Bool
    {
        var isAleadyHave:Bool = false
        if selectedValuesArrSectionTemp.count != 0
        {
            for tempDic in selectedValuesArrSectionTemp
            {
                let tempCart:NSDictionary = tempDic as! NSDictionary
                
                let str1 = "\(tempCart.value(forKey: "category_id")!)"
                
                if str1 == productId
                {
                    isAleadyHave = true
                }
            }
        }
        return isAleadyHave
    }
    
    func productAdd()
    {
        self.view.endEditing(true)
        
        var priceSelection = ""
        
        if self.txtPriceOnSelection.text! == "YES"
        {
            priceSelection = "1"
        }
        else
        {
            priceSelection = "0"
        }
        
        var discountDict = NSMutableDictionary()
        discountDict.setObject(self.txtDiscountPrice.text!, forKey: "price" as NSCopying)
        discountDict.setObject(self.txtStartDate.text!, forKey: "date_start" as NSCopying)
        discountDict.setObject(self.txtEndDate.text!, forKey: "date_end" as NSCopying)
        var quantity = ""
        
        if self.txtQuantity.text! == "YES"
        {
            quantity = "1"
        }
        else
        {
            quantity = "0"
        }
        
        var productType = 0
        if self.btnVeg.currentImage == UIImage(named: "ic_radio_check"){
            productType = 1
        }else if self.btnNonVeg.currentImage == UIImage(named: "ic_radio_check"){
            productType = 2
        }
        
        var selectedStatus = ""
        
        if self.txtStatus.text! == "Enabled"
        {
            selectedStatus = "1"
        }
        else
        {
            selectedStatus = "0"
        }
        let sectionDict = NSMutableDictionary()
        
        if selectedValuesArrSection.count != 0
        {
            let tempArr = NSMutableArray()
            tempArr.addObjects(from: selectedValuesArrSection as! [Any])
            for i in 0..<tempArr.count
            {
                let str = "\(String(describing: (tempArr.object(at: i) as AnyObject).value(forKey: "category_id")!))"
                sectionDict.setObject(str, forKey: "\(i)" as NSCopying)
            }
        }
        
        let params = ["name" : self.txtName.text!,
                      "description" : self.txtDescription.text!,
                      "delivery_note" : self.txtDeliveryNote.text!,
                      "item_note" : self.txtItemNote.text!,
                      "price_selection" : priceSelection,
                      "price" : self.txtPrice.text!,
                      "product_special" : discountDict,
                      "quantity_required" : quantity,
                      "quantity" : self.txtQuantityValue.text!,
                      "preparing_time" : selectedStatus,
                      "status" : selectedStatus,
                      "sort_order" : self.txtSortOrder.text!,
                      "image" : productImageStr,
                      "product_type" : productType,
                      "product_category" : sectionDict
            
            ] as [String : Any]
        
        let urlStr = "\(ConfigUrl.baseUrl)store/product/add"
        
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
                
                print(String(data: responseObject.data!, encoding: String.Encoding.utf8)!)
                if responseObject.result.isSuccess
                {
                    SharedManager.dismissHUD(viewController: self)
                    let result = responseObject.result.value! as AnyObject
                    
                    if "\(String(describing: responseObject.response!.statusCode))" == "200"
                    {
                        
                        let productID = "\(result.value(forKey : "product_id")!)"
                        self.navigationController?.isNavigationBarHidden = true
                        
                        let storeid = "\(UserDefaults.standard.string(forKey: "STORE_ID")!)"
                        
                        var priceSelection = ""
                        if self.txtPriceOnSelection.text == "YES"
                        {
                            priceSelection = "1"
                        }
                        else
                        {
                            priceSelection = "0"
                        }

                        //  self.webView.isHidden = false
                        let url = NSString(format: "\(ConfigUrl.baseUrl)restaurant/product_option&product_id=%@&store_id=%@&price_selection=%@" as NSString, productID, storeid, priceSelection)
                        print("url:\(url)")
                        let urlRequest = URLRequest(url: URL(string: url as String)!)
                        
                        let preferences = WKPreferences()
                        preferences.javaScriptEnabled = true
                        let configuration = WKWebViewConfiguration()
                        configuration.preferences = preferences
                        self.wkwebView = WKWebView(frame:  self.view.bounds, configuration: configuration)
                        self.view.addSubview(self.wkwebView)
                        self.wkwebView.navigationDelegate = self
                        self.wkwebView.load(urlRequest)
                        
                        SharedManager.showAlertWithMessage(title: "", alertMessage: NSLocalizedString("Product Added Successfully", comment: ""), viewController: self)
                        
                        self.viewProductDetail.isHidden = true
                        
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
    
    func productEdit(productId : String)
    {
        self.view.endEditing(true)
        
        var priceSelection = ""
        
        if self.txtPriceOnSelection.text! == "YES"
        {
            priceSelection = "1"
        }
        else
        {
            priceSelection = "0"
        }
        
        var discountDict = NSMutableDictionary()
        discountDict.setObject(self.txtDiscountPrice.text!, forKey: "price" as NSCopying)
        discountDict.setObject(self.txtStartDate.text!, forKey: "date_start" as NSCopying)
        discountDict.setObject(self.txtEndDate.text!, forKey: "date_end" as NSCopying)
        var quantity = ""
        
        if self.txtQuantity.text! == "YES"
        {
            quantity = "1"
        }
        else
        {
            quantity = "0"
        }
        
        var productType = 0
        if self.btnVeg.currentImage == UIImage(named: "ic_radio_check"){
            productType = 1
        }else if self.btnNonVeg.currentImage == UIImage(named: "ic_radio_check"){
            productType = 2
        }
        
        var selectedStatus = ""
        
        if self.txtStatus.text! == "Enabled"
        {
            selectedStatus = "1"
        }
        else
        {
            selectedStatus = "0"
        }
        let sectionDict = NSMutableDictionary()
        if selectedValuesArrSection.count != 0
        {
            let tempArr = NSMutableArray()
            tempArr.addObjects(from: selectedValuesArrSection as! [Any])
            
            for i in 0..<tempArr.count
            {
                let str = "\(String(describing: (tempArr.object(at: i) as AnyObject).value(forKey: "category_id")!))"
                sectionDict.setObject(str, forKey: "\(i)" as NSCopying)
            }
        }
        
        let params = ["name" : self.txtName.text!,
                      "product_id" : productId,
                      "language_id" : self.selectedLanguageId,
                      "description" : self.txtDescription.text!,
                      "delivery_note" : self.txtDeliveryNote.text!,
                      "item_note" : self.txtItemNote.text!,
                      "price_selection" : priceSelection,
                      "price" : self.txtPrice.text!,
                      "product_special" : discountDict,
                      "quantity_required" : quantity,
                      "quantity" : self.txtQuantityValue.text!,
                      "preparing_time" : selectedStatus,
                      "status" : selectedStatus,
                      "sort_order" : self.txtSortOrder.text!,
                      "image" : productImageStr,
                      "product_type" : productType,
                      "product_category" : sectionDict
            
            ] as [String : Any]
        
        let urlStr = "\(ConfigUrl.baseUrl)store/product/edit"
        
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
                    
                    if "\(String(describing: responseObject.response!.statusCode))" == "200"
                    {
                        self.navigationController?.isNavigationBarHidden = true
                        
                        let storeid = "\(UserDefaults.standard.string(forKey: "STORE_ID")!)"
                        
                        var priceSelection = ""
                        if self.txtPriceOnSelection.text == "YES"
                        {
                            priceSelection = "1"
                        }
                        else
                        {
                            priceSelection = "0"
                        }
                        
                        //  self.webView.isHidden = false
                        
                        let url = NSString(format: "\(ConfigUrl.baseUrl)restaurant/product_option&product_id=%@&store_id=%@&price_selection=%@" as NSString, productId, storeid, priceSelection)
                        
                        let urlRequest = URLRequest(url: URL(string: url as String)!)
                        
                        let preferences = WKPreferences()
                        preferences.javaScriptEnabled = true
                        let configuration = WKWebViewConfiguration()
                        configuration.preferences = preferences
                        self.wkwebView = WKWebView(frame:  self.view.bounds, configuration: configuration)
                        self.view.addSubview(self.wkwebView)
                        self.wkwebView.navigationDelegate = self
                        self.wkwebView.load(urlRequest)
                        
                        SharedManager.showAlertWithMessage(title: "", alertMessage: NSLocalizedString("Product Edited Successfully", comment: ""), viewController: self)
                        
                        self.viewProductDetail.isHidden = true
                        
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
                            self.productListAPI()
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
    
    func clearFields()
    {
        self.mainScroll.scrollsToTop = true
        self.viewProductDetail.isHidden = false
        self.viewLanguage.isHidden = true
        self.txtName.text = ""
        self.txtDescription.text = ""
        self.txtDeliveryNote.text = ""
        self.txtItemNote.text = ""
        self.txtPriceOnSelection.text = "NO"
        self.txtPrice.text = ""
        self.txtDiscountPrice.text = ""
        self.txtStartDate.text = ""
        self.txtEndDate.text = ""
        self.txtName.text = ""
        self.txtQuantity.text = "NO"
        self.txtQuantityValue.isHidden = true
        self.txtQuantityValue.text = ""
        self.txtStatus.text = "Enabled"
        self.lblSection.text = ""
        self.imgProductImage.image = nil
        self.productImageStr = ""
        
        self.txtPrice.isUserInteractionEnabled = true
        self.txtDiscountPrice.isUserInteractionEnabled = true
        self.txtStartDate.isHidden = false
        self.txtEndDate.isHidden = false
        self.btnStartDate.isEnabled = true
        self.btnEndDate.isEnabled = true
        self.selectedValuesArrSection = []
        setFrames()
    }
    
    func setFrames()
    {
        if selectedValuesArrSection.count != 0
        {
            self.lblSection.sizeToFit()
            self.lblSection.frame.size.width = self.txtStatus.frame.size.width
            
            let height = self.lblSection.frame.size.height
            if height < 40
            {
                self.lblSection.frame.size.height = self.txtSortOrder.frame.size.height
                self.btnSection.frame.size.height = self.lblSection.frame.size.height
            }
        }
        else
        {
            self.lblSection.frame.size.height = self.txtSortOrder.frame.size.height
        }
        self.btnSection.frame.size.height = self.lblSection.frame.size.height
        self.lblline.frame.origin.y = self.lblSection.frame.origin.y + self.lblSection.frame.size.height
        self.viewContain.frame.size.height = self.lblline.frame.origin.y + 10
        self.mainScroll.contentSize = CGSize(width: self.view.bounds.width, height: self.viewContain.frame.size.height + 10)
    }
    
    //MARK: Webview Delegates
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!)
    {
        SharedManager.showHUD(viewController: self)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
         print("wkwebview delgate")
        self.wkwebView.scrollView.showsHorizontalScrollIndicator = false
        
        SharedManager.dismissHUD(viewController: self)
        let string = wkwebView.url?.absoluteString
        let responseString = string as! NSString
        
        if responseString.range(of: "restaurant/product_option/success").location != NSNotFound
        {
            var html = ""
            webView.evaluateJavaScript("document.documentElement.outerHTML") { (result, error) in
                if error != nil
                {
                    print(error?.localizedDescription)
                }
                else
                {
                    html = "\(String(describing: result))"
                    
                    if ((html as NSString).range(of: "1").location != NSNotFound)
                    {
                        var message = ""
                        if self.saveType == NSLocalizedString("edit", comment: "")
                        {
                            message = NSLocalizedString("Your Changes saved Successfully", comment: "")
                        }
                        else
                        {
                            message = NSLocalizedString("Product added Successfully", comment: "")
                        }
                        let alert = UIAlertController(title: NSLocalizedString("Success!", comment: ""), message: message, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {(alert :UIAlertAction) in
                            
                            // code
                            self.navigationController?.isNavigationBarHidden = false
                            self.wkwebView.removeFromSuperview()
                            self.viewProductDetail.isHidden = true
                            self.productListAPI()
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else
                    {
                        let alert = UIAlertController(title: NSLocalizedString("Sorry!", comment: ""), message: NSLocalizedString("Something went wrong!", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: { action in
                            // code
                            self.navigationController?.isNavigationBarHidden = false
                            self.wkwebView.isHidden = true
                            self.viewProductDetail.isHidden = true
                            self.productListAPI()
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)
    {
        print(error.localizedDescription)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        self.dismiss(animated: true, completion: {})
                
        guard let pickedImage = info[.originalImage] as? UIImage else {
            fatalError("Something went wrong")
        }
        
        self.imgProductImage.contentMode = .scaleAspectFit
        self.imgProductImage.image = pickedImage
        
        if let updatedImage = self.imgProductImage.image?.updateImageOrientionUpSide() {
            uploadGalleryImage(image: updatedImage)
        } else {
            uploadGalleryImage(image: self.imgProductImage.image!)
        }
    }
    
    func uploadGalleryImage( image:UIImage)
    {
        let imageData = image.jpegData(compressionQuality: 0.01)
        let baseStr = imageData?.base64EncodedString(options: .lineLength64Characters)
        
        var params = [String : Any]()
        
        params = ["file": baseStr!, "filename": "logo.jpg"]
        
        if Connectivity.isConnectedToInternet()
        {
            let urlStr = "\(ConfigUrl.baseUrl)store/product/upload"
            
            let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
            var request = URLRequest(url: URL(string: setFinalURl)!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let setTemp: [String : Any] = params
            
            if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
                request.httpBody = jsonData
            }
            
            SharedManager.showHUD(viewController: self)
            Alamofire.request(request).responseJSON { (responseObject) -> Void in
                
                print(String(data: responseObject.data!, encoding: String.Encoding.utf8)!)
                
                if responseObject.result.isSuccess
                {
                    SharedManager.dismissHUD(viewController: self)
                    if let status = (responseObject.result.value! as AnyObject).value(forKeyPath: "success.status")
                    {
                        if "\(status)" == "200"
                        {
                            if "\(status)" == "200"
                            {
                                self.productImageStr = "\((responseObject.result.value! as AnyObject).value(forKey: "filepath")!)"
                            }
                            else
                            {
                                SharedManager.showAlertWithMessage(title: "Sorry", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "success.message") as! String, viewController: self)
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
                    SharedManager.dismissHUD(viewController: self)
                    let error : Error = responseObject.result.error!
                    print(error.localizedDescription)
                    if "\(error.localizedDescription))" == "The Internet connection appears to be offline"
                    {
                        SharedManager.showAlertWithMessage(title: "Sorry", alertMessage: "The Internet connection appears to be offline", viewController: self)
                    }
                }
            }
        }
        else
        {
            SharedManager.showAlertWithMessage(title: "Sorry", alertMessage: "The Internet connection appears to be offline", viewController: self)
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
            
            let params = [
                "page_per_unit" : limit,
                "page" : page,
                "category_id" :categoryId,
                "sub_category_id" :subCategoryId
                
            ] as [String : Any]
            
            let urlStr = "\(ConfigUrl.baseUrl)product-list"
            
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
                    
                    SharedManager.dismissHUD(viewController: self)
                    if responseObject.result.isSuccess
                    {
                        SharedManager.dismissHUD(viewController: self)
                        if "\(String(describing: responseObject.response!.statusCode))" == "200"
                        {
                            let result = responseObject.result.value! as AnyObject
                            let array = (result.value(forKey: "product") as! NSArray).mutableCopy() as! NSMutableArray
                            self.productListArr.addObjects(from: array as! [Any])
                            self.tblProductList.reloadData()
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
    
    func pullToRefreshSection()
    {
        if (self.isScrolledOnceSection == true)
        {
            return
        }
        self.isScrolledOnceSection = true
        
        if pageSection <= Int(self.pageCountSection)
        {
            pageSection += 1
            
            SharedManager.showHUD(viewController: self)
            
            let urlStr = "\(ConfigUrl.baseUrl)store/section&page=\(pageSection)&limit=\(limitSection)"
            
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
                                
                                let array = (result.value(forKey: "sections") as! NSArray).mutableCopy() as! NSMutableArray
                                
                                self.sectionArr.addObjects(from: array as! [Any])
                                
                                self.tblSection.reloadData()
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
                        self.isScrolledOnceSection = false
                }
            }
            else
            {
                SharedManager.showHUD(viewController: self)
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
            self.isScrolledOnceSection = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if scrollView == self.wkwebView
        {
            if (scrollView.contentOffset.x > 0)
            {
                scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
            }
        }
        else
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
                if pagenationType == "section"
                {
                    if isScrolledOnceSection == false
                    {
                        //self.pullToRefreshSection()
                    }
                }
                else
                {
                    if isScrolledOnce == false
                    {
                        self.pullToRefresh()
                    }
                }
                
            }
        }
    }
    
    //MARK: UITableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == tblProductList
        {
            return productListArr.count
        }
        else if tableView == tblSection
        {
            return sectionArr.count
        }
        else
        {
            if self.typeTable == "language"
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
        if tableView == tblProductList
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCell") as! ProductTblCell
            
            cell.lblProductName.text = "\((productListArr.object(at: indexPath.row) as AnyObject).value(forKey: "item_name")!)"
            cell.lblProductPrice.text = "\((productListArr.object(at: indexPath.row) as AnyObject).value(forKey: "price")!)"
            
            let productStatus = "\((productListArr.object(at: indexPath.row) as AnyObject).value(forKey: "status")!)"
            
            if productStatus == "1" {
                cell.switchBtn.isOn = true
            }else {
                cell.switchBtn.isOn = false
            }
            
            cell.viewShadow.layer.shadowColor = UIColor.gray.cgColor
            cell.viewShadow.layer.shadowOpacity = 1
            cell.viewShadow.layer.shadowOffset = CGSize.zero
            cell.viewShadow.layer.shadowRadius = 3
            
            cell.switchBtn.addTarget(self, action: #selector(changeProductStatus(_:)), for: UIControl.Event.touchUpInside)
            cell.switchBtn.tag = (indexPath as NSIndexPath).row
            
            return cell
        }
        else if tableView == tblSection
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as! ProductTblCell
            
            cell.lblSectionName.text = "\((sectionArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
            
            let str2 = "\((sectionArr.object(at: indexPath.row) as AnyObject).value(forKey: "category_id")!)"
            
            if self.checkSection(str2) == true
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
            if self.typeTable == "language"
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
            else if typeTable == "price"
            {
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                
                if indexPath.row == 0
                {
                    cell.textLabel?.text = "YES"
                }
                else
                {
                    cell.textLabel?.text = "NO"
                }
                return cell
            }
            else if typeTable == "quantity"
            {
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                
                if indexPath.row == 0
                {
                    cell.textLabel?.text = "YES"
                }
                else
                {
                    cell.textLabel?.text = "NO"
                }
                return cell
            }
            else
            {
                
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                
                if indexPath.row == 0
                {
                    cell.textLabel?.text = "Enabled"
                }
                else
                {
                    cell.textLabel?.text = "Disabled"
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == tblProductList
        {
            return 85
        }
        else
        {
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == tblProductList
        {
            
            
        }
        else if tableView == tblSection
        {
            let selectedId = "\((sectionArr.object(at: indexPath.row) as AnyObject).value(forKey: "category_id")!)"
            let isHave:Bool = self.checkSection(selectedId)
            
            if isHave == true
            {
                let tempArr = NSMutableArray()
                tempArr.addObjects(from: selectedValuesArrSectionTemp as! [Any])
                if isHave
                {
                    for i in 0..<tempArr.count
                    {
                        let str1 = "\((tempArr[i] as AnyObject).value(forKey: "category_id")!)"
                        
                        if str1 == selectedId
                        {
                            selectedValuesArrSectionTemp.removeObject(at: i)
                        }
                    }
                }
            }
            else
            {
                let currentArr : NSDictionary  = sectionArr.object(at: indexPath.row) as! NSDictionary
                let sectionDict = NSMutableDictionary()
                sectionDict.setObject("\(String(describing: currentArr.value(forKey: "category_id")!))", forKey: "category_id" as NSCopying)
                selectedValuesArrSectionTemp.add(sectionDict)
            }
            self.tblSection.reloadData()
        }
        else
        {
            if self.typeTable == "language"
            {
                self.lblLanguage.text = "\((languageArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
                self.selectedLanguageId = "\((languageArr.object(at: indexPath.row) as AnyObject).value(forKey: "language_id")!)"
                self.productInfoAPI()
                self.popover.dismiss()
            }
            else if self.typeTable == "price"
            {
                if indexPath.row == 0
                {
                    self.txtPriceOnSelection.text = "YES"
                    self.txtPrice.isUserInteractionEnabled = false
                    self.txtDiscountPrice.isUserInteractionEnabled = false
                    self.txtPrice.text = ""
                    self.txtDiscountPrice.text = ""
                    self.btnStartDate.isEnabled = false
                    self.btnEndDate.isEnabled = false
                    self.txtStartDate.isHidden = true
                    self.txtEndDate.isHidden = true
                    self.txtStartDate.text = ""
                    self.txtEndDate.text = ""
                }
                else
                {
                    self.txtPriceOnSelection.text = "NO"
                    self.txtPrice.isUserInteractionEnabled = true
                    self.txtDiscountPrice.isUserInteractionEnabled = true
                    self.txtStartDate.isHidden = false
                    self.txtEndDate.isHidden = false
                    self.btnStartDate.isEnabled = true
                    self.btnEndDate.isEnabled = true
                }
                self.popover.dismiss()
            }
            else if self.typeTable == "quantity"
            {
                if indexPath.row == 0
                {
                    self.txtQuantity.text = "YES"
                    self.txtQuantityValue.isHidden = false
                }
                else
                {
                    self.txtQuantity.text = "NO"
                    self.txtQuantityValue.isHidden = true
                    self.txtQuantityValue.text = ""
                }
                self.popover.dismiss()
            }
            else
            {
                if statusType == "filter"
                {
                    if indexPath.row == 0
                    {
                        self.txtFilterStatus.text = "Enabled"
                        
                    }
                    else
                    {
                        self.txtFilterStatus.text = "Disabled"
                        
                    }
                    self.popover.dismiss()
                }
                else if statusType == "productDetail"
                {
                    if indexPath.row == 0
                    {
                        self.txtStatus.text = NSLocalizedString("Enabled", comment: "")
                        
                    }
                    else
                    {
                        self.txtStatus.text = NSLocalizedString("Disabled", comment: "")
                        
                    }
                    self.popover.dismiss()
                }
                else
                {
                    if indexPath.row == 0
                    {
                        self.txtCategoryStatus.text = NSLocalizedString("Enabled", comment: "")
                        
                    }
                    else
                    {
                        self.txtCategoryStatus.text = NSLocalizedString("Disabled", comment: "")
                        
                    }
                }
                self.popover.dismiss()
            }
        }
    }

    // MARK: Button Action
    
    @IBAction func clickAddNew(_ sender: Any)
    {
        saveType = "new"
        clearFields()
    }
    
    @objc func editProduct(_ sender : UIButton)
    {
        self.productId = "\((productListArr.object(at: sender.tag) as AnyObject).value(forKey: "product_id")!)"
        self.saveType = "edit"
        self.viewLanguage.isHidden = false
        self.mainScroll.scrollsToTop = true
        if sectionArr.count == 0
        {
            getCategoryList()
        }
        clearFields()
        productInfoAPI()
    }
    
    @objc func deleteProduct(_ sender : UIButton)
    {
        let alert = UIAlertController(title: NSLocalizedString("Are you sure?", comment: ""), message: NSLocalizedString("Do you want to remove this product", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
            
            let productId = "\((self.productListArr.object(at: sender.tag) as AnyObject).value(forKey: "product_id")!)"
            
            let params = ["product_id" : productId,
                          
                          ] as [String : Any]
            
            let urlStr = "\(ConfigUrl.baseUrl)store/product/delete&product_id=\(productId)"
            
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
                
                Alamofire.request(request).responseJSON
                    { (responseObject) -> Void in
                        
                        if responseObject.result.isSuccess
                        {
                            SharedManager.dismissHUD(viewController: self)
                            let result = responseObject.result.value as AnyObject
                            if "\(String(describing: responseObject.response!.statusCode))" == "200"
                            {
                                let result = responseObject.result.value as AnyObject
                                SharedManager.showAlertWithMessage(title: "", alertMessage: NSLocalizedString("Successfully Deleted", comment: ""), viewController: self)
                                self.productListAPI()
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
    
    @IBAction func addProductImages(_ sender: Any)
    {
        let actionSheet: UIAlertController = UIAlertController(title: NSLocalizedString("Select Product Image", comment: ""), message: "", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            print("Cancel")
        }
        actionSheet.addAction(cancelActionButton)
        
        let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default)
        { _ in
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
            {
                
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.imagePicker.cameraCaptureMode = .photo
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else
            {
                SharedManager.showAlertWithMessage(title: NSLocalizedString("Camera Not Found", comment: ""), alertMessage: NSLocalizedString("This device has no Camera", comment: ""), viewController: self)
            }
        }
        actionSheet.addAction(cameraAction)
        
        let galleryAction = UIAlertAction(title: NSLocalizedString("Gallery", comment: ""), style: .default)
        { _ in
            
            self.selectImage()
        }
        actionSheet.addAction(galleryAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func changeProductStatus(_ sender : UIButton)
    {
        self.productId = "\((productListArr.object(at: sender.tag) as AnyObject).value(forKey: "product_item_id")!)"
        updateProductStatus(productId: self.productId)
    }
    
    func selectImage()
    {
        guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else {
            //Show error to user?
            return
        }
        
        //Example Instantiating OpalImagePickerController with Closures
        let imagePicker = OpalImagePickerController()
        imagePicker.maximumSelectionsAllowed = 1
        imagePicker.allowedMediaTypes = Set([PHAssetMediaType.image])
        
        let configuration = OpalImagePickerConfiguration()
        configuration.maximumSelectionsAllowedMessage = NSLocalizedString("You can upload any one image only!", comment: "")
        imagePicker.configuration = configuration
        
        //Present Image Picker
        presentOpalImagePickerController(imagePicker, animated: true, select: { (assets) in
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            // this one is key
            requestOptions.isSynchronous = true
            
            var params = [String : Any]()
            
            let asset = (assets as AnyObject).object(at: 0) as PHAsset
            if (asset.mediaType == PHAssetMediaType.image)
            {
                PHImageManager.default().requestImage(for: asset , targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestOptions, resultHandler: { (pickedImage, info) in
                    
                    self.imgProductImage.contentMode = .scaleAspectFit
                    self.imgProductImage.image = pickedImage
                    
                    let imageData = pickedImage?.jpegData(compressionQuality: 0.01)
                    let baseStr = imageData?.base64EncodedString(options: .lineLength64Characters)
                    
                    params = ["file": baseStr!, "filename": "logo.jpg"]
                })
            }
            
            if Connectivity.isConnectedToInternet()
            {
                let urlStr = "\(ConfigUrl.baseUrl)store/product/upload"
                
                let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
                var request = URLRequest(url: URL(string: setFinalURl)!)
                request.httpMethod = HTTPMethod.post.rawValue
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                // request.setValue(userIDStr, forHTTPHeaderField: "Driver-Authorization")
                
                let setTemp: [String : Any] = params
                
                if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
                    //  let jsonString = String(data: jsonData , encoding: .utf8)!
                    request.httpBody = jsonData
                }
                
                //  request.httpBody = testData
                SharedManager.showHUD(viewController: self)
                Alamofire.request(request).responseJSON { (responseObject) -> Void in
                    
                    if responseObject.result.isSuccess
                    {
                        SharedManager.dismissHUD(viewController: self)
                        
                        if let status = (responseObject.result.value! as AnyObject).value(forKeyPath: "success.status")
                        {
                            if "\(status)" == "200"
                            {
                                self.productImageStr = "\((responseObject.result.value! as AnyObject).value(forKey: "filepath")!)"
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
                //let storyboard = UIStoryboard(name: "Main", bundle: nil)
                // let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController") as! ErrorViewController
                // self.present(viewController, animated: true, completion: { () -> Void in
                // })
            }
            //Dismiss Controller
            imagePicker.dismiss(animated: true, completion: nil)
        }, cancel: {
            
        })
    }
    
    @IBAction func clickPriceOnSelection(_ sender: Any)
    {
        view.endEditing(true)
        self.typeTable = "price"
        let tableView = UITableView(frame: CGRect(x: self.txtPriceOnSelection.frame.origin.x, y: 0, width: self.txtName.frame.size.width, height: 2*45))
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
        self.popover.show(tableView, fromView: self.txtPriceOnSelection)
    }
    
    @IBAction func clickQuantity(_ sender: Any)
    {
        view.endEditing(true)
        self.typeTable = "quantity"
        let tableView = UITableView(frame: CGRect(x: 10, y: 0, width: self.viewQuantity.frame.size.width, height: 2*45))
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
        self.popover.show(tableView, fromView: self.viewQuantity)
    }
    
    @IBAction func clickVeg(_ sender: Any)
    {
        if self.btnVeg.currentImage == UIImage(named: "ic_radio_check"){
            var image = UIImage(named: "ic_radio_uncheck")
            self.btnVeg.setImage(image, for: .normal)
            image = UIImage(named: "ic_radio_uncheck")
            self.btnNonVeg.setImage(image, for: .normal)
        }else{
            var image = UIImage(named: "ic_radio_check")
            self.btnVeg.setImage(image, for: .normal)
            image = UIImage(named: "ic_radio_uncheck")
            self.btnNonVeg.setImage(image, for: .normal)
        }
    }
    
    @IBAction func clickNonVeg(_ sender: Any)
    {
        if self.btnNonVeg.currentImage == UIImage(named: "ic_radio_check"){
            var image = UIImage(named: "ic_radio_uncheck")
            self.btnVeg.setImage(image, for: .normal)
            image = UIImage(named: "ic_radio_uncheck")
            self.btnNonVeg.setImage(image, for: .normal)
        }else{
            var image = UIImage(named: "ic_radio_uncheck")
            self.btnVeg.setImage(image, for: .normal)
            image = UIImage(named: "ic_radio_check")
            self.btnNonVeg.setImage(image, for: .normal)
        }
    }
    
    @IBAction func clickStatus(_ sender: Any)
    {
        view.endEditing(true)
        self.typeTable = "status"
        self.statusType = "productDetail"
        let tableView = UITableView(frame: CGRect(x: 10, y: 0, width: self.txtStatus.frame.size.width, height: 2*45))
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
        self.popover.show(tableView, fromView: self.txtStatus)
    }
    
    @IBAction func clickStatusCategory(_ sender: Any)
    {
        view.endEditing(true)
        self.typeTable = "status"
        self.statusType = "category"
        let tableView = UITableView(frame: CGRect(x: 10, y: 0, width: self.txtCategoryStatus.frame.size.width, height: 2*45))
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
        self.popover.show(tableView, fromView: self.txtCategoryStatus)
    }
    
    @IBAction func clickSection(_ sender: Any)
    {
        self.view.endEditing(true)
        if sectionArr.count != 0
        {
            self.viewSection.isHidden = false
            self.viewBlurSection.isHidden = false
            self.selectedValuesArrSectionTemp = []
            self.selectedValuesArrSectionTemp.addObjects(from: selectedValuesArrSection as! [Any])
            self.tblSection.reloadData()
        }
        else
        {
            self.selectedValuesArrSectionTemp = []
            self.selectedValuesArrSectionTemp.addObjects(from: selectedValuesArrSection as! [Any])
            getCategoryList()
            sectionType = "sectionTbl"
        }
        pagenationType = "section"
    }
    
    @IBAction func clickAddCategory(_ sender: Any)
    {
        self.txtCategoryName.text = ""
        self.txtCategoryStatus.text = ""
        self.txtCategorySortOrder.text = ""
        self.vwAddCategory.isHidden = false
    }
    
    @IBAction func clickCancelCategory(_ sender: Any)
    {
        self.vwAddCategory.isHidden = true
    }
    
    @IBAction func clickSaveCategory(_ sender: Any)
    {
        
        self.view.endEditing(true)
        
        var selectedStatus = ""
        
        if self.txtCategoryStatus.text! == NSLocalizedString("Enabled", comment: "")
        {
            selectedStatus = "1"
        }
        else
        {
            selectedStatus = "0"
        }
        let dict = NSMutableDictionary()
        
        dict.setValue(self.txtCategoryName.text!, forKey: languageID)
        let params = [
            "category_description" : dict,
            "status" : selectedStatus,
            "sort_order" : self.txtCategorySortOrder.text!,
            "language_id" : languageID,
            "language_code" : languageCode
            ] as [String : Any]
        let urlStr = "\(ConfigUrl.baseUrl)store/product/createCategory"
        
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
                        self.vwAddCategory.isHidden = true
                        SharedManager.showAlertWithMessage(title: NSLocalizedString("", comment: ""), alertMessage: NSLocalizedString("Category Added Successfully", comment: ""), viewController: self)
                        self.getCategoryList()
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
    
    //Save Product and Category
    
    @IBAction func clickSaveSection(_ sender: Any)
    {
        var sectionStr = String()
        
        if self.selectedValuesArrSectionTemp.count != 0
        {
            for i in 0..<self.selectedValuesArrSectionTemp.count
            {
                let selectedID = "\((self.selectedValuesArrSectionTemp.object(at: i) as AnyObject).value(forKey: "category_id")!)"
                
                for j in 0..<self.sectionArr.count
                {
                    let id = "\((self.sectionArr.object(at: j) as AnyObject).value(forKey: "category_id")!)"
                    if selectedID == id
                    {
                        sectionStr = sectionStr + "\((self.sectionArr.object(at: j) as AnyObject).value(forKey: "name")!), "
                    }
                }
                
            }
            sectionStr.removeLast(2)
            self.lblSection.text = sectionStr
            self.selectedValuesArrSection = []
            self.selectedValuesArrSection.addObjects(from: selectedValuesArrSectionTemp as! [Any])
            self.viewSection.isHidden = true
            self.viewBlurSection.isHidden = true
            setFrames()
        }
        else
        {
            self.lblSection.text = ""
            self.selectedValuesArrSection.removeAllObjects()
            
            self.viewSection.isHidden = true
            self.viewBlurSection.isHidden = true
            setFrames()
        }
        pagenationType = "home"
    }
    
    @IBAction func clickCancelSection(_ sender: Any)
    {
        self.viewSection.isHidden = true
        self.viewBlurSection.isHidden = true
        pagenationType = "home"
    }
    
    @IBAction func clickSaveProductDetail(_ sender: Any)
    {
        if self.txtName.text == ""
        {
            SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please Enter Product Name", comment: ""), viewController: self)
            
        }
        else
        {
            if txtPriceOnSelection.text == "NO"
            {
                if txtPrice.text != ""
                {
                    if saveType == "edit"
                    {
                        productEdit(productId: self.productId)
                    }
                    else
                    {
                        productAdd()
                    }
                }
                else
                {
                    
                    SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please Enter Price", comment: ""), viewController: self)

                }
            }
            else
            {
                if saveType == "edit"
                {
                    productEdit(productId: self.productId)
                }
                else
                {
                    productAdd()
                }
            }
        }
    }
    
    @IBAction func clickCancelProductDetail(_ sender: Any)
    {
        self.viewProductDetail.isHidden = true
    }
    
    @IBAction func clickEditLanguage(_ sender: UIButton)
    {
        self.typeTable = "language"
        let tableView = UITableView(frame: CGRect(x: self.viewLanguage.frame.origin.x, y: 0, width: self.viewLanguage.frame.size.width, height: CGFloat(languageArr.count * 45)))
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
        self.popover.show(tableView, fromView: self.viewLanguage)
    }
    
    @IBAction func clickStartDate(_ sender: Any)
    {
        view.endEditing(true)
        self.viewDatePicker.isHidden = false
        dateType = "start"
        self.datePicker.minimumDate = Date()
        self.txtEndDate.text = ""
    }
    
    @IBAction func clickEndDate(_ sender: Any)
    {
        view.endEditing(true)
        self.viewDatePicker.isHidden = false
        dateType = "end"
        let date = self.txtStartDate.text
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let endDate = dateFormatter.date(from: date!)
        self.datePicker.minimumDate = endDate
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
    
    //MARK: Filter and Sort
    @IBAction func clickSort(_ sender: Any)
    {
        self.viewBlurSort.isHidden = false
        self.mainSortView.isHidden = false
    }
    
    @IBAction func clickCancelSort(_ sender: Any)
    {
        self.viewBlurSort.isHidden = true
        self.mainSortView.isHidden = true
        self.mainFilterView.isHidden = true
       
    }
    
    @IBAction func clickFilter(_ sender: Any)
    {
        self.mainFilterView.isHidden = false
        self.viewBlurSort.isHidden = false
    }
    
    @IBAction func clickFilterApply(_ sender: Any)
    {
        var selectedStatus = ""
        
        if self.txtFilterStatus.text! == "Enabled"
        {
            selectedStatus = "1"
        }
        else
        {
            selectedStatus = "0"
        }
        page = 1
        let urlStr = "\(ConfigUrl.baseUrl)store/product/products&filter_name=\(self.txtFilterName.text!)&filter_status=\(selectedStatus)&page=\(page)&limit=\(limit)"
        
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
                            
                            self.productListArr = (result.value(forKey: "products") as! NSArray).mutableCopy() as! NSMutableArray
                            
                            if self.productListArr.count == 0
                            {
                                let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Product list is empty. Please add new Product", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
                                    
                                    
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                            let total = "\(String(describing: result.value(forKey: "total")!))"
                            self.pageCount = Double(Int(total)!/Int(self.limit)!)
                            self.mainFilterView.isHidden = true
                            self.viewBlurSort.isHidden = true
                            self.tblProductList.reloadData()
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
    
    @IBAction func clickFilterCancel(_ sender: Any)
    {
        self.mainFilterView.isHidden = true
        self.viewBlurSort.isHidden = true
    }
    
    @IBAction func clickSortOption(_ sender: UIButton)
    {
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
        
        productListAPI()
        self.viewBlurSort.isHidden = true
        self.mainSortView.isHidden = true
    }
    
    @IBAction func clickStatusFilter(_ sender: Any)
    {
        self.typeTable = "status"
        self.statusType = "filter"
        let tableView = UITableView(frame: CGRect(x: self.txtFilterStatus.frame.origin.x, y: 0, width: self.txtFilterName.frame.size.width, height: 2*45))
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
        self.popover.show(tableView, fromView: self.txtFilterStatus)
    }
    
    @IBAction func clickSearch(_ sender : Any){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "SearchVc") as! SearchVc
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func clickClearSearch(_ sender : Any){
        view.endEditing(true)
        self.myTxtSearch.text = ""
        self.myViewSearchClear.isHidden = true
        self.productListArr.removeAllObjects()
        productListAPI()
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

extension ProductsVc: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == myCollCategory {
            return categoryArr.count
        }else {
            return subCategoryArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == myCollCategory {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCatCell", for: indexPath as IndexPath) as! ProductCategoryCollCell
            cell.lblCategoryTitle.text = "\((categoryArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
            if categorySelectedIndex == indexPath.row {
                cell.lblLine.isHidden = true
                cell.viewSelected.isHidden = false
                cell.lblCategoryTitle.font = UIFont(name: "System", size: 14)
                cell.lblCategoryTitle.textColor = themeColor
            }else {
                cell.lblLine.isHidden = true
                cell.viewSelected.isHidden = true
                cell.lblCategoryTitle.font = UIFont(name: "System", size: 14)
                cell.lblCategoryTitle.textColor = .black
            }
            
            cell.lblCategoryTitle.frame.size.height = 33
            cell.lblCategoryTitle.translatesAutoresizingMaskIntoConstraints = true
            
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCatCell", for: indexPath as IndexPath) as! ProductCategoryCollCell
            cell.lblCategoryTitle.text = "\((subCategoryArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
            if subCategorySelectedIndex == indexPath.row {
                cell.lblLine.isHidden = true
                cell.lblCategoryTitle.font = UIFont(name: "System", size: 14)
                cell.lblCategoryTitle.layer.borderColor = themeColor.cgColor
                cell.lblCategoryTitle.layer.borderWidth = 1
                cell.lblCategoryTitle.backgroundColor = UIColor(named: "clr_light_red")
                cell.lblCategoryTitle.textColor = themeColor
                cell.lblCategoryTitle.layer.cornerRadius = 23
                cell.lblCategoryTitle.layer.masksToBounds = true
            
            }else {
                cell.lblLine.isHidden = true
                cell.lblCategoryTitle.font = UIFont(name: "System", size: 14)
                cell.lblCategoryTitle.layer.borderColor = UIColor.lightGray.cgColor
                cell.lblCategoryTitle.layer.borderWidth = 1
                cell.lblCategoryTitle.backgroundColor = .white
                cell.lblCategoryTitle.textColor = .black
                cell.lblCategoryTitle.layer.cornerRadius = 23
                cell.lblCategoryTitle.layer.masksToBounds = true
                
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == myCollCategory {
            categorySelectedIndex = indexPath.row
            subCategorySelectedIndex = 0
            self.myCollCategory.reloadData()
        }else {
            subCategorySelectedIndex = indexPath.row
            self.myCollSubCategory.reloadData()
        }
        self.getCategoryList()
    }
}

extension ProductsVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == myCollCategory {
            return CGSize(width: 150, height: 50)
        }else {
            return CGSize(width: 150, height: 50)
        }
    }
}

extension ProductsVc : UITextFieldDelegate{
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            print(txtAfterUpdate)
            self.myViewSearchClear.isHidden = txtAfterUpdate == "" ? true : false
            if txtAfterUpdate.count > 2{
                callGetSearchRestaurantApi(searchKey: txtAfterUpdate)
            }else if txtAfterUpdate == ""{
                callGetSearchRestaurantApi(searchKey: txtAfterUpdate)
            }
        }
        return true
    }
}
