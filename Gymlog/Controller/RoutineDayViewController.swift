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
    
    //Current values that need to be tracked for database schema
    var currentRoutineDay : RoutineDay!
    var currentRoutine : Routine!
    
    //From last view controller that describe the current routine
    var routineKey: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        ref = Database.database().reference(fromURL: "https://gymlog-afa5e.firebaseio.com/")
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        insertNewDayCell()
    }
    
    func insertNewDayCell() {
        if routineDayTextField.text! == "" {
            print("Empty Cell")
        } else {
            //Routine Day database ID
            let key = ref.child("Routine Days").childByAutoId().key
            
            //Current Routine Day Item added by user
            let tempRoutineDay = RoutineDay(routineDayTitle: routineDayTextField.text!, routineDayKey: key)
            currentRoutine.routineDays.append(tempRoutineDay)
            
            let routineDayTitle = tempRoutineDay.routineDayTitle
            
            let indexPath = IndexPath(row: currentRoutine.routineDays.count - 1, section: 0)
            
            writeToDatabase(title: routineDayTitle, key: key, index: indexPath)
            
            //Inserting cell to tableView
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            view.endEditing(true)
            
            //Resetting textfield text
            routineDayTextField.text = ""
        }
       
    }
    
    func writeToDatabase(title: String, key: String, index: IndexPath) {
        
        let routineDay = ["Routine Day Title": title]
        let childUpdates = ["Routine Days/\(routineKey!)/\(key)": routineDay]
        ref.updateChildValues(childUpdates)
        
    }
    
}

//Table Setup
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
        
        //Sets title for next view
        vc?.exerciseDayLabelText = currentRoutine.routineDays[indexPath.row].routineDayTitle
        
        //Current routine day selected
        currentRoutineDay = currentRoutine.routineDays[indexPath.row]
        vc?.currentRoutineDayFromPreviousVC = currentRoutineDay
        
        //Current routine day name and ID
        vc?.routineDayKey = currentRoutine.routineDays[indexPath.row].routineDayKey
        
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
}
