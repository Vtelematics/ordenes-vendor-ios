//
//  ViewController.swift
//  Foodesoft Vendor
//
//  Created by Apple on 22/11/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import OpalImagePicker
import Photos
import OneSignal
import GoogleMaps
import GooglePlaces
import EventKit
protocol loginIntimation {
    func loginSuccess()
    func loginFailure()
}

class LoginVc: UIViewController,CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, CalendarViewDataSource, CalendarViewDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate, GMSMapViewDelegate {
 
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnRegisterNow: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tblRegister: UITableView!
    @IBOutlet weak var viewRegister: UIView!
    @IBOutlet weak var lblJoinNow: UILabel!
    
    //Restro Name
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var viewRestroName: UIView!
    @IBOutlet weak var txtRestroNameEng: UITextField!
    @IBOutlet weak var txtRestroNameAr: UITextField!
    
    //Personal info
    @IBOutlet weak var viewPersonalInfo: UIView!
    @IBOutlet weak var txtOwnername: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var txtRegPwd: UITextField!
    @IBOutlet weak var txtConfirmPwd: UITextField!
    @IBOutlet weak var txtStatus: UITextField!
    @IBOutlet weak var lblAddress: UILabel!
    //@IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    // Restaurant info
    @IBOutlet weak var viewRestaurantInfo: UIView!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var imgBanner: UIImageView!
    @IBOutlet weak var txtPreparationTime: UITextField!
    @IBOutlet weak var tblCuisines: UITableView!
    @IBOutlet weak var viewRestroBottom: UIView!
    
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //Payment Method and delivery
    @IBOutlet weak var viewPaymentMethod: UIView!
    @IBOutlet weak var tblPaymentMethod: UITableView!
    @IBOutlet weak var switchPickup: UISwitch!
    @IBOutlet weak var switchDelivery: UISwitch!
    @IBOutlet weak var viewPaymentBottom: UIView!
    
    // Working Hours
    @IBOutlet weak var viewWorkingHours: UIView!
    @IBOutlet weak var switchSun: UISwitch!
    
    @IBOutlet weak var txtSunStart: UITextField!
    @IBOutlet weak var txtSunEnd: UITextField!
    @IBOutlet weak var switchMon: UISwitch!
    @IBOutlet weak var txtMonStart: UITextField!
    @IBOutlet weak var txtMonEnd: UITextField!
    @IBOutlet weak var switchTue: UISwitch!
    @IBOutlet weak var txtTueStart: UITextField!
    @IBOutlet weak var txtTueEnd: UITextField!
    @IBOutlet weak var switchWed: UISwitch!
    @IBOutlet weak var txtWedStart: UITextField!
    @IBOutlet weak var txtWedEnd: UITextField!
    @IBOutlet weak var switchThu: UISwitch!
    @IBOutlet weak var txtThuStart: UITextField!
    @IBOutlet weak var txtThuEnd: UITextField!
    @IBOutlet weak var switchFri: UISwitch!
    @IBOutlet weak var txtFriStart: UITextField!
    @IBOutlet weak var txtFriEnd: UITextField!
    @IBOutlet weak var switchSat: UISwitch!
    @IBOutlet weak var txtSatStart: UITextField!
    @IBOutlet weak var txtSatEnd: UITextField!
    @IBOutlet weak var datePicker2: UIDatePicker!
    @IBOutlet weak var viewDatePicker: UIView!
    @IBOutlet weak var viewBankDetails: UIView!
    @IBOutlet weak var txtPanCard: UITextField!
    @IBOutlet weak var txtAcNo: UITextField!
    @IBOutlet weak var txtIFSCCode: UITextField!
    @IBOutlet weak var lblSelectCuisine: UILabel!
    @IBOutlet weak var btnVeg: UIButton!
    @IBOutlet weak var btnNonVeg: UIButton!
    @IBOutlet weak var btnBoth: UIButton!
    // Login
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var imgShowPass: UIImageView!
    
    // Forgot Password
    @IBOutlet weak var txtForgotPassword: UITextField!
    @IBOutlet weak var viewForgetPass: UIView!
    @IBOutlet weak var viewBlur: UIView!
    
    var isFromAutoComplete = false
    var logoImageStr = ""
    var restroImageStr = ""
   
    var deviceIDStr:String = ""
    // Other objects
    var delegate:loginIntimation?
    
    var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    var typeStr: String = ""
    var isAutoComplete = Bool()
    
    var tagValue : Int = 0
    var timeType = ""
    var time = ""
    var pageType = ""
    var selectedAddress = ""
    var selectedLatitude = ""
    var selectedLongitude = ""
    var geoCoder = CLGeocoder()
    
    let imagePicker = UIImagePickerController()
    var imageType = ""
    
    var listType = ""
    var cuisinesArr = NSArray()
    var paymentMethodsArr = NSArray()
    var selectedCuisines = NSMutableArray()
    var selectedPaymentMethods = NSMutableArray()
    var didSelectDate : NSMutableArray = []
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.auto),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            let app = UIApplication.shared
            let statusBarHeight: CGFloat = app.statusBarFrame.size.height
            
            let statusbarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: statusBarHeight))
            statusbarView.backgroundColor = themeColor
            view.addSubview(statusbarView)
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = themeColor
        }
        
        let backImage = UIImage()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: UIBarButtonItem.Style.plain, target: self, action: nil)
        self.txtUserName.textAlignment = isRTLenabled == true ? .right : .left
        self.txtPassword.textAlignment = isRTLenabled == true ? .right : .left
        self.txtForgotPassword.textAlignment = isRTLenabled == true ? .right : .left
        self.navigationItem.title = NSLocalizedString("Login", comment: "")
        self.lblTitle.text = NSLocalizedString("Login", comment: "")
        let normalText = NSLocalizedString("Want to join us as a Chef?", comment: "")
        let attributedStringColor = [NSAttributedString.Key.foregroundColor : positiveBtnColor];
        let attributedString = NSAttributedString(string: NSLocalizedString("Join Now", comment: ""), attributes: attributedStringColor)
        let normalString = NSMutableAttributedString(string:normalText)
        normalString.append(attributedString)
        self.lblJoinNow.attributedText = normalString
