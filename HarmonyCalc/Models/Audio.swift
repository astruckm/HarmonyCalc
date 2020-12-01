//
//  AudioEngine.swift
//  Chord Calculator
//
//  Created by ASM on 5/14/18.
//  Copyright © 2018 ASM. All rights reserved.

import Foundation
import AVFoundation


class Audio: NSObject {
    static let sharedInstance = Audio()
    
    var players = [URL: AVAudioPlayer]()
    var numPlayersPlaying = 0
    
    private override init() { }
    
    //Load sound files if audio is not on
    func loadSound(at url: URL) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[url] = player
        } catch let error as NSError {
            print(error.description)
        }
        
    }
    
    //Remove sound file if colored key is re-tapped
    func removeSound(at url: URL) {
        players.removeValue(forKey: url)
        if let player = players[url] {
            player.stop()
            player.currentTime = 0
        }
    }
    
    //Audio player
    func playSound(soundFileName: String) {
        if let url = urlLookUp(of: soundFileName) {
            do {    
                let player = try AVAudioPlayer(contentsOf: url)
//                let data = try Data(contentsOf: url)
//                let player = try AVAudioPlayer(data: data)
                players[url] = player
                player.delegate = self
                player.prepareToPlay()
                player.play()
                numPlayersPlaying += 1
            } catch let error as NSError {
                print(error.description)
            }
        } else {
            print("Couldn't load audio file")
        }
    }
    
    func playSounds(soundFileNames: [String]) {
        if numPlayersPlaying != 0 {
            for player in players.values {
                if player.isPlaying {
                    player.stop()
                    player.currentTime = 0
                    player.prepareToPlay()
                }
            }
        }
        for player in players.values {
            numPlayersPlaying += 1
            player.play()
        }
    }
    
    func urlLookUp(of soundFileName: String) -> URL? {
        if let url = Bundle.main.url(forResource: soundFileName, withExtension: "m4a") {
            return url
        } else { return nil }
    }


}

extension Audio: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            numPlayersPlaying -= 1
            player.prepareToPlay()
        }
    }
}
