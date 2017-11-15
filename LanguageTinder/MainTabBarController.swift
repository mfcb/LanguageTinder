//
//  MainTabBarController.swift
//  LanguageTinder
//
//  Created by Markus Buhl on 10.11.17.
//  Copyright © 2017 Markus Buhl. All rights reserved.
//

import UIKit
import CoreData

class MainTabBarController: UITabBarController {
    
    var thisUser:NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let thisUser = self.thisUser else {
            print("user is \(self.thisUser)")
            switchToLoginVC()
            return
        }
        print("We are in main and thisUser is \(thisUser)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //MARK: Functions
    func switchToLoginVC() {
        let loginSB = UIStoryboard(name: "Login", bundle: nil)
        let loginVC = loginSB.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
        self.present(loginVC, animated: false, completion: nil)
    }

}
