//
//  SideMenuTableViewCell.swift
//  Grocery
//
//  Created by Adyas Infotech on 21/07/18.
//  Copyright © 2018 Adyas Iinfotech. All rights reserved.
//

import UIKit

class SideMenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var btnEditAccount: UIButton!
    @IBOutlet weak var lblUserMobile: UILabel!
    @IBOutlet weak var lbluserEmail: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
