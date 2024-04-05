//
//  OrderTblCell.swift
//  Foodesoft Vendor
//
//  Created by Adyas Infotech on 01/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class OrderTblCell: UITableViewCell {

    //MARK: Order List
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var lblCustomerName: UILabel!
    @IBOutlet weak var lblPhoneNo: UILabel!
    @IBOutlet weak var lblOrderDate: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDeliveryType: UILabel!
    @IBOutlet weak var lblSchedule: UILabel!
    @IBOutlet weak var lblScheduleColon: UILabel!
    @IBOutlet weak var lblScheduleDate: UILabel!
    @IBOutlet weak var imgProductEdit: UIImageView!
    @IBOutlet weak var btnViewDetails: UIButton!
    
    //MARK: Order Details
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblProductQuantity: UILabel!
    @IBOutlet weak var lblProductTotal: UILabel!
    @IBOutlet weak var lblOption: UILabel!
    
    @IBOutlet weak var lblTotalTitle: UILabel!
    @IBOutlet weak var lblTotalValue: UILabel!
    
    @IBOutlet weak var lblHistoryStatus: UILabel!
    @IBOutlet weak var lblHistoryDateOrder: UILabel!
    
    
    @IBOutlet weak var viewShadow1: UIView!
    @IBOutlet weak var viewShadow2: UIView!
    @IBOutlet weak var viewShadow3: UIView!
    
    //Mark: Section
    @IBOutlet weak var lblSectionName: UILabel!
    @IBOutlet weak var lblSectionStatus: UILabel!
    @IBOutlet weak var btnEditSection: UIButton!
    @IBOutlet weak var btnDeleteSection: UIButton!
    @IBOutlet weak var viewShadowSection: UIView!
    @IBOutlet weak var imgEdit: UIImageView!
    @IBOutlet weak var imgDelete: UIImageView!
    
    @IBOutlet weak var btnPreparing: UIButton!
    @IBOutlet weak var btnDelay: UIButton!
    @IBOutlet weak var btnReady: UIButton!
    @IBOutlet weak var btnDelay2: UIButton!
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    
    //Mark: Coupon
    @IBOutlet weak var lblCouponName: UILabel!
    @IBOutlet weak var lblCouponCode: UILabel!
    @IBOutlet weak var lblCouponDiscount: UILabel!
    @IBOutlet weak var lblCouponStatus: UILabel!
    @IBOutlet weak var viewShadowCoupon: UIView!
    
    @IBOutlet weak var imgEditCoupon: UIImageView!
    @IBOutlet weak var imgDeleteCoupon: UIImageView!
    @IBOutlet weak var btnEditCoupon: UIButton!
    @IBOutlet weak var btnDeleteCoupon: UIButton!
    
    @IBOutlet weak var imgCheckBox: UIImageView!
    @IBOutlet weak var lblProductName: UILabel!
    
    //Language
    @IBOutlet var lblLanguage: UILabel!
    @IBOutlet var imgLanguage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
