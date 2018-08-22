//
//  ExerciseOptionCell.swift
//  Gymlog
//
//  Created by Orlando Ortega on 2018-08-20.
//  Copyright © 2018 Orlando Ortega. All rights reserved.
//

import UIKit

class ExerciseOptionCell: UITableViewCell {

    @IBOutlet weak var exerciseOptionTitle: UILabel!
    @IBOutlet weak var actionTextField: UITextField!
    
    var option : Option! {
        didSet {
            exerciseOptionTitle.text = option.title
            actionTextField.placeholder = "Enter \(option.title)"
        }
    }
    
    
}
