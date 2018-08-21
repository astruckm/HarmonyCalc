//
//  UserDefaults.swift
//  HarmonyCalc
//
//  Created by ASM on 8/20/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation

final class Defaults {
    let userDefaults = UserDefaults.standard
    let audioIsOn = "audioIsOn"
    let collectionUsesSharps = "collectionUsesSharps"
    
    func writeAudioSetting(_ isOn: Bool) {
        userDefaults.set(isOn, forKey: audioIsOn)
    }
        
    func writeCollectionUsesSharps(_ usesSharps: Bool) {
        userDefaults.set(usesSharps, forKey: collectionUsesSharps)
    }

}
