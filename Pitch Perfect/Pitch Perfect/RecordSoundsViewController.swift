//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Kirkland Poole on 5/26/15.
//  Copyright (c) 2015 Kirkland Poole. All rights reserved.
//
// Reference: http://rshankar.com/how-to-record-and-play-sound-in-swift/
// Reference: http://stackoverflow.com/questions/24318791/avaudiosession-swift

import UIKit
import AVFoundation


class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var stopButtonLabel: UILabel!
    
    
    // MARK: Global variables
    var audioRecorder:AVAudioRecorder!  // Audio recorder object
    var recordedAudio:RecordedAudio!    // Recorded audio object
    var session = AVAudioSession.sharedInstance() // audio session
    var soundFileURL:NSURL?             // URL to sound file
    var currentlyRecording:Bool = false // Are we currently recording
  
    
    // MARK: View lifecycle
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI ("Ready To Record",
            recordingInProgressText: "Ready To Record",
            titleText: "Ready To Record",
            recordButtonEnabled: true,
            stopButtonHidden: true,
            stopButtonEnabled: false,
            stopButtonLabelHidden: true,
            stopButtonLabelText: "Tap To Stop Recording",
            recordingInProgressHidden: false)
        
        currentlyRecording = false // not recording
        
        setSessionPlayback()
    }
    
    
    // View Will Appear
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        currentlyRecording = false // not recording
        audioRecorder = nil
    }
    
    // MARK: Configure the UI
    func configureUI(currentStateText: String, recordingInProgressText: String, titleText: String, recordButtonEnabled: Bool, stopButtonHidden: Bool, stopButtonEnabled: Bool,stopButtonLabelHidden: Bool, stopButtonLabelText: String, recordingInProgressHidden: Bool) {
        //print("configureUI currentState =  \(currentStateText).... currentlyRecording = \(currentlyRecording)")
        recordingInProgress.text = recordingInProgressText
        recordingInProgress.hidden = recordingInProgressHidden
        self.title = titleText
        recordButton.enabled = recordButtonEnabled
        stopButton.hidden = stopButtonHidden
        stopButton.enabled = stopButtonEnabled
        stopButtonLabel.hidden = stopButtonLabelHidden
        stopButtonLabel.text = stopButtonLabelText
    }
    
    // MARK: Handle Button Pressed to Record Audio or to Pause recording
    @IBAction func recordAudio(sender: UIButton) {
        if audioRecorder == nil {
            //Nothing recorded
            configureUI ("Press to pause",
                recordingInProgressText: "Press to pause",
                titleText: "Recording",
                recordButtonEnabled: true,
                stopButtonHidden: false,
                stopButtonEnabled: true,
                stopButtonLabelHidden: false,
                stopButtonLabelText: "Tap To Stop Recording",
                recordingInProgressHidden: false)
            recordWithPermission(true)
            return
        } else {
            if (currentlyRecording) {
                // Request To Resume Recording
                configureUI ("Resume Recording",
                    recordingInProgressText: "Press to pause",
                    titleText: "Recording",
                    recordButtonEnabled: true,
                    stopButtonHidden: false,
                    stopButtonEnabled: true,
                    stopButtonLabelHidden: false,
                    stopButtonLabelText: "Tap To Stop Recording",
                    recordingInProgressHidden: false)
            recordWithPermission(false)
            } else {
                // Request To Pause Recording
                configureUI ("Paused",
                    recordingInProgressText: "Tap To Resume Recording",
                    titleText: "Recording Paused",
                    recordButtonEnabled: true,
                    stopButtonHidden: true,
                    stopButtonEnabled: false,
                    stopButtonLabelHidden: true,
                    stopButtonLabelText: "",
                    recordingInProgressHidden: false)
                recordWithPermission(false)
            }
        }
    }
    
    
    // MARK: Handle Button Pressed to Stop recording audio
    @IBAction func stopRecording(sender: UIButton) {
        //Stoping
        audioRecorder?.stop()
        currentlyRecording = false // not recording
        configureUI ("Ready To Record",
            recordingInProgressText: "Tap To Record",
            titleText: "Ready To Record",
            recordButtonEnabled: true,
            stopButtonHidden: true,
            stopButtonEnabled: false,
            stopButtonLabelHidden: true,
            stopButtonLabelText: "Tap To Stop Recording",
            recordingInProgressHidden: false)
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        do {
            try session.setActive(false)
        } catch let error1 as NSError {
            error = error1
            print("Error: Could not make session inactive")
            if let sessionError = error {
                print(sessionError.localizedDescription)
                return
            }
        }
        
    }
    
    
    // MARK: Setup For Recording Audio
    func setupRecorder() {
        // Create file for holding sound using system date and time
        let format = NSDateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let currentFileName = "PitchPerfect-\(format.stringFromDate(NSDate())).m4a"
        var error: NSError?
        var dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir: AnyObject = dirPaths[0]
        let soundFilePath = docsDir.stringByAppendingPathComponent(currentFileName)
        soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        
        // Check if sound file already exists
        let filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(soundFilePath) {
            // probably won't happen. want to do something about it?
            print("sound file already exists")
        }
        // Recording settings
        let recordSettings = [AVSampleRateKey : NSNumber(float: Float(44100.0)),
            AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),
            AVNumberOfChannelsKey : NSNumber(int: 1),
            AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))]
        
        do {
            audioRecorder = try AVAudioRecorder(URL: soundFileURL!, settings: recordSettings)
        } catch let error1 as NSError {
            error = error1
            audioRecorder = nil
        }
        if let e = error {
            print(e.localizedDescription)
        } else {
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            
            //Calling audioRecorder.prepareToRecord()...")
            audioRecorder.prepareToRecord() // creates/overwrites the file at soundFileURL
            if filemanager.fileExistsAtPath(soundFilePath) {
                //sound file now exists
            } else {
                print("Error: Sound file STILL does not exist!!!!!!")
            }
        }
    }
    
    
    // MARK: Get Permission For Recording Audio
    // Request Permission To Use Recording Object
    func recordWithPermission(setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.respondsToSelector("requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    //Permission to record granted
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    if (!self.currentlyRecording) {
                        self.audioRecorder.record()
                        self.currentlyRecording = true // recording
                    } else {
                        self.audioRecorder.pause()
                        self.currentlyRecording = false // paused
                    }
                } else {
                    print("Permission to record not granted")
                }
            })
        } else {
            print("requestRecordPermission unrecognized")
        }
    }
    
    // MARK: Set audio session
    func setSessionPlayback() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error1 as NSError {
            error = error1
            print("Error: Could not set session category")
            if let sessionError = error {
                print(sessionError.localizedDescription)
            }
        }
        do {
            try session.setActive(true)
        } catch let error1 as NSError {
            error = error1
            print("Error: Could not make session active")
            if let sessionError = error {
                print(sessionError.localizedDescription)
            }
        }
    }
    
    // MARK: Set Session for Record and playback
    func setSessionPlayAndRecord() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error1 as NSError {
            error = error1
            print("Error: Could not set session category")
            if let sessionError = error {
                print(sessionError.localizedDescription)
            }
        }
        do {
            try session.setActive(true)
        } catch let error1 as NSError {
            error = error1
            print("Error: Could not make session active")
            if let sessionError = error {
                print(sessionError.localizedDescription)
            }
        }
    }
    
    
    // MARK: Prepare Segue for View Controller to play recorded sound
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecordingSegue") {
            configureUI ("Ready To Record",
                recordingInProgressText: "Tap To Record",
                titleText: "Ready To Record",
                recordButtonEnabled: true,
                stopButtonHidden: true,
                stopButtonEnabled: false,
                stopButtonLabelHidden: true,
                stopButtonLabelText: "Tap To Stop Recording",
                recordingInProgressHidden: false)
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    
    // MARK: AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        recordingInProgress.text = "Tap To Record"
        if (flag) {
            currentlyRecording = false
            recordedAudio = RecordedAudio(filePathUrl:recorder.url, title:recorder.url.lastPathComponent)
            if (recordedAudio != nil) {
                self.performSegueWithIdentifier("stopRecordingSegue", sender:recordedAudio)
            } else {
                print("RecordSoundsViewController: audioRecorderDidFinishRecording: recordedAudio == nil!!!!!!")
            }
        } else {
            print("Recording was not sucessful")
            configureUI ("Ready To Record",
                recordingInProgressText: "Tap To Record",
                titleText: "Ready To Record",
                recordButtonEnabled: true,
                stopButtonHidden: true,
                stopButtonEnabled: false,
                stopButtonLabelHidden: true,
                stopButtonLabelText: "Tap To Stop Recording",
                recordingInProgressHidden: false)
        }
    }
    
    
     // MARK: Audio Recorder End Interruption
    func audioRecorderEndInterruption(recorder: AVAudioRecorder, withOptions flags: Int) {
        if (flags == AVAudioSessionInterruptionFlags_ShouldResume) {
            recorder.record()
            currentlyRecording = true
        }
    }
}

