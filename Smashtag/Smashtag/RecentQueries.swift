//
//  RecentQueries.swift
//  Smashtag
//
//  Created by certainly on 2017/4/6.
//  Copyright © 2017年 certainly. All rights reserved.
//

import Foundation

struct RecentQueries {
    fileprivate static let defaults = UserDefaults.standard
    fileprivate struct Constants {
        static let key = "RecentQueries"
        static let limit = 100
    }
    
    static var queries: [String] {
        return (defaults.object(forKey: Constants.key) as? [String]) ?? []
    }
    
    static func add(_ term: String) {
        var newArray = queries.filter({ term.caseInsensitiveCompare($0) != .orderedSame })
        newArray.insert(term, at: 0)
        while newArray.count > Constants.limit {
            newArray.removeLast()
        }
        defaults.set(newArray, forKey: Constants.key)
        
    }
    
    static func removeAtIndex(_ index: Int) {
        var currentQueries = (defaults.object(forKey: Constants.key) as? [String]) ?? []
        currentQueries.remove(at: index)
        defaults.set(currentQueries, forKey: Constants.key)
        
    }
}
