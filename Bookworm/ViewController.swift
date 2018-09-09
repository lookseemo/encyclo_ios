//
//  LoginViewController.swift
//  
//
//  Created by Rajesh Raman on 25/10/17.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField


class ViewController: UIViewController, UITextFieldDelegate {
    
    let PROGRESS_DIALOG_TAG = 999
    let PROGRESS_DIALOG_LABEL_TAG = 99
    let progressIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var progress = UIView()
    var fullName : String = ""
    
    @IBOutlet weak var stackView: UIStackView!
    let emailTextField: SkyFloatingLabelTextField = SkyFloatingLabelTextField(frame: CGRect(x: 10, y: 10,width: 120,height: 45))
    let passwordTextField: SkyFloatingLabelTextField = SkyFloatingLabelTextField(frame: CGRect(x: 10,y: 26,width: 120,height: 45))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBackground()
        setUpTextField()
        setUpProgress()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print ("Lifecycle : ViewController viewDidAppear")
        toggleProgress(with: "", message: "", show: false)
        checkIfUserIsSignedIn()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "studentLoggedInSegue" {
            print("Student - - \(fullName)")
            let vc = segue.destination as? StudentLoggedInViewController
            vc?.name = fullName
        } else if segue.identifier == "lecturerLoggedInSegue" {
            print("Lecturer")
        }
    }
    
    private func checkIfUserIsSignedIn() {
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            print("Lifecycle: Auth.statedidchangelistener")
            print("User: \(user as AnyObject)")
            if user != nil {
                // user is signed in - go to feature controller
                self.fetchUserDetails(user!)
            } else {
                // user is not signed - go to login controller
                return
            }
        }
    }
    
    fileprivate func goToStudentLoggedInView(name : String) {
        print ("Lifecycle : ViewController goToStudentLoggedInView")
        toggleProgress(with: "", message: "", show: false)
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let studentLoggedInViewController : StudentLoggedInViewController = storyBoard.instantiateViewController(withIdentifier: "studentLoggedInViewController") as! StudentLoggedInViewController
        studentLoggedInViewController.name = name
        performSegue(withIdentifier: "studentLoggedInSegue", sender: nil)
        
    }
    
    fileprivate func goToLecturerLoggedInView(name : String) {
        print ("Lifecycle : ViewController goToLecturerLoggedInView")
        toggleProgress(with: "", message: "", show: false)
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let lecturerLoggedInViewController : LecturerLoggedInViewController = storyBoard.instantiateViewController(withIdentifier: "lecturerLoggedInViewController") as! LecturerLoggedInViewController
        lecturerLoggedInViewController.name = name
        performSegue(withIdentifier: "lecturerLoggedInSegue", sender: nil)
        
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        print ("Lifecycle : ViewController loginTapped")
        if let email = emailTextField.text, let password = passwordTextField.text{
            toggleProgress(with: "", message: "Logging in...", show: true)
            FirebaseService.sharedInstance.login(email: email, password: password
                , onSuccess: {
                    //Do nothing
            }, onError: {error in
                self.toggleProgress(with: "", message: "", show: false)
                self.showErrorDialog(error!)
            });
            
        }
    }
    
    func fetchUserDetails(_ user : User) {
        print ("Lifecycle : ViewController fetchUserDetails")
        let ref = Database.database().reference(fromURL: "https://bookwom-a3033.firebaseio.com/")
        let userID = user.uid
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let firstName = value?["firstName"] as? String ?? ""
            let lastName = value?["lastName"] as? String ?? ""
            let userType = value?["userType"] as? String ?? ""
            self.fullName = firstName + " " + lastName as String
            print ("Name is \(self.fullName)")
            print ("Usertype is \(userType)")
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            if(userType.elementsEqual("Student")){
                self.goToStudentLoggedInView(name: self.fullName)
            }else{
                self.goToLecturerLoggedInView(name: self.fullName)
            }
        }) {(error) in
            print(error.localizedDescription)
            self.showErrorDialog(error)
        }
    }
    
    
    fileprivate func showErrorDialog(_ error: Error) {
        print ("Lifecycle : ViewController showErrorDialog")
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func createAccountTapped(_ sender: UIButton) {
        print ("Lifecycle : ViewController createAccount")
        let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let registrationViewController:RegistrationViewController = storyBoard.instantiateViewController(withIdentifier: "registrationViewController") as! RegistrationViewController
        self.present(registrationViewController, animated: true, completion: nil)
    }
    
    func toggleProgress( with title : String?, message: String?, show : Bool){
        print ("Lifecycle : ViewController toggleProgress")
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
    
    func setUpBackground(){
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "LoginScreenBG")
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    func setUpTextField(){
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        emailTextField.placeholder = "Email Address"
        emailTextField.title = "Email Address"
        emailTextField.textColor = UIColor.white
        emailTextField.errorColor = UIColor.red
        emailTextField.tintColor =  AppColor.appPrimaryColor // the color of the blinking cursor
        emailTextField.selectedLineColor = AppColor.appPrimaryColor
        emailTextField.selectedTitleColor = AppColor.appPrimaryColor
        emailTextField.delegate = self
        self.stackView.insertArrangedSubview(emailTextField, at: 0)
        
        passwordTextField.placeholder = "Password"
        passwordTextField.title = "Password"
        passwordTextField.textColor = UIColor.white
        passwordTextField.selectedTitleColor = AppColor.appPrimaryColor
        passwordTextField.selectedLineColor = AppColor.appPrimaryColor
        passwordTextField.tintColor =  AppColor.appPrimaryColor // the color of the blinking cursor
        passwordTextField.isSecureTextEntry = true
        passwordTextField.errorColor = UIColor.red
        passwordTextField.delegate = self
        self.stackView.insertArrangedSubview(passwordTextField,at: 1)
    }
    
    
    /// UITextField delegate method to check if the editing is finished for email validation rules.
    ///
    /// - Parameter textField: textField
    // TODO: Ask the validation rules for email
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField {
            if let text = textField.text {
                if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                    if(text.count < 3 || !text.contains("@")) {
                        floatingLabelTextField.errorMessage = "Invalid email"
                    }
                    else {
                        // The error message will only disappear when we reset it to nil or empty string
                        floatingLabelTextField.errorMessage = ""
                    }
                }
            }
        }
    }
    
    
    /// Reset the error once we start editing the textfield
    ///
    /// - Parameters:
    ///   - textField: <#textField description#>
    ///   - range: <#range description#>
    ///   - string: <#string description#>
    /// - Returns: <#return value description#>
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailTextField {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                // The error message will only disappear when we reset it to nil or empty string
                floatingLabelTextField.errorMessage = ""
            }
        }
        return true
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
}
