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
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var repeatPasswordHeightConstraint: NSLayoutConstraint!
    
    private let operationQueue = OperationQueue()
    private var login = true { didSet{ repeatPasswordHeightConstraint.constant = login ? CGFloat(0) : CGFloat(30) } }
    
    @IBAction func loginTapped(sender: UIButton) {
        
        emailTextField.text = "asd@ASdASD.c"  // TODO: REMOVE THIS
        passwordTextField.text = PASSWORD
        repeatPasswordTextField.text = PASSWORD
        
        view.endEditing(true)
        if validateFields() {
            loginButton.enabled = false
            if login { getToken() }
            else {
                let registerUserOperation = RegisterUserOperation(
                    email: emailTextField.text!,
                    password: passwordTextField.text!,
                    repeatPassword: repeatPasswordTextField.text!
                )
                registerUserOperation.delegate = self
                operationQueue.addOperation(registerUserOperation)
            }
        }
    }
    
    @IBAction func noAccountTapped(sender: UIButton) {
        login = !login
        sender.setTitle(login ? "No account yet? Click here" : "Click here to login", forState: .Normal)
        loginButton.setTitle(login ? "Login" : "Register", forState: .Normal)
    }
    
    private func getToken() {
        let generateTokenOperation = GenerateTokenOperation(email: emailTextField.text!, password: passwordTextField.text!)
        generateTokenOperation.delegate = self
        operationQueue.addOperation(generateTokenOperation)
    }
    
    private func validateFields() -> Bool {
        var valid = true
        
        if let email = emailTextField.text where email.isEmail() {} else {
            emailTextField.text = ""
            emailTextField.attributedPlaceholder = NSAttributedString(string: "please enter a valid email", attributes: [
                NSForegroundColorAttributeName : UIColor.redColor(),
                NSFontAttributeName: UIFont.italicSystemFontOfSize(12)
                ])
            valid = false
        }
        
        if let password = passwordTextField.text where password.characters.count >= 6 {} else {
            passwordTextField.text = ""
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "password must be at least 6 chars long", attributes: [
                NSForegroundColorAttributeName : UIColor.redColor(),
                NSFontAttributeName: UIFont.italicSystemFontOfSize(12)
                ])
            valid = false
        }
        
        if !login {
            if let repPassword = repeatPasswordTextField.text, password = passwordTextField.text where repPassword == password {} else {
                repeatPasswordTextField.text = ""
                repeatPasswordTextField.attributedPlaceholder = NSAttributedString(string: "passwords must match", attributes: [
                    NSForegroundColorAttributeName : UIColor.redColor(),
                    NSFontAttributeName: UIFont.italicSystemFontOfSize(12)
                    ])
                valid = false
            }
        }
        
        return valid
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        login = true
    }
}

extension LoginViewController: GenerateTokenOperationDelegate {
    func didGenerateToken(token: Token) {
        dispatch_async(dispatch_get_main_queue()) {
            self.loginButton.enabled = true
            Preferences.tokenID = token.tokenID
            self.performSegueWithIdentifier("showRevealViewController", sender: self)
        }
    }
    
    func accessDenied() {
        loginButton.enabled = true
    }
}

extension LoginViewController: RegisterUserOperationDelegate {
    func didRegisterUser() {
        getToken()
    }
    
    func registerFailure() {
        loginButton.enabled = true
    }
}
