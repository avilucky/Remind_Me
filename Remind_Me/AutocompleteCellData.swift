//
//  AutocompleteCellData.swift
//  Remind_Me
//
//  Created by Ajinkya Kulkarni on 10/29/16.
//  Copyright © 2016 Ajinkya Kulkarni. All rights reserved.
//


import UIKit

public protocol AutocompletableOption {
    var text: String { get }
}

open class AutocompleteCellData: AutocompletableOption {
    fileprivate let _text: String
    open var text: String { get { return _text } }
   
    public init(text: String) {
        self._text = text
        
    }
}
