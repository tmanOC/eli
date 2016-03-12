//
//  ViewController.swift
//  bfinterpreter
//
//  Created by Tielman Janse van Vuuren on 2015/11/28.
//  Copyright © 2015 tman. All rights reserved.
//

import UIKit

protocol DoneActionable
{
    func doneButtonAction()
}
protocol StepActionable
{
    func stepButtonAction()
}

extension UIToolbar
{
    func addStepThroughAction(target: StepActionable)
    {
        let step = UIBarButtonItem(title: "Step", style: UIBarButtonItemStyle.Done, target: target as? AnyObject, action: "stepButtonAction")
        self.items?.insert(step, atIndex: 0);
    }
    
    class func makeDoneAccessory(target: DoneActionable) -> UIToolbar
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 44))
        doneToolbar.barStyle = UIBarStyle.Default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: target as? AnyObject, action: Selector("doneButtonAction"))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        return doneToolbar
    }
    
    
}

extension String
{
    func characterAtIndex(index:Int) -> String
    {
        return self.substringWithRange(self.startIndex.advancedBy(index) ... self.startIndex.advancedBy(index))
    }
}

class ViewController: UIViewController,DoneActionable,StepActionable {
    let text_view_input:UITextView = UITextView()
    let text_view_output:UITextView = UITextView()
    var delegate_text_view:TextViewDelegate?
    
