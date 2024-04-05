//
//  ProfileVc.swift
//  Foodesoft Vendor
//
//  Created by Adyas Infotech on 29/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import OpalImagePicker
import Photos
//import Popover
import EventKit
import GoogleMaps
import GooglePlaces

class ProfileVc: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, CalendarViewDataSource, CalendarViewDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate, GMSMapViewDelegate
{
    
    @IBOutlet weak var viewRegister: UIView!
    
    //Restro Name
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
    //  @IBOutlet weak var calenderView: UIView!
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
    @IBOutlet weak var txtBankDetails: UITextView!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnVeg: UIButton!
    @IBOutlet weak var btnNonVeg: UIButton!
    @IBOutlet weak var btnBoth: UIButton!
    @IBOutlet weak var lblSelectCuisine: UILabel!
    
    var isFromAutoComplete = false
    var logoImageStr = ""
    var restroImageStr = ""
    
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
        self.navigationItem.title = NSLocalizedString("Account", comment: "")
        
        getRegisterFields()
        
        CalendarView.Style.cellShape                = .bevel(8.0)
        CalendarView.Style.cellColorDefault         = UIColor.clear
        CalendarView.Style.cellColorToday           = positiveBtnColor
        CalendarView.Style.cellSelectedBorderColor  = themeColor
        CalendarView.Style.cellEventColor           = .clear
        CalendarView.Style.headerTextColor          = .black
        CalendarView.Style.cellTextColorDefault     = .black
        CalendarView.Style.cellTextColorToday       = .white
        CalendarView.Style.firstWeekday             = .sunday
        
        calendarView.dataSource = self
        calendarView.delegate = self
        
        calendarView.direction = .horizontal
        calendarView.multipleSelectionEnable = true
        calendarView.marksWeekends = true
        
        calendarView.backgroundColor = .white
        self.txtRestroNameEng.textAlignment = isRTLenabled == true ? .right : .left
        self.txtOwnername.textAlignment = isRTLenabled == true ? .right : .left
        self.txtEmail.textAlignment = isRTLenabled == true ? .right : .left
        self.txtMobileNumber.textAlignment = isRTLenabled == true ? .right : .left
        self.txtStatus.textAlignment = isRTLenabled == true ? .right : .left
        self.txtPreparationTime.textAlignment = isRTLenabled == true ? .right : .left
        self.txtBankDetails.textAlignment = isRTLenabled == true ? .right : .left
        self.txtBankDetails.layer.borderWidth = 0.7
        let today = Date()
        
