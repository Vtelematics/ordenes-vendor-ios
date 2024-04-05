//
//  ParentViewController.swift
//  eGroceryStore
//
//  Created by Adyas Infotech on 23/11/18.
//  Copyright © 2018 Adyas Infotech. All rights reserved.
//

import UIKit
import Alamofire

class ParentViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
