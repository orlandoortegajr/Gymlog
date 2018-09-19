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
import FBSDKCoreKit
import FirebaseDatabase

class LoginViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ref : DatabaseReference!
    
    var email = "", password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        ref = Database.database().reference(fromURL: "https://gymlog-afa5e.firebaseio.com/")
        
        setupGoogleButton()
        setupFacebookButton()
        
        //If FB user logged in transfer them to Main View.
        if FBSDKAccessToken.current() != nil {
            print("FB user already Logged In!")
            performTransitionToMainScreen()
        }
        
        //Check if user is logged in and transfer them to Main View
        if Auth.auth().currentUser != nil {
            print("An Email/Google user is already Logged In!")
            performTransitionToMainScreen()
        }
        
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        login()
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toSignUpScreen", sender: self)
    }
    
    func setupFacebookButton() {
        let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: 75, y: 485, width: 225, height: 30)
        loginButton.delegate = self
    }
    
    func setupGoogleButton() {
        let googleButton = GIDSignInButton()
        //TODO: Figure out ratios for button to fix UI
        
        //TODO: SWITCH CGFRAMES TO CONSTRAINTS
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
            authenticationForFBUser()
        }
        //Successful login
    }
    
    func authenticationForFBUser() {
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            // User is signed in
            self.writeToDatabaseForFBUser(withAuthenticationResult: authResult)
            self.performTransitionToMainScreen()
        }
    }
    
    func writeToDatabaseForFBUser(withAuthenticationResult authResult : AuthDataResult? ) {
        let usersReference = self.ref.child("users")
        
        //child values of parent "user" in Database
        let values = ["email" : authResult!.user.email!, "name" : authResult!.user.displayName! ]
        
        usersReference.child((authResult?.user.uid)!).updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                print(error!)
                return
            }
            
            print("Facebook user has been added to the database.")
            
        })
    }
    
    //Conform to FBSDK delegate
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("FB user logged out!")
    }
    
    //TODO: Make Errors Appear On Screen
    //Logs email user in and checks for textFields
    func login() {
        if emailTextField.text != "" {
            email = emailTextField.text!
            if passwordTextField.text != "" {
                password = passwordTextField.text!
                
               emailAuthentication(withEmail: email, password: password)
                
            } else {
                print("Password can't be empty")
            }
        } else {
            print("Email can't empty")
        }
    }
    
    func emailAuthentication(withEmail: String, password: String) {
        //MARK: Start Loading
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            //MARK: Hide Loading
            if let error = error {
                //TODO: Show this to screen
                print(error.localizedDescription)
            } else {
                self.performTransitionToMainScreen()
            }
        }
    }
    
    func performTransitionToMainScreen() {
        performSegue(withIdentifier: "toMainScreen", sender: self)
    }
    
    //Hides Keyboard after return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

