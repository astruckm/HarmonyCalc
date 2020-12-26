//
//  ScaleTypes.swift
//  HarmonyCalc
//
//  Created by ASM on 9/24/19.
//  Copyright © 2019 ASM. All rights reserved.
//

import Foundation

public enum ScaleName: String {
    case major, naturalMinor, harmonicMinor, melodicMinor
    
    var orderedIntervalsFromRoot: [Interval] {
        let icrIntervals = Interval.ValidIntervalsWithinIntervalClassRange()
        let minSecond = icrIntervals.minorSecond
        let majSecond = icrIntervals.majorSecond
        let augSecond = icrIntervals.augmentedSecond
        
        switch self {
        case .major:
            return [majSecond, majSecond, minSecond, majSecond, majSecond, majSecond]
        case .naturalMinor:
            return [majSecond, minSecond, majSecond, majSecond, minSecond, majSecond]
        case .harmonicMinor:
            return [majSecond, minSecond, majSecond, majSecond, minSecond, augSecond]
        case .melodicMinor:
            return [majSecond, minSecond, majSecond, majSecond, majSecond, majSecond]
        }
    }
    
}

public struct Scale {
    let notes: [Note]
    let tonic: Note
    let name: ScaleName
    
//    var possibleTriads: [TonalChord] {}
    
    init(tonic: Note, name: ScaleName) {
        self.tonic = tonic
        self.name = name
        var notes: [Note] = [tonic]
        for interval in name.orderedIntervalsFromRoot {
            //TODO: function to convert one Note and Interval to another Note
        }
        
        self.notes = notes
    }
    
    //TODO: init? from just notes, init from tonic and name
}
