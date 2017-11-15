//
//  LoggedInViewController.swift
//  LanguageTinder
//
//  Created by Markus Buhl on 10.11.17.
//  Copyright © 2017 Markus Buhl. All rights reserved.
//

import UIKit
import CoreData

class LoggedInViewController: UIViewController {
    
    //MARK: Interface Builder properties
    
    @IBOutlet weak var iv_profilePic: UIImageView!
    @IBOutlet weak var label_loginInfo: UILabel!
    
    //MARK: Properties
    var user:NSManagedObject?
    
    //MARK: Interface Builder actions
    
    @IBAction func continueToMain(_ sender: UIButton) {
        let mainSB = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = mainSB.instantiateInitialViewController() as! MainTabBarController
        mainVC.thisUser = user
        print("We are in logged in view and our user is \(user)")
        self.present(mainVC, animated: true, completion: nil)
    }
    
    @IBAction func switchUser(_ sender: UIButton) {
        //set up managed context for persistance
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        user?.setValue(false, forKey: "isLoggedInOnThisDevice")
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save user data. \(error), \(error.userInfo)")
        }
        switchToLoginVC()
    }
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let user = user else {
            switchToLoginVC()
            return
        }
        let imgURL = user.value(forKey: "profilePictureURL") as! URL
        iv_profilePic.contentMode = .scaleAspectFit
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
            if let path = NSURL(fileURLWithPath: dir).appendingPathComponent(imgURL.lastPathComponent) {
                print(path as Any)
                if  let imageData = NSData(contentsOf: path) {
                    iv_profilePic.image = UIImage(data:imageData as Data)
                    
                }
            }
        }
        let imgThumb = UIImage(contentsOfFile: imgURL.relativePath)
        print("img thumb: \(imgURL.lastPathComponent)")
        //iv_profilePic.image = imgThumb
        let firstName = user.value(forKey: "firstName") as! String
        let lastName = user.value(forKey: "lastName") as! String
        label_loginInfo.text = "Logged in as \(firstName) \(lastName)"
        
        
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
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
        self.present(loginVC, animated: false, completion: nil)
    }

}
