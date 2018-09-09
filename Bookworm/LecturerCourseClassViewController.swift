//
//  LecturerCourseClassViewController.swift
//  Bookworm
//
//  Created by Rajesh Raman on 7/12/17.
//  Copyright © 2017 DeedsIT. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialDialogs

class LecturerCourseClassViewController : UIViewController, UITableViewDelegate{
    @IBOutlet weak var classesTableView: UITableView!
    let addClassFAB = MDCFloatingButton()
    var classes = [CourseClass] ()
    var alertController = UIAlertController()
    var courseCode = ""
    var classSuccessfullyCreated = false
    
    var addClassViewController = UIViewController()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setupFAB()
        classesTableView.dataSource = self
        classesTableView.delegate = self
        loadClasses()
    }
    
    
    func setUpNavBar(){
        let logoView = UIImageView(image: #imageLiteral(resourceName: "Logo_titlebar"))
        navigationItem.titleView = logoView
    }
    
    fileprivate func setUpAddCourseDialog(){
        //Setting title and message for the alert dialog
        alertController = UIAlertController(title: "New Class", message: "", preferredStyle: .alert)
        
        let width:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view,
                                                          attribute: NSLayoutAttribute.width,
                                                          relatedBy: NSLayoutRelation.equal,
                                                          toItem: nil,
                                                          attribute: NSLayoutAttribute.notAnAttribute,
                                                          multiplier: 1, constant: self.view.frame.width * 0.90)
        alertController.view.addConstraint(width);
        
        
        alertController.view.tintColor = UIColor.init(red: 1.0, green: 0.34, blue: 0.13, alpha: 1.0)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Start now", style: .default) { (_) in
            
            //getting the input values from user
            let className = (self.alertController.textFields?[0].text)!
            print("className \(String(describing: className))")
            self.startClass(name: className)
            
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.style()   
            textField.placeholder = "Class Name"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    fileprivate func startClass(name: String){
        
        if let clazz = CourseClass.init(title: name){
            FirebaseService.sharedInstance.startClassForCourse(courseId: courseCode, clazz: clazz, onSuccess: {
                self.classSuccessfullyCreated = true
                self.alertController.dismiss(animated: true, completion: nil)
                self.goToLiveClassScreen()
            }, onError: { (error) in
                self.showErrorDialog(error!)
            })
        }
    }
    
    fileprivate func goToLiveClassScreen(){
        self.performSegue(withIdentifier: "startClassSegue", sender: self)
    }
    
    fileprivate func setupFAB(){
        view.addSubview(addClassFAB)
        addClassFAB.translatesAutoresizingMaskIntoConstraints = false
        addClassFAB.backgroundColor = UIColor.orange
        addClassFAB.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        addClassFAB.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -96.0).isActive = true
        addClassFAB.setTitle("+", for: .normal)
        addClassFAB.titleLabel?.font = addClassFAB.titleLabel?.font.withSize(36)
        addClassFAB.setTitleColor(UIColor.white, for: .normal)
        addClassFAB.addTarget(self, action: #selector(LecturerCourseClassViewController.addClassFABTapped(sender:)), for: .touchUpInside)
    }
    
    fileprivate func loadClasses(){
        
        FirebaseService.sharedInstance.getClassListForCourse(courseCode: courseCode, onSuccess: {(classes) in
            self.classes = classes
            self.classesTableView.reloadData()
        }, onError: {(error) in
            self.showErrorDialog(error!)
        })
    }
    
    fileprivate func showErrorDialog(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func addClassFABTapped(sender : UIButton){
        print("Create course was tapped")
        setUpAddCourseDialog()
    }
    
}

extension LecturerCourseClassViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath)
        
        cell.textLabel?.text = classes[indexPath.row].title
        
        return cell
    }
}

extension UITextField{
    func style(){
        self.borderStyle = .none
        self.font = UIFont.init(name: "Avenir Next Medium", size: 17.0)
    }
}

