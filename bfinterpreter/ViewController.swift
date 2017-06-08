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
    func addStepThroughAction(_ target: StepActionable)
    {
        let step = UIBarButtonItem(title: "Step", style: UIBarButtonItemStyle.done, target: target, action: #selector(ViewController.stepButtonAction))
        self.items?.insert(step, at: 0);
    }
    
    class func makeDoneAccessory(_ target: DoneActionable) -> UIToolbar
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: target, action: #selector(ViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        return doneToolbar
    }
    
    
}

class ViewController: UIViewController,DoneActionable,StepActionable {
    let text_view_input:UITextView = UITextView()
    let text_view_output:UITextView = UITextView()
    var delegate_text_view:TextViewDelegate?
    
    override func viewDidLoad() {
        self.delegate_text_view = TextViewDelegate()
        self.text_view_output.delegate = self.delegate_text_view
        
        self.text_view_input.frame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: (self.view.frame.height-20)/2)
        self.text_view_output.frame = CGRect(x: 0, y: self.text_view_input.frame.height + 20, width: self.view.frame.width, height: (self.view.frame.height-20)/2)
        self.text_view_input.layer.borderColor = UIColor.black.cgColor
        self.text_view_output.layer.borderColor = UIColor.black.cgColor
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
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.text_view_input.text = UserDefaults.standard.object(forKey: "INPUT") as? String
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    func stepButtonAction() {
        print("Step")
    }
    func doneButtonAction() {
        if(self.text_view_output.isFirstResponder)
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
        let input:NSString = self.text_view_input.text as NSString
        //let inputB:NSString = self.text_view_input.text
        //print(inputB)
        UserDefaults.standard.set(input, forKey: "INPUT")
        
        
        while i < input.length
        {
            if(input.character(at: i) == NSString(string: "+").character(at: 0))
            {
                array_chars[position] += 1
            }else if(input.character(at: i) == NSString(string: "-").character(at: 0))
            {
                array_chars[position] -= 1
            }
            else if(input.character(at: i) == NSString(string: "<").character(at: 0))
            {
                position -= 1
            }
            else if(input.character(at: i) == NSString(string: ">").character(at: 0))
            {
                position += 1
                if(position == array_chars.count)
                {
                    array_chars.append(0)
                }
            }
            else if(input.character(at: i) == NSString(string: ".").character(at: 0))
            {
                if(self.text_view_output.text == nil)
                {
                    print("###")
                }
                let string:String = String.init(Character(UnicodeScalar(
                    UInt8(array_chars[position]))))
                print(string)
                
                self.text_view_output.text.append(string)
                print(self.text_view_output.text)
                print(Character(UnicodeScalar(
                    UInt8(array_chars[position]))))
            }
            else if(input.character(at: i) == NSString(string: ",").character(at: 0))
            {
                let string_input = self.delegate_text_view!.input_string
                if let character = string_input.substring(from:string_input.index(string_input.startIndex, offsetBy: input_pos)).utf8.first {
                    array_chars[position] = Int8(character)
                }
                //string.substring(from:string.index(string.startIndex, offsetBy: 3))
                //array_chars[position] = CChar(
                //(self.delegate_text_view!.input_string as NSString).utf8String.advancedBy(input_pos).pointee)
                input_pos += 1
                print(array_chars[position])
                //wait for a single key from input
                
            }
            else if(input.character(at: i) == NSString(string: "[").character(at: 0))
            {
                if(array_chars[position] == 0)
                {
                    while(i < input.length && input.character(at: i) != NSString(string: "]").character(at: 0))
                    {
                        i += 1
                    }
                }
            }
            else if(input.character(at: i) == NSString(string: "]").character(at: 0))
            {
                if(array_chars[position] != 0)
                {
                    var extra = 0
                    while(input.character(at: i) != NSString(string: "[").character(at: 0) || extra != 0)
                    {
                        
                        
                        if(input.character(at: i) == NSString(string: "]").character(at: 0))
                        {
                            extra += 1;
                        }
                        i -= 1
                        if(input.character(at: i) == NSString(string: "[").character(at: 0))
                        {
                            extra -= 1;
                        }
                        
                    }
                }
            }
            else if(input.character(at: i) == NSString(string: "^").character(at: 0))
            {
                //let string:String = String.init(Character(UnicodeScalar(
                    //UInt8(array_chars[position]))))
                let string = String(format: "%d",position)
                self.text_view_output.text.append(string)
            }
            else if(input.character(at: i) == NSString(string: "$").character(at: 0))
            {
                let string = String(format: "%d", array_chars[position])
                self.text_view_output.text.append(string)
                
            }
            else if(input.character(at: i) == NSString(string: ";").character(at: 0))
            {
                while(i < input.length && input.character(at: i) != NSString(string: "\n").character(at: 0))
                {
                    i += 1;
                }
            }
            i = i + 1
        }
        
        //output the results to text_view_output
       
        return
    }

    
    func keyboardWillShow(_ notification: Notification)
    {
        let (start,end,duration,curve) = retrieveFramesFromKeyboardNotification(notification)
        UIView.animate(withDuration: duration, delay: 0, options: curve, animations: { () -> Void in
            _ = start.origin.y - end.origin.y
            if(self.text_view_input.isFirstResponder)
            {
                self.text_view_input.frame.size.height = end.origin.y - self.text_view_input.frame.origin.y
                print("top")
                self.view.bringSubview(toFront: self.text_view_input)
            }
            else if(self.text_view_output.isFirstResponder)
            {
                self.text_view_output.frame.origin.y = 20
                self.text_view_output.frame.size.height = end.origin.y - self.text_view_output.frame.origin.y
                self.view.bringSubview(toFront: self.text_view_output)
                print("bottom")
            }
            }, completion: nil)
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        let (start,end,duration,curve) = retrieveFramesFromKeyboardNotification(notification)
        
        UIView.animate(withDuration: duration, delay: 0, options: curve, animations: { () -> Void in
            _ = start.origin.y - end.origin.y
            self.text_view_input.frame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: (self.view.frame.height-20)/2)
            self.text_view_output.frame = CGRect(x: 0, y: self.text_view_input.frame.height + 20, width: self.view.frame.width, height: (self.view.frame.height-20)/2)
            }, completion: nil)
    }
}



