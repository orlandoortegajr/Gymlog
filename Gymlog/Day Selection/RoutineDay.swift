//
//  RoutineDay.swift
//  Gymlog
//
//  Created by Orlando Ortega on 2018-08-23.
//  Copyright © 2018 Orlando Ortega. All rights reserved.
//

import Foundation

class RoutineDay {
    
    var routineDayTitle : String
    var routineDayExercises = [Exercise]()
    
    init(routineDayTitle: String) {
        self.routineDayTitle = routineDayTitle
    }
}
