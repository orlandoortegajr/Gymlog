//
//  Routine.swift
//  Gymlog
//
//  Created by Orlando Ortega on 2018-08-23.
//  Copyright © 2018 Orlando Ortega. All rights reserved.
//

import Foundation

class Routine {
    
    var routineTitle : String
    var routineDays = [RoutineDay]()
    
    init(routineTitle: String) {
        self.routineTitle = routineTitle
    }
}
