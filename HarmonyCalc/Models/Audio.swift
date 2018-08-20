//
//  AudioEngine.swift
//  Chord Calculator
//
//  Created by ASM on 5/14/18.
//  Copyright © 2018 ASM. All rights reserved.

import Foundation
import AVFoundation

//TODO: Implement sampler using AudioKit

class Audio: NSObject, AVAudioPlayerDelegate {
    static let sharedInstance = Audio()
    
    var players = [URL: AVAudioPlayer]()
    
    //Load sound files if audio is not on
    func loadSound(at url: URL) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            players[url] = player
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    //Remove sound file if colored key is re-tapped
    func removeSound(at url: URL) {
        players.removeValue(forKey: url)
    }
    
    //Audio player
    func playSound(soundFileName: String) {
        if let url = urlLookUp(of: soundFileName) {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                players[url] = player
                player.delegate = self
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        } else {
            print("Couldn't load audio file")
        }
    }
    
    func playSounds(soundFileNames: [String]) {
        for player in players.values {
            player.stop()
            player.prepareToPlay()
        }
        for player in players.values {
            player.play()
        }
    }
    
    func urlLookUp(of soundFileName: String) -> URL? {
        if let url = Bundle.main.url(forResource: soundFileName, withExtension: "m4a") {
            return url
        } else { return nil }
    }


}
