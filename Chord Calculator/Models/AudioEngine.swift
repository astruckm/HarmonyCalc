//
//  AudioEngine.swift
//  MusicWeb
//
//  Created by ASM on 4/24/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation
import AudioKit

class AudioEngine {
    var oscillator: AKOscillator
    var envelope: AKAmplitudeEnvelope
    
    let sampler = AKSampler()
    
    init() {
        AKAudioFile.cleanTempDirectory()
        AKSettings.playbackWhileMuted = true
        
        oscillator = AKOscillator()
        oscillator.amplitude = random(in: 0.5...1.0)
        envelope = AKAmplitudeEnvelope(oscillator, attackDuration: 0.1, decayDuration: 0.1, sustainLevel: 0.1, releaseDuration: 0.3)
        
        sampler.ampReleaseTime = 0.8
        
        AudioKit.output = envelope
        do {
            try AudioKit.start()
        } catch {
            print("error starting audio engine")
        }
    }
    
    func playOscillator(withKey keyValue: Int) {
        if oscillator.isPlaying {
            oscillator.stop()
        } else {
            let semitoneRatio: Double = pow(2, (1/12))
            oscillator.frequency = 261.63 * pow(semitoneRatio, Double(keyValue))
            oscillator.start()
        }
    }
    
    
}
