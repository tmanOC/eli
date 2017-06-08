//
//  KeyboardNotification.swift
//  GoogleMap
//
//  Created by Tielman Janse van Vuuren on 2015/10/20.
//  Copyright © 2015 4imobile. All rights reserved.
//

import Foundation
import UIKit

func retrieveRectFromNSValue(_ value:NSValue) -> CGRect
{
    let frame_pointer:UnsafeMutablePointer<CGRect> = UnsafeMutablePointer.allocate(capacity: 1)
    value.getValue(frame_pointer)
    let start_frame = frame_pointer.pointee
    frame_pointer.deallocate(capacity: 1)
    return start_frame
}

func retrieveFramesFromKeyboardNotification(_ notification:Notification)->(CGRect,CGRect,Double,UIViewAnimationOptions)
{
    let key_info:Dictionary = notification.userInfo!
    let start_frame_value:NSValue = key_info[UIKeyboardFrameBeginUserInfoKey] as! NSValue
    let end_frame_value:NSValue = key_info[UIKeyboardFrameEndUserInfoKey] as! NSValue
    
    let duration = (key_info[UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
    let curve:UIViewAnimationCurve = UIViewAnimationCurve(rawValue:  (key_info[UIKeyboardAnimationCurveUserInfoKey]! as AnyObject).intValue!)!
    
    let animation_options:UIViewAnimationOptions
    switch(curve)
    {
    case UIViewAnimationCurve.easeIn:
        animation_options = UIViewAnimationOptions.curveEaseIn
    case UIViewAnimationCurve.easeInOut:
        animation_options = UIViewAnimationOptions()
    case UIViewAnimationCurve.linear:
        animation_options = UIViewAnimationOptions.curveLinear
    case UIViewAnimationCurve.easeOut:
        animation_options = UIViewAnimationOptions.curveEaseOut
    }
    return (retrieveRectFromNSValue(start_frame_value),retrieveRectFromNSValue(end_frame_value),duration!,animation_options)
}
