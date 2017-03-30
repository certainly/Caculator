//
//  Constants.swift
//  Caculator
//
//  Created by certainly on 2017/3/27.
//  Copyright © 2017年 certainly. All rights reserved.
//

import Foundation

struct Constants {
    struct Math {
        static let numberOfDigitsAfterDecimalPoint = 6
        static let variableName = "M"
    }
    
    struct Drawing {
        static let pointsPerUnit = 40.0
    }
    
    struct Error {
        static let data = "Calculator: DataSource wasn't found"
        static let partialResult = "Calculator: Trying to draw a partial result"
    }
}
