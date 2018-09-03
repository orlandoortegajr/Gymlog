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
import FBSDKLoginKit
import FirebaseDatabase

class LoginViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        ref = Database.database().reference(fromURL: "https://gymlog-afa5e.firebaseio.com/")
        
        setupGoogleButton()
        setupFacebookButton()
        
        if FBSDKAccessToken.current() != nil {
            print("FB user logged in")
        } else {
            print("No FB user logged in")
        }
        
    }
    
    func setupFacebookButton() {
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email"]
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: 75, y: 485, width: 225, height: 30)
        loginButton.delegate = self
    }
    
    func setupGoogleButton() {
        let googleButton = GIDSignInButton()
        //TODO: Maybe figure out ratios for line below?
        //SWITCH CGFRAMES TO CONSTRAINTS
        googleButton.frame = CGRect(x: 71, y: 425 , width: 235, height: 30)
        
        view.addSubview(googleButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    //MARK: FB Login Protocols
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
        } else if result.isCancelled{
            print("User Cancelled")
        } else {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                // User is signed in
                let usersReference = self.ref.child("users")
                let values = ["email" : authResult!.user.email!, "name" : authResult!.user.displayName! ]
                usersReference.child((authResult?.user.uid)!).updateChildValues(values, withCompletionBlock: { (error, ref) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    print("Facebook user has been added to the database.")
                })
                self.performSegue(withIdentifier: "toMainScreen", sender: self)
            }
        }
        //Successful login
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("FB user logged out!")
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

