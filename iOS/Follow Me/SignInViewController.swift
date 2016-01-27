//
//  SignInViewController.swift
//  Follow Me
//
//  Created by Nick Baidikoff on 09.01.16.
//  Copyright © 2016 Follow. All rights reserved.
//

import UIKit
import FlatUIKit
import ChameleonFramework
import Material

class SignInViewController: UIViewController {
  
  @IBOutlet weak var loginTextField: TextField!
  @IBOutlet weak var passwordTextField: TextField!
 
  override func viewWillAppear(animated: Bool) {
    loginTextField.borderStyle = UITextBorderStyle.None
    loginTextField.backgroundColor = UIColor.clearColor()
    loginTextField.attributedPlaceholder = NSAttributedString(string:"Login", attributes:[NSForegroundColorAttributeName: UIColor.flatGrayColor(), NSFontAttributeName: UIFont(name: "Helvetica Light", size: 18.0)!])
    loginTextField.font = UIFont(name: "Helvetica Light", size: 18.0)
    loginTextField.textColor = UIColor.flatWhiteColor()
    loginTextField.titleLabel = UILabel()
    loginTextField.titleLabel?.font = RobotoFont.lightWithSize(12.0)
    loginTextField.titleLabelColor = UIColor.flatGrayColor()
    loginTextField.titleLabelActiveColor = UIColor.flatWhiteColor()
    loginTextField.clearButtonMode = .WhileEditing
    
    passwordTextField.borderStyle = UITextBorderStyle.None
    passwordTextField.backgroundColor = UIColor.clearColor()
    passwordTextField.attributedPlaceholder = NSAttributedString(string:"Password", attributes:[NSForegroundColorAttributeName: UIColor.flatGrayColor(), NSFontAttributeName: UIFont(name: "Helvetica Light", size: 18.0)!])
    passwordTextField.font = UIFont(name: "Helvetica Light", size: 18.0)
    passwordTextField.textColor = UIColor.flatWhiteColor()
    passwordTextField.titleLabel = UILabel()
    passwordTextField.titleLabel?.font = RobotoFont.lightWithSize(12.0)
    passwordTextField.titleLabelColor = UIColor.flatGrayColor()
    passwordTextField.titleLabelActiveColor = UIColor.flatWhiteColor()
    passwordTextField.clearButtonMode = .WhileEditing
    passwordTextField.secureTextEntry = true
  }
  
  @IBAction func login(sender: UIButton) {
    if loginTextField.text == "l" && passwordTextField.text == "p" {
      performSegueWithIdentifier("loginSegue", sender: sender)
    } else {
      showAlertWithMessage("Incorrect login or password")
    }
  }
  
  @IBAction func hideKeyboard(sender: AnyObject) {
    view.endEditing(true)
  }
  
  func showAlertWithMessage(message: String) {
    Util.createErrorPopup(message).showPopup()
  }
}
