//
//  main_profileViewController.swift
//  LanguageTinder
//
//  Created by Markus Buhl on 19.11.17.
//  Copyright © 2017 Markus Buhl. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class main_profileViewController: ExtendedUIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Interface Builder Properties
    
    @IBOutlet weak var iv_profilePicture: UIImageView!
    
    @IBOutlet weak var tf_firstName: UITextField!
    @IBOutlet weak var tf_lastName: UITextField!
    @IBOutlet weak var tf_eMail: UITextField!
    @IBOutlet weak var tf_university: UITextField!
    
    @IBOutlet weak var button_playVoiceSample: UIButton!
    @IBOutlet weak var button_recordVoiceSample: UIButton!
    
    @IBOutlet weak var tf_nativeLanguage: UITextField!
    @IBOutlet weak var tf_desiredLanguage: UITextField!
    
    @IBOutlet weak var tv_aboutView: UITextView!
    
    //MARK: Interface Builder Actions
    
    @IBAction func selectProfilePicture(_ sender: Any) {
        print("image tapped")
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func blaaa(_ sender: Any) {
        print("blaaa")
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            return
        }
        
        let id = thisUser.value(forKey: "id") as! UUID
        let imageName = "profilePic_" + id.uuidString + ".jpg"
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = UIImageJPEGRepresentation(image, 80) {
            do {
                try jpegData.write(to: imagePath)
                print("uploaded image to \(imagePath.relativePath)")
            } catch let error as NSError {
                print("Unable to write image: \(error)")
            }
            
        }
        self.imagePath = imagePath
        
        dismiss(animated: true) {
            self.thisUser.setValue(self.imagePath, forKey:"profilePictureURL")
            self.storeUserInfo()
            self.iv_profilePicture.image = UIImage(contentsOfFile: imagePath.path)
        }
        
    }
    
    //MARK: Properties
    var thisUser:NSManagedObject!
    var managedContext:NSManagedObjectContext!
    let languagePicker = UIPickerView()
    var pickerLanguages = ["German", "English", "Italian", "Dutch", "Arabic"]
    
    var activeTextField:UITextField?
    
    //image upload properties
    var imagePath:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get the appDelegate to set up CoreData context
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate!.persistentContainer.viewContext
        
        //get the user from the tab bar controller
        let parentController = self.tabBarController as! MainTabBarController
        self.thisUser = parentController.thisUser
        
        setUpCustomKeyboard()
        
        populateUserProfile()
        createLanguagePicker(textField: tf_nativeLanguage)
        createLanguagePicker(textField: tf_desiredLanguage)
        
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerLanguages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerLanguages[row]
    }
    
    @objc func languageWasSubmitted() {
        self.activeTextField!.text = pickerLanguages[languagePicker.selectedRow(inComponent: 0)]
        storeUserInfo()
        self.view.endEditing(true)
    }
    
    
    override func keyboardToolBarDoneButtonWasPressed() {
        storeUserInfo()
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func setUpCustomKeyboard() {
        
        self.tf_nativeLanguage.inputAccessoryView = keyboardToolBar
        self.tf_desiredLanguage.inputAccessoryView = keyboardToolBar
        self.tf_eMail.inputAccessoryView = keyboardToolBar
        self.tf_university.inputAccessoryView = keyboardToolBar
        self.tf_firstName.inputAccessoryView = keyboardToolBar
        self.tf_lastName.inputAccessoryView = keyboardToolBar
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateUserProfile() {
        tf_firstName.text = thisUser.value(forKey: "firstName") as? String
        tf_lastName.text = thisUser.value(forKey: "lastName") as? String
        tf_eMail.text = thisUser.value(forKey: "email") as? String
        tf_university.text = thisUser.value(forKey:"university") as? String
        tf_nativeLanguage.text = thisUser.value(forKey:"nativeLanguage") as? String
        tf_desiredLanguage.text = thisUser.value(forKey:"desiredLanguage") as? String
        
        //load profile picture
        iv_profilePicture.contentMode = .scaleAspectFit
        iv_profilePicture.image = loadProfilePicture(withImageURL: thisUser.value(forKey: "profilePictureURL") as! URL)
    }
    
    func storeUserInfo() {
        thisUser.setValue(tf_firstName.text, forKey: "firstName")
        thisUser.setValue(tf_lastName.text, forKey: "lastName")
        thisUser.setValue(tf_eMail.text, forKey: "email")
        thisUser.setValue(tf_university.text, forKey: "university")
        thisUser.setValue(tf_nativeLanguage.text, forKey: "nativeLanguage")
        thisUser.setValue(tf_desiredLanguage.text, forKey: "desiredLanguage")
        thisUser.setValue(tv_aboutView.text, forKey: "aboutDescription")
        
        do {
            try self.managedContext!.save()
            
        } catch let error as NSError {
            print("Could not save user data. \(error), \(error.userInfo)")
        }
    }
    
    func loadProfilePicture(withImageURL imgURL:URL)->UIImage? {
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
            if let path = NSURL(fileURLWithPath: dir).appendingPathComponent(imgURL.lastPathComponent) {
                print(path as Any)
                if  let imageData = NSData(contentsOf: path) {
                    return UIImage(data:imageData as Data)
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func getDocumentsDirectory()->URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
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
