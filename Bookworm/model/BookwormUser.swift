//
//  BookwormUser.swift
//  Bookworm
//
//  Created by Rajesh Raman on 6/12/17.
//  Copyright © 2017 DeedsIT. All rights reserved.
//

import Foundation
class BookwormUser{
    var email : String
    var password: String
    var firstName : String
    var lastName: String
    var userType : UserType
    
    enum UserType: String {
        case Student = "Student"
        case Lecturer = "Lecturer"
    }
    
    init?(email:String, password: String, firstName : String, lastName :String, type : String){
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.userType = UserType(rawValue: type)!
    }
}
