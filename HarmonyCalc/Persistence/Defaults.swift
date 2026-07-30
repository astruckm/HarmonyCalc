//
//  UserDefaults.swift
//  HarmonyCalc
//
//  Created by ASM on 8/20/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation

protocol UserDefaultsProtocol: AnyObject {
    func bool(forKey defaultName: String) -> Bool
    func set(_ value: Bool, forKey defaultName: String)
}

extension UserDefaults: UserDefaultsProtocol { }

final class Defaults {
    private(set) var userDefaults: UserDefaultsProtocol
    let audioIsOn = "audioIsOn"
    let collectionUsesSharps = "collectionUsesSharps"

    init(defaultsObj: UserDefaultsProtocol = UserDefaults.standard) {
        self.userDefaults = defaultsObj
    }

    func readAudioSetting() -> Bool {
        return userDefaults.bool(forKey: audioIsOn)
    }

    func writeAudioSetting(_ isOn: Bool) {
        userDefaults.set(isOn, forKey: audioIsOn)
    }

    func readCollectionUsesSharps() -> Bool {
        return userDefaults.bool(forKey: collectionUsesSharps)
    }
        
    func writeCollectionUsesSharps(_ usesSharps: Bool) {
        userDefaults.set(usesSharps, forKey: collectionUsesSharps)
    }

}
