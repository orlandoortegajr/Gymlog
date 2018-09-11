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
    var exerciseDayLabelText : String!
    var currentRoutineDayFromPreviousVC : RoutineDay!
    
    var ref: DatabaseReference!
    
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

    @IBAction func addButtonPressed(_ sender: Any) {
        insertNewExercise()
    }

    func insertNewExercise() {
        if exerciseTextField.text! == "" {
            print("Empty Cell")
        } else {
            let tempExercise = Exercise(title: exerciseTextField.text!)
            let userID = Auth.auth().currentUser?.uid
            currentRoutineDayFromPreviousVC.routineDayExercises.append(tempExercise)
            let values = ["sets": tempExercise.sets ?? 0, "reps" : tempExercise.reps ?? 0, "weight" : tempExercise.weight ?? 0 ]
            
            let indexPath = IndexPath(row: (currentRoutineDayFromPreviousVC.routineDayExercises.count) - 1, section: 0)
            self.ref.child("Gym Routines/\(userID!)/routine exercises/\(tempExercise.title)").updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error!)
                    return
                }
                print("Exercise added to database")
            })
            
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            view.endEditing(true)
            
            exerciseTextField.text = ""
        }
        
    }
    
    @IBAction func unwindToExerciseScreen(_ sender: UIStoryboardSegue){}

}

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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            currentRoutineDayFromPreviousVC.routineDayExercises.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ExerciseOptionsViewController") as? ExerciseOptionsViewController
        vc?.exerciseTitleText = currentRoutineDayFromPreviousVC.routineDayExercises[indexPath.row].title
        currentExercise = currentRoutineDayFromPreviousVC.routineDayExercises[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
        

    }
    
}
