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
    var exerciseTitleText: String!
    
    //Stores the values input by the user to be placed in previous view controller cells' subtitles
    var individualOptionData = ["0", "0", "0", "0"]
    
    var ref : DatabaseReference!
    var routineNumber : Int!
    
    var routineDayKey : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOptions()
        tableView.tableFooterView = UIView(frame: .zero)
        
        //Sets exercise title to current view controller title to indicate which exercise is being edited
        exerciseTitle.text = exerciseTitleText
        
        ref = Database.database().reference(fromURL: "https://gymlog-afa5e.firebaseio.com/")
    }
    
    func setupOptions() {
        let reps = Option(title: "Number of Reps", counter: 0), sets = Option(title: "Number of Sets", counter: 0), weight = Option(title: "Weight", counter: 0), restTime = Option(title: "Total Rest Time", counter: 0)
        exerciseOptions += [reps, sets, weight, restTime]
    }
    
    //Dismisses Keyboard when return is pressed
    func textFieldDidEndEditing(_ textField: UITextField) {
        individualOptionData[textField.tag] = textField.text!
    }
    
    //Indicates boolean value of of textfield returning value
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField.tag {
            
        case 0:
            //Calls function to highlight to user return has been pressed
            textFieldAfterReturn(textField)
        case 1:
            textFieldAfterReturn(textField)
        case 2:
            textFieldAfterReturn(textField)
        default:
            textFieldAfterReturn(textField)
            
        }
        
        return true
    }
    
    //Highlights to user that return has been pressed and value received
    func textFieldAfterReturn(_ textField: UITextField) {
        individualOptionData[textField.tag] = textField.text!
        textField.borderStyle = .none
        textField.textAlignment = .center
        textField.backgroundColor = UIColor.green
        textField.resignFirstResponder()
    }
    
    //Prepares for segueway backwards to previous view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! ExerciseSelectionViewController
        
        //Sets current Exercise's cell subtitles
        destVC.currentExercise.reps = Int(individualOptionData[0])
        destVC.currentExercise.sets = Int(individualOptionData[1])
        destVC.currentExercise.weight = Int(individualOptionData[2])
        destVC.currentExercise.restTime = Int(individualOptionData[3])
        
        writeToDatabase(previousView: destVC)
       
        destVC.tableView.reloadData()
    }
    
    func writeToDatabase(previousView : ExerciseSelectionViewController) {
        let values = ["sets": Int(individualOptionData[1])!, "reps" : Int(individualOptionData[0])!, "weight" : Int(individualOptionData[2])! ]
        //"Exercises/\(routineDayKey!)/"
        self.ref.child("Exercises/\(routineDayKey!)/\(previousView.currentExercise.title)").updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            print("Exercise added to database")
        })
    }

}

//Table Setup

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

