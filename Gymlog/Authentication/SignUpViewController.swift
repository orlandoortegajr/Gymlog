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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        ref = Database.database().reference(fromURL: "https://gymlog-afa5e.firebaseio.com/")
    }
    
    //TODO: Make Errors Display Properly
    //TODO: Managae Users Documentation
    @IBAction func completeSignUp(_ sender: UIButton) {
        if let name = nameTextField.text, name != "" {
        if let email = emailTextField.text, email != "" {
            if let password = passwordTextField.text {
                if let confirmPassword = confirmPasswordTextField.text {
                    if password.lowercased() == confirmPassword.lowercased() {
                        // MARK: Begin Loading Interface
                        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                            // MARK: End Loading
                            
                            guard let email = authResult?.user.email, error == nil else {
                                //Find a way to display error to screen
                                
                                print(error!.localizedDescription)
                                return
                            }
                            let usersReference = self.ref.child("users")
                            let values = ["email" : email, "name" : name ]
                            usersReference.child((authResult?.user.uid)!).updateChildValues(values, withCompletionBlock: { (error, ref) in
                                
                                if error != nil {
                                    print(error!)
                                    return
                                }
                                
                                print("E-mail user has been added to the database.")
                            })
                            
                            print("\(email) created")
                            
                            // TODO: Exit the view Controller back to Gym Log Intro Screen
                            
                            guard (authResult?.user) != nil else {return}
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    } else {
                        //Show this to screen
                        print("Passwords do not match")
                    }
                } else {
                    print("Confirm Password can't be empty")
                }
            } else {
                print("Password can't be empty")
            }
        } else {
            print("Email can't be empty")
        }
        } else {
            print("Name can't be empty")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
