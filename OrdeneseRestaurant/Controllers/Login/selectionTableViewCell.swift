//
//  selectionTableViewCell.swift
//  Foodesoft Vendor
//
//  Created by Apple on 28/11/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class selectionTableViewCell: UITableViewCell
{
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgSelection: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
