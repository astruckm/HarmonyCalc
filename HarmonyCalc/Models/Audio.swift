//
//  AudioEngine.swift
//  HarmonyCalc
//
//  Created by ASM on 5/14/18.
//  Copyright © 2018 ASM. All rights reserved.

import Foundation
import AVFoundation


class Audio: NSObject {
    static let sharedInstance = Audio()
    
    var players = [URL: AVAudioPlayer]()
    var numPlayersPlaying = 0
    
    private override init() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
        } catch let error {
            print("error setting audio session category: \(error.localizedDescription)")
        }
        
        do {
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch let error {
            print("error activating audio session: \(error.localizedDescription)")
        }
    }
        
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
        guard let firstPlayer = players.first?.value else { return }
        for player in players.values {
            if player.isPlaying {
                player.stop()
                player.currentTime = 0
                player.prepareToPlay()
            }
        }
        let timeToPlay = firstPlayer.deviceCurrentTime + 0.05
        for player in players.values {
            numPlayersPlaying += 1
            player.play(atTime: timeToPlay)
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
