//
//  DefinitionsViewController.swift
//  HarmonyCalc
//
//  Created by ASM on 5/16/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import UIKit

class DefinitionsViewController: UIViewController {
    @IBOutlet weak private(set) var definition: UITextView!
    
    let definitions: [String: String] = [
        "Chord": """
        Maj = Major
        min = Minor
        o   = Diminished
        +   = Augmented
        ø⁷  = Half diminished seventh
        Sus = Suspension
        """,
        "Inversion": "Whether the chord is in root position or is an inversion of the chord. Determined by the lowest (bass) note.",
        "Normal Form": """
        Normal form is the most compact ordering of the notes in a chord (or "collection," in music set theory).
        0 = C, 1 = C♯/D♭, 2 = D, 3 = D♯/E♭, 4 = E, 5 = F, 6 = F♯/G♭, 7 = G, 8 = G♯/A♭, 9 = A, t(10) = A♯/B♭, e(11) = B
        """,
        "Prime Form": "Prime form takes the collection's normal form, then transposes it so its first note is 0 and compares it against its inversion to find the most compact version. This classifies the collection in a more general form by its intervals. HarmonyCalc uses the Forte version of prime form."
    ]
    
    var chordType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definition.isEditable = false
        if presentingViewController?.traitCollection.verticalSizeClass == .regular && presentingViewController?.traitCollection.horizontalSizeClass == .regular && definition.font != nil {
            definition.font = UIFont(name: (definition.font?.fontName)!, size: 40)
        }
        
        if let chordType = chordType, let definitionsText = definitions[chordType] {
            definition.text = definitionsText
        }
    }
}
