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
        
    }
    
    func speak(text: String) -> Void {
        // Create an utterance.
        let utterance = AVSpeechUtterance(string: text)

        // Configure the utterance.
        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8
        
        // Assign the voice to the utterance.
        utterance.voice = voice
        
        // Tell the synthesizer to speak the utterance.
        synthesizer.speak(utterance)
    }
}
