//
//  DayViewController.swift
//  Gymlog
//
//  Created by Orlando Ortega on 2018-08-19.
//  Copyright © 2018 Orlando Ortega. All rights reserved.
//

import UIKit
import FirebaseAuth

class RoutineDaySelectionViewController: UIViewController {

    @IBOutlet weak var routineTitleLabel: UILabel!
    
    @IBOutlet weak var routineDayTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var currentRoutineDay : RoutineDay!
    var currentRoutineFromPreviousVC : Routine!
    
    var handle : AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
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
            let tempRoutineDay = RoutineDay(routineDayTitle: routineDayTextField.text!)
            
            currentRoutineFromPreviousVC.routineDays.append(tempRoutineDay)
            
            let indexPath = IndexPath(row: currentRoutineFromPreviousVC.routineDays.count - 1, section: 0)
            
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
        return currentRoutineFromPreviousVC.routineDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let day = currentRoutineFromPreviousVC.routineDays[indexPath.row].routineDayTitle
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell") as! RoutineDayCell
        
        cell.routineDayTitle.text = day
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            currentRoutineFromPreviousVC.routineDays.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ExerciseSelectionViewController") as? ExerciseSelectionViewController
        vc?.exerciseDayLabelText = currentRoutineFromPreviousVC.routineDays[indexPath.row].routineDayTitle
        currentRoutineDay = currentRoutineFromPreviousVC.routineDays[indexPath.row]
        vc?.currentRoutineDayFromPreviousVC = currentRoutineDay
        print(currentRoutineDay.routineDayTitle)
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
}
