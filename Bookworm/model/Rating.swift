//
//  Rating.swift
//  Bookworm
//
//  Created by Rajesh Raman on 5/12/17.
//  Copyright © 2017 DeedsIT. All rights reserved.
//

import Foundation
class Rating{
    var studentEmail : String
    var classId : String
    var score : Double
    public var description : String
    
    init?(studentEmail: String, score: Double){
        if studentEmail.isEmpty{
            return nil
        }
        self.studentEmail = studentEmail
        self.score = score
        self.classId = ""
        
        description = String ("Rating : { studentEmail : \(studentEmail) \n classID : \(classId) \n score : \(score)")
    }
    
}
