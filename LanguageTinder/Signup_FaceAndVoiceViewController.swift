//
//  Signup_FaceAndVoiceViewController.swift
//  LanguageTinder
//
//  Created by Markus Buhl on 08.11.17.
//  Copyright © 2017 Markus Buhl. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class Signup_FaceAndVoiceViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Interface Builder Properties
    
    
    //MARK: Interface Builder Image Selection Outlets
    
    @IBOutlet weak var iv_profileThumb: UIImageView!
    @IBOutlet weak var button_imageSelector: UIButton!
    
    //MARK: Interface Builder Audio Recording Outlets
    @IBOutlet weak var button_recordAudio: UIButton!
    @IBOutlet weak var button_playAudio: UIButton!
    @IBOutlet weak var button_pauseAudio: UIButton!
    
    @IBOutlet weak var button_audioPermission: UIButton!
    
    //MARK: Properties
    
    var managedContext:NSManagedObjectContext!
    var user:NSManagedObject!
    
    var appDelegate:UIApplicationDelegate!
    
    var recordingSession:AVAudioSession!
    var recorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    
    var imagePath:URL?
    var audioFilePath:URL?
    //MARK: Interface Builder Actions
    
    
    @IBAction func signupUser(_ sender: UIButton) {
        user.setValue(imagePath, forKeyPath:"profilePictureURL")
        user.setValue(audioFilePath, forKey: "voiceRecordingURL")
        
        //log in the newly created user
        user.setValue(true, forKey: "isLoggedInOnThisDevice")
        
        do {
            try self.managedContext!.save()
         
        } catch let error as NSError {
            print("Could not save user data. \(error), \(error.userInfo)")
        }
        let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "loggedInViewController") as! LoggedInViewController
        loginViewController.user = user
        self.present(loginViewController, animated: true, completion: nil)
        
    }
    
    //MARK: Interface Builder Image Selection Actions
    
    @IBAction func selectImage(_ sender: UIButton) {
        
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            return
        }
        
        let id = user.value(forKey: "id") as! UUID
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
            self.iv_profileThumb.contentMode = .scaleAspectFit
            self.iv_profileThumb.image = UIImage(contentsOfFile: imagePath.path)
        }
        
    }
    
    //MARK: Interface Builder Audio Recording Actions
    @IBAction func allowRecordingAudio(_ sender: UIButton) {
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        self.loadRecordingFailUI()
                    }
                }
            }
            
        } catch {
            self.loadRecordingFailUI()
        }
    }
    
    
    @IBAction func startRecordingAudio(_ sender: UIButton) {
        //view.backgroundColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 1)
        button_playAudio.isEnabled = false
        button_pauseAudio.isEnabled = false
        
        let audioURL = getRecordingURL()
        print(audioURL.absoluteString)
        
        let recordingSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            recorder = try AVAudioRecorder(url: audioURL, settings: recordingSettings)
            recorder.delegate = self
            recorder.record()
            
        } catch {
            
        }
    }
    
    func finishRecording(success:Bool) {
        recorder.stop()
        recorder = nil
        if success {
            self.audioFilePath = getRecordingURL()
        } else {
            let ac = UIAlertController(title: "Recording failed!", message:"There was a problem recording your voice. Please try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok!", style: .default, handler: nil))
            present(ac,animated: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @IBAction func stopRecordingAudio(_ sender: UIButton) {
        finishRecording(success: true)
        print("Successfully recorded your voice.")
        button_playAudio.isEnabled = true
    }
    
    @IBAction func cancelRecordingAudio(_ sender: UIButton) {
        finishRecording(success: true)
        print("Canceled recording. Will delete.")
        do {
            try FileManager.default.removeItem(at: getRecordingURL())
        } catch let error as NSError {
            print("Unable to remove audio file: \(error)")
        }
        
    }
    
    
    @IBAction func playbackAudio(_ sender: UIButton) {
        button_playAudio.isEnabled = false
        button_pauseAudio.isEnabled = true
        button_recordAudio.isEnabled = false
            
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getRecordingURL())
            audioPlayer.delegate = self
            audioPlayer.play()
        } catch let error as NSError {
            print("Unable to playback recording: \(error)")
        }
    }
    
    
    @IBAction func pauseAudio(_ sender: UIButton) {
        button_playAudio.isEnabled = true
        button_pauseAudio.isEnabled = false
        if audioPlayer.isPlaying {
            audioPlayer.stop()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        button_recordAudio.isEnabled = true
        button_playAudio.isEnabled = true
        button_pauseAudio.isEnabled = false
    }
    
    
    
    //MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get the appDelegate to set up CoreData context
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate!.persistentContainer.viewContext
        
        recordingSession = AVAudioSession.sharedInstance()
        
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
    
    func loadRecordingUI() {
        self.button_audioPermission.setTitle("Hold record button to record. Let go to cancel.", for: UIControlState.normal)
        self.button_audioPermission.setTitleColor(UIColor.blue, for: .disabled)
        self.button_audioPermission.isEnabled = false
        
        self.button_recordAudio.isEnabled = true
    }
    
    func loadRecordingFailUI() {
        self.button_audioPermission.setTitleColor(UIColor.red, for: .normal)
        self.button_audioPermission.isEnabled = false
        self.button_audioPermission.setTitle("Permission not given. Unable to record.", for: .disabled)
    }
    
    func getDocumentsDirectory()->URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getRecordingURL()->URL {
        let id = user.value(forKey: "id") as! UUID
        return getDocumentsDirectory().appendingPathComponent("voiceRecording_"+id.uuidString+".mp4")
    }
}
