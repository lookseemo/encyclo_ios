//
//  StudentLoggedInViewController.swift
//  Bookworm
//
//  Created by Rajesh Raman on 25/10/17.
//  Copyright © 2017 DeedsIT. All rights reserved.
//

import UIKit
import Firebase

class StudentLoggedInViewController: UIViewController {
    @IBOutlet weak var studentWelcomeLabel: UILabel!
    var name : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentWelcomeLabel.text = studentWelcomeLabel.text! + " " + name
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        FirebaseService.sharedInstance.logout(controller: presentingViewController!)
    }
    
}

