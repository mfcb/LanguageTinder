//
//  LoginViewController.swift
//  LanguageTinder
//
//  Created by Markus Buhl on 06.11.17.
//  Copyright © 2017 Markus Buhl. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: ExtendedUIViewController, UITextFieldDelegate {
    
    //MARK: Interface Builder properties
    @IBOutlet weak var tf_login_email: UITextField!
    @IBOutlet weak var tf_login_password: UITextField!
    
    //MARK: Properties
    var managedContext:NSManagedObjectContext?
    var user:NSManagedObject?
    
    //MARK: Interface Builder actions
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        loginUser()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tf_login_password {
            loginUser()
        }
        return true
    }
    
    func loginUser() {
        guard let user = checkForEmail(withEmail: tf_login_email.text!) else {
            print("User not found in database.")
            return
        }
        if checkPassword(forPassword: tf_login_password.text!, withUser: user) {
            //password username and password correct, log user in
            user.setValue(true, forKey: "isLoggedInOnThisDevice")
            do {
                try self.managedContext?.save()
            } catch let error as NSError {
                print("unable to store user as logged in: \(error)")
            }
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mainViewController = mainStoryboard.instantiateInitialViewController() as! MainTabBarController
            mainViewController.thisUser = user
            self.present(mainViewController, animated: true, completion: nil)
        } else {
            return
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //check if we're a returning user who is already logged in
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"User")
        
        fetchRequest.predicate = NSPredicate(format: "isLoggedInOnThisDevice == true")
        var result = [NSManagedObject]()
        do {
            result = try managedContext!.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if result.count == 1 {
            //returning user, go to loggedInView
            print("Number of user results is 1")
            let loggedInVC = storyboard?.instantiateViewController(withIdentifier: "loggedInViewController") as! LoggedInViewController
            loggedInVC.user = result[0]
            print("You have logged in as: \(loggedInVC.user)")
            self.present(loggedInVC, animated: false, completion: nil)
            
        } else {
            print("Number of user results is \(result.count)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set up managed context for persistance
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate!.persistentContainer.viewContext
        
        //set up custom keyboard
        tf_login_email.inputAccessoryView = keyboardToolBar
        tf_login_password.inputAccessoryView = keyboardToolBar
        
        
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
    
    func checkForEmail(withEmail email:String)->NSManagedObject? {
        guard let managedContext = self.managedContext as NSManagedObjectContext! else {
            print("managed context not found")
            return nil
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"User")
        
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        var result = [NSManagedObject]()
        do {
            result = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if result.count == 0 {
            return nil // no matching email address found, user does not exist
        } else {
            return result[0] // matching email address found, user exists
        }
        
    }
    
    func checkPassword(forPassword password:String, withUser user:NSManagedObject)->Bool {
        if password == user.value(forKey: "password") as! String {
            print("Entered password is correct!")
            return true
        } else {
            print("Entered password is incorrect!")
            return false
        }
    }

}
