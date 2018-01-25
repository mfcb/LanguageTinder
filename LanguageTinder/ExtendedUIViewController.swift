//
//  ExtendedUIViewController.swift
//  LanguageTinder
//
//  Created by Markus Buhl on 20.11.17.
//  Copyright © 2017 Markus Buhl. All rights reserved.
//

import UIKit

class ExtendedUIViewController: UIViewController {
    var keyboardToolBar:UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardToolBar = UIToolbar()
        keyboardToolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(keyboardToolBarDoneButtonWasPressed))
        keyboardToolBar.setItems([doneButton], animated: false)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyboardToolBarDoneButtonWasPressed() {
        print("done button pressed")
        self.view.endEditing(true)
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
