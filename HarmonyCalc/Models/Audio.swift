//
//  AudioEngine.swift
//  HarmonyCalc
//
//  Created by ASM on 5/14/18.
//  Copyright © 2018 ASM. All rights reserved.

import Foundation
import AVFoundation
import os.log

/// Uses a singleton instance for sound playback
class Audio: NSObject {
    static let sharedInstance = Audio()
    
    var players = [URL: AVAudioPlayer]()
    var numPlayersPlaying = 0
    
    private override init() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
        } catch {
            os_log("Error setting audio session category: %{public}@", log: OSLog.audioPlayback, type: .error, error.localizedDescription)
        }
        
        do {
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            os_log("Error activating audio session: %{public}@", log: OSLog.audioPlayback, type: .error, error.localizedDescription)
        }
    }
        
    /// Load sound file into AVAudioPlayer object and add it to store of players
    /// - Parameter url: Path of the audio file
    func loadSound(at url: URL) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[url] = player
        } catch {
            os_log("Error initializing audio player from url: : %{public}@", log: OSLog.audioPlayback, type: .error, error.localizedDescription)
        }
        
    }
    
    /// Use to remove the audio player if colored key is re-tapped
    /// - Parameter url: Path of the
    func removeSound(at url: URL) {
        if let player = players[url] {
            player.stop()
            player.currentTime = 0
        }
        players.removeValue(forKey: url)
    }
    
    /// Play a single audio file, creating an AVAudioPlayer to do so
    /// - Parameter soundFileName: The audio filename
    func playSound(soundFileName: String) {
        if let url = urlLookUp(of: soundFileName) {
            do {    
                let player = try AVAudioPlayer(contentsOf: url)
                players[url] = player
                player.delegate = self
                player.prepareToPlay()
                player.play()
                numPlayersPlaying += 1
            } catch {
                os_log("Could not initialize audio player with url %{public}@", log: OSLog.audioPlayback, type: .error, url.absoluteString)
            }
        } else {
            os_log("Couldn't load audio file, no sound file with name %{public}@ in app bundle", log: OSLog.audioPlayback, type: .error, soundFileName)
        }
    }
    
    /// Play multiple sounds at the same time
    /// - Parameter soundFileNames: <#soundFileNames description#>
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
        return Bundle.main.url(forResource: soundFileName, withExtension: "m4a")
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