    override func viewDidLoad() {
        self.delegate_text_view = TextViewDelegate()
        self.text_view_output.delegate = self.delegate_text_view
        
        self.text_view_input.frame = CGRectMake(0, 20, self.view.frame.width, (self.view.frame.height-20)/2)
        self.text_view_output.frame = CGRectMake(0, self.text_view_input.frame.height + 20, self.view.frame.width, (self.view.frame.height-20)/2)
        self.text_view_input.layer.borderColor = UIColor.blackColor().CGColor
        self.text_view_output.layer.borderColor = UIColor.blackColor().CGColor
        self.text_view_input.layer.borderWidth = 0.5
        self.text_view_output.layer.borderWidth = 0.5
        super.viewDidLoad()
        self.view.addSubview(self.text_view_output)
        self.view.addSubview(self.text_view_input)
        //self.text_view_output.userInteractionEnabled = false
        
        self.addAccessoryToTextView()
        
        self.text_view_input.font = UIFont(name: "Courier New", size: 14)
        self.text_view_output.font = UIFont(name: "Courier New", size: 14)
    }
    func addAccessoryToTextView()
    {
        let toolbar = UIToolbar.makeDoneAccessory(self)
        toolbar.addStepThroughAction(self);
        self.text_view_input.inputAccessoryView = toolbar
        
        self.text_view_output.inputAccessoryView = UIToolbar.makeDoneAccessory(self)
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.text_view_input.text = NSUserDefaults.standardUserDefaults().objectForKey("INPUT") as? String
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    func stepButtonAction() {
        print("Step")
    }
    func doneButtonAction() {
        if(self.text_view_output.isFirstResponder())
        {
            self.text_view_output.resignFirstResponder()
            return
        }
        self.text_view_input.resignFirstResponder()
        //empty text_view_output
        self.text_view_output.text = ""
        var array_chars:Array<CChar> = [0]
        var position:Int = 0
        //execute all the instructions in text_view_input
        
        var i:Int = 0
        var input_pos:Int = 0
        let input:NSString = self.text_view_input.text
        //let inputB:NSString = self.text_view_input.text
        //print(inputB)
        NSUserDefaults.standardUserDefaults().setObject(input, forKey: "INPUT")
        
        
        while i < input.length
        {
            if(input.characterAtIndex(i) == NSString(string: "+").characterAtIndex(0))
            {
                array_chars[position] += 1
            }else if(input.characterAtIndex(i) == NSString(string: "-").characterAtIndex(0))
            {
                array_chars[position] -= 1
            }
            else if(input.characterAtIndex(i) == NSString(string: "<").characterAtIndex(0))
            {
                position -= 1
            }
            else if(input.characterAtIndex(i) == NSString(string: ">").characterAtIndex(0))
            {
                position += 1
                if(position == array_chars.count)
                {
                    array_chars.append(0)
                }
            }
            else if(input.characterAtIndex(i) == NSString(string: ".").characterAtIndex(0))
            {
                if(self.text_view_output.text == nil)
                {
                    print("###")
                }
                let string:String = String.init(Character(UnicodeScalar(
                    UInt8(array_chars[position]))))
                print(string)
                
                self.text_view_output.text.appendContentsOf(string)
                print(self.text_view_output.text)
                print(Character(UnicodeScalar(
                    UInt8(array_chars[position]))))
            }
            else if(input.characterAtIndex(i) == NSString(string: ",").characterAtIndex(0))
            {
                array_chars[position] = CChar(
                (self.delegate_text_view!.input_string as NSString).UTF8String.advancedBy(input_pos).memory)
                input_pos += 1
                print(array_chars[position])
                //wait for a single key from input
                
            }
            else if(input.characterAtIndex(i) == NSString(string: "[").characterAtIndex(0))
            {
                if(array_chars[position] == 0)
                {
                    while(i < input.length && input.characterAtIndex(i) != NSString(string: "]").characterAtIndex(0))
                    {
                        i += 1
                    }
                }
            }
            else if(input.characterAtIndex(i) == NSString(string: "]").characterAtIndex(0))
            {
                if(array_chars[position] != 0)
                {
                    var extra = 0
                    while(input.characterAtIndex(i) != NSString(string: "[").characterAtIndex(0) || extra != 0)
                    {
                        
                        
                        if(input.characterAtIndex(i) == NSString(string: "]").characterAtIndex(0))
                        {
                            extra += 1;
                        }
                        i -= 1
                        if(input.characterAtIndex(i) == NSString(string: "[").characterAtIndex(0))
                        {
                            extra -= 1;
                        }
                        
                    }
                }
            }
            else if(input.characterAtIndex(i) == NSString(string: "^").characterAtIndex(0))
            {
                //let string:String = String.init(Character(UnicodeScalar(
                    //UInt8(array_chars[position]))))
                let string = String(format: "%d",position)
                self.text_view_output.text.appendContentsOf(string)
            }
            else if(input.characterAtIndex(i) == NSString(string: "$").characterAtIndex(0))
            {
                let string = String(format: "%d", array_chars[position])
                self.text_view_output.text.appendContentsOf(string)
                
            }
            else if(input.characterAtIndex(i) == NSString(string: ";").characterAtIndex(0))
            {
                while(i < input.length && input.characterAtIndex(i) != NSString(string: "\n").characterAtIndex(0))
                {
                    i += 1;
                }
            }
            i = i + 1
        }
        
        //output the results to text_view_output
       
        return
    }

    
    func keyboardWillShow(notification: NSNotification)
    {
        let (start,end,duration,curve) = retrieveFramesFromKeyboardNotification(notification)
        UIView.animateWithDuration(duration, delay: 0, options: curve, animations: { () -> Void in
            let change = start.origin.y - end.origin.y
            if(self.text_view_input.isFirstResponder())
            {
                self.text_view_input.frame.size.height = end.origin.y - self.text_view_input.frame.origin.y
                print("top")
                self.view.bringSubviewToFront(self.text_view_input)
            }
            else if(self.text_view_output.isFirstResponder())
            {
                self.text_view_output.frame.origin.y = 20
                self.text_view_output.frame.size.height = end.origin.y - self.text_view_output.frame.origin.y
                self.view.bringSubviewToFront(self.text_view_output)
                print("bottom")
            }
            }, completion: nil)
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        let (start,end,duration,curve) = retrieveFramesFromKeyboardNotification(notification)
        
        UIView.animateWithDuration(duration, delay: 0, options: curve, animations: { () -> Void in
            let change = start.origin.y - end.origin.y
            self.text_view_input.frame = CGRectMake(0, 20, self.view.frame.width, (self.view.frame.height-20)/2)
            self.text_view_output.frame = CGRectMake(0, self.text_view_input.frame.height + 20, self.view.frame.width, (self.view.frame.height-20)/2)
            }, completion: nil)
    }
}



