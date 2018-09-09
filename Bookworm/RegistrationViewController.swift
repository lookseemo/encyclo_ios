//
//  ViewController.swift
//  Bookworm
//
//  Created by Rajesh Raman on 13/10/17.
//  Copyright © 2017 DeedsIT. All rights reserved.
//

import UIKit
import Firebase



class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var emailAddressInputField: UITextField!
    @IBOutlet weak var passwordInputField: UITextField!
    @IBOutlet weak var confirmPasswordInputField: UITextField!
    @IBOutlet weak var lastNameInputField: UITextField!
    @IBOutlet weak var firstNameInputField: UITextField!
    @IBOutlet weak var iAmAStudentButton: UIButton!
    @IBOutlet weak var iAmALecturerButton: UIButton!
    
    var userType = "Student"
    
    let PROGRESS_DIALOG_TAG = 999
    let PROGRESS_DIALOG_LABEL_TAG = 99
    
    weak var alertController : UIAlertController!
    let progressIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    var progress = UIView()
    
    
    let greenColor = UIColor(red:-0.108958, green: 0.714926, blue: 0.758113, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUpIAmAButtons()
        setUpProgress()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavigationController()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.leftBarButtonItem?.title = "Login"
    }
    
    func setUpNavigationController() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.leftBarButtonItem?.title="Login"
    }
    
    func setUpProgress(){
        
        let container : UIView = UIView()
        container.frame = view.frame
        container.center = view.center
        container.backgroundColor = UIColor.black
        container.alpha = 0.3
        
        
        progress = UIView(frame: CGRect(x:0, y:0, width:200, height:50))
        progress.backgroundColor = UIColor.black
        progress.alpha = 0.7
        progress.layer.cornerRadius = 10
        progress.center = container.center
        progress.tag = PROGRESS_DIALOG_TAG
        
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        spinner.center = CGPoint(x: progress.frame.size.width/2 - 60, y: progress.frame.size.height/2)
        spinner.clipsToBounds = true
        spinner.hidesWhenStopped = false
        spinner.startAnimating()
        
        let message = UILabel(frame: CGRect(x: 60, y: 0, width: 100, height: 50))
        message.textColor = UIColor.white
        message.tag = PROGRESS_DIALOG_LABEL_TAG
        message.autoresizingMask = [.flexibleWidth]
        
        progress.addSubview(spinner)
        progress.addSubview(message)
        progress.center = self.view.center
        
        container.addSubview(progress)
        
    }
    
    func setUpIAmAButtons(){
        iAmAStudentButton.setBorderSettings(borderColor: UIColor.white)
        iAmALecturerButton.setBorderSettings(borderColor: UIColor.white)
    }
    
    @IBAction func iAmAButtonClicked(_ sender: UIButton) {
        let clickedButton = sender.currentTitle!
        setIAmAButtonGroupState(clickedButton: clickedButton)
    }
    
    func setIAmAButtonGroupState( clickedButton : String){
        userType = clickedButton
        switch clickedButton{
        case "Student":
            iAmAStudentButton.setBorderSettings(borderColor: greenColor)
            iAmALecturerButton.setBorderSettings(borderColor: UIColor.white)
            break
        case "Lecturer":
            iAmAStudentButton.setBorderSettings(borderColor: UIColor.white)
            iAmALecturerButton.setBorderSettings(borderColor: greenColor)
            break
        default:
            break
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func showErrorDialog(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func tryRegisterWithEmailAndPassword(_ sender: UIButton) {
        
        print("Logging in with email and password")
        let email = emailAddressInputField.text
        let password = passwordInputField.text
        let confirmPassword = confirmPasswordInputField.text
        let firstName = firstNameInputField.text
        let lastName = lastNameInputField.text
        
        if(inputValuesAreValidated(email:email!, password:password!, confirmPassword:confirmPassword!, firstName: firstName!)){
            
            let user = BookwormUser(email: email!, password: password!, firstName: firstName!, lastName: lastName!, type: userType)
            toggleProgress(with: "", message: "Registering...", show: true)
            
            FirebaseService.sharedInstance.register(user: user!, onSuccess: {
                self.toggleProgress(with: "", message: "", show: false)
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }, onError: {error in
                self.toggleProgress(with: "", message: "", show: false)
                self.showErrorDialog(error!)
            })
        }else{
            toggleProgress(with: "", message: "", show: false)
            return
        }
    }
    
    
    func inputValuesAreValidated(email : String, password: String, confirmPassword:String, firstName:String)-> Bool{
        var isValid = true
        if(email.isEmpty){
            emailAddressInputField.text = ""
            emailAddressInputField.attributedPlaceholder = NSAttributedString(string:  "Email address cannot be empty", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            isValid = false
        }else {
            if(!email.isValidEmail()){
                emailAddressInputField.text = ""
                emailAddressInputField.attributedPlaceholder = NSAttributedString(string:  "Email address is not valid", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                isValid = false
            }
        }
        if(password.isEmpty){
            passwordInputField.text = ""
            passwordInputField.attributedPlaceholder = NSAttributedString(string: "Password cannot be empty", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            isValid = false
        }
        if(confirmPassword.isEmpty){
            confirmPasswordInputField.text = ""
            confirmPasswordInputField.attributedPlaceholder = NSAttributedString(string: "Confirm Password cannot be empty", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            isValid = false
        }
        if(firstName.isEmpty){
            firstNameInputField.text = ""
            firstNameInputField.attributedPlaceholder = NSAttributedString(string: "First name cannot be empty", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            isValid = false
        }
        return isValid
    }
    
    func saveUserDetails(){
        
        let ref = Database.database().reference(fromURL: "https://bookwom-a3033.firebaseio.com/")
        let usersRef = ref.child("users")
        let key = Auth.auth().currentUser?.uid
        let value = ["id" : key,
                     "firstName" : firstNameInputField.text! as String,
                     "lastName" : lastNameInputField.text! as String,
                     "email" : emailAddressInputField.text! as String,
                     "userType": userType as String]
        
        usersRef.child(key!).setValue(value)
        self.toggleProgress(with: nil, message: nil, show: false)
        print ("User added")
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func toggleProgress( with title : String?, message: String?, show : Bool){
        if(show){
            for sub in progress.subviews {
                if let theLabel = sub.viewWithTag(PROGRESS_DIALOG_LABEL_TAG) as? UILabel {
                    theLabel.text = message
                }
            }
            self.view.addSubview(progress)
        }else{
            self.view.superview?.viewWithTag(PROGRESS_DIALOG_TAG)?.removeFromSuperview()
        }
    }
}



extension UIButton {
    func setBorderSettings(borderColor : UIColor){
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = borderColor.cgColor
        self.layer.masksToBounds = true
    }
}

extension String {
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[A-Z0-9a-z][a-zA-Z0-9_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
        
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: characters.count)) != nil
    }
}


