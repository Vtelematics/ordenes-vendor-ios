//
//  SectionVc.swift
//  Foodesoft Vendor
//
//  Created by Adyas Infotech on 04/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import Alamofire

class SectionVc: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var sectionArr = NSMutableArray()
    
    @IBOutlet weak var tblSectionList: UITableView!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var viewEdit: UIView!
    @IBOutlet weak var viewBlur: UIView!
    @IBOutlet weak var txtDescriptionEng: UITextField!
    @IBOutlet weak var txtDescriptionArabic: UITextField!
    @IBOutlet weak var txtSortOrder: UITextField!
    @IBOutlet weak var txtStatus: UITextField!
    @IBOutlet weak var lblHeader: UILabel!
    
    var typeStr: String = "new"
    var sectionID = ""
    
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

        self.title = NSLocalizedString("Section", comment: "")
        self.viewBlur.isHidden = true
        self.viewEdit.isHidden = true
        
        viewShadow.layer.shadowColor = UIColor.gray.cgColor
        viewShadow.layer.shadowOpacity = 1
        viewShadow.layer.shadowOffset = CGSize.zero
        viewShadow.layer.shadowRadius = 3
        
        sectionListAPI()
        // Do any additional setup after loading the view.
    }
    
    //MARK: API
    func sectionListAPI()
    {
        page = 1
        let urlStr = "\(ConfigUrl.baseUrl)store/section&page=\(page)&limit=\(limit)"
        
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
                            self.sectionArr = (result.value(forKey: "sections") as! NSArray).mutableCopy() as! NSMutableArray
                            
                            if self.sectionArr.count == 0
                            {
                                let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Section list is empty. Do you want add new Section?", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
                                    
                                    self.typeStr = NSLocalizedString("new", comment: "")
                                    self.lblHeader.text = NSLocalizedString("Add Section", comment: "")
                                    self.txtDescriptionEng.text = ""
                                    self.txtDescriptionArabic.text = ""
                                    self.txtSortOrder.text = ""
                                    self.txtStatus.text = NSLocalizedString("Enabled", comment: "")
                                    
                                    self.viewBlur.isHidden = false
                                    self.viewEdit.isHidden = false
                                    
                                }))
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil))
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                            let total = "\(String(describing: result.value(forKey: "total_sections")!))"
                            self.pageCount = Double(Int(total)!/Int(self.limit)!)
                                
                            self.tblSectionList.reloadData()
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

    func addNew()
    {
        self.view.endEditing(true)
        
        let dict = NSMutableDictionary()
        
        dict.setObject(self.txtDescriptionEng.text!, forKey: "1" as NSCopying)
        dict.setObject(self.txtDescriptionArabic.text!, forKey: "2" as NSCopying)
        
        var selectedStatus = ""
        
        if self.txtStatus.text! == NSLocalizedString("Enabled", comment: "")
        {
            selectedStatus = "1"
        }
        else
        {
            selectedStatus = "0"
        }
        
        let params = [
            "section_description" : dict,
            "status" : selectedStatus,
            "sort_order" : self.txtSortOrder.text!
            
            ] as [String : Any]
        
        let urlStr = "\(ConfigUrl.baseUrl)store/section/add"
        
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
                        self.viewBlur.isHidden = true
                        self.viewEdit.isHidden = true
                        
                        SharedManager.showAlertWithMessage(title: NSLocalizedString("", comment: ""), alertMessage: NSLocalizedString("Section Added Successfully", comment: ""), viewController: self)
                        
                        self.sectionListAPI()
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
    
    func edit()
    {
        self.view.endEditing(true)
        
        
        let dict = NSMutableDictionary()
        
        dict.setObject(self.txtDescriptionEng.text!, forKey: "1" as NSCopying)
        dict.setObject(self.txtDescriptionArabic.text!, forKey: "2" as NSCopying)
        
        var selectedStatus = ""
        
        if self.txtStatus.text! == NSLocalizedString("Enabled", comment: "")
        {
            selectedStatus = "1"
        }
        else
        {
            selectedStatus = "0"
        }
        
        let params = [
            "section_description" : dict,
            "status" : selectedStatus,
            "section_id" : sectionID,
            "sort_order" : self.txtSortOrder.text!
            
            ] as [String : Any]
        let urlStr = "\(ConfigUrl.baseUrl)store/section/edit"
        
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
                        self.viewEdit.isHidden = true
                        
                        SharedManager.showAlertWithMessage(title: NSLocalizedString("", comment: ""), alertMessage: NSLocalizedString("Section Edited Successfully", comment: ""), viewController: self)
                        
                        self.sectionListAPI()
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
            
            let urlStr = "\(ConfigUrl.baseUrl)store/section&page=\(page)&limit=\(limit)"
            
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
                            print(responseObject)
                            if "\(String(describing: responseObject.response!.statusCode))" == "200"
                            {
                                let result = responseObject.result.value! as AnyObject
                                let array = (result.value(forKey: "sections") as! NSArray).mutableCopy() as! NSMutableArray
                                
                                self.sectionArr.addObjects(from: array as! [Any])
                                
                                self.tblSectionList.reloadData()
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
        if tableView == tblSectionList
        {
            return sectionArr.count
        }
        else
        {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == tblSectionList
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as! OrderTblCell
            
            cell.lblSectionName.text = "\((sectionArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
            cell.lblSectionStatus.text = "\((sectionArr.object(at: indexPath.row) as AnyObject).value(forKey: "status")!)"
            cell.btnEditSection.addTarget(self, action: #selector(SectionVc.editSection(_:)), for: UIControl.Event.touchUpInside)
            
            cell.btnEditSection.tag = (indexPath as NSIndexPath).row
            
            cell.btnDeleteSection.addTarget(self, action: #selector(SectionVc.deleteSection(_:)), for: UIControl.Event.touchUpInside)
            cell.btnDeleteSection.tag = (indexPath as NSIndexPath).row
            
            cell.imgEdit.image = UIImage (named: "ic_edit")
            cell.imgEdit.image = cell.imgEdit.image!.withRenderingMode(.alwaysTemplate)
            cell.imgEdit.tintColor = UIColor.lightGray
            
            cell.imgDelete.image = UIImage (named: "ic_delete")
            cell.imgDelete.image = cell.imgDelete.image!.withRenderingMode(.alwaysTemplate)
            cell.imgDelete.tintColor = UIColor.lightGray
            
            cell.viewShadowSection.layer.shadowColor = UIColor.gray.cgColor
            cell.viewShadowSection.layer.shadowOpacity = 1
            cell.viewShadowSection.layer.shadowOffset = CGSize.zero
            cell.viewShadowSection.layer.shadowRadius = 3
            
            return cell
        }
        else
        {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            
            if indexPath.row == 0
            {
                cell.textLabel?.text = NSLocalizedString("Enabled", comment: "")
            }
            else
            {
                cell.textLabel?.text = NSLocalizedString("Disabled", comment: "")
            }
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == tblSectionList
        {
            return 76
        }
        else
        {
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
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
    @objc func editSection(_ sender : UIButton)
    {
        SharedManager.showHUD(viewController: self)
        
        self.sectionID = "\((sectionArr.object(at: sender.tag) as AnyObject).value(forKey: "category_id")!)"
        
        let urlStr = "\(ConfigUrl.baseUrl)store/section/info&section_id=\(sectionID)"
        
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
                        SharedManager.dismissHUD(viewController: self)
                        
                        if "\(String(describing: responseObject.response!.statusCode))" == "200"
                        {
                            let result = responseObject.result.value! as AnyObject
                            
                            let sectionInfo = result.value(forKey: "section_info") as! NSDictionary
                            
                            self.txtSortOrder.text = "\(String(describing: sectionInfo.value(forKey: "sort_order")!))"
                            self.txtStatus.text = "\(String(describing: sectionInfo.value(forKey: "status")!))"
                            
                            let sectionDescription = sectionInfo.value(forKey: "section_description") as! NSArray
                            self.txtDescriptionEng.text = "\((sectionDescription.object(at: 0) as AnyObject).value(forKey: "name")!)"
                            
                            self.txtDescriptionArabic.text = "\((sectionDescription.object(at: 1) as AnyObject).value(forKey: "name")!)"
                            
                            self.lblHeader.text = NSLocalizedString("Edit Section", comment: "")
                            self.typeStr = "edit"
                            
                            self.viewBlur.isHidden = false
                            self.viewEdit.isHidden = false
                            
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
    
    @objc func deleteSection(_ sender : UIButton)
    {
        let alert = UIAlertController(title: NSLocalizedString("Are you sure?", comment: ""), message: NSLocalizedString("Do you want to remove this Section", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            self.sectionID = "\((self.sectionArr.object(at: sender.tag) as AnyObject).value(forKey: "category_id")!)"
            
            let urlStr = "\(ConfigUrl.baseUrl)store/section/delete&section_id=\(self.sectionID)"
            
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
                                let result = responseObject.result.value! as AnyObject
                                SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Successfully Deleted", comment: ""), viewController: self)
                                self.sectionListAPI()
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
   
    
    @IBAction func clickAddNew(_ sender: Any)
    {
        typeStr = "new"
        self.lblHeader.text = NSLocalizedString("Add Section", comment: "")
        self.txtDescriptionEng.text = ""
        self.txtDescriptionArabic.text = ""
        self.txtSortOrder.text = ""
        self.txtStatus.text = NSLocalizedString("Enabled", comment: "")
        
        self.viewBlur.isHidden = false
        self.viewEdit.isHidden = false
    }
    
    @IBAction func clickSave(_ sender: Any)
    {
        view.endEditing(true)
        if self.txtDescriptionEng.text == ""
        {
            SharedManager.showAlertWithMessage(title: NSLocalizedString("", comment: "Sorry"), alertMessage: NSLocalizedString("Please Enter Name in English", comment: ""), viewController: self)
        }
        else if self.txtDescriptionArabic.text == ""
        {
            SharedManager.showAlertWithMessage(title: NSLocalizedString("", comment: "Sorry"), alertMessage: NSLocalizedString("Please Enter Name in Arabic", comment: ""), viewController: self)
        }
        else
        {
            if typeStr == "new"
            {
                self.addNew()
            }
            else
            {
                self.edit()
            }
        }
    }
    
    @IBAction func clickCancel(_ sender: Any)
    {
        view.endEditing(true)
        self.viewBlur.isHidden = true
        self.viewEdit.isHidden = true
    }
    
    @IBAction func clickStatus(_ sender: Any)
    {
        view.endEditing(true)
        let tableView = UITableView(frame: CGRect(x: self.txtStatus.frame.origin.x, y: 0, width: self.txtSortOrder.frame.size.width, height: 2*45))
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
    
    
    
    /*// MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
