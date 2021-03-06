//
//  LoginView.swift
//  Tertius
//
//  Created by mac on 9/19/15.
//  Copyright (c) 2015 Ryan Li. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet var topTitleLayout: NSLayoutConstraint!

    @IBOutlet var loginButton: UIButton!
    @IBAction func signUpTouched(sender: UIButton) {
        signUp(usernameTextField.text!, password: passwordTextField.text!)
    }

    @IBAction func loginTouched(sender: UIButton) {
        logIn(usernameTextField.text!, password: passwordTextField.text!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 20
        handleKeyboard()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func signUp(username: String, password: String) {
        let user = PFUser()
        user.username = username
        user.password = password
        user.signUpInBackgroundWithBlock { succeeded, error in
            if succeeded {
                NSLog("Sign up successfully with \(user.username)")
                self.logIn(username, password: password)
            } else {
                NSLog("An error occured with: \(error)")
            }
        }
    }

    func logIn(username: String, password: String) {
        PFUser.logInWithUsernameInBackground(username, password: password) {
            user, error in
            if let error = error {
                NSLog("Error %@", error.localizedDescription)
            } else {
                if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                    delegate.switchRootViewController()
                    delegate.registerNotification()

                }
            }
        }
    }

    func handleKeyboard() {
        addTapGestureRecognizer()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboard:", name: "UIKeyboardWillShowNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboard:", name: "UIKeyboardWillHideNotification", object: nil)
    }
    
    func addTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapReceived:")
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func tapReceived(sender: UITapGestureRecognizer) {
        passwordTextField.endEditing(true)
        usernameTextField.endEditing(true)
    }

    func handleKeyboard(note: NSNotification) {
        if let info = note.userInfo {
            let duration = info[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
            let curve = info[UIKeyboardAnimationCurveUserInfoKey]?.integerValue
            let options = curve! << 16
            if note.name == UIKeyboardWillShowNotification {
                let kbFrame = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
                let kbHeight = kbFrame?.height
                UIView.animateWithDuration(NSTimeInterval(duration!), delay: NSTimeInterval(0), options: UIViewAnimationOptions(rawValue: UInt(options)), animations: {
                    self.view.frame = CGRectMake(0, -120, self.view.frame.width, self.view.frame.height)
                    self.topTitleLayout.constant = 32
                    self.view.layoutIfNeeded()
                    print(kbHeight!)
                }, completion: nil)
            } else {
                self.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
                self.topTitleLayout.constant = 108
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func showUsernameFailureAlert() {
        let alert = SCLAlertView(newWindow: ())
        alert.showError("Wrong username", subTitle: "Please check the username you typed in", closeButtonTitle: "Dismiss", duration: NSTimeInterval(0.0))
    }
    
    func showPasswordFailureAlert() {
        let alert = SCLAlertView(newWindow: ())
        alert.showError("Wrong password", subTitle: "Please check the password you typed in", closeButtonTitle: "Dismiss", duration: NSTimeInterval(0.0))
    }
}
