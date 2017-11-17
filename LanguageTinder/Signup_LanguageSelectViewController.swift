//
//  Signup_LanguageSelectViewController.swift
//  LanguageTinder
//
//  Created by Markus Buhl on 17.11.17.
//  Copyright © 2017 Markus Buhl. All rights reserved.
//

import UIKit
import CoreData

class Signup_LanguageSelectViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    
    
    //MARK: Interface Builder Properties
    
    @IBOutlet weak var tf_nativeLanguage: UITextField!
    @IBOutlet weak var tf_foreignLanguage: UITextField!
    
    //MARK: Properties
    let languagePicker = UIPickerView()
    var pickerLanguages = ["German", "English", "Italian", "Dutch", "Arabic"]
    var user:NSManagedObject!
    var activeTextField:UITextField?
    
    //MARK: Class overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createLanguagePicker(textField: tf_nativeLanguage)
        createLanguagePicker(textField: tf_foreignLanguage)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createLanguagePicker(textField:UITextField) {
        //format date picker for dates only
        self.languagePicker.dataSource = self;
        self.languagePicker.delegate = self;
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(languageWasSubmitted))
        toolbar.setItems([doneButton], animated: false)
        
        textField.inputAccessoryView = toolbar
        
        textField.inputView = self.languagePicker
        
        
    }
    
    @objc func languageWasSubmitted() {
        print("about to set pickerLanguage")
        self.activeTextField!.text = pickerLanguages[languagePicker.selectedRow(inComponent: 0)]
        print("about to close view")
        self.view.endEditing(true)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerLanguages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerLanguages[row]
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    @IBAction func continueToNextSignupScreen(_ sender: UIButton) {
        user.setValue(tf_nativeLanguage.text, forKey: "nativeLanguage")
        user.setValue(tf_foreignLanguage.text, forKey: "desiredLanguage")
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "Signup_FaceAndVoice") as! Signup_FaceAndVoiceViewController
        nextVC.user = user
        navigationController?.pushViewController(nextVC, animated: true)
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
