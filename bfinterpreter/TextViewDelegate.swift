//
//  TextViewDelegate.swift
//  bfinterpreter
//
//  Created by Tielman Janse van Vuuren on 2015/11/28.
//  Copyright © 2015 tman. All rights reserved.
//

import Foundation
import UIKit
class TextViewDelegate: NSObject,UITextViewDelegate
{
    var input_string:String = ""
    func textViewDidEndEditing(textView: UITextView) {
        input_string = textView.text
    }
    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = input_string
    }
}