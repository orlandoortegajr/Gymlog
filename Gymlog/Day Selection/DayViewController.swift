//
//  DayViewController.swift
//  Gymlog
//
//  Created by Orlando Ortega on 2018-08-19.
//  Copyright © 2018 Orlando Ortega. All rights reserved.
//

import UIKit

class DaySelectionViewController: UIViewController {

    @IBOutlet weak var dayTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var days = ["Upper Body I", "Lower Body I", "Upper Body II", "Lower Body II"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        insertNewDay()
    }
    
    func insertNewDay() {
        if dayTextField.text! == "" {
            print("Empty Cell")
        } else {
            days.append(dayTextField.text!)
            
            let indexPath = IndexPath(row: days.count - 1, section: 0)
            
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            view.endEditing(true)
            
            dayTextField.text = ""
        }
       
    }
    
}

//Setting Up the Table and It's action capabilities

extension DaySelectionViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let day = days[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell") as! DayCell
        
        cell.dayTitle.text = day
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            days.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "toExerciseSelection", sender: self)
    }
    
}
