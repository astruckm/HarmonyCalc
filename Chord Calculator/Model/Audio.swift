//
//  AudioEngine.swift
//  MusicWeb
//
//  Created by ASM on 5/14/18.
//  Copyright © 2018 ASM. All rights reserved.


import Foundation
import AVFoundation

class Audio: NSObject, AVAudioPlayerDelegate {
    static let sharedInstance = Audio()
    
    var players = [URL: AVAudioPlayer]()
    var duplicatePlayers = [AVAudioPlayer]()
    
    func loadSound(at url: URL) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            players[url] = player
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    //Audio player
    func playSound(soundFileName: String) {
        if let url = urlLookUp(of: soundFileName) {
            if let player = players[url] {
                    let duplicatePlayer = try! AVAudioPlayer(contentsOf: url)
                    duplicatePlayer.delegate = self
                    duplicatePlayers.append(duplicatePlayer)
                    player.prepareToPlay()
                    player.play()
                    print("added to duplicate player")
            } else {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    players[url] = player
                    player.prepareToPlay()
                    player.play()
                } catch let error as NSError {
                    print(error.description)
                }
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
    
    func playSoundNotification(notification: NSNotification) {
        if let soundFileName = notification.userInfo?["fileName"] as? String {
            playSound(soundFileName: soundFileName)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        duplicatePlayers.remove(at: duplicatePlayers.index(of: player)!)
    }
    
    //Helper function
    func urlLookUp(of soundFileName: String) -> URL? {
        if let url = Bundle.main.url(forResource: soundFileName, withExtension: "m4a") {
            return url
        } else { return nil }
    }


}
