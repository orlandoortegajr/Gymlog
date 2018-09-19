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
    
    var currentSelectedRoutine : Routine!
    
    //Stores keys to group children with correct parent in database
    var routineKeyDict = [Int: String]()
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //Removes unused table cells
        tableView.tableFooterView = UIView(frame: .zero)
        
        //Set database ref
        ref = Database.database().reference(fromURL: "https://gymlog-afa5e.firebaseio.com/")
    }
    
    //Logout Button From NavigationController
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            //Logout email user
            try firebaseAuth.signOut()
            
            //Logout Google user
            GIDSignIn.sharedInstance().signOut()
            
            //Logout Facebook user
            FBSDKLoginManager().logOut()
            
            self.navigationController?.popToRootViewController(animated: true)
        }   catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
    }
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        displayActionSheet()
    }

    //Displays the actionsheet when menu button is pressed
    func displayActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //Sets up functionality of the add button in ActionSheet menu
        let add = UIAlertAction(title: "Add", style: .default) { action in
            self.menuOptionAddAlertSetup()
        }
        
        let settings = UIAlertAction(title: "Settings", style: .default) { action in
            // TODO: Make Settings Page, allow user to record data such as weight, age, height, etc...
            // TODO: Transition to Settings Page
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil )
        
        actionSheet.addAction(add)
        actionSheet.addAction(settings)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }

    
    //Alert shown when Add is pressed from the menu
    func menuOptionAddAlertSetup() {
        //Alert message displayed to user
        let alert = UIAlertController(title: "Routine Message", message: "Please enter the name of the routine", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Type Here"
        }
        
        //Action when user presses done in the alert message
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField!.text! == "" {
                print("Please provide a name for your Routine!")
            } else {
                //Record routine in the routines array
                self.routines.append(Routine(routineTitle: textField!.text!))
                self.insertNewRoutine()
            }
        }))
        
        //Action when cancel is pressed, Alert message is dismissed
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //Method that adds cells respective to the given routine name
    func insertNewRoutine() {
        let indexPath = IndexPath(row: routines.count - 1, section: 0)
        let routineTitle = routines[indexPath.row].routineTitle
        writeToDatabase(index: indexPath, routineTitle: routineTitle)
        
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()

        view.endEditing(true)
        
    }
    
    func writeToDatabase(index indexPath: IndexPath, routineTitle: String) {
        
        //User Firebase ID
        let userID = (Auth.auth().currentUser?.uid)!
        
        //Key is specific routine ID
        let key = ref.child("Routines").childByAutoId().key
        
        routineKeyDict[indexPath.row] = key
        
        let routine = ["Routine Title": routineTitle]
        let childUpdates = ["Routines/\(userID)/\(key)": routine]
        
        //Uploads changes to database reference
        ref.updateChildValues(childUpdates)
        
        
    }
    
}

//TableView Setup
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
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
        
        //Passes on the current selected routine to the next view controller
        vc?.currentRoutine = currentSelectedRoutine
        
        //Current routine ID passed on to track database association between parents and child nodes.
        vc?.routineKey = routineKeyDict[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

