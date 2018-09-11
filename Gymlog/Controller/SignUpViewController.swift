//
//  SignUpViewController.swift
//  Gymlog
//
//  Created by Orlando Ortega on 2018-08-25.
//  Copyright © 2018 Orlando Ortega. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase



class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    var ref: DatabaseReference!
    
    var name = "", email = "", password = "", confirmPassword = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //declaring UITextFieldDelegates to allow for textField methods to work
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        nameTextField.delegate = self
        
        ref = Database.database().reference(fromURL: "https://gymlog-afa5e.firebaseio.com/")
    }
    
    //TODO: Display Print Satements to Screen
    @IBAction func completeSignUpButton(_ sender: UIButton) {
        completeSignUp()
    }
    
    //When return is pressed, keyboard exits
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func authentication() {
        // MARK: Begin Loading Interface
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            // MARK: End Loading
            
            guard let email = authResult?.user.email, error == nil else {
                //TODO: Find a way to display error to screen
                
                print(error!.localizedDescription)
                return
            }
            
            //MARK: Write to Database
            self.writeToDatabase(newUser: authResult)
           
            print("\(email) created")
            
            // TODO: Exit the view Controller back to Gym Log Intro Screen
            
            guard (authResult?.user) != nil else {return}
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func writeToDatabase(newUser : AuthDataResult? ) {
        let usersReference = self.ref.child("users")
        let values = ["email" : email, "name" : name ]
        usersReference.child((newUser?.user.uid)!).updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                print(error!)
                return
            }
            
            print("E-mail user has been added to the database.")
        })
    }
    
    func completeSignUp() {
        if nameTextField.text != "" {
            name = nameTextField.text!
            if emailTextField.text != "" {
                email = emailTextField.text!
                if passwordTextField.text != "" {
                    password = passwordTextField.text!
                    if confirmPasswordTextField.text != "" {
                        confirmPassword = confirmPasswordTextField.text!
                        if password.lowercased() == confirmPassword.lowercased() {
                            
                            authentication()
                            
                        } else {
                            //Show this to screen
                            print("Passwords do not match")
                        }
                    } else {
                        print("Please confirm your password")
                    }
                } else {
                    print("Please enter a password")
                }
            } else {
                print("Please enter your email")
            }
        } else {
            print("Please enter your name")
        }
    }
    
}
