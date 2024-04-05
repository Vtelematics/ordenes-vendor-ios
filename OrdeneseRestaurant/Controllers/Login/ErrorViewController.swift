//
//  ErrorViewController.swift
//  Foodesoft Vendor
//
//  Created by Adyas on 09/01/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class ErrorViewController: ParentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func clickRetry(_ sender: Any) {
        
        let reachability = Reachability()
        if (reachability?.isReachable)! {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: {})
        }else {
            SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Still there is no Connection Found", comment: ""), viewController: self)
        }
    }
    
}
