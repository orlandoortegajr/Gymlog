//
//  DayViewController.swift
//  Gymlog
//
//  Created by Orlando Ortega on 2018-08-19.
//  Copyright © 2018 Orlando Ortega. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RoutineDaySelectionViewController: UIViewController {

    @IBOutlet weak var routineTitleLabel: UILabel!
    
    @IBOutlet weak var routineDayTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref : DatabaseReference!
    
    
    var currentRoutineDay : RoutineDay!
    var currentRoutine : Routine!
    var currentRoutineDayChildValue : Dictionary<String, String>!
    
    //From last view controller that describe the current routine
    var routineKey: String!
    
    //Current routine day selected variables to be passed on
    var currentRoutineDayIdentifier: String!
    var currentRoutineDayName: String!
    
    var handle : AuthStateDidChangeListenerHandle?
    
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
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        insertNewDay()
    }
    
    func insertNewDay() {
        if routineDayTextField.text! == "" {
            print("Empty Cell")
        } else {
            let key = ref.child("Routine Days").childByAutoId().key
            let tempRoutineDay = RoutineDay(routineDayTitle: routineDayTextField.text!, routineDayKey: key)
            currentRoutine.routineDays.append(tempRoutineDay)
            let routineDayTitle = tempRoutineDay.routineDayTitle
            
            let indexPath = IndexPath(row: currentRoutine.routineDays.count - 1, section: 0)
            currentRoutineDayChildValue = ["routine day \(indexPath.row + 1)" : routineDayTitle]
            for (key,value) in currentRoutineDayChildValue {
                currentRoutineDayIdentifier = key
                currentRoutineDayName = value
            }
            
            let routineDay = ["Routine Day Title": routineDayTitle]
            let childUpdates = ["Routine Days/\(routineKey!)/\(key)": routineDay]
            ref.updateChildValues(childUpdates)
            
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            view.endEditing(true)
            
            routineDayTextField.text = ""
        }
       
    }
    
}

//Setting Up the Table and It's action capabilities

extension RoutineDaySelectionViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentRoutine.routineDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let day = currentRoutine.routineDays[indexPath.row].routineDayTitle
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell") as! RoutineDayCell
        
        cell.routineDayTitle.text = day
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            currentRoutine.routineDays.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ExerciseSelectionViewController") as? ExerciseSelectionViewController
        vc?.exerciseDayLabelText = currentRoutine.routineDays[indexPath.row].routineDayTitle
        currentRoutineDay = currentRoutine.routineDays[indexPath.row]
        vc?.currentRoutineDayFromPreviousVC = currentRoutineDay
        vc?.currentRoutineDayName = currentRoutineDayName
        vc?.currentRoutineDayIdentifier = currentRoutineDayIdentifier
        vc?.routineDayKey = currentRoutine.routineDays[indexPath.row].routineDayKey
        print(currentRoutineDay.routineDayTitle)
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
}
