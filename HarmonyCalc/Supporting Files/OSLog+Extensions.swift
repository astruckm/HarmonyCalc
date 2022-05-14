//
//  OSLog+Extensions.swift
//  HarmonyCalc
//
//  Created by Andrew Struck-Marcell on 5/9/22.
//  Copyright © 2022 ASM. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.POTO.HarmonyCalc"
    static let audioPlayback = OSLog(subsystem: subsystem, category: "audioPlayback")
}
