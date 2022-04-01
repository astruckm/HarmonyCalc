//
//  Array+Extensions.swift
//  HarmonyCalc
//
//  Created by Andrew Struck-Marcell on 2/18/22.
//  Copyright © 2022 ASM. All rights reserved.
//

import Foundation

extension Array {
    /// Get the next element in an array as if it were a circular array.
    /// - Parameter currentIdx: The index from which to get the next one.
    /// - Returns: The index after the current index, or 0 if the current index is the last element.
    func next(after currentIdx: Int) -> Int {
        if (currentIdx + 1) < endIndex {
            return index(after: currentIdx)
        } else {
            return 0
        }
    }
    
    /// Get the previous element in an array as if it were a circular array.
    /// - Parameter currentIdx: The index from which to get the previous one.
    /// - Returns: The index before the current index, or 0 if the current index is the last element.
    func prev(before currentIdx: Int) -> Int {
        if currentIdx == 0 {
            return index(before: endIndex)
        } else {
            return index(before: currentIdx)
        }
    }
}
