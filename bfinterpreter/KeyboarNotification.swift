//
//  KeyboardNotification.swift
//  GoogleMap
//
//  Created by Tielman Janse van Vuuren on 2015/10/20.
//  Copyright © 2015 4imobile. All rights reserved.
//

import Foundation
import UIKit

func retrieveRectFromNSValue(value:NSValue) -> CGRect
{
    let frame_pointer:UnsafeMutablePointer<CGRect> = UnsafeMutablePointer.alloc(1)
    value.getValue(frame_pointer)
    let start_frame = frame_pointer.memory
    frame_pointer.dealloc(1)
    return start_frame
}

func retrieveFramesFromKeyboardNotification(notification:NSNotification)->(CGRect,CGRect,Double,UIViewAnimationOptions)
{
    let key_info:Dictionary = notification.userInfo!
    let start_frame_value:NSValue = key_info[UIKeyboardFrameBeginUserInfoKey] as! NSValue
    let end_frame_value:NSValue = key_info[UIKeyboardFrameEndUserInfoKey] as! NSValue
    
    let duration = key_info[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
    let curve:UIViewAnimationCurve = UIViewAnimationCurve(rawValue:  key_info[UIKeyboardAnimationCurveUserInfoKey]!.integerValue!)!
    
    let animation_options:UIViewAnimationOptions
    switch(curve)
    {
    case UIViewAnimationCurve.EaseIn:
        animation_options = UIViewAnimationOptions.CurveEaseIn
    case UIViewAnimationCurve.EaseInOut:
        animation_options = UIViewAnimationOptions.CurveEaseInOut
    case UIViewAnimationCurve.Linear:
        animation_options = UIViewAnimationOptions.CurveLinear
    case UIViewAnimationCurve.EaseOut:
        animation_options = UIViewAnimationOptions.CurveEaseOut
    }
    return (retrieveRectFromNSValue(start_frame_value),retrieveRectFromNSValue(end_frame_value),duration,animation_options)
}
