//
//  Array+Extensions.swift
//  HarmonyCalc
//
//  Created by Andrew Struck-Marcell on 2/18/22.
//  Copyright © 2022 ASM. All rights reserved.
//

import Foundation

extension Array {
    func next(after currentIdx: Int) -> Int {
        if (currentIdx + 1) < endIndex {
            return index(after: currentIdx)
        } else {
            return 0
        }
    }
    
    func prev(before currentIdx: Int) -> Int {
        if currentIdx == 0 {
            return index(before: endIndex)
        } else {
            return index(before: currentIdx)
        }
    }
}
