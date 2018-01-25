//
//  Signup_AboutViewController.swift
//  LanguageTinder
//
//  Created by Markus Buhl on 10.11.17.
//  Copyright © 2017 Markus Buhl. All rights reserved.
//

import UIKit
import CoreData

class Signup_AboutViewController: ExtendedUIViewController, UITextFieldDelegate {
    //MARK: Interface Builder Properties
    
    @IBOutlet weak var button_next: UIButton!
    @IBOutlet weak var tf_birthDate: UITextField!
    @IBOutlet weak var tf_university: UITextField!
    
    @IBOutlet weak var tv_bio: UITextView!
    
    //MARK: Properties
    var user:NSManagedObject!
    let datePicker = UIDatePicker()
    var birthDate:Date?
    
    var currentTextField:UITextField?
    
    //MARK: Interface Builder Actions
    
    @IBAction func continueToNextSignupScreen(_ sender: UIButton) {
        user.setValue(birthDate!, forKey: "birthDate")
        user.setValue(tf_university.text, forKey: "university")
        user.setValue(tv_bio.text, forKey: "aboutDescription")
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "Signup_LanguageSelect") as! Signup_LanguageSelectViewController
        nextVC.user = user
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tf_university.inputAccessoryView = keyboardToolBar
        tf_birthDate.inputAccessoryView = self.keyboardToolBar
        createDatePicker()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createDatePicker() {
        //format date picker for dates only
        datePicker.datePickerMode = .date
        tf_birthDate.inputView = datePicker
        
        
    }

    override func keyboardToolBarDoneButtonWasPressed() {
        if currentTextField == tf_birthDate {
            //format the date for output
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            tf_birthDate.text = dateFormatter.string(from: datePicker.date)
            self.view.endEditing(true)
            birthDate = datePicker.date
            print("birth date: \(birthDate)")
        } else {
            self.view.endEditing(true)
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tf_birthDate {
            print("birthDate")
        }
        self.currentTextField = textField
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
