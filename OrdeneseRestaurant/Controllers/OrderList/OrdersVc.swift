
import UIKit
import Alamofire

class OrdersVc: UIViewController {

    @IBOutlet weak var tblOrderList: UITableView!
    @IBOutlet weak var collHeader: UICollectionView!
    @IBOutlet weak var viewRefresh: UIView!
    @IBOutlet weak var imgRefresh: UIImageView!
    
    var orderListArr = NSMutableArray()
    var orderStatusId = ""
    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "10"
    var orderStatusListArr = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblOrderList.register(UINib(nibName: "OrderCell", bundle: nil), forCellReuseIdentifier: "OrderTblCell")
        self.imgRefresh.image = UIImage(named: "ic_refresh")
        self.imgRefresh.image = self.imgRefresh.image!.withRenderingMode(.alwaysTemplate)
        self.imgRefresh.tintColor = .white
        self.orderStatusList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if orderStatusListArr.count != 0{
            self.getOrderList()
        }
    }
    
    // MARK: API Methods
    func orderStatusList()
    {
        SharedManager.showHUD(viewController: self)
        let urlStr = "\(ConfigUrl.baseUrl)order-status-list"
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
                    if "\(String(describing: responseObject.response!.statusCode))" == "200"
                    {
                        let result = responseObject.result.value! as AnyObject
                        print(result)
                        let statusIds = (result.value(forKey: "order_statuses") as! NSArray).mutableCopy() as! NSMutableArray
                        if statusIds.count != 0
                        {
                            if UserDefaults.standard.object(forKey: "USER_DETAILS") != nil
                            {
                                let data = UserDefaults.standard.object(forKey: "USER_DETAILS") as! Data
                                let userDic = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
                                let vendorType = "\(userDic.value(forKeyPath: "vendor_info.vendor_type")!)"
                                if vendorType == "2" {
                                    for i in 0..<statusIds.count{
                                        let id = "\((statusIds.object(at: i) as AnyObject).value(forKey: "vendor_status_id")!)"
                                        if id != "3"{
                                            self.orderStatusListArr.add(statusIds[i])
                                        }
                                    }
                                }else{
                                    for i in 0..<statusIds.count{
                                        let id = "\((statusIds.object(at: i) as AnyObject).value(forKey: "vendor_status_id")!)"
//                                        if id != "2"{
//                                            self.orderStatusListArr.add(statusIds[i])
//                                        }
                                        self.orderStatusListArr.add(statusIds[i])
                                    }
                                }
                            }
                            self.orderStatusId = "\((self.orderStatusListArr.object(at: 0) as AnyObject).value(forKey: "vendor_status_id")!)"
                            self.collHeader.dataSource = self
                            self.collHeader.delegate = self
                            self.collHeader.reloadData()
                            if isRTLenabled {
                                self.collHeader.scrollToItem(at: [0, 0], at: .right, animated: true)
                            }else {
                                self.collHeader.setContentOffset(.zero, animated: false)
                            }
                            SharedManager.dismissHUD(viewController: self)
                            self.getOrderList()
                        }
                    }
                    else
                    {
                        SharedManager.dismissHUD(viewController: self)
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
    
    func getOrderList()
    {
        SharedManager.showHUD(viewController: self)
        page = 1
        let params = [
            "page_per_unit" : limit,
            "page" : page,
            "order_status_id" :orderStatusId
        ] as [String : Any]
        let urlStr = "\(ConfigUrl.baseUrl)order-list"
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
                        if "\(status)" == "200"
                        {
                            let result = (responseObject.result.value! as AnyObject) as! NSDictionary
                            print(result)
                            self.orderListArr = (result.value(forKey: "order") as! NSArray).mutableCopy() as! NSMutableArray
                            if self.orderListArr.count == 0
                            {
                                self.tblOrderList.isHidden = true
                                self.viewRefresh.isHidden = true
                            }
                            else
                            {
                                self.viewRefresh.isHidden = false
                                self.tblOrderList.isHidden = false
                            }
                            let total = "\(String(describing: result.value(forKey: "total")!))"
                            self.pageCount = Double(Int(total)!/Int(self.limit)!)
                            self.tblOrderList.dataSource = self
                            self.tblOrderList.delegate = self
                            self.tblOrderList.reloadData()
                            SharedManager.dismissHUD(viewController: self)
                        }
                    }
                    else
                    {
                        SharedManager.dismissHUD(viewController: self)
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
    
    //MARK: Pagination
    func pullToRefresh()
    {
        if (self.isScrolledOnce == true)
        {
            return
        }
        self.isScrolledOnce = true
        print(page, pageCount)
        
        if page <= Int(self.pageCount)
        {
            page += 1
            
            SharedManager.showHUD(viewController: self)
            let params = [
                "page_per_unit" : limit,
                "page" : page,
                "order_status_id" :orderStatusId
            ] as [String : Any]
            
            let urlStr = "\(ConfigUrl.baseUrl)order-list"
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
                    
                    SharedManager.dismissHUD(viewController: self)
                    if responseObject.result.isSuccess
                    {
                        SharedManager.dismissHUD(viewController: self)
                        print(responseObject)
                        if "\(String(describing: responseObject.response!.statusCode))" == "200"
                        {
                            let result = (responseObject.result.value! as AnyObject) as! NSDictionary
                            print(result)
                            
                            let array = (result.value(forKey: "order") as! NSArray).mutableCopy() as! NSMutableArray
                            
                            self.orderListArr.addObjects(from: array as! [Any])
                            
                            self.tblOrderList.reloadData()
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
        if scrollView == tblOrderList{
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
    }
    
    //MARK: Button action
    @IBAction func clickRefresh(_ sender: Any)
    {
        self.getOrderList()
    }
}

extension OrdersVc: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return orderListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTblCell") as! OrderTblCell
        
        let type = "\(String(describing: (orderListArr.object(at: indexPath.row) as AnyObject).value(forKey: "delivery_type")!))"
        cell.viewShadow.layer.shadowColor = UIColor.gray.cgColor
        cell.viewShadow.layer.shadowOpacity = 1
        cell.viewShadow.layer.shadowOffset = CGSize.zero
        cell.viewShadow.layer.shadowRadius = 3
        let orderTime = "\(String(describing: (orderListArr.object(at: indexPath.row) as AnyObject).value(forKey: "order_time")!))"
        let orderDate = "\(String(describing: (orderListArr.object(at: indexPath.row) as AnyObject).value(forKey: "order_date")!))"
        if isRTLenabled{
            cell.lblOrderId.text = "\(String(describing: (orderListArr.object(at: indexPath.row) as AnyObject).value(forKey: "order_id")!))" + NSLocalizedString("Order ID:", comment: "")
            cell.lblOrderDate.text = orderTime + " | " + orderDate
            cell.lblDeliveryType.textAlignment = .left
        }else{
            cell.lblOrderId.text = NSLocalizedString("Order ID:", comment: "") + "\(String(describing: (orderListArr.object(at: indexPath.row) as AnyObject).value(forKey: "order_id")!))"
            cell.lblOrderDate.text = orderDate + " | " + orderTime
            cell.lblDeliveryType.textAlignment = .right
        }
        cell.lblDeliveryType.text = type == "1" ? NSLocalizedString("Order type: Delivery", comment: "") : NSLocalizedString("Order type: Pickup", comment: "")
        cell.lblCustomerName.text = "\(String(describing: (orderListArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!))"
        cell.lblTotal.text = "\(String(describing: (orderListArr.object(at: indexPath.row) as AnyObject).value(forKey: "total")!))"
        cell.lblStatus.text = "\(String(describing: (orderListArr.object(at: indexPath.row) as AnyObject).value(forKey: "status")!))"
        cell.imgProductEdit.image = UIImage (named: "ic_edit")
        cell.imgProductEdit.image = cell.imgProductEdit.image!.withRenderingMode(.alwaysTemplate)
        cell.imgProductEdit.tintColor = UIColor.lightGray
        cell.viewShadow.layer.shadowColor = UIColor.gray.cgColor
        cell.viewShadow.layer.shadowOpacity = 0.5
        cell.viewShadow.layer.shadowOffset = CGSize.zero
        cell.viewShadow.layer.shadowRadius = 2
        if let scheduleStatus = (orderListArr.object(at: indexPath.row) as AnyObject).value(forKey: "schedule_status"), scheduleStatus as! String == "1"{
            cell.lblScheduleDate.text = "\(String(describing: (orderListArr.object(at: indexPath.row) as AnyObject).value(forKey: "schedule_date")!)) | \(String(describing: (orderListArr.object(at: indexPath.row) as AnyObject).value(forKey: "schedule_time")!))"
            cell.lblScheduleDate.isHidden = false
            cell.lblSchedule.isHidden = false
            cell.lblScheduleColon.isHidden = false
        }else{
            cell.lblScheduleDate.isHidden = true
            cell.lblSchedule.isHidden = true
            cell.lblScheduleColon.isHidden = true
        }
        cell.btnViewDetails.addTarget(self, action: #selector(clickViewDetails(_ :)), for: .touchUpInside)
        cell.btnViewDetails.tag = indexPath.row
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if let scheduleStatus = (orderListArr.object(at: indexPath.row) as AnyObject).value(forKey: "schedule_status"), scheduleStatus as! String == "1"{
            return 235
        }else{
            return 210
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    
    
    @objc func clickViewDetails(_ sender: UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "OrderDetailsVc") as! OrderDetailsVc
        let orderID = "\(String(describing: (orderListArr.object(at: sender.tag) as AnyObject).value(forKey: "order_id")!))"
        viewController.orderId = orderID
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension OrdersVc: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderStatusListArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath) as! HomeHeaderCollCell
        cell.lblHeader.text = "\((orderStatusListArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
        let statusId = "\((orderStatusListArr.object(at: indexPath.row) as AnyObject).value(forKey: "vendor_status_id")!)"
        if statusId == orderStatusId {
            cell.lblHeader.textColor = themeColor
            cell.lblLine.backgroundColor = themeColor
        }else{
            cell.lblHeader.textColor = .black
            cell.lblLine.backgroundColor = .clear
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.orderStatusId = "\((orderStatusListArr.object(at: indexPath.row) as AnyObject).value(forKey: "vendor_status_id")!)"
        self.collHeader.reloadData()
        self.getOrderList()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
                        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 40)
    }
}

