//
//  ExerciseOptionsViewController.swift
//  Gymlog
//
//  Created by Orlando Ortega on 2018-08-20.
//  Copyright © 2018 Orlando Ortega. All rights reserved.
//

import UIKit

class ExerciseOptionsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var exerciseTitle: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var exerciseOptions = [Option]()
    var individualOptionData = ["0", "0", "0", "0"]
    
    var exerciseTitleText : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        exerciseTitle.text = exerciseTitleText
        setupOptions()
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    @IBAction func completeSetButtonPressed(_ sender: UIButton) {
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
        textField.borderStyle = .none
        textField.textAlignment = .center
        textField.backgroundColor = UIColor.green
        textField.resignFirstResponder()
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

