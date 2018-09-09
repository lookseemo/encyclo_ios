//
//  LecutrerRatingViewController.swift
//  Bookworm
//
//  Created by Rajesh Raman on 1/12/17.
//  Copyright © 2017 DeedsIT. All rights reserved.
//

import Foundation
import UIKit

class LecturerRatingViewController : UIViewController{
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        FirebaseService.sharedInstance.logout(controller: presentingViewController!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
    }
    
    func setUpNavBar(){
        let logoView = UIImageView(image: #imageLiteral(resourceName: "Logo_titlebar"))
        navigationItem.titleView = logoView
    }
    
}
