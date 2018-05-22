//
//  DefinitionsViewController.swift
//  MusicWeb
//
//  Created by ASM on 5/16/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import UIKit

class DefinitionsViewController: UIViewController {
    @IBOutlet weak var definition: UITextView!
    
    let definitions: [String: String] = [
        "Chord": """
        A standard chord in tonal harmony.
        
        Maj = Major
        min = Minor
        o   = Diminished
        +   = Augmented
        ø⁷  = Half diminished seventh
        Sus = Suspension
        """,
        "Inversion": "The inversion of the chord. Determined by the lowest (bass) note.",
        "Normal Form": """
        Normal form is the most compact ordering of the notes in a chord (or "collection," in music set theory).
        
        0 = C
        1 = C♯/D♭
        2 = D
        3 = D♯/E♭
        4 = E
        5 = F
        6 = F♯/G♭
        7 = G
        8 = G♯/A♭
        9 = A
        t = A♯/B♭
        e = B
        """,
        "Prime Form": "Prime form takes the collection's normal form, then transposes it so its first note is 0 and compares it against its inversion to find the most compact version. This classifies the collection in a more general form by its constituent intervals. Chord Calculator uses the Forte version of prime form."
    ]
    
    var chordType: String?
    var contentHeight: CGFloat? //TODO: figure out how to get this
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definition.isEditable = false
        
        if let chordType = chordType, let definitionsText = definitions[chordType] {
            definition.text = definitionsText
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentHeight = definition.bounds.height
        print("viewDidAppear height: \(String(describing: contentHeight))")
    }
    
    //TODO: Dismiss button?
}
