//
//  AutocompleteDelegate.swift
//  Remind_Me
//
//  Created by Ajinkya Kulkarni on 10/29/16.
//  Copyright © 2016 Ajinkya Kulkarni. All rights reserved.
//


import UIKit

public protocol AutocompleteDelegate: class {
    func autoCompleteTextField() -> UITextField
    func autoCompleteThreshold(_ textField: UITextField) -> Int
    func autoCompleteItemsForSearchTerm(_ term: String) -> [AutocompletableOption]
    func autoCompleteHeight() -> CGFloat
    func didSelectItem(_ item: AutocompletableOption) -> Void

    func nibForAutoCompleteCell() -> UINib
    func heightForCells() -> CGFloat
    func getCellDataAssigner() -> ((UITableViewCell, AutocompletableOption) -> Void)
}

public extension AutocompleteDelegate {
    func nibForAutoCompleteCell() -> UINib {
        return UINib(nibName: "DefaultAutoCompleteCell", bundle: Bundle(for: AutoCompleteViewController.self))
    }

    func heightForCells() -> CGFloat {
        return 60
    }

    func getCellDataAssigner() -> ((UITableViewCell, AutocompletableOption) -> Void) {
        let assigner: ((UITableViewCell, AutocompletableOption) -> Void) = {
            (cell: UITableViewCell, cellData: AutocompletableOption) -> Void in
            if let cell = cell as? AutoCompleteCell, let cellData = cellData as? AutocompleteCellData {
                cell.textImage = cellData
            }
        }
        return assigner
    }
}