//
//        if #available(iOS 13.4, *) {
//            datePicker?.preferredDatePickerStyle = .wheels
//            datePicker2?.preferredDatePickerStyle = .wheels
//        }
//        self.btnBack.isHidden = true
//        self.viewForgetPass.isHidden = true
//        self.viewBlur.isHidden = true
//        self.mainScrollView.isHidden = true
//        self.mainScrollView.addSubview(viewRegister)
//        self.mainScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.viewRegister.frame.size.height)
//        viewRegister.layer.shadowColor = UIColor.gray.cgColor
//        viewRegister.layer.shadowOpacity = 1
//        viewRegister.layer.shadowOffset = CGSize.zero
//        viewRegister.layer.shadowRadius = 3
//
//        self.mapView.delegate = self
//        self.locationManager.delegate = self
//        self.locationManager.requestAlwaysAuthorization()
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//
////        getRegisterFields()
//        setFrames()
//
//        CalendarView.Style.cellShape                = .bevel(8.0)
//        CalendarView.Style.cellColorDefault         = UIColor.clear
//        CalendarView.Style.cellColorToday           = positiveBtnColor
//        CalendarView.Style.cellSelectedBorderColor  = themeColor
//        CalendarView.Style.cellEventColor           = .clear
//        CalendarView.Style.headerTextColor          = .black
//        CalendarView.Style.cellTextColorDefault     = .black
//        CalendarView.Style.cellTextColorToday       = .white
//        CalendarView.Style.firstWeekday             = .sunday
//
//        calendarView.dataSource = self
//        calendarView.delegate = self
//
//        calendarView.direction = .horizontal
//        calendarView.multipleSelectionEnable = true
//        calendarView.marksWeekends = true
//
//        calendarView.backgroundColor = .white
//
//        let today = Date()
//
//        self.calendarView.loadEvents() { error in
//            if error != nil {
//                let message = "The calender could not load system events. It is possibly a problem with permissions"
//                let alert = UIAlertController(title: NSLocalizedString("Events Loading Error", comment: ""), message: message, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//
//            }
//        }
//
//        self.calendarView.setDisplayDate(today)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        //self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        //self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func clickBarButtonBack()
    {
        //self.mainView.backgroundColor = themeColor
        self.mainScrollView.isHidden = true
        self.viewDatePicker.isHidden = true
        self.btnBack.isHidden = true
        self.lblTitle.text = NSLocalizedString("", comment: "")
        self.navigationItem.title = NSLocalizedString("Login", comment: "")
        let backImage = UIImage()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: UIBarButtonItem.Style.plain, target: self, action: nil)
    }
    
    //MARK: Button Actions
    @IBAction func clickForgetPassDone(_ sender: Any)
    {
        if self.isValidEmail(testStr: txtForgotPassword.text!)
        {
            self.view.endEditing(true)
            SharedManager.showHUD(viewController: self)
            
            let params = [
                "email" : self.txtForgotPassword.text!,
                "language_id" : languageID,
                "language_code" : languageCode
                ] as [String : Any]
            
            let urlStr = "\(ConfigUrl.baseUrl)forget-password"
            let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
            var request = URLRequest(url: URL(string: setFinalURl)!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let setTemp: [String : Any] = params
            
            if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
                let jsonString = String(data: jsonData , encoding: .utf8)!
                print(jsonString)
                request.httpBody = jsonData
            }
            
            if Connectivity.isConnectedToInternet() {
                Alamofire.request(request).responseJSON { (responseObject) -> Void in
                    
                    if responseObject.result.isSuccess
                    {
                        SharedManager.dismissHUD(viewController: self)
                        let result = responseObject.result.value! as AnyObject
                        print(result)
                        if let status = (responseObject.result.value! as AnyObject).value(forKeyPath: "success.status")
                        {
                            if "\(status)" == "200" {
                                let alert = UIAlertController(title: NSLocalizedString("Information", comment: ""), message: "\(result.value(forKeyPath: "success.message")!)", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
                                    self.viewForgetPass.isHidden = true
                                    self.viewBlur.isHidden = true
                                    self.txtForgotPassword.text = ""
                                }))
                                self.present(alert, animated: true, completion: nil)
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
        else
        {
            SharedManager.showAlertWithMessage(title:"Information", alertMessage: "Please enter valid email Id", viewController: self)
        }
    }
    
    @IBAction func clickForgetPassCancel(_ sender: Any)
    {
        self.view.endEditing(true)
        self.viewForgetPass.isHidden = true
        self.viewBlur.isHidden = true
        self.txtForgotPassword.text = ""
    }
    
    @IBAction func clickStatus(_ sender: Any)
    {
        self.view.endEditing(true)
        let tableView = UITableView(frame: CGRect(x: self.txtStatus.frame.origin.x, y: 0, width: self.txtStatus.frame.size.width, height: 2*45))
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
    
    @IBAction func clickLogo(_ sender: Any)
    {
        self.view.endEditing(true)
        imageType = "logo"
        let actionSheet: UIAlertController = UIAlertController(title: NSLocalizedString("Select Store Logo", comment: ""), message: "", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            print("Cancel")
        }
        actionSheet.addAction(cancelActionButton)
        
        let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default)
        { _ in
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
            {
                self.imagePicker.delegate = self
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
    
    @IBAction func clickBannerImage(_ sender: Any)
    {
        self.view.endEditing(true)
        imageType = "banner"
        let actionSheet: UIAlertController = UIAlertController(title: NSLocalizedString("Select Store Banner Image", comment: ""), message: "", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            print("Cancel")
        }
        actionSheet.addAction(cancelActionButton)
        
        let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default)
        { _ in
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
            {
                self.imagePicker.delegate = self
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
    
    @IBAction func clickCurrentLocation(_ sender: Any)
    {
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    
    @IBAction func clickRegisterSubmit(_ sender: Any)
    {
        
        if txtRestroNameEng.text == ""
        {
            txtRestroNameEng.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.25)
            SharedManager.showAlertWithMessage(title: "Sorry!", alertMessage: "Please Enter restaurant Name", viewController: self)
        }
        else
        {
            if txtOwnername.text == ""
            {
                txtOwnername.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.25)
                SharedManager.showAlertWithMessage(title: "Sorry!", alertMessage: "Please Enter Owner Name", viewController: self)
            }
            else
            {
                if txtEmail.text == ""
                {
                    txtEmail.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.25)
                    SharedManager.showAlertWithMessage(title: "Sorry!", alertMessage: "Please Enter your Email-Id", viewController: self)
                }
                else
                {
                    if !self.isValidEmail(testStr: txtEmail.text!)
                    {
                        txtEmail.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.1)
                        SharedManager.showAlertWithMessage(title: "Sorry!", alertMessage: "Please Enter a Valid Email-Id", viewController: self)
                    }
                    else
                    {
                        if txtMobileNumber.text == ""
                        {
                            txtMobileNumber.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.25)
                            SharedManager.showAlertWithMessage(title: "Sorry!", alertMessage: "Please Enter your Mobile Number", viewController: self)
                        }
                        else
                        {
                            if txtRegPwd.text == ""
                            {
                                txtRegPwd.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.25)
                                SharedManager.showAlertWithMessage(title: "Sorry!", alertMessage: "Please Enter Password", viewController: self)
                            }
                            else
                            {
                                if txtConfirmPwd.text == ""
                                {
                                    txtConfirmPwd.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.25)
                                    SharedManager.showAlertWithMessage(title: "Sorry!", alertMessage: "Please Re-Enter Password", viewController: self)
                                }
                                else
                                {
                                    if txtRegPwd.text != txtConfirmPwd.text
                                    {
                                        txtRegPwd.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.25)
                                        txtConfirmPwd.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.25)
                                        SharedManager.showAlertWithMessage(title: "Sorry!", alertMessage: "Passwords Mismatching", viewController: self)
                                    }
                                    else
                                    {
                                        if lblAddress.text == ""
                                        {
                                            txtStatus.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.25)
                                            SharedManager.showAlertWithMessage(title: "Sorry!", alertMessage: "Please Select Address from Map", viewController: self)
                                        }
                                        else
                                        {
                                            registerUser()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func clickLogin(_ sender: Any)
    {
        if txtUserName.text == ""
        {
            txtUserName.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.25)
            SharedManager.showAlertWithMessage(title: "Sorry!", alertMessage: "Please Enter Email", viewController: self)
        }
        else
        {
            if txtPassword.text == ""
            {
                txtPassword.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.1)
                SharedManager.showAlertWithMessage(title: "Sorry!", alertMessage: "Please Enter Password", viewController: self)
            }
            else
            {
                loginUser()
            }
        }
    }
    
    @IBAction func clickForgetPassword(_ sender: Any)
    {
        self.viewForgetPass.isHidden = false
        self.viewBlur.isHidden = false
    }
    
    @IBAction func clickRegister(_ sender: Any)
    {
        var backImage = UIImage(named: "right-arrow")
        backImage = backImage?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.clickBarButtonBack))
        
        self.mainScrollView.isHidden = false
        self.locationManager.startUpdatingLocation()
        self.btnBack.isHidden = false
        self.navigationItem.title = NSLocalizedString("Sign Up", comment: "")
        
        self.txtRestroNameEng.text = ""
        self.txtRestroNameAr.text = ""
        self.txtOwnername.text = ""
        self.txtEmail.text = ""
        self.txtMobileNumber.text = ""
        self.txtRegPwd.text = ""
        self.txtConfirmPwd.text = ""
        self.txtStatus.text = NSLocalizedString("Enabled", comment: "")
        self.lblAddress.text = ""
        self.imgLogo.image = nil
        self.imgBanner.image = nil
        self.logoImageStr = ""
        self.restroImageStr = ""
        self.txtPreparationTime.text = ""
        self.selectedCuisines.removeAllObjects()
        self.tblCuisines.reloadData()
        self.didSelectDate.removeAllObjects()
        self.selectedPaymentMethods.removeAllObjects()
        self.tblPaymentMethod.reloadData()
        self.txtSunStart.text = "00.00"
        self.txtSunEnd.text = "00.00"
        self.txtMonStart.text = "00.00"
        self.txtMonEnd.text = "00.00"
        self.txtTueStart.text = "00.00"
        self.txtTueEnd.text = "00.00"
        self.txtWedStart.text = "00.00"
        self.txtWedEnd.text = "00.00"
        self.txtThuStart.text = "00.00"
        self.txtThuEnd.text = "00.00"
        self.txtFriStart.text = "00.00"
        self.txtFriEnd.text = "00.00"
        self.txtSatStart.text = "00.00"
        self.txtSatEnd.text = "00.00"
        self.switchSun.setOn(true, animated: false)
        self.switchMon.setOn(true, animated: false)
        self.switchTue.setOn(true, animated: false)
        self.switchWed.setOn(true, animated: false)
        self.switchThu.setOn(true, animated: false)
        self.switchFri.setOn(true, animated: false)
        self.switchSat.setOn(true, animated: false)
        self.switchPickup.setOn(true, animated: false)
        self.switchDelivery.setOn(true, animated: false)
        self.txtPanCard.text = ""
        self.txtAcNo.text = ""
        self.txtIFSCCode.text = ""
    }
    
    @IBAction func clickBack(_ sender: Any)
    {
        self.mainScrollView.isHidden = true
        self.viewDatePicker.isHidden = true
        self.btnBack.isHidden = true
        self.lblTitle.text = NSLocalizedString("Login", comment: "")
    }
    
    @IBAction func clickShowPassword(_ sender: Any)
    {
        if self.txtPassword.isSecureTextEntry == true
        {
            self.txtPassword.isSecureTextEntry = false
            self.imgShowPass.image = UIImage(named: "ic_checkbox")
        }
        else
        {
            self.txtPassword.isSecureTextEntry = true
            self.imgShowPass.image = UIImage(named: "ic_uncheckbox")
        }
    }
    
    @IBAction func clickStartTime(_ sender: UIButton)
    {
        self.view.endEditing(true)
        timeType = "start"
        tagValue = sender.tag
        if sender.tag == 0 && self.switchSun.isOn
        {
            self.viewDatePicker.isHidden = false
        }
        else if sender.tag == 1 && self.switchMon.isOn
        {
            self.viewDatePicker.isHidden = false
        }
        else if sender.tag == 2 && self.switchTue.isOn
        {
            self.viewDatePicker.isHidden = false
        }
        else if sender.tag == 3 && self.switchWed.isOn
        {
            self.viewDatePicker.isHidden = false
        }
        else if sender.tag == 4 && self.switchThu.isOn
        {
            self.viewDatePicker.isHidden = false
        }
        else if sender.tag == 5 && self.switchFri.isOn
        {
            self.viewDatePicker.isHidden = false
        }
        else if sender.tag == 6 && self.switchSat.isOn
        {
            self.viewDatePicker.isHidden = false
        }
    }
    
    @IBAction func clickEndTime(_ sender: UIButton)
    {
        self.view.endEditing(true)
        timeType = "end"
        tagValue = sender.tag
        if sender.tag == 0 && self.switchSun.isOn
        {
            self.viewDatePicker.isHidden = false
        }
        else if sender.tag == 1 && self.switchMon.isOn
        {
            self.viewDatePicker.isHidden = false
        }
        else if sender.tag == 2 && self.switchTue.isOn
        {
            self.viewDatePicker.isHidden = false
        }
        else if sender.tag == 3 && self.switchWed.isOn
        {
            self.viewDatePicker.isHidden = false
        }
        else if sender.tag == 4 && self.switchThu.isOn
        {
            self.viewDatePicker.isHidden = false
        }
        else if sender.tag == 5 && self.switchFri.isOn
        {
            self.viewDatePicker.isHidden = false
        }
        else if sender.tag == 6 && self.switchSat.isOn
        {
            self.viewDatePicker.isHidden = false
        }
    }
    
    @IBAction func clickSwitchWorkingDays(_ sender: Any)
    {
        if (sender as AnyObject).tag == 0
        {
            self.txtSunStart.text = "00:00"
            self.txtSunEnd.text = "00:00"
        }
        else if (sender as AnyObject).tag == 1
        {
            self.txtMonStart.text = "00:00"
            self.txtMonEnd.text = "00:00"
        }
        else if (sender as AnyObject).tag == 2
        {
            self.txtTueStart.text = "00:00"
            self.txtTueEnd.text = "00:00"
        }
        else if (sender as AnyObject).tag == 3
        {
            self.txtWedStart.text = "00:00"
            self.txtWedEnd.text = "00:00"
        }
        else if (sender as AnyObject).tag == 4
        {
            self.txtThuStart.text = "00:00"
            self.txtThuEnd.text = "00:00"
        }
        else if (sender as AnyObject).tag == 5
        {
            self.txtFriStart.text = "00:00"
            self.txtFriEnd.text = "00:00"
        }
        else if (sender as AnyObject).tag == 6
        {
            self.txtSatStart.text = "00:00"
            self.txtSatEnd.text = "00:00"
        }
    }
    
    @IBAction func clickVeg(_ sender: Any)
    {
        self.btnVeg.setImage(UIImage(named: "ic_radio_check"), for: .normal)
        self.btnNonVeg.setImage(UIImage(named: "ic_radio_uncheck"), for: .normal)
        self.btnBoth.setImage(UIImage(named: "ic_radio_uncheck"), for: .normal)
    }
    
    @IBAction func clickNonVeg(_ sender: Any)
    {
        self.btnVeg.setImage(UIImage(named: "ic_radio_uncheck"), for: .normal)
        self.btnNonVeg.setImage(UIImage(named: "ic_radio_check"), for: .normal)
        self.btnBoth.setImage(UIImage(named: "ic_radio_uncheck"), for: .normal)
    }
    
    @IBAction func clickBoth(_ sender: Any)
    {
        self.btnVeg.setImage(UIImage(named: "ic_radio_uncheck"), for: .normal)
        self.btnNonVeg.setImage(UIImage(named: "ic_radio_uncheck"), for: .normal)
        self.btnBoth.setImage(UIImage(named: "ic_radio_check"), for: .normal)
    }
    
    //MARK: Date Picker
    
    @IBAction func clickDateDone(_ sender: Any)
    {
        self.viewDatePicker.isHidden = true
        
        let dateFormatterGet = DateFormatter()
        
        dateFormatterGet.dateFormat = "HH:mm"
        let todaysDate = dateFormatterGet.string(from:  datePicker2.date)
        time = todaysDate
        
        if timeType == "start"
        {
            if tagValue == 0
            {
                self.txtSunStart.text = todaysDate
            }
            else if tagValue == 1
            {
                self.txtMonStart.text = todaysDate
            }
            else if tagValue == 2
            {
                self.txtTueStart.text = todaysDate
            }
            else if tagValue == 3
            {
                self.txtWedStart.text = todaysDate
            }
            else if tagValue == 4
            {
                self.txtThuStart.text = todaysDate
            }
            else if tagValue == 5
            {
                self.txtFriStart.text = todaysDate
            }
            else if tagValue == 6
            {
                self.txtSatStart.text = todaysDate
            }
        }
        else
        {
            if tagValue == 0
            {
                 self.txtSunEnd.text = todaysDate
            }
            else if tagValue == 1
            {
                self.txtMonEnd.text = todaysDate
            }
            else if tagValue == 2
            {
                self.txtTueEnd.text = todaysDate
            }
            else if tagValue == 3
            {
                self.txtWedEnd.text = todaysDate
            }
            else if tagValue == 4
            {
                self.txtThuEnd.text = todaysDate
            }
            else if tagValue == 5
            {
                self.txtFriEnd.text = todaysDate
            }
            else if tagValue == 6
            {
                self.txtSatEnd.text = todaysDate
            }
        }
    }
    
    @IBAction func clickClose(_ sender: Any)
    {
        self.viewDatePicker.isHidden = true
    }
    
    //MARK: Map View Methods and delegates
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D)
    {
        self.view.endEditing(true)
        let camera = GMSCameraPosition.camera(withLatitude: (coordinate.latitude), longitude: (coordinate.longitude), zoom: 17.0)
        self.mapView?.animate(to: camera)
        selectedLatitude = "\(coordinate.latitude)"
        selectedLongitude = "\(coordinate.longitude)"
        addressFromLatLong(lat: coordinate.latitude, long: coordinate.longitude)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition)
    {
        self.view.endEditing(true)
        self.selectedLatitude = "\(mapView.camera.target.latitude)"
        self.selectedLongitude = "\(mapView.camera.target.longitude)"
//        addressFromLatLong(lat: mapView.camera.target.latitude, long: mapView.camera.target.longitude)
        
        self.mapView.settings.consumesGesturesInView = false
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panHandler(_:)))
        self.mapView.addGestureRecognizer(panGesture)
    }
    
    @objc private func panHandler(_ pan : UIPanGestureRecognizer){
        
        if pan.state == .ended{
            let mapSize = self.mapView.frame.size
            let point = CGPoint(x: mapSize.width/2, y: mapSize.height/2)
            let newCoordinate = self.mapView.projection.coordinate(for: point)
            selectedLatitude = "\(newCoordinate.latitude)"
            selectedLongitude = "\(newCoordinate.longitude)"
            addressFromLatLong(lat: newCoordinate.latitude, long: newCoordinate.longitude)
        }
    }
    
    func addressFromLatLong(lat: Double, long: Double)
    {
        let reachability = Reachability()
        if (reachability?.isReachable)!
        {
            let urlStr = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(long)&key=\(apiKey)"
            let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
            var request = URLRequest(url: URL(string: setFinalURl)!)
            request.httpMethod = HTTPMethod.get.rawValue
            request.setValue(userIDStr, forHTTPHeaderField: "Customer-Authorization")

            Alamofire.request(request).responseJSON
                { (responseObject) -> Void in
                    if responseObject.result.isSuccess
                    {
                        let result = responseObject.result.value! as AnyObject
                        if let status = result.value(forKey: "status")
                        {
                            if status as! String == "OK"
                            {
                                let address = (result.value(forKey: "results") as AnyObject).object(at: 0) as AnyObject
                                self.selectedLatitude = "\(lat)"
                                self.selectedLongitude = "\(long)"
                                self.lblAddress.text = "\(address.value(forKey: "formatted_address")!)"
                                self.selectedAddress = "\(address.value(forKey: "formatted_address")!)"
                                self.locationManager.stopUpdatingLocation()
                            }
                            else
                            {
                                print(status)
                            }
                        }
                        else
                        {
                            SharedManager.showAlertWithMessage(title: "", alertMessage: result.value(forKeyPath: "message") as! String, viewController: self)
                        }
                    }
                    if responseObject.result.isFailure
                    {
                        SharedManager.dismissHUD(viewController: self)
                        let error : Error = responseObject.result.error!
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
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if locations.last != nil
        {
            let location = locations.last
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
            self.mapView?.animate(to: camera)
            let lat = location?.coordinate.latitude as! Double
            let long = location?.coordinate.longitude as! Double
            selectedLatitude = "\(String(describing: lat))"
            selectedLongitude = "\(String(describing: long))"
            self.addressFromLatLong(lat: (location?.coordinate.latitude)!, long: (location?.coordinate.longitude)!)
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    //MARK: Google Auto Complete Search
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        mapView.delegate = nil
        let lat = place.coordinate.latitude
        let long = place.coordinate.longitude
        self.selectedLatitude = "\(lat)"
        self.selectedLongitude = "\(long)"
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 17.0)
        self.mapView?.animate(to: camera)
        self.lblAddress.text = "\(String(describing: place.formattedAddress!))"
        UINavigationBar.appearance().barTintColor = themeColor
        UINavigationBar.appearance().tintColor = .white
        dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2)
        {
            self.mapView.delegate = self
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        UINavigationBar.appearance().barTintColor = themeColor
        UINavigationBar.appearance().tintColor = .white
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        
        UINavigationBar.appearance().barTintColor = themeColor
        UINavigationBar.appearance().tintColor = .white
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    //MARK: Autosearch
    @IBAction func clickAutoSearch(_ sender: Any)
    {
        isFromAutoComplete = true
        let autocompleteController = GMSAutocompleteViewController()
        UINavigationBar.appearance().barTintColor = UIColor.lightGray
        UINavigationBar.appearance().tintColor = .black
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    //MARK: API Methods
    
    //Login
    func loginUser()
    {
        self.view.endEditing(true)
        
        if let userId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId{
            deviceIDStr = userId
        }
        
        let params = ["email" : self.txtUserName.text!,
                      "password" : self.txtPassword.text!,
                      "push_id" : deviceIDStr,
                      "device_type" : "2"
        ] as [String : Any]
        
        let urlStr = "\(ConfigUrl.baseUrl)login"
        print(urlStr)
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let setTemp: [String : Any] = params
        
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
                    print(result)
                    if let status = (responseObject.result.value! as AnyObject).value(forKeyPath: "success.status")
                    {
                        if "\(status)" == "200" {
                            storeIDStr = result.value(forKeyPath: "vendor_info.secret_key") as! String
                            UserDefaults.standard.set("\(result.value(forKeyPath: "vendor_info.id")!)", forKey: "STORE_ID")
                            UserDefaults.standard.set(storeIDStr, forKey: "SECRET_KEY")
                            let data = NSKeyedArchiver.archivedData(withRootObject: result)
                            UserDefaults.standard.set(data, forKey: "USER_DETAILS")
                            
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "HomeVc") as! HomeVc
                            self.navigationController?.pushViewController(viewController, animated: true)
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
    
    func registerUser()
    {
        self.view.endEditing(true)
        
        if let userId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId{
            deviceIDStr = userId
        }
        
        var pickup = ""
        var delivery = ""
        
        if switchPickup.isOn == true
        {
            pickup = "1"
        }
        else
        {
            pickup = "0"
        }
        
        if switchDelivery.isOn == true
        {
            delivery = "1"
        }
        else
        {
            delivery = "0"
        }
        
        var dateStr = String()
        if didSelectDate.count != 0
        {
            for i in 0..<didSelectDate.count
            {
                dateStr = dateStr + "\(didSelectDate.object(at: i)),"
            }
            dateStr.removeLast()
        }
        
        let tempArr = NSMutableArray()
        tempArr.addObjects(from: self.selectedCuisines as! [Any])
        selectedCuisines.removeAllObjects()
        var cuisinesDict = NSMutableDictionary()
        
        for i in 0..<tempArr.count
        {
            let str = "\(tempArr.object(at: i))"
            cuisinesDict.setObject(str, forKey: "\(i)" as NSCopying)
        }
        tempArr.removeAllObjects()
        
        tempArr.addObjects(from: self.selectedPaymentMethods as! [Any])
        selectedPaymentMethods.removeAllObjects()
        
        var paymentDict = NSMutableDictionary()
        
        for i in 0..<tempArr.count
        {
            let str = "\(tempArr.object(at: i))"
            paymentDict.setObject(str, forKey: "\(i)" as NSCopying)
        }
        
        let timeDict = NSMutableDictionary()
        
        for i in 0..<7
        {
            let temp = NSMutableDictionary()
            
            if i == 0
            {
                temp.setObject(self.txtSunStart.text!, forKey: "start_time" as NSCopying)
                temp.setObject(self.txtSunEnd.text!, forKey: "end_time" as NSCopying)
                if switchSun.isOn
                {
                    temp.setObject("1", forKey: "working" as NSCopying)
                }
                else
                {
                    temp.setObject("0", forKey: "working" as NSCopying)
                }
            }
            else if i == 1
            {
                temp.setObject(self.txtMonStart.text!, forKey: "start_time" as NSCopying)
                temp.setObject(self.txtMonEnd.text!, forKey: "end_time" as NSCopying)
                if switchMon.isOn
                {
                    temp.setObject("1", forKey: "working" as NSCopying)
                }
                else
                {
                    temp.setObject("0", forKey: "working" as NSCopying)
                }
            }
            else if i == 2
            {
                temp.setObject(self.txtTueStart.text!, forKey: "start_time" as NSCopying)
                temp.setObject(self.txtTueEnd.text!, forKey: "end_time" as NSCopying)
                if switchTue.isOn
                {
                    temp.setObject("1", forKey: "working" as NSCopying)
                }
                else
                {
                    temp.setObject("0", forKey: "working" as NSCopying)
                }
            }
            else if i == 3
            {
                temp.setObject(self.txtWedStart.text!, forKey: "start_time" as NSCopying)
                temp.setObject(self.txtWedEnd.text!, forKey: "end_time" as NSCopying)
                if switchWed.isOn
                {
                    temp.setObject("1", forKey: "working" as NSCopying)
                }
                else
                {
                    temp.setObject("0", forKey: "working" as NSCopying)
                }
            }
            else if i == 4
            {
                temp.setObject(self.txtThuStart.text!, forKey: "start_time" as NSCopying)
                temp.setObject(self.txtThuEnd.text!, forKey: "end_time" as NSCopying)
                if switchThu.isOn
                {
                    temp.setObject("1", forKey: "working" as NSCopying)
                }
                else
                {
                    temp.setObject("0", forKey: "working" as NSCopying)
                }
            }
            else if i == 5
            {
                temp.setObject(self.txtFriStart.text!, forKey: "start_time" as NSCopying)
                temp.setObject(self.txtFriEnd.text!, forKey: "end_time" as NSCopying)
                if switchFri.isOn
                {
                    temp.setObject("1", forKey: "working" as NSCopying)
                }
                else
                {
                    temp.setObject("0", forKey: "working" as NSCopying)
                }
            }
            else if i == 6
            {
                temp.setObject(self.txtSatStart.text!, forKey: "start_time" as NSCopying)
                temp.setObject(self.txtSatEnd.text!, forKey: "end_time" as NSCopying)
                if switchSat.isOn
                {
                    temp.setObject("1", forKey: "working" as NSCopying)
                }
                else
                {
                    temp.setObject("0", forKey: "working" as NSCopying)
                }
            }
            timeDict.setObject(temp, forKey: "\(i)" as NSCopying)
        }
        var chefType = 0
               if self.btnVeg.currentImage == UIImage(named: "ic_radio_check"){
                   chefType = 1
               }else if self.btnNonVeg.currentImage == UIImage(named: "ic_radio_check"){
                   chefType = 2
               }else if self.btnBoth.currentImage == UIImage(named: "ic_radio_check"){
                   chefType = 3
               }
        
        let registerDict = NSMutableDictionary()
        registerDict.setObject(self.txtRestroNameEng.text!, forKey: "name" as NSCopying)
        registerDict.setObject(self.txtRestroNameEng.text!, forKey: "name_arabic" as NSCopying)
        registerDict.setObject(self.txtOwnername.text!, forKey: "owner" as NSCopying)
        registerDict.setObject(self.txtEmail.text!, forKey: "email" as NSCopying)
        registerDict.setObject(self.txtMobileNumber.text!, forKey: "telephone" as NSCopying)
        registerDict.setObject(self.txtRegPwd.text!, forKey: "password" as NSCopying)
        registerDict.setObject(self.txtConfirmPwd.text!, forKey: "confirm" as NSCopying)
        registerDict.setObject(self.selectedLatitude, forKey: "latitude" as NSCopying)
        registerDict.setObject(self.selectedLongitude, forKey: "longitude" as NSCopying)
        registerDict.setObject(self.lblAddress.text!, forKey: "address" as NSCopying)
        registerDict.setObject(self.lblAddress.text!, forKey: "geocode" as NSCopying)
        registerDict.setObject(self.restroImageStr, forKey: "image" as NSCopying)
        registerDict.setObject(self.logoImageStr, forKey: "logo" as NSCopying)
        registerDict.setObject(self.txtPreparationTime.text!, forKey: "preparing_time" as NSCopying)
        registerDict.setObject(cuisinesDict, forKey: "store_cuisine" as NSCopying)
        registerDict.setObject(dateStr, forKey: "non_available_date" as NSCopying)
        registerDict.setObject(paymentDict, forKey: "store_payment_method" as NSCopying)
        registerDict.setObject(pickup, forKey: "pickup" as NSCopying)
        registerDict.setObject(delivery, forKey: "delivery" as NSCopying)
        registerDict.setObject(timeDict, forKey: "working_hours" as NSCopying)
        registerDict.setObject(deviceIDStr, forKey: "push_id" as NSCopying)
        registerDict.setObject("2", forKey: "device_type" as NSCopying)
        registerDict.setObject(self.txtPanCard.text!, forKey: "pan_card" as NSCopying)
        registerDict.setObject(self.txtAcNo.text!, forKey: "acc_no" as NSCopying)
        registerDict.setObject(self.txtIFSCCode.text!, forKey: "ifsc_code" as NSCopying)
        registerDict.setObject(chefType, forKey: "store_type" as NSCopying)
        
        if txtStatus.text == "Enabled"
        {
            registerDict.setObject("1", forKey: "status" as NSCopying)
            registerDict.setObject("1", forKey: "working_status_id" as NSCopying)
        }
        else
        {
            registerDict.setObject("0", forKey: "status" as NSCopying)
            registerDict.setObject("0", forKey: "working_status_id" as NSCopying)
        }
        
        print(registerDict)
        let reachability = Reachability()
        if (reachability?.isReachable)!
        {
            self.view.endEditing(true)
            SharedManager.showHUD(viewController: self)

            let urlStr = "\(ConfigUrl.baseUrl)store/store/registration&language_id=\(languageID)&language_code=\(languageCode)"
            
            let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
            var request = URLRequest(url: URL(string: setFinalURl)!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
          //  request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let setTemp: [String : Any] = registerDict as! [String : Any]
            
            if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
                let jsonString = String(data: jsonData , encoding: .utf8)!
                request.httpBody = jsonData
            }
            
            if Connectivity.isConnectedToInternet() {
                
                Alamofire.request(request).responseJSON { (responseObject) -> Void in
                    
                    if responseObject.result.isSuccess
                    {
                        SharedManager.dismissHUD(viewController: self)
                        let result = responseObject.result.value! as AnyObject
                        if "\(String(describing: responseObject.response!.statusCode))" == "200"
                        {
                           
                            let alert = UIAlertController(title: "Thanks", message: "\(result.value(forKeyPath: "success.message")!)", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                
                                self.txtUserName.text = self.txtEmail.text!
                                self.txtPassword.text = self.txtRegPwd.text!
                                
                                self.loginUser()
                                
                                self.mainScrollView.isHidden = true
                                self.viewDatePicker.isHidden = true
                                self.btnBack.isHidden = true
                                self.navigationItem.title = NSLocalizedString("Login", comment: "")
                                
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                        else
                        {
                            SharedManager.showAlertWithMessage(title: "Sorry", alertMessage: "\(result.value(forKeyPath: "error.message")!)", viewController: self)
                        }
                    }
                    if responseObject.result.isFailure
                    {
                        SharedManager.dismissHUD(viewController: self)
                        let error : Error = responseObject.result.error!
                        print(error.localizedDescription)
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
        else
        {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
               as! ErrorViewController
           self.present(viewController, animated: true, completion: { () -> Void in
           })
        }
    }
    
    func isValidEmail(testStr:String) -> Bool
    {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
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
                    
                    if self.imageType == "logo"
                    {
                        self.imgLogo.contentMode = .scaleToFill
                        self.imgLogo.image = pickedImage
                    }
                    else
                    {
                        self.imgBanner.contentMode = .scaleToFill
                        self.imgBanner.image = pickedImage
                    }
                    
                    let imageData = pickedImage?.jpegData(compressionQuality: 0.01)
                    let baseStr = imageData?.base64EncodedString(options: .lineLength64Characters)
                    
                    params = ["file": baseStr!, "filename": "logo.jpg"]
                })
            }
            
            if Connectivity.isConnectedToInternet()
            {
                let urlStr = "\(ConfigUrl.baseUrl)store/account/upload"
                
                let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
                var request = URLRequest(url: URL(string: setFinalURl)!)
                request.httpMethod = HTTPMethod.post.rawValue
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                // request.setValue(userIDStr, forHTTPHeaderField: "Driver-Authorization")
                
                let setTemp: [String : Any] = params
                
                if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
                    //  let jsonString = String(data: jsonData , encoding: .utf8)!
                    // print(jsonString as Any)
                    request.httpBody = jsonData
                }
                
                //  request.httpBody = testData
                
                Alamofire.request(request).responseJSON { (responseObject) -> Void in
                    
                    print(String(data: responseObject.data!, encoding: String.Encoding.utf8)!)
                    
                    if responseObject.result.isSuccess
                    {
                        SharedManager.dismissHUD(viewController: self)
                        
                        if let status = (responseObject.result.value! as AnyObject).value(forKeyPath: "success.status")
                        {
                            if "\(status)" == "200"
                            {
                                if self.imageType == "logo"
                                {
                                    self.logoImageStr = "\((responseObject.result.value! as AnyObject).value(forKey: "filepath")!)"
                                }
                                else
                                {
                                    self.restroImageStr = "\((responseObject.result.value! as AnyObject).value(forKey: "filepath")!)"
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
            }
            else
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                    as! ErrorViewController
                self.present(viewController, animated: true, completion: { () -> Void in
                })
            }
            //Dismiss Controller
            imagePicker.dismiss(animated: true, completion: nil)
        }, cancel: {
            
        })
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        self.dismiss(animated: true, completion: {})
        
        guard let pickedImage = info[.originalImage] as? UIImage else {
            fatalError("Something went wrong")
        }
        
        if self.imageType == "logo"
        {
            self.imgLogo.contentMode = .scaleToFill
            self.imgLogo.image = pickedImage
            
            
            if let updatedImage = self.imgLogo.image?.updateImageOrientionUpSide() {
                uploadGalleryImage(image: updatedImage)
            } else {
                uploadGalleryImage(image: self.imgLogo.image!)
            }
        }
        else
        {
            self.imgBanner.contentMode = .scaleToFill
            self.imgBanner.image = pickedImage
                        
            if let updatedImage = self.imgBanner.image?.updateImageOrientionUpSide() {
                uploadGalleryImage(image: updatedImage)
            } else {
                uploadGalleryImage(image: self.imgBanner.image!)
            }
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
            let urlStr = "\(ConfigUrl.baseUrl)store/account/upload"
            
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
                if responseObject.result.isSuccess
                {
                    SharedManager.dismissHUD(viewController: self)
                    
                    if let status = (responseObject.result.value! as AnyObject).value(forKeyPath: "success.status")
                    {
                        if "\(status)" == "200"
                        {
                            if self.imageType == "logo"
                            {
                                self.logoImageStr = "\((responseObject.result.value! as AnyObject).value(forKey: "filepath")!)"
                            }
                            else
                            {
                                self.restroImageStr = "\((responseObject.result.value! as AnyObject).value(forKey: "filepath")!)"
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
    
    //MARK: UITableView Methods
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == tblCuisines
        {
            return self.cuisinesArr.count
        }
        else if tableView == tblPaymentMethod
        {
            return self.paymentMethodsArr.count
        }
        else if tableView == tblRegister
        {
            return 0
        }
        else
        {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == tblCuisines
        {
            let cell:selectionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cuisineCell") as! selectionTableViewCell
            
            cell.lblTitle.text = "\((self.cuisinesArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
            
            cell.imgSelection.image = UIImage (named: "ic_uncheckbox")
            
            if self.selectedCuisines.contains("\((self.cuisinesArr.object(at: indexPath.row) as AnyObject).value(forKey: "cuisine_id")!)")
            {
                cell.imgSelection.image = UIImage (named: "ic_checkbox")
            }
            return cell
        }
        else if tableView == tblPaymentMethod
        {
            let cell:selectionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "paymentMethodCell") as! selectionTableViewCell
            
            cell.lblTitle.text = "\((self.paymentMethodsArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
            
            cell.imgSelection.image = UIImage (named: "ic_uncheckbox")
            
            if self.selectedPaymentMethods.contains("\((self.paymentMethodsArr.object(at: indexPath.row) as AnyObject).value(forKey: "payment_method_id")!)")
            {
                cell.imgSelection.image = UIImage (named: "ic_checkbox")
            }
            
            return cell
        }
        else if tableView == tblRegister
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "registerCell", for: indexPath)
            //viewRegister.frame.origin.y = 0
            //cell.contentView.addSubview(viewRegister)
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
        if tableView == tblRegister
        {
            let height = viewRegister.frame.size.height
            return height
        }
        else
        {
            return 45
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == tblCuisines
        {
            if self.selectedCuisines.count != 0
            {
                let tempArr = NSMutableArray()
                tempArr.addObjects(from: self.selectedCuisines as! [Any])
                
                var isHave = false
                
                for i in 0..<self.selectedCuisines.count
                {
                    let str = "\(self.selectedCuisines.object(at: i))"
                    
                    if str == "\((self.cuisinesArr.object(at: indexPath.row) as AnyObject).value(forKey: "cuisine_id")!)"
                    {
                        isHave = true
                        tempArr.removeObject(at: i)
                    }
                }
                
                if !isHave
                {
                    tempArr.add("\((self.cuisinesArr.object(at: indexPath.row) as AnyObject).value(forKey: "cuisine_id")!)")
                }
                
                self.selectedCuisines = tempArr
                
            }
            else
            {
              //  let temp = NSMutableDictionary()
              //  temp.setObject("\((self.cuisinesArr.object(at: indexPath.row) as AnyObject).value(forKey: "cuisine_id")!)", forKey: "0" as NSCopying)
                
                self.selectedCuisines.add("\((self.cuisinesArr.object(at: indexPath.row) as AnyObject).value(forKey: "cuisine_id")!)")
            }
           
            self.tblCuisines.reloadData()
        }
        else if tableView == tblPaymentMethod
        {
            if self.selectedPaymentMethods.count != 0
            {
                let tempArr = NSMutableArray()
                tempArr.addObjects(from: self.selectedPaymentMethods as! [Any])
                
                var isHave = false
                
                for i in 0..<self.selectedPaymentMethods.count
                {
                    let str = "\(self.selectedPaymentMethods.object(at: i))"
                    
                    if str == "\((self.paymentMethodsArr.object(at: indexPath.row) as AnyObject).value(forKey: "payment_method_id")!)"
                    {
                        isHave = true
                        tempArr.removeObject(at: i)
                    }
                }
                
                if !isHave
                {
                    tempArr.add("\((self.paymentMethodsArr.object(at: indexPath.row) as AnyObject).value(forKey: "payment_method_id")!)")
                }
                
                self.selectedPaymentMethods = tempArr
            }
            else
            {
                //let temp = NSMutableDictionary()
                //temp.setObject("\((self.paymentMethodsArr.object(at: indexPath.row) as AnyObject).value(forKey: "payment_method_id")!)", forKey: "0" as NSCopying)
                
                self.selectedPaymentMethods.add("\((self.paymentMethodsArr.object(at: indexPath.row) as AnyObject).value(forKey: "payment_method_id")!)")
            }
            self.tblPaymentMethod.reloadData()
        }
        else if tableView == tblRegister
        {
            
        }
        else
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
    }
    
    func setFrames()
    {
        if self.cuisinesArr.count != 0{
            self.tblCuisines.frame.size.height = CGFloat(self.cuisinesArr.count * 45) + 10
            self.lblSelectCuisine.isHidden = false
        }else{
            self.tblCuisines.frame.size.height = CGFloat(0.0)
            self.lblSelectCuisine.isHidden = true
        }
        self.tblPaymentMethod.frame.size.height = CGFloat(self.paymentMethodsArr.count * 42)
        
        self.viewRestroBottom.frame.origin.y = self.tblCuisines.frame.origin.y + self.tblCuisines.frame.size.height + 8
        
        self.viewPaymentBottom.frame.origin.y = self.tblPaymentMethod.frame.origin.y + self.tblPaymentMethod.frame.size.height + 8
                
        self.viewRestaurantInfo.frame.size.height = self.tblCuisines.frame.size.height + 656
        self.viewPaymentMethod.frame.size.height = self.tblPaymentMethod.frame.size.height + 132
        
        if self.paymentMethodsArr.count == 0 {
            self.viewPaymentBottom.frame.origin.y = 0
            self.viewPaymentMethod.frame.size.height = self.viewPaymentBottom.frame.size.height
        }
        
        self.viewPaymentMethod.frame.origin.y = self.viewRestaurantInfo.frame.origin.y + self.viewRestaurantInfo.frame.size.height + 10
        self.viewWorkingHours.frame.origin.y = self.viewPaymentMethod.frame.origin.y + self.viewPaymentMethod.frame.size.height + 10
        self.viewBankDetails.frame.origin.y = self.viewWorkingHours.frame.origin.y + self.viewWorkingHours.frame.size.height + 10
        self.btnRegisterNow.frame.origin.y = self.viewBankDetails.frame.origin.y + self.viewBankDetails.frame.size.height + 10
        
//        self.viewRegister.frame.size.height = self.btnRegisterNow.frame.origin.y + self.btnRegisterNow.frame.size.height + 10
//        self.mainScrollView.addSubview(viewRegister)
//        self.mainScrollView.contentSize = CGSize(width: self.viewRegister.frame.size.width, height: self.viewRegister.frame.size.height)
    }
    
    func getRegisterFields()
    {
        if Connectivity.isConnectedToInternet()
        {
            let urlStr = "\(ConfigUrl.baseUrl)store/store/register_fields"
            
            let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
            var request = URLRequest(url: URL(string: setFinalURl)!)
            request.httpMethod = HTTPMethod.get.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           // request.setValue(userIDStr, forHTTPHeaderField: "Driver-Authorization")
            
            Alamofire.request(request).responseJSON
                { (responseObject) -> Void in
                    
                    if responseObject.result.isSuccess
                    {
                        
                        if "\(String(describing: responseObject.response!.statusCode))" == "200"
                        {
                            let result = responseObject.result.value! as AnyObject
                            
                            self.cuisinesArr = (result.value(forKey: "cuisines") as! NSArray).mutableCopy() as! NSMutableArray
                            self.tblCuisines.reloadData()
                            self.tblPaymentMethod.reloadData()
                            self.setFrames()
                        }
                        else
                        {
                            print(((responseObject.result.value!) as AnyObject).value(forKeyPath: "message")!)
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
    
    //MARK: Calender Methods
    // MARK : KDCalendarDataSource
    
    func startDate() -> Date
    {
        var dateComponents = DateComponents()
        dateComponents.day = 0
        
        let today = Date()
        
        let threeMonthsAgo = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!
        
        return today
    }
    
    func endDate() -> Date
    {
        var dateComponents = DateComponents()
        
        dateComponents.year = 2;
        let today = Date()
        
        let twoYearsFromNow = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!
        
        return twoYearsFromNow
        
    }
    
    
    // MARK : KDCalendarDelegate
    
    func calendar(_ calendar: CalendarView, didSelectDate date : Date, withEvents events: [CalendarEvent]) {
        
        print("Did Select: \(date) with \(events.count) events")
        
        let dateFormatterGet = DateFormatter()
        
        dateFormatterGet.dateFormat = "yyyy-M-d"
        let todaysDate = dateFormatterGet.string(from: date)
        
        self.didSelectDate.add(todaysDate)
    }
    
    
    func calendar(_ calendar : CalendarView, didDeselectDate date : Date)
    {
        let dateFormatterGet = DateFormatter()
        
        dateFormatterGet.dateFormat = "yyyy-M-d"
        let todaysDate = dateFormatterGet.string(from: date)
        
        self.didSelectDate.remove(todaysDate)
        
        print(self.didSelectDate)
    }
    
    func calendar(_ calendar: CalendarView, didScrollToMonth date : Date) {
        
       // self.datePicker.setDate(date, animated: true)
    }
    
    
    func calendar(_ calendar: CalendarView, didLongPressDate date : Date) {
        
        let alert = UIAlertController(title: NSLocalizedString("Create New Event", comment: ""), message: "Message", preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Event Title"
        }
        
        let addEventAction = UIAlertAction(title: "Create", style: .default, handler: { (action) -> Void in
            let title = alert.textFields?.first?.text
            self.calendarView.addEvent(title!, date: date)
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
        
        alert.addAction(addEventAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK : Events
    
    @IBAction func onValueChange(_ picker : UIDatePicker) {
        self.calendarView.setDisplayDate(picker.date, animated: true)
    }
    
    @IBAction func goToPreviousMonth(_ sender: Any) {
        self.calendarView.goToPreviousMonth()
    }
    @IBAction func goToNextMonth(_ sender: Any) {
        self.calendarView.goToNextMonth()
        
    }
}


