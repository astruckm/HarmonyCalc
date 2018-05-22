////
////  AudioEngine.swift
////  MusicWeb
////
////  Created by ASM on 4/24/18.
////  Copyright © 2018 ASM. All rights reserved.
////
//// Using the solution from AudioKit's 'ROMPlayer' open source code (DX7 app)
////
//
//import Foundation
//import AudioKit
//
//class AudioKit {
//    var oscillator: AKOscillator
//    var envelope: AKAmplitudeEnvelope
//    
//    let sampler = AKSampler()
//    let midi = AKMIDI()
//    
//    init() {
//        AKAudioFile.cleanTempDirectory()
//        AKSettings.playbackWhileMuted = true
//        
//        oscillator = AKOscillator()
//        oscillator.amplitude = random(in: 0.5...1.0)
//        envelope = AKAmplitudeEnvelope(oscillator, attackDuration: 0.1, decayDuration: 0.1, sustainLevel: 0.1, releaseDuration: 0.3)
//        
//        midi.createVirtualPorts()
//        midi.openInput()
//        midi.openOutput()
//        
//        sampler.ampReleaseTime = 0.8
//        
////        let sampleDescriptor = generateSampleDescripter()
////        let audioFile = loadAudioFile()
////        sampler.loadAKAudioFile(sd: sampleDescriptor, file: audioFile)
////        print(audioFile)
//        
//        AudioKit.output = envelope
//        do {
//            try AudioKit.start()
//        } catch {
//            print("error starting audio engine")
//        }
//    }
//    
//    func playOscillator(withKey keyValue: Int) {
//        if oscillator.isPlaying {
//            oscillator.stop()
//        } else {
//            let semitoneRatio: Double = pow(2, (1/12))
//            oscillator.frequency = 261.63 * pow(semitoneRatio, Double(keyValue))
//            oscillator.start()
//        }
//    }
//    
//    
//    func addMidiListener(listener: AKMIDIListener) {
//        midi.addListener(listener)
//    }
//    
//    func playNote(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
//        sampler.play(noteNumber: note, velocity: velocity)
//        sleep(1)
//    }
//    
//    func stopNote(note: MIDINoteNumber, channel: MIDIChannel) {
//        sampler.stop(noteNumber: note)
//    }
//
//    
//    
//    private func generateSampleDescripter() -> AKSampleDescriptor {
//        let descriptor = AKSampleDescriptor(noteNumber: 60, noteHz: 261.63, min_note: 0, max_note: 127, min_vel: 0, max_vel: 127, bLoop: true, fLoopStart: 0.0, fLoopEnd: 1.0, fStart: 0, fEnd: 0)
//        return descriptor
//    }
//    
//    private func loadAudioFile() -> AKAudioFile {
//        let soundsFolder = Bundle.main.bundleURL.appendingPathComponent("Supporting Files/Sounds/Samples/C4.wav")
//        sampler.unloadAllSamples()
//
//        let file = try! AKAudioFile(forReading: soundsFolder)
//        return file
//    }
//    
//    
//}
