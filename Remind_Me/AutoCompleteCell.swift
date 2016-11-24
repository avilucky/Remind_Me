//
//  AutocompleteCell.swift
//  Remind_Me
//
//  Created by Ajinkya Kulkarni on 10/29/16.
//  Copyright © 2016 Ajinkya Kulkarni. All rights reserved.
//


import UIKit
open class AutoCompleteCell: UITableViewCell {
    //MARK: - outlets
    @IBOutlet fileprivate weak var lblTitle: UILabel!
    @IBOutlet fileprivate weak var imgIcon: UIImageView!

    //MARK: - public properties
    open var textImage: AutocompleteCellData? {
        didSet {
            self.lblTitle.text = textImage!.text
            
        }
    }
}
