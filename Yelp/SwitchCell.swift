//
//  SwitchCell.swift
//  Yelp
//
//  Created by Matthew Goo on 9/22/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}
//UITableViewCellAccessoryCheckmark
class SwitchCell: UITableViewCell {
    weak var delegate: SwitchCellDelegate?
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        onSwitch.addTarget(self, action: "switchValueChanged", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func switchValueChanged() {
        delegate?.switchCell?(self, didChangeValue: onSwitch.on)
    }

}
