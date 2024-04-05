//
//  ReportViewCell.swift
//  GroceryStore
//
//  Created by Adyas Infotech on 07/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ReportViewCell: UITableViewCell {

    //MARK: Order Report
    @IBOutlet weak var lblOrderNo: UILabel!
    @IBOutlet weak var lblOrderCustomer: UILabel!
    @IBOutlet weak var lblOrderStore: UILabel!
    @IBOutlet weak var lblOrderProducts: UILabel!
    @IBOutlet weak var lblOrderType: UILabel!
    @IBOutlet weak var lblOrderPaymentType: UILabel!
    @IBOutlet weak var lblOrderAmount: UILabel!
    @IBOutlet weak var viewShadowOrder: UIView!
    
    //MARK: Shipping Report
    @IBOutlet weak var lblShippingDateStart: UILabel!
    @IBOutlet weak var lblShippingDateEnd: UILabel!
    @IBOutlet weak var lblShippingTitle: UILabel!
    @IBOutlet weak var lblShippingOrdersCount: UILabel!
    @IBOutlet weak var lblShippingTotal: UILabel!
    @IBOutlet weak var viewShadowShipping: UIView!
    
    //MARK: Commission Report
    @IBOutlet weak var lblCommissionOrderId: UILabel!
    @IBOutlet weak var lblCommissionStore: UILabel!
    @IBOutlet weak var lblCommissionTotal: UILabel!
    @IBOutlet weak var lblCommission: UILabel!
    @IBOutlet weak var lblCommissionBalance: UILabel!
    @IBOutlet weak var viewShadowCommission: UIView!
    
    //MARK: Coupon Report
    @IBOutlet weak var lblCouponName: UILabel!
    @IBOutlet weak var lblCouponCode: UILabel!
    @IBOutlet weak var lblCouponOrders: UILabel!
    @IBOutlet weak var lblCouponTotal: UILabel!
    @IBOutlet weak var viewShadowCoupon: UIView!
    
    //MARK: Product Report
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblProductQuantity: UILabel!
    @IBOutlet weak var lblProductTotal: UILabel!
    @IBOutlet weak var viewShadowProduct: UIView!
    
    //MARK: Report
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblReportName: UILabel!
    @IBOutlet weak var lblReportAmount: UILabel!
    @IBOutlet weak var lblReportCount: UILabel!
    @IBOutlet weak var imgSelect: UIImageView!
    
    @IBOutlet weak var viewEmpty: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
