//
//  ExerciseOptionsViewController.swift
//  Gymlog
//
//  Created by Orlando Ortega on 2018-08-20.
//  Copyright © 2018 Orlando Ortega. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ExerciseOptionsViewController: UIViewController, UITextFieldDelegate {
    
    //TODO: Setup Two TextFields for Total Rest Time in order to get minute and seconds and improve UI
    
    @IBOutlet weak var exerciseTitle: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var exerciseOptions = [Option]()
    var individualOptionData = ["0", "0", "0", "0"]
    
    var exerciseTitleText : String!
    
    var ref : DatabaseReference!
    var routineNumber : Int!
    
    var routineDayKey : String!
    var exerciseKey: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        exerciseTitle.text = exerciseTitleText
        setupOptions()
        tableView.tableFooterView = UIView(frame: .zero)
        
        ref = Database.database().reference(fromURL: "https://gymlog-afa5e.firebaseio.com/")
    }
    
    func setupOptions() {
        let reps = Option(title: "Number of Reps", counter: 0), sets = Option(title: "Number of Sets", counter: 0), weight = Option(title: "Weight", counter: 0), restTime = Option(title: "Total Rest Time", counter: 0)
        exerciseOptions += [reps, sets, weight, restTime]
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        individualOptionData[textField.tag] = textField.text!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            textFieldAfterReturn(textField)
        } else if textField.tag == 1 {
            textFieldAfterReturn(textField)
        } else if textField.tag == 2 {
            textFieldAfterReturn(textField)
        } else if textField.tag == 3 {
            textFieldAfterReturn(textField)
            
        }
        
        return true
    }
    
    func textFieldAfterReturn(_ textField: UITextField) {
        individualOptionData[textField.tag] = textField.text!
        textField.borderStyle = .none
        textField.textAlignment = .center
        textField.backgroundColor = UIColor.green
        textField.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! ExerciseSelectionViewController
        print(destVC.currentExercise.title)
        destVC.currentExercise.reps = Int(individualOptionData[0])
        destVC.currentExercise.sets = Int(individualOptionData[1])
        destVC.currentExercise.weight = Int(individualOptionData[2])
        destVC.currentExercise.restTime = Int(individualOptionData[3])
        
        let values = ["sets": Int(individualOptionData[1])!, "reps" : Int(individualOptionData[0])!, "weight" : Int(individualOptionData[2])! ]
        //"Exercises/\(routineDayKey!)/"
        self.ref.child("Exercises/\(routineDayKey!)/\(exerciseKey!)/\(destVC.currentExercise.title)").updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            print("Exercise added to database")
        })
        destVC.tableView.reloadData()
    }

}

extension ExerciseOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseOptionCell") as! ExerciseOptionCell
        
        cell.actionTextField.delegate = self
        
        cell.actionTextField.tag = indexPath.row
        
        cell.option = exerciseOptions[indexPath.row]
        
        return cell
    }
    
}

