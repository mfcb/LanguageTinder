//
//  SignupViewController.swift
//  LanguageTinder
//
//  Created by Markus Buhl on 03.11.17.
//  Copyright © 2017 Markus Buhl. All rights reserved.
//

import UIKit
import CoreData

class SignupViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    //MARK: Interface Builder properties
    
    
    @IBOutlet weak var sv_main: UIScrollView!
    
    @IBOutlet weak var tf_firstName: UITextField!
    @IBOutlet weak var tf_lastName: UITextField!
    
    
    @IBOutlet weak var tf_email: UITextField!
    @IBOutlet weak var tf_password: UITextField!
    @IBOutlet weak var tf_password2: UITextField!
    
    @IBOutlet weak var tb_cancelButton: UIBarButtonItem!
    @IBOutlet weak var tb_doneButton: UIBarButtonItem!
    
    @IBOutlet weak var label_emailWarning: UILabel!
    @IBOutlet weak var button_signup: UIButton!
    
    
    
    
    //MARK: Interface Builder actions
    
    @IBAction func userTouchedSignupButton(_ sender: UIButton) {
        signupUser()
        self.present(self.storyboard!.instantiateViewController(withIdentifier: "loginViewController"), animated: true, completion: nil)
    }
    
    
    @IBAction func doneEditing(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        self.activeTextField!.resignFirstResponder()
    }
    
    //MARK: Interface Builder Events
    
    @IBAction func editingEmailEnded(_ sender: UITextField) {
        if !checkEmailValidity(emailString: sender.text!) {
            //entered email is incorrect
            label_emailWarning.text = "Entered e-mail address is not valid."
            label_emailWarning.isHidden = false
            //set email-flag to zero
            validityFlags = validityFlags & 0b01111111
        } else {
            //entered email is correct
            label_emailWarning.isHidden = true
            validityFlags = validityFlags | 0b10000000
        }
    }
    
    @IBAction func editingPasswordEnded(_ sender: UITextField) {
        if sender.text!.count <= 1 {
            label_emailWarning.text = "Please enter a password."
            return
        }
        if tf_password2.text!.count > 0 {
            matchPasswords()
        }
    }
    
    @IBAction func editingPassword2Ended(_ sender: UITextField) {
        matchPasswords()
        
    }
    
    func matchPasswords() {
        if tf_password2.text! != tf_password.text! {
            //entered passwords do not match
            label_emailWarning.text = "Entered passwords do not match."
            label_emailWarning.isHidden = false
            validityFlags = validityFlags & 0b10111111
        } else {
            label_emailWarning.isHidden = true
            validityFlags = validityFlags | 0b01000000
            
        }
    }
    
    
    @IBAction func cancelSignup(_ sender: UIBarButtonItem) {
       let transition = CATransition()
        transition.duration = 0.2
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.present(self.storyboard!.instantiateViewController(withIdentifier: "loginViewController"), animated: false, completion: nil)
    }
    
    
    
    
    
    @IBAction func editingFirstNameEnded(_ sender: UITextField) {
        if sender.text!.count <= 1 {
            //first name too short
            validityFlags = validityFlags & 0b11011111
        } else {
            validityFlags = validityFlags | 0b00100000
        }
    }
    
    @IBAction func editingLastNameEnded(_ sender: UITextField) {
        if sender.text!.count <= 1 {
            //last name too short
            validityFlags = validityFlags & 0b11101111
        } else {
            validityFlags = validityFlags | 0b00010000
        }
    }
    
    
    
    
    //MARK: properties
    var managedContext:NSManagedObjectContext?
    var activeTextField:UIView?

    //Unsigned integer to test for textfield validity
    //Order of flags: 0b-email-password-firstName-lastName-0000
    var validityFlags:UInt8 = 0b00001111
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate!.persistentContainer.viewContext

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
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
    
    //MARK: - Storage Functionality
    func signupUser() {
        guard let managedContext = managedContext as NSManagedObjectContext! else {
            return
        }
        let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)!
        
        let user = NSManagedObject(entity:entity, insertInto: managedContext)
        
        //set first name and last name
        user.setValue(self.tf_firstName.text, forKeyPath:"firstName")
        user.setValue(self.tf_lastName.text, forKeyPath:"lastName")
        
        //set e-mail
        user.setValue(self.tf_email.text, forKey: "email")
        
        //set password
        user.setValue(self.tf_password.text, forKey:"password")
        
        
        
        do {
            try self.managedContext!.save()
            
        } catch let error as NSError {
            print("Could not save user data. \(error), \(error.userInfo)")
        }
        
    }
    
    //MARK: Textfield Delegate functions
    func textFieldShouldBeginEditing(_ textField: UITextField)->Bool {
        print("LOL")
        self.activeTextField = textField
        self.tb_doneButton.isEnabled = true
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView)->Bool {
        print("Text view did begin")
        self.activeTextField = textView
        print(activeTextField!)
        self.tb_doneButton.isEnabled = true
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if validityFlags == 0b11111111 {
            //all fields filled out correctly
            button_signup.isEnabled = true
        } else {
            //one or more fields contain errors
            button_signup.isEnabled = false
        }
    }
    
    
    
    @objc func keyboardWillShow(_ notification:Notification) {
        guard let keyboardFrame:NSValue = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as?  NSValue else {
            print("can't get keyboard frame!")
            return
        }
        guard let activeTextField = activeTextField else {
            print("no active text field found")
            return
        }
        print("keyboard will show")
        let keyboardRect = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRect.height
        print("keyboard size: \(keyboardHeight)")
        let contentInsets:UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardHeight, 0.0)
        
        sv_main.contentInset = contentInsets
        sv_main.scrollIndicatorInsets = contentInsets
        
        var aRect:CGRect = self.view.frame
        aRect.size.height -= keyboardHeight
        
        let activeTextFieldRect:CGRect? = activeTextField.frame
        let activeTextFieldOrigin:CGPoint? = activeTextFieldRect?.origin
        
        if(!aRect.contains(activeTextFieldOrigin!)) {
            sv_main.scrollRectToVisible(activeTextFieldRect!, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        let contentInsets:UIEdgeInsets = .zero
        sv_main.contentInset = contentInsets
        sv_main.scrollIndicatorInsets = contentInsets
    }
    
    //MARK: Text Field validation functions
    func checkEmailValidity(emailString:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: emailString)
    }

}
