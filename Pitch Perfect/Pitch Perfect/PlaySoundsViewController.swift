//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Kirkland Poole on 5/27/15.
//  Copyright (c) 2015 Kirkland Poole. All rights reserved.
//
// Reference: http://rshankar.com/how-to-record-and-play-sound-in-swift/
// Reference: http://stackoverflow.com/questions/25333140/swift-using-sound-effects-with-audioengine
// Reference: https://developer.apple.com/library/tvos/documentation/AVFoundation/Reference/AVAudioUnitReverb_Class/#//apple_ref/occ/instp/AVAudioUnitReverb/wetDryMix
// Reference: https://developer.apple.com/library/prerelease/ios/documentation/AVFoundation/Reference/AVAudioUnitReverb_Class/index.html
// Reference: https://developer.apple.com/videos/play/wwdc2014-502/
// Reference: https://www.udacity.com/course/viewer#!/c-ud585/l-3314308908/m-3335198807
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    // MARK: Outlets
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var stopPlayBackLabel: UILabel!
    
    // MARK: Global variables for Audio Playaer and Audio Player Node
    var receivedAudio:RecordedAudio!  // audio object passed into view controller
    var audioEngine: AVAudioEngine! // audio engine
    var audioPlayer:AVAudioPlayer!  // main audio player
    var audioFile: AVAudioFile!      // audio file
    var audioPlayerNode: AVAudioPlayerNode! // audio Player not for setting pitch effects
    
    
    // MARK: Constants for FX settings
    let slowPlayRate: Float = 0.5
    let fastPlayRate: Float = 1.5
    let turtlePitch: Float = 1300
    let chipmunkPitch: Float = 1000
    let darthVadorPitch: Float = -500
    let rabbitPitch: Float = -800
    let echoRate: Float = 0.4
    let reverbRate: Float = 80.0
    let noEffectRate: Float = 0
    let normalPitch: Float = 1.0
    let halfPitchRate: Float = 0.5
    let normalPitchRate: Float = 1.0
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        enableStopPlaybackButton(false)
        // Get the audio file created during sound recording
        audioFile = try? AVAudioFile(forReading: receivedAudio.filePathUrl)
    }
    
    
    // MARK: Play sound after configuring audio components
    private func configureAndPlayAudio(pitch : Float, rate: Float, echoSetting: Float, reverbSetting: Float) {
        // Setup Audio engine, audio player and attach player to engine
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine = AVAudioEngine()
        audioEngine.attachNode(audioPlayerNode)
        // Setup playback rate
        let playbackRate = AVAudioUnitVarispeed()
        playbackRate.rate = rate
        audioEngine.attachNode(playbackRate)
        // Set up pitch effect
        let effectForPitch = AVAudioUnitTimePitch()
        effectForPitch.pitch = pitch
        audioEngine.attachNode(effectForPitch)
        // Setting the echo effect on a specific interval
        let echoEffect = AVAudioUnitDelay()
        echoEffect.delayTime = NSTimeInterval(echoSetting)
        audioEngine.attachNode(echoEffect)
        // Setting the reverb effect (use Large Hall 2 factory preset)
        let reverbEffect = AVAudioUnitReverb()
        reverbEffect.loadFactoryPreset(AVAudioUnitReverbPreset.LargeHall2)
        reverbEffect.wetDryMix = reverbSetting
        audioEngine.attachNode(reverbEffect)
        // Make all of the connects
        audioEngine.connect(audioPlayerNode, to: playbackRate, format: nil)
        audioEngine.connect(playbackRate, to: effectForPitch, format: nil)
        audioEngine.connect(effectForPitch, to: reverbEffect, format: nil)
        audioEngine.connect(reverbEffect, to: echoEffect, format: nil)
        audioEngine.connect(echoEffect, to: audioEngine.outputNode, format: nil)
        // enable Stop Button
        enableStopPlaybackButton(true)
        // Stop audio player in case it is currently playing
        audioPlayerNode.stop()
        // Play Audio File at current time
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        do {
            try audioEngine.start()
            audioPlayerNode.play()
        } catch _ {
            print("Error starting audio engine")
        }
    }
      
    // MARK: Configure Stop Button
    func configureStopButton(stopButtonHidden: Bool, stopButtonEnabled: Bool, stopPlayBackLabelHidden: Bool,  stopPlayBackLabelText: String) {
       // Set stopButton and StopPayBackLabel states
        stopButton.hidden = stopButtonHidden
        stopButton.enabled = stopButtonEnabled
        stopPlayBackLabel.hidden = stopPlayBackLabelHidden
        stopPlayBackLabel.text = stopPlayBackLabelText
    }
    
    // MARK: Toggle hidden/unhidden Stop Button and Stop Button label
    func enableStopPlaybackButton(enabled: Bool) {
        if (enabled) { // enabled
            configureStopButton(false, stopButtonEnabled: true, stopPlayBackLabelHidden: false,  stopPlayBackLabelText: "Press To Stop Playback")
        } else { // disabled
            configureStopButton(true, stopButtonEnabled: false, stopPlayBackLabelHidden: true,  stopPlayBackLabelText: "")
        }
    }
    
    
    
    
    // MARK: Playback like turtle (slow)
    @IBAction func playSlowRateAudio(sender: UIButton) {
        configureAndPlayAudio(turtlePitch, rate: halfPitchRate, echoSetting: noEffectRate, reverbSetting: noEffectRate)
    }
    
    
    // MARK: Playback like rabbit (fast)
    @IBAction func playFastRateAudio(sender: UIButton) {
        configureAndPlayAudio(rabbitPitch, rate: fastPlayRate, echoSetting: noEffectRate, reverbSetting: noEffectRate)
    }
    
    // MARK: Chipmunk Effect
    @IBAction func playChipmunkAudo(sender: UIButton) {
        configureAndPlayAudio(chipmunkPitch, rate: normalPitchRate, echoSetting: noEffectRate, reverbSetting: noEffectRate)
    }
    
    
    // MARK: Darth Vader Effect
    @IBAction func playDarthvaderAudio(sender: UIButton) {
        configureAndPlayAudio(darthVadorPitch, rate: normalPitchRate, echoSetting: noEffectRate, reverbSetting: noEffectRate)
    }
    
    // MARK: Playback sound with echo audio effect
    @IBAction func playEchoAudio(sender: UIButton) {
        configureAndPlayAudio(normalPitch, rate: normalPitchRate, echoSetting: echoRate, reverbSetting: noEffectRate)
    }
    
    // MARK: Playback sound with Reverb audio effect
    @IBAction func playReverbAudio(sender: UIButton) {
        configureAndPlayAudio(normalPitch, rate: normalPitchRate, echoSetting: noEffectRate, reverbSetting: reverbRate)
    }
    
    // MARK: Stop AudioPlayer and AudioEngine
    func stopAudio() {
        // Stops audio playback and audio player node level
        audioPlayerNode.stop()
    }
    
    
    // MARK: Handle Stop Button Pressed Event
    @IBAction func stopButtonPressed(sender: UIButton) {
        stopAudio()
        enableStopPlaybackButton(false)
    }

  }

