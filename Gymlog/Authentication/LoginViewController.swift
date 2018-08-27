//
//  ViewController.swift
//  Gymlog
//
//  Created by Orlando Ortega on 2018-08-17.
//  Copyright © 2018 Orlando Ortega. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let isLoggedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        
        setupGoogleButton()
    }
    
    func setupGoogleButton() {
        let googleButton = GIDSignInButton()
        //TODO: Maybe figure out ratios for line below?
        googleButton.frame = CGRect(x: 72.5, y: 425 , width: 230, height: 30)
        
        view.addSubview(googleButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    //TODO: Make Errors Appear Properly
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            //TODO: Start Loading
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                //TODO: Hide Loading
                if let error = error {
                    //TODO: Show this to screen
                    print(error.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: "toMainScreen", sender: self)
                }
            }
        } else {
            //TODO: Show this to screen
            print("Email/Password can't be empty")
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toSignUpScreen", sender: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

