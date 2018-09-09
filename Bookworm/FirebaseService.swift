//
//  FirebaseService.swift
//  Bookworm
//
//  Created by Rajesh Raman on 30/11/17.
//  Copyright © 2017 DeedsIT. All rights reserved.
//

import Foundation
import Firebase
import SwiftyBeaver
class FirebaseService {
    static let sharedInstance = FirebaseService()
    
    let ref = Database.database().reference(fromURL: "https://bookwom-a3033.firebaseio.com/")
    
    
    /**--------------------------------------------------
     ** User
     **--------------------------------------------------*/
    
    /// Firebase login function. Uses email + password credentials to login the user
    ///
    /// - Parameters:
    ///   - email: email address of the user
    ///   - password: password of the user
    ///   - onSuccess: callback for successful login
    ///   - onError: callback for any error
    func login(email: String, password: String, onSuccess: @escaping ()-> Void, onError: @escaping (_ error : Error?) -> Void){
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if let firebaseError = error {
                print(firebaseError.localizedDescription)
                onError(firebaseError)
            }
            if user != nil{
                print("User has signed in")
                onSuccess()
            }
        })
    }
    
    
    /// Firebase register function.
    ///
    /// - Parameters:
    ///   - user: BookwormUser object containing all details for registration
    ///   - onSuccess: callback for successful login
    ///   - onError: callback for any error
    func register(user: BookwormUser, onSuccess: @escaping () -> Void, onError: @escaping (_ error : Error?) -> Void){
        
        Auth.auth().createUser(withEmail: user.email, password: user.password) { (userResponse, error) in
            if let error = error{
                onError(error)
            }else{
                self.saveUser(user: user, onSuccess: onSuccess, onError: onError)
            }
        }
        
    }
    
    
    /// Function to save the user details into the firebase database
    ///
    /// - Parameters:
    ///   - user: Bookworm user object
    ///   - onSuccess: callback for successful login
    ///   - onError: callback for any error
    func saveUser(user: BookwormUser, onSuccess : @escaping () -> Void, onError: @escaping ((Error?) -> Void)){
        
        let key = Auth.auth().currentUser?.uid 
        let value = ["id" : key!,
                     "firstName" : user.firstName,
                     "lastName" : user.lastName,
                     "email" : user.email,
                     "userType": user.userType.rawValue] as [String : Any]
        
        getCurrentUser().setValue(value, withCompletionBlock: ({ (error, ref) in
            if(error != nil){
                onError(error)
            }else{
                print ("User added")
                onSuccess()
            }
        }))
    }
    
    /// Getter for the users database reference
    ///
    /// - Returns: reference to the users path in the database
    func getUsers() -> DatabaseReference {
        return ref.child("users")
    }
    
    
    /// Getter for current Firebase user
    ///
    /// - Returns: reference to the current user in the database
    func getCurrentUser() -> DatabaseReference {
        let uid = Auth.auth().currentUser?.uid
        return getUsers().child(uid!)
    }
    
    
    /// Function to logout the current user
    ///
    /// - Parameter controller: UIViewController to dismiss after successful 
    func logout(controller: UIViewController){
        do {
            try Firebase.Auth.auth().signOut()
            controller.dismiss(animated: true, completion: nil)
        }catch{
            print("Could not log out. Something went wrong!")
        }
    }
    
    /**--------------------------------------------------
     ** Course
     **--------------------------------------------------*/
    
    /// Function to create a course for lecturer
    ///
    /// - Parameters:
    ///   - course: Course object with the necessary information
    ///   - onSuccess: callback for successful course creation
    ///   - onError: callback for error scenarios
    func createCourseForUser(course: Course, onSuccess : @escaping () -> Void, onError: @escaping ((Error?) -> Void)){
        
        SwiftyBeaver.debug("Starting course for user", context: "FirebaseService")
        
        let userId = Auth.auth().currentUser?.uid
        
        let courseData = ["course_id" : course.code,
                          "course_title" : course.name,
                          "course_rating" : course.rating] as [String : Any]
        
        let courseMetaData = ["course_title" : course.name,
                              "course_id" : course.code]
        
        let childUpdates = ["/courses/\(course.code)": courseData,
                            "/users/\(userId ?? "")/courses/\(course.code)/": courseMetaData] as [String : Any]
        
        ref.updateChildValues(childUpdates, withCompletionBlock: ({(error, ref) in
            if(error != nil){
                onError(error)
            }else{
                print ("Course added")
                onSuccess()
            }
        }))
    }
    
    /// Getter for all courses for current user
    ///
    /// - Returns: reference to the courses path of the current user
    func getCoursesForCurrentUser() -> DatabaseReference {
        return getCurrentUser().child("courses")
    }
    
    /**--------------------------------------------------
     ** Class
     **--------------------------------------------------*/
    
    /// Function to start a classs for course
    ///
    /// - Parameters:
    ///   - courseId: id of the course the classs belongs to
    ///   - clazz: CourseClass object that holds required information for the class
    ///   - onSuccess: callback on successfully starting the class
    ///   - onError: callback for any error
    func startClassForCourse(courseId: String, clazz: CourseClass, onSuccess: @escaping() -> Void, onError: @escaping ((Error?) -> Void)){
        SwiftyBeaver.debug("Starting class for course", context: "FirebaseService")
        
        let key = ref.child("classes").childByAutoId().key
        
        let classData = ["class_title" : clazz.title,
                         "status": "STARTED",
                         "startTime": ServerValue.timestamp()] as [String : Any]
        
        let classMetaData = ["id": key,
                             "class_title" : clazz.title]
        
        let childUpdates = ["/classes/\(key)" : classData,
        "/courses/\(courseId)/classes/\(clazz.title)" : classMetaData] as [String:Any]
        
        ref.updateChildValues(childUpdates, withCompletionBlock: ({(error, ref) in
            if(error != nil){
                onError(error)
            }else{
                print ("Class started")
                onSuccess()
            }
        }))
    }
   
    /// Getter for all classes for a particular course
    ///
    /// - Returns: reference to the classes path for the course Code
    func getClassesForCourse(courseCode: String) -> DatabaseReference {
        return getCurrentUser().child("courses").child("classes")
    }
    
    func getClassListForCourse(courseCode: String,
                               onSuccess : @escaping (([CourseClass]) -> Void),
                               onError: @escaping ((Error?) -> Void)){
        SwiftyBeaver.debug("Getting class list for course", context: "FirebaseService")
        ref.child("courses").child(courseCode).observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            var classes: [CourseClass] = []
            
            let raw = value?["classes"] as? NSDictionary ?? [:]
            
            for (key,_) in raw {
                
                let clazz:NSObject = raw[key] as! NSObject
                let title:String! = clazz.value(forKey: "class_title") as? String
                let id:String! = clazz.value(forKey: "id") as? String
//                let avgRating:Double! = clazz.value(forKey: "averageRating") as? Double
                
                let cl = CourseClass(title: title)
                cl?.id = id
//                cl?.averageRating = avgRating
                
                classes.append(cl!)
            }
            
            onSuccess(classes)
        }){ (error) in
            print(error.localizedDescription)
            onError(error)
        }
    }
    
   
    
//    func loadCourses(completion: ([Course], Error) -> ()){
//        let key = Auth.auth().currentUser?.uid
//        var courses = [Course]()
//        ref.child("users").child(key!).child("courses").observe(.childAdded) { (snapshot) in
//            if let dict = snapshot.value as? [String : Any]{
//                let course = Course(
//                    name: dict["course_title"] as! String,
//                    code: dict["course_id"] as! String,
//                    rating: dict["course_rating"] as! Double,
//                    classes: dict["courses"] as! [CourseClass])
//
//                courses.append(course!)
//            }
//
//        }
//
//    }
}
