//
//  ScaleTypes.swift
//  HarmonyCalc
//
//  Created by ASM on 9/24/19.
//  Copyright © 2019 ASM. All rights reserved.
//

import Foundation

//TODO: all scale types, derived from chord types
public enum ScaleName: String {
    case major, naturalMinor, harmonicMinor, melodicMinor
}

public struct Scale {
    let notes: [Note]
    let tonic: Note
    let name: ScaleName
    
    //TODO:
    //TODO: init
}
