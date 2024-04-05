//
//  ProductTblCell.swift
//  GroceryStore
//
//  Created by Adyas Infotech on 11/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ProductTblCell: UITableViewCell {

    //MARK: ProductVc - List
    
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblProductPrice: UILabel!
    @IBOutlet weak var lblProductQuantity: UILabel!
    @IBOutlet weak var lblProductStatus: UILabel!
    
    @IBOutlet weak var imgProductEdit: UIImageView!
    @IBOutlet weak var imgProductDelete: UIImageView!
    @IBOutlet weak var btnProductEdit: UIButton!
    @IBOutlet weak var btnProductDelete: UIButton!
    
    //MARK: ProductVc - Detail
    @IBOutlet weak var imgProductProductDetail: UIImageView!
    @IBOutlet weak var txtSortProductDetail: UITextField!
    @IBOutlet weak var btnDeleteProductDetail: UITextField!
    
    //Mark: TblSection(ProductVc)
    @IBOutlet weak var imgCheckBox: UIImageView!
    @IBOutlet weak var lblSectionName: UILabel!
    
    //MARK: CategoryVc
    @IBOutlet weak var lblCatName: UILabel!
    @IBOutlet weak var lblCatSortTitle: UILabel!
    @IBOutlet weak var lblCatSortOrder: UILabel!
    @IBOutlet weak var viewShadowCat: UIView!
    @IBOutlet weak var imgEdit: UIImageView!
    @IBOutlet weak var imgDelete: UIImageView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    //Mark: OptionVc
    @IBOutlet weak var lblOptionName: UILabel!
    @IBOutlet weak var lblOptionSortTitle: UILabel!
    @IBOutlet weak var lblOptionSortOrder: UILabel!
    @IBOutlet weak var viewShadowOption: UIView!
    @IBOutlet weak var imgEditOption: UIImageView!
    @IBOutlet weak var imgDeleteOption: UIImageView!
    @IBOutlet weak var btnEditOption: UIButton!
    @IBOutlet weak var btnDeleteOption: UIButton!
    
    //optionValue(OptionVc)
    @IBOutlet weak var viewShadowOptionValue: UIView!
    @IBOutlet weak var lblOptionValueName: UILabel!
    @IBOutlet weak var lblOptionValueSortOrder: UILabel!
    @IBOutlet weak var imgEditOptionValue: UIImageView!
    @IBOutlet weak var imgDeleteOptionValue: UIImageView!
    @IBOutlet weak var btnEditOptionValue: UIButton!
    @IBOutlet weak var btnDeleteOptionValue: UIButton!
    
    @IBOutlet var switchBtn: UISwitch!
    
    //search
    @IBOutlet weak var lblSearchPdtName: UILabel!
    @IBOutlet weak var lblSearchPdtPrice: UILabel!
    @IBOutlet var switchBtnSearch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
