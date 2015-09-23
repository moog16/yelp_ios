//
//  CheckboxCell.swift
//  Yelp
//
//  Created by Matthew Goo on 9/23/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit

class CheckboxCell: UITableViewCell {

    @IBOutlet weak var checkboxLabel: UILabel!
    @IBOutlet weak var checkboxImage: UIImageView!
    var isSelected: Bool! = false
    let outline: UIImage = UIImage(named: "outline")!
    let checkbox: UIImage = UIImage(named: "checkbox")!
    var value: Double?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkboxImage.image = outline
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func checkOff() {
        isSelected = false
        checkboxImage.image = outline
    }
    
    func toggleValue() {
        isSelected = !isSelected
        checkboxImage.image = isSelected == true ? checkbox : outline
    }

}
