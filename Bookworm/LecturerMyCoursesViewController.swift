//
//  LecturerMyCoursesViewController.swift
//  Bookworm
//
//  Created by Rajesh Raman on 1/12/17.
//  Copyright © 2017 DeedsIT. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialDialogs


class LecturerMyCoursesViewController : UIViewController, UITableViewDelegate{
    
    @IBOutlet weak var coursesTableView: UITableView!
    let addCourseFAB = MDCFloatingButton()
    var alertController = UIAlertController()
    var courses = [Course] ()
    var selectedCourse = Course()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFAB()
        coursesTableView.dataSource = self
        coursesTableView.delegate = self
        loadCourses()
        setUpNavBar()
    }
    
    func setUpNavBar(){
        let logoView = UIImageView(image: #imageLiteral(resourceName: "Logo_titlebar"))
        navigationItem.titleView = logoView
    }
    
    fileprivate func loadCourses(){
        FirebaseService.sharedInstance.getCoursesForCurrentUser().observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String : Any]{
                let course = Course(
                    name: dict["course_title"] as! String,
                    code: dict["course_id"] as! String,
                    rating: 0.0,
                    classes : [])
                course?.id = dict["course_id"] as! String
                print("\(String(describing: course))")
                self.courses.append(course!)
                self.coursesTableView.reloadData()
            }
        }
    }
    
    @objc func addCourseFABTapped(sender : UIButton){
        print("Create course was tapped")
        
        alertController = UIAlertController(title: "Create new course", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            let courseNameField = self.alertController.textFields![0] as UITextField
            let courseCodeField = self.alertController.textFields![1] as UITextField
            
            print("courseName \(String(describing: courseNameField.text)), courseCode \(String(describing: courseCodeField.text))")
            
            
            self.createCourse(courseName: courseNameField.text!, courseCode: courseCodeField.text!)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Course Name (optional)"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Course code (required)"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func createCourse(courseName: String, courseCode: String){
        
        if let course = Course.init(name: courseName, code: courseCode, rating: 0.0, classes: []){
            FirebaseService.sharedInstance.createCourseForUser(course: course, onSuccess: {
                self.alertController.dismiss(animated: true, completion: nil)
            }, onError: { (error) in
                self.showErrorDialog(error!)
            })
        }
    }
    
    
    fileprivate func setupFAB(){
        view.addSubview(addCourseFAB)
        addCourseFAB.translatesAutoresizingMaskIntoConstraints = false
        addCourseFAB.backgroundColor = UIColor.orange
        addCourseFAB.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        addCourseFAB.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -96.0).isActive = true
        addCourseFAB.setTitle("+", for: .normal)
        addCourseFAB.titleLabel?.font = addCourseFAB.titleLabel?.font.withSize(36)
        addCourseFAB.setTitleColor(UIColor.white, for: .normal)
        addCourseFAB.addTarget(self, action: #selector(LecturerMyCoursesViewController.addCourseFABTapped(sender:)), for: .touchUpInside)
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        FirebaseService.sharedInstance.logout(controller: presentingViewController!)
    }
    
    fileprivate func showErrorDialog(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "courseClassSegue"){
            guard let lecturerCourseClassVC = segue.destination as? LecturerCourseClassViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedCourseCell = sender as? UITableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = coursesTableView.indexPath(for: selectedCourseCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedCourse = courses[indexPath.row]
            lecturerCourseClassVC.courseCode = selectedCourse.code
        }
    }
}

extension LecturerMyCoursesViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Count : \(courses.count)")
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath)
        
        cell.textLabel?.text = courses[indexPath.row].name
        cell.detailTextLabel?.text = courses[indexPath.row].code
        
        return cell
    }
}
