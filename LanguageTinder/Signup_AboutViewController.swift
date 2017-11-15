//
//  Signup_AboutViewController.swift
//  LanguageTinder
//
//  Created by Markus Buhl on 10.11.17.
//  Copyright © 2017 Markus Buhl. All rights reserved.
//

import UIKit
import CoreData

class Signup_AboutViewController: UIViewController {
    //MARK: Interface Builder Properties
    
    @IBOutlet weak var button_next: UIButton!
    @IBOutlet weak var tf_birthDate: UITextField!
    @IBOutlet weak var tf_university: UITextField!
    
    @IBOutlet weak var tv_bio: UITextView!
    
    //MARK: Properties
    var user:NSManagedObject!
    let datePicker = UIDatePicker()
    var birthDate:Date!
    
    //MARK: Interface Builder Actions
    
    @IBAction func continueToNextSignupScreen(_ sender: UIButton) {
        user.setValue(birthDate, forKey: "birthDate")
        user.setValue(tf_university.text, forKey: "university")
        user.setValue(tv_bio.text, forKey: "aboutDescription")
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "Signup_FaceAndVoice") as! Signup_FaceAndVoiceViewController
        nextVC.user = user
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(birthDateWasSubmitted))
        toolbar.setItems([doneButton], animated: false)
        
        tf_birthDate.inputAccessoryView = toolbar
        
        tf_birthDate.inputView = datePicker
        
        
    }
    
    
    @objc func birthDateWasSubmitted() {
        //format the date for output
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        tf_birthDate.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
        birthDate = datePicker.date
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
