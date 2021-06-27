//
//  PlayerManager.swift
//  Venus WatchKit Extension
//
//  Created by 邵业程 on 2021/6/27.
//

import Foundation
import AVFoundation

let DefaultPlayerManager = PlayerManager.default

class PlayerManager: NSObject, ObservableObject {
    static let `default` = PlayerManager()
    
    // Create a speech synthesizer.
    let synthesizer = AVSpeechSynthesizer()
    
    // Retrieve the British English voice.
    let voice = AVSpeechSynthesisVoice(language: "zh-CN")

    
    override init() {
        super.init()
        
        self.setupSession()
    }
    
    func setupSession() -> Void {
        // Set up the session.
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(AVAudioSession.Category.playback,
                                    mode: .voicePrompt,
                                    policy: AVAudioSession.RouteSharingPolicy.longFormAudio,
                                    options: [])
        } catch let error {
            print("*** Unable to set up the audio session: \(error.localizedDescription) ***")
        }
        
        // Activate and request the route.
        session.activate(options: []) { (success, error) in
            guard error == nil else {
                print("*** An error occurred: \(error!.localizedDescription) ***")
                // Handle the error here.
                return
            }
            
            // Play the audio file.
        }
    }
    
    func speak(text: String) -> Void {
        // Create an utterance.
        let utterance = AVSpeechUtterance(string: text)

        // Configure the utterance.
        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 1.0
        
        // Assign the voice to the utterance.
        utterance.voice = voice
        
        // Tell the synthesizer to speak the utterance.
        synthesizer.speak(utterance)
    }
}
