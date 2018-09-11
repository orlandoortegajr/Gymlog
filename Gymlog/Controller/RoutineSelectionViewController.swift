//
//  SelectionViewController.swift
//  Gymlog
//
//  Created by Orlando Ortega on 2018-08-18.
//  Copyright © 2018 Orlando Ortega. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import FirebaseDatabase

class RoutineSelectionViewController: UIViewController {
    
    var routines = [Routine]()
    var addedRoutine : String?
    var currentSelectedRoutine : Routine!
    var currentRoutineChildValue: Dictionary<String, String>!
    
    var handle : AuthStateDidChangeListenerHandle?
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.tableFooterView = UIView(frame: .zero)
        ref = Database.database().reference(fromURL: "https://gymlog-afa5e.firebaseio.com/")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            self.tableView.reloadData()
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
    }
//==================================
//   NavigationBar Configurations
//==================================
    
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance().signOut()
            FBSDKLoginManager().logOut()
            self.navigationController?.popToRootViewController(animated: true)
        }   catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
    }
    
//==================================
//   ActionSheet Configurations
//==================================
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        displayActionSheet()
    }
    
//==================================
//         Helper Methods
//==================================

//Displays the actionsheet when menu button is pressed
    func displayActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let add = UIAlertAction(title: "Add", style: .default) { action in
            self.menuOptionAddAlertSetup()
        }
        
        let settings = UIAlertAction(title: "Settings", style: .default) { action in
            //
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil )
        
        actionSheet.addAction(add)
        actionSheet.addAction(settings)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }

    
//Alert shown when Add is pressed from the menu
    func menuOptionAddAlertSetup() {
        let alert = UIAlertController(title: "Routine Message", message: "Please enter the name of the routine", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Type Here"
        }
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField!.text! == "" {
                print("Empty Cell")
            } else {
                self.routines.append(Routine(routineTitle: textField!.text!))
                self.insertNewRoutine()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
//Method that adds cells respective to the given routine name
    func insertNewRoutine() {
        let indexPath = IndexPath(row: routines.count - 1, section: 0)
        let routine = routines[indexPath.row].routineTitle
        currentRoutineChildValue = ["routine \(indexPath.row + 1)": routine]
        self.ref.child("Gym Routines").child((Auth.auth().currentUser?.uid)!).child("routine titles").updateChildValues(currentRoutineChildValue)
        
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()

        view.endEditing(true)
        
    }
}

//TableView setup to add cells and display default

extension RoutineSelectionViewController : UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routines.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let routine = routines[indexPath.row].routineTitle

        let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineCell") as! RoutineCell
        
        cell.routineTitle.text = routine

        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            routines.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "DaySelectionViewController") as? RoutineDaySelectionViewController
        currentSelectedRoutine = routines[indexPath.row]
        vc?.currentRoutineFromPreviousVC = currentSelectedRoutine
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

