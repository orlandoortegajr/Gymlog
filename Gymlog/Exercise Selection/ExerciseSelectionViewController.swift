//
//  ExerciseSelectionViewController.swift
//  Gymlog
//
//  Created by Orlando Ortega on 2018-08-20.
//  Copyright © 2018 Orlando Ortega. All rights reserved.
//

import UIKit

class ExerciseSelectionViewController: UIViewController {

    @IBOutlet weak var exerciseDayLabel: UILabel!
    
    @IBOutlet weak var exerciseTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var exercises = [Exercise]()
    var exerciseDayLabelText : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        exerciseDayLabel.text = exerciseDayLabelText
        tableView.tableFooterView = UIView(frame: .zero)
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        insertNewExercise()
    }

    func insertNewExercise() {
        if exerciseTextField.text! == "" {
            print("Empty Cell")
        } else {
            let tempExercise = Exercise(title: exerciseTextField.text!)
            exercises.append(tempExercise)
            
            let indexPath = IndexPath(row: exercises.count - 1, section: 0)
            
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            view.endEditing(true)
            
            exerciseTextField.text = ""
        }
        
    }

}

extension ExerciseSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exercise = exercises[indexPath.row].title
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCell") as! ExerciseCell
        
        cell.exerciseTitle.text = exercise
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            exercises.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ExerciseOptionsViewController") as? ExerciseOptionsViewController
        vc?.exerciseTitleText = exercises[indexPath.row].title
        self.navigationController?.pushViewController(vc!, animated: true)

    }
    
}