        self.calendarView.loadEvents() { error in
            if error != nil {
                let message = "The calender could not load system events. It is possibly a problem with permissions"
                let alert = UIAlertController(title: NSLocalizedString("Events Loading Error", comment: ""), message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        self.calendarView.setDisplayDate(today)
        storeInfoAPI()
        if #available(iOS 13.4, *) {
            datePicker?.preferredDatePickerStyle = .wheels
            datePicker2?.preferredDatePickerStyle = .wheels
        }
    }
    
    //MARK: API Methods
    func storeInfoAPI()
    {
        SharedManager.showHUD(viewController: self)
        
        let urlStr = "\(ConfigUrl.baseUrl)store/account/info"
        
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
                            print(result)
                            self.txtRestroNameEng.text = "\(result.value(forKeyPath: "store_info.name")!)"
                            self.txtRestroNameAr.text = "\(result.value(forKeyPath: "store_info.name_arabic")!)"
                            self.txtOwnername.text = "\(result.value(forKeyPath: "store_info.owner")!)"
                            self.txtEmail.text = "\(result.value(forKeyPath: "store_info.email")!)"
                            self.txtMobileNumber.text = "\(result.value(forKeyPath: "store_info.telephone")!)"
                            self.logoImageStr = "\(result.value(forKeyPath: "store_info.logo_path")!)"
                            self.restroImageStr = "\(result.value(forKeyPath: "store_info.image_path")!)"
                            let status = "\(result.value(forKeyPath: "store_info.status")!)"
                            
                            if status == "1"
                            {
                                self.txtStatus.text = NSLocalizedString("Enabled", comment: "")
                            }
                            else
                            {
                                self.txtStatus.text = NSLocalizedString("Disabled", comment: "")
                            }
                            self.lblAddress.text = "\(result.value(forKeyPath: "store_info.address")!)"
                            self.selectedLatitude = "\(result.value(forKeyPath: "store_info.latitude")!)"
                            self.selectedLongitude = "\(result.value(forKeyPath: "store_info.longitude")!)"
                            self.txtPreparationTime.text = "\(result.value(forKeyPath: "store_info.preparing_time")!)"
                            
                            let cuisine = (result.value(forKey: "store_cuisine") as! NSArray).mutableCopy() as! NSMutableArray
                            
                            for i in 0..<cuisine.count
                            {
                                let temp = "\((cuisine.object(at: i) as AnyObject).value(forKey: "cuisine_id")!)"
                                self.selectedCuisines.add(temp)
                            }
                            var imageUrl = "\(result.value(forKeyPath: "store_info.image")!)"
                            
                            var trimmedUrl = imageUrl.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20")
                            
                            var activityLoader = UIActivityIndicatorView()
                            activityLoader = UIActivityIndicatorView(style: .gray)
                            activityLoader.center = self.imgBanner.center
                            activityLoader.startAnimating()
                            self.imgBanner.addSubview(activityLoader)
                            
                            self.imgBanner.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
                                
                                if image != nil
                                {
                                    activityLoader.stopAnimating()
                                }else
                                {
                                    print("image not found")
                                    self.imgBanner.image = UIImage(named: "ic_add")
                                    activityLoader.stopAnimating()
                                }
                            })
                            self.imgBanner.contentMode = .scaleToFill
                            
                            imageUrl = "\(result.value(forKeyPath: "store_info.logo")!)"
                            
                            trimmedUrl = imageUrl.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20")
                            
                            activityLoader = UIActivityIndicatorView()
                            activityLoader = UIActivityIndicatorView(style: .gray)
                            activityLoader.center = self.imgLogo.center
                            activityLoader.startAnimating()
                            self.imgLogo.addSubview(activityLoader)
                            
                            self.imgLogo.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
                                
