//
//  CourseClass.swift
//  Bookworm
//
//  Created by Rajesh Raman on 5/12/17.
//  Copyright © 2017 DeedsIT. All rights reserved.
//

import Foundation

class CourseClass {
    var id : String
    var start_time : Double
    var finish_time : Double
    var title : String
    var averageRating : Double
    var ratings : [Rating]
    var status : String
    public var description : String
    
//    public convenience init(title: String, id: String, averageRating: Double? = 0.0) {
//        self.init(title: title)!
//        self.id = id
//        self.averageRating = averageRating!
//
//    }
    
    init?(title: String){
        if title.isEmpty{
            return nil
        }
        self.id = ""
        self.title = title
        self.start_time = 0
        self.finish_time = 0
        self.averageRating = 0
        self.ratings = []
        self.status = "Started"
        
        description = String ("Course : { title : \(title) \n average rating : \(averageRating)")
    }
}
