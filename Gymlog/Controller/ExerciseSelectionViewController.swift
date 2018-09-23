//
//  ExerciseSelectionViewController.swift
//  Gymlog
//
//  Created by Orlando Ortega on 2018-08-20.
//  Copyright © 2018 Orlando Ortega. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ExerciseSelectionViewController: UIViewController {

    @IBOutlet weak var exerciseDayLabel: UILabel!
    
    @IBOutlet weak var exerciseTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var currentExercise : Exercise!
    var currentRoutineDayFromPreviousVC : RoutineDay!
    
    var exerciseDayLabelText: String!
    
    //From last view controller which describe current routine
    var routineDayKey: String!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        tableView.tableFooterView = UIView(frame: .zero)
        
        //Previous routine day title presented as view controller title to organize exercises
        exerciseDayLabel.text = exerciseDayLabelText
        
        ref = Database.database().reference(fromURL: "https://gymlog-afa5e.firebaseio.com/")
        
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        insertNewExercise()
    }

    func insertNewExercise() {
        if exerciseTextField.text! == "" {
            print("Empty Cell")
        } else {
            //Current exercise entered by user
            let tempExercise = Exercise(title: exerciseTextField.text!)
            currentRoutineDayFromPreviousVC.routineDayExercises.append(tempExercise)
            
            let indexPath = IndexPath(row: (currentRoutineDayFromPreviousVC.routineDayExercises.count) - 1, section: 0)
            
            writeToDatabase(currentExercise: tempExercise, with: indexPath)
            
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            view.endEditing(true)
            
            //Reset textfield
            exerciseTextField.text = ""
        }
        
    }
    
    func writeToDatabase(currentExercise: Exercise, with Index: IndexPath ) {
        
        let exercise = ["sets": currentExercise.sets ?? 0, "reps" : currentExercise.reps ?? 0, "weight" : currentExercise.weight ?? 0 ]
        
        //Setting up Schema
        let childUpdates = ["Exercises/\(routineDayKey!)/\(currentRoutineDayFromPreviousVC.routineDayExercises[Index.row].title)": exercise]
        
        ref.updateChildValues(childUpdates)
    }
    
    //Receives segueway from exercise option view controller when Done button is selected.
    @IBAction func unwindToExerciseScreen(_ sender: UIStoryboardSegue){}

}

//Table setup
extension ExerciseSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (currentRoutineDayFromPreviousVC.routineDayExercises.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let exercise = currentRoutineDayFromPreviousVC.routineDayExercises[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCell") as! ExerciseCell
        
        cell.exerciseTitle.text = exercise.title
        cell.exerciseSubtitle.text = "\(exercise.sets ?? 0) x \(exercise.reps ?? 0)     \(exercise.weight ?? 0) lbs     \(exercise.restTime ?? 0) mins"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            currentRoutineDayFromPreviousVC.routineDayExercises.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ExerciseOptionsViewController") as? ExerciseOptionsViewController
        
        //Sets title for next view controller
        vc?.exerciseTitleText = currentRoutineDayFromPreviousVC.routineDayExercises[indexPath.row].title
        
        //Sends routine day ID
        vc?.routineDayKey = currentRoutineDayFromPreviousVC.routineDayKey
        
        //Tracks current exercise
        currentExercise = currentRoutineDayFromPreviousVC.routineDayExercises[indexPath.row]
        
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
}
