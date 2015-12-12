//
//  LoginViewController.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/11/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import UIKit

private let EMAIL = "senart@ymail.co"
private let PASSWORD = "123456Senart#"

class LoginViewController: UIViewController
{
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var noAccountLabel: UILabel!
    
    private let operationQueue = OperationQueue()
    
    @IBAction func loginTapped(sender: UIButton) {
        if validateFields() {
            let generateTokenOperation = GenerateTokenOperation(email: emailTextField.text!, password: passwordTextField.text!)
            generateTokenOperation.delegate = self
            operationQueue.addOperation(generateTokenOperation)
        }
    }
    
    private func validateFields() -> Bool {
        var valid = true
        
        guard let email = emailTextField.text where email.isEmail() else {
            emailTextField.text = ""
            emailTextField.attributedPlaceholder = NSAttributedString(string: "please enter a valid email", attributes: [
                NSForegroundColorAttributeName : UIColor.redColor(),
                NSFontAttributeName: UIFont.italicSystemFontOfSize(12)
                ])
            valid = false
            return false
        }
        
        guard let password = passwordTextField.text where password.characters.count >= 6 else {
            passwordTextField.text = ""
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "password must be at least 6 chars long", attributes: [
                NSForegroundColorAttributeName : UIColor.redColor(),
                NSFontAttributeName: UIFont.italicSystemFontOfSize(12)
                ])
            valid = false
            return false
        }
        
        return valid
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension LoginViewController: GenerateTokenOperationDelegate {
    func didGenerateToken(token: Token) {
        Preferences.tokenID = token.tokenID
        performSegueWithIdentifier("showRevealViewController", sender: self)
    }
    
    func accessDenied() {
        print(":(")
    }
}