                                if image != nil
                                {
                                    activityLoader.stopAnimating()
                                }else
                                {
                                    self.imgLogo.image = UIImage(named: "ic_add")
                                    activityLoader.stopAnimating()
                                }
                            })
                            self.imgLogo.contentMode = .scaleToFill
                            
                            var switchState = "\(result.value(forKeyPath: "store_info.delivery")!)"
                            if switchState == "1"
                            {
                                self.switchDelivery.setOn(true, animated: false)
                            }
                            else
                            {
                                self.switchDelivery.setOn(false, animated: false)
                            }
                            
                            switchState = "\(result.value(forKeyPath: "store_info.pickup")!)"
                            if switchState == "1"
                            {
                                self.switchPickup.setOn(true, animated: false)
                            }
                            else
                            {
                                self.switchPickup.setOn(false, animated: false)
                            }
                            
                            let workingHours = result.value(forKey: "working_hours") as! NSDictionary
                            
                            self.txtSunStart.text = "\(String(describing: workingHours.value(forKeyPath: "sunday.start_time")!))"
                            self.txtSunEnd.text = "\(String(describing: workingHours.value(forKeyPath: "sunday.end_time")!))"
                            switchState = "\(String(describing: workingHours.value(forKeyPath: "sunday.working")!))"
                            if switchState == "open"
                            {
                                self.switchSun.setOn(true, animated: false)
                            }
                            else
                            {
                                self.switchSun.setOn(false, animated: false)
                            }
                            self.txtMonStart.text = "\(String(describing: workingHours.value(forKeyPath: "monday.start_time")!))"
                            self.txtMonEnd.text = "\(String(describing: workingHours.value(forKeyPath: "monday.end_time")!))"
                            switchState = "\(String(describing: workingHours.value(forKeyPath: "monday.working")!))"
                            if switchState == "open"
                            {
                                self.switchMon.setOn(true, animated: false)
                            }
                            else
                            {
                                self.switchMon.setOn(false, animated: false)
                            }
                            self.txtTueStart.text = "\(String(describing: workingHours.value(forKeyPath: "tuesday.start_time")!))"
                            self.txtTueEnd.text = "\(String(describing: workingHours.value(forKeyPath: "tuesday.end_time")!))"
                            switchState = "\(String(describing: workingHours.value(forKeyPath: "tuesday.working")!))"
                            if switchState == "open"
                            {
                                self.switchTue.setOn(true, animated: false)
                            }
                            else
                            {
                                self.switchTue.setOn(false, animated: false)
                            }
                            self.txtWedStart.text = "\(String(describing: workingHours.value(forKeyPath: "wednesday.start_time")!))"
                            self.txtWedEnd.text = "\(String(describing: workingHours.value(forKeyPath: "wednesday.end_time")!))"
                            switchState = "\(String(describing: workingHours.value(forKeyPath: "wednesday.working")!))"
                            if switchState == "open"
                            {
                                self.switchWed.setOn(true, animated: false)
                            }
                            else
                            {
                                self.switchWed.setOn(false, animated: false)
                            }
                            self.txtThuStart.text = "\(String(describing: workingHours.value(forKeyPath: "thursday.start_time")!))"
                            self.txtThuEnd.text = "\(String(describing: workingHours.value(forKeyPath: "thursday.end_time")!))"
                            switchState = "\(String(describing: workingHours.value(forKeyPath: "thursday.working")!))"
                            if switchState == "open"
                            {
                                self.switchThu.setOn(true, animated: false)
                            }
                            else
                            {
                                self.switchThu.setOn(false, animated: false)
                            }
                            self.txtFriStart.text = "\(String(describing: workingHours.value(forKeyPath: "friday.start_time")!))"
                            self.txtFriEnd.text = "\(String(describing: workingHours.value(forKeyPath: "friday.end_time")!))"
                            switchState = "\(String(describing: workingHours.value(forKeyPath: "friday.working")!))"
                            if switchState == "open"
                            {
                                self.switchFri.setOn(true, animated: false)
                            }
                            else
                            {
                                self.switchFri.setOn(false, animated: false)
                            }
                            self.txtSatStart.text = "\(String(describing: workingHours.value(forKeyPath: "saturday.start_time")!))"
                            self.txtSatEnd.text = "\(String(describing: workingHours.value(forKeyPath: "saturday.end_time")!))"
                            switchState = "\(String(describing: workingHours.value(forKeyPath: "saturday.working")!))"
                            if switchState == "open"
                            {
                                self.switchSat.setOn(true, animated: false)
                            }
                            else
                            {
                                self.switchSat.setOn(false, animated: false)
                            }
                            let nonAvailableDate = "\(result.value(forKey: "non_available_date")!)"
                            if nonAvailableDate != ""
                            {
                                let array = nonAvailableDate.components(separatedBy: ",")
                                let tempArr = (array as NSArray).mutableCopy() as! NSMutableArray
                                
                                if tempArr.count != 0
                                {
                                    for i in 0..<tempArr.count
                                    {
                                        let dateStr = "\(tempArr[i])"
                                        if dateStr != ""
                                        {
                                            let date = self.UTCToLocal(date: dateStr)
                                            self.calendarView.selectDate(date)
                                        }
                                    }
                                }
                            }

                            let chefType = "\(result.value(forKeyPath: "store_info.store_type")!)"
                            if chefType == "1"{
                                self.btnVeg.setImage(UIImage(named: "ic_radio_check"), for: .normal)
                                self.btnNonVeg.setImage(UIImage(named: "ic_radio_uncheck"), for: .normal)
                                self.btnBoth.setImage(UIImage(named: "ic_radio_uncheck"), for: .normal)
                            }else if chefType == "2"{
                                self.btnVeg.setImage(UIImage(named: "ic_radio_uncheck"), for: .normal)
                                self.btnNonVeg.setImage(UIImage(named: "ic_radio_check"), for: .normal)
                                self.btnBoth.setImage(UIImage(named: "ic_radio_uncheck"), for: .normal)
                            }else if chefType == "3"{
                                self.btnVeg.setImage(UIImage(named: "ic_radio_uncheck"), for: .normal)
                                self.btnNonVeg.setImage(UIImage(named: "ic_radio_uncheck"), for: .normal)
                                self.btnBoth.setImage(UIImage(named: "ic_radio_check"), for: .normal)
                            }else{
                                self.btnVeg.setImage(UIImage(named: "ic_radio_uncheck"), for: .normal)
                                self.btnNonVeg.setImage(UIImage(named: "ic_radio_uncheck"), for: .normal)
                                self.btnBoth.setImage(UIImage(named: "ic_radio_uncheck"), for: .normal)
                            }
                            if (result.value(forKey: "payment_detail")) != nil{
                                self.txtBankDetails.text = "\(result.value(forKey: "payment_detail")!)"
                            }
                            self.tblCuisines.reloadData()
                            self.setFrames()
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
    func saveProfile()
    {
        self.view.endEditing(true)
        
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
        registerDict.setObject(self.txtRestroNameAr.text!, forKey: "name_arabic" as NSCopying)
        registerDict.setObject(self.txtOwnername.text!, forKey: "owner" as NSCopying)
        registerDict.setObject(self.txtEmail.text!, forKey: "email" as NSCopying)
        registerDict.setObject(self.txtMobileNumber.text!, forKey: "telephone" as NSCopying)
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
        registerDict.setObject(self.txtBankDetails.text!, forKey: "payment_detail" as NSCopying)
        registerDict.setObject(chefType, forKey: "store_type" as NSCopying)
        if txtStatus.text == NSLocalizedString("Enabled", comment: "")
        {
            registerDict.setObject("1", forKey: "status" as NSCopying)
            registerDict.setObject("1", forKey: "working_status_id" as NSCopying)
        }
        else
        {
            registerDict.setObject("0", forKey: "status" as NSCopying)
            registerDict.setObject("0", forKey: "working_status_id" as NSCopying)
        }
        
        let reachability = Reachability()
        if (reachability?.isReachable)!
        {
            self.view.endEditing(true)
            SharedManager.showHUD(viewController: self)
            
            let urlStr = "\(ConfigUrl.baseUrl)store/account/edit"
            
            let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
            var request = URLRequest(url: URL(string: setFinalURl)!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(storeIDStr, forHTTPHeaderField: "Vendor-Authorization")
            
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
                            let alert = UIAlertController(title: NSLocalizedString("", comment: ""), message: NSLocalizedString("Store Details updated successfully", comment: ""), preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
                                self.navigationController?.popViewController(animated: true)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                        else
                        {
                            SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: "\(result.value(forKeyPath: "error.message")!)", viewController: self)
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
        else
        {
            // let nextVC = UIStoryboard(name: deviceType, bundle: nil).instantiateViewController(withIdentifier: "ErrorViewController") as! ErrorViewController
            //  self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    func isValidEmail(testStr:String) -> Bool
    {
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
        imagePicker.modalPresentationStyle = .fullScreen
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
                let urlStr = "\(ConfigUrl.baseUrl)store/product/upload"
                
                let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
                var request = URLRequest(url: URL(string: setFinalURl)!)
                request.httpMethod = HTTPMethod.post.rawValue
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                // request.setValue(userIDStr, forHTTPHeaderField: "Driver-Authorization")
                
                let setTemp: [String : Any] = params
                
                if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
                    request.httpBody = jsonData
                }
                
                //  request.httpBody = testData
                
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
        return 45
        
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
        self.tblCuisines.frame.size.height = CGFloat(self.cuisinesArr.count * 45) + 10
        self.tblCuisines.translatesAutoresizingMaskIntoConstraints = true
        self.tblPaymentMethod.frame.size.height = CGFloat(self.paymentMethodsArr.count * 42)
        self.tblPaymentMethod.translatesAutoresizingMaskIntoConstraints = true
        self.viewRestroBottom.frame.origin.y = self.tblCuisines.frame.origin.y + self.tblCuisines.frame.size.height + 8
        self.viewRestroBottom.translatesAutoresizingMaskIntoConstraints = true
        self.viewPaymentBottom.frame.origin.y = self.tblPaymentMethod.frame.origin.y + self.tblPaymentMethod.frame.size.height + 8
        self.viewPaymentBottom.translatesAutoresizingMaskIntoConstraints = true
        self.viewRestaurantInfo.frame.size.height = self.tblCuisines.frame.size.height + 656
        self.viewPaymentMethod.frame.size.height = self.tblPaymentMethod.frame.size.height + 132
        self.viewRestaurantInfo.translatesAutoresizingMaskIntoConstraints = true
        self.viewPaymentMethod.translatesAutoresizingMaskIntoConstraints = true
        if self.paymentMethodsArr.count == 0 {
            self.viewPaymentBottom.frame.origin.y = 0
            self.viewPaymentMethod.frame.size.height = self.viewPaymentBottom.frame.size.height
            self.viewPaymentMethod.translatesAutoresizingMaskIntoConstraints = true
        }
        self.viewPaymentMethod.frame.origin.y = self.viewRestaurantInfo.frame.origin.y + self.viewRestaurantInfo.frame.size.height + 10
        self.viewPaymentMethod.translatesAutoresizingMaskIntoConstraints = true
        self.viewWorkingHours.frame.origin.y = self.viewPaymentMethod.frame.origin.y + self.viewPaymentMethod.frame.size.height + 10
        self.viewWorkingHours.translatesAutoresizingMaskIntoConstraints = true
        self.viewBankDetails.frame.origin.y = self.viewWorkingHours.frame.origin.y + self.viewWorkingHours.frame.size.height + 10
        self.viewBankDetails.translatesAutoresizingMaskIntoConstraints = true
        self.btnUpdate.frame.origin.y = self.viewBankDetails.frame.origin.y + self.viewBankDetails.frame.size.height + 10
        self.btnUpdate.translatesAutoresizingMaskIntoConstraints = true
        
        self.viewRegister.frame.size.height = self.btnUpdate.frame.origin.y + self.btnUpdate.frame.size.height + 7
        self.viewRegister.frame.origin.y = 0
        self.viewRegister.translatesAutoresizingMaskIntoConstraints = true
        self.mainScrollView.addSubview(viewRegister)
        self.mainScrollView.contentSize = CGSize(width: self.viewRegister.frame.size.width, height: self.viewRegister.frame.size.height)
        self.viewRegister.isHidden = false
        
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
                            self.setFrames()
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
            // let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController") as! ErrorViewController
            // self.present(viewController, animated: true, completion: { () -> Void in
            // })
        }
    }
    
    //MARK: Map View Methods and delegates
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D)
    {
        let camera = GMSCameraPosition.camera(withLatitude: (coordinate.latitude), longitude: (coordinate.longitude), zoom: 17.0)
        self.mapView?.animate(to: camera)
        selectedLatitude = "\(coordinate.latitude)"
        selectedLongitude = "\(coordinate.longitude)"
        addressFromLatLong(lat: coordinate.latitude, long: coordinate.longitude)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition)
    {
        self.selectedLatitude = "\(mapView.camera.target.latitude)"
        self.selectedLongitude = "\(mapView.camera.target.longitude)"
        addressFromLatLong(lat: mapView.camera.target.latitude, long: mapView.camera.target.longitude)
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
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
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
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    func latLongFromAddress(address: String)
    {
        let reachability = Reachability()
        if (reachability?.isReachable)!
        {
            let urlStr = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address)&sensor=true&key=\(apiKey)"
            let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
            var request = URLRequest(url: URL(string: setFinalURl)!)
            request.httpMethod = HTTPMethod.get.rawValue
            request.setValue(userIDStr, forHTTPHeaderField: "Customer-Authorization")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            Alamofire.request(request).responseJSON
                { (responseObject) -> Void in
                    //SharedManager.showHUD(viewController: self)
                    if responseObject.result.isSuccess
                    {
                        let result = responseObject.result.value! as AnyObject
                        if let status = result.value(forKey: "status")
                        {
                            if status as! String == "OK"
                            {
                                let addressComponents = (result.value(forKey: "results") as AnyObject).object(at: 0) as AnyObject
                                let lat = "\(String(describing: addressComponents.value(forKeyPath: "geometry.location.lat")!))"
                                let long = "\(String(describing: addressComponents.value(forKeyPath: "geometry.location.lng")!))"
                                self.selectedLatitude = lat
                                self.selectedLongitude = long
                                let camera = GMSCameraPosition.camera(withLatitude: Double(lat)!, longitude: Double(long)!, zoom: 17.0)
                                self.mapView?.animate(to: camera)
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
        }else{
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
        //        print("Place name: \(place.name)")
        //        print("Place address: \(String(describing: place.formattedAddress!))")
        //        print("Place attributions: \(String(describing: place.attributions))")
        latLongFromAddress(address: "\(String(describing: place.formattedAddress!))")
        self.lblAddress.text = "\(String(describing: place.formattedAddress!))"
        UINavigationBar.appearance().barTintColor = themeColor
        UINavigationBar.appearance().tintColor = .white
        dismiss(animated: true, completion: nil)
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
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController){
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
                
                print(String(data: responseObject.data!, encoding: String.Encoding.utf8)!)
                if responseObject.result.isSuccess
                {
                    SharedManager.dismissHUD(viewController: self)
                    print(responseObject.result.value!)
                    
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
        
    }
    
    func calendar(_ calendar: CalendarView, didScrollToMonth date : Date) {
        
        // self.datePicker.setDate(date, animated: true)
    }
    
    
    func calendar(_ calendar: CalendarView, didLongPressDate date : Date) {
        
        let alert = UIAlertController(title: NSLocalizedString("Create New Event", comment: ""), message: "Message", preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = NSLocalizedString("Event Title", comment: "")
        }
        
        let addEventAction = UIAlertAction(title: NSLocalizedString("Create", comment: ""), style: .default, handler: { (action) -> Void in
            let title = alert.textFields?.first?.text
            self.calendarView.addEvent(title!, date: date)
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
        
        alert.addAction(addEventAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func UTCToLocal(date:String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dt!
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
    
    //MARK: Button Actions
    
    @IBAction func clickStatus(_ sender: Any)
    {
        view.endEditing(true)
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
        self.locationManager.startUpdatingLocation()
    }
    
    @IBAction func clickUpdateProfile(_ sender: Any)
    {
        
        if txtRestroNameEng.text == ""
        {
            txtRestroNameEng.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.25)
            SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry!", comment: ""), alertMessage: NSLocalizedString("Please Enter restaurant Name in English", comment: ""), viewController: self)
        }
        else
        {
            if txtRestroNameAr.text == ""
            {
                txtRestroNameAr.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.25)
                SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry!", comment: ""), alertMessage: NSLocalizedString("Please Enter restaurant Name in Arabic", comment: ""), viewController: self)
            }
            else
            {
                if txtOwnername.text == ""
                {
                    txtOwnername.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.25)
                     SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry!", comment: ""), alertMessage: NSLocalizedString("Please Enter Owner Name", comment: ""), viewController: self)
                }
                else
                {
                    if txtEmail.text == ""
                    {
                        txtEmail.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.25)
                        SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry!", comment: ""), alertMessage: NSLocalizedString("Please Enter your Email-Id", comment: ""), viewController: self)
                    }
                    else
                    {
                        if !self.isValidEmail(testStr: txtEmail.text!)
                        {
                            txtEmail.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.1)
                            SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry!", comment: ""), alertMessage: NSLocalizedString("Please Enter a Valid Email-Id", comment: ""), viewController: self)
                        }
                        else
                        {
                            if txtMobileNumber.text == ""
                            {
                                txtMobileNumber.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.25)
                                 SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry!", comment: ""), alertMessage: NSLocalizedString("Please Enter your Mobile Number", comment: ""), viewController: self)
                            }
                            else
                            {
                                if lblAddress.text == ""
                                {
                                    txtStatus.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.25)
                                     SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry!", comment: ""), alertMessage: NSLocalizedString("Please Select Address from Map", comment: ""), viewController: self)
                                }
                                else
                                {
                                    saveProfile()
                                }
                            }
                        }
                    }
                }
            }
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
}
