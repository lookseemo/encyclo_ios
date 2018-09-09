//
//  Course.swift
//  Bookworm
//
//  Created by Rajesh Raman on 3/12/17.
//  Copyright © 2017 DeedsIT. All rights reserved.
//

import Foundation

class Course {
    var id : String
    var name : String
    var code : String
    var rating : Double
    var classes : [CourseClass]
    public var description : String
    
    
    init?(name: String, code: String, rating: Double, classes : [CourseClass]){
        self.id = ""
        self.name = name
        self.code = code
        self.rating = rating
        self.classes = []
        description = String ("Course : { name : \(name) \n code : \(code) \n rating : \(rating) \n num classes: \(classes.count)")
    }
    
    convenience init?(){
        self.init(name: "", code: "", rating: 0.0, classes: [])
    }
}

