//
//  DefinitionsViewController.swift
//  HarmonyCalc
//
//  Created by ASM on 5/16/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import UIKit

class DefinitionsViewController: UIViewController {
    enum Topic: String, CaseIterable {
        case chord = "Chord"
        case inversion = "Inversion"
        case normalForm = "Normal Form"
        case primeForm = "Prime Form"

        var text: String {
            switch self {
            case .chord:
                return """
                Maj = Major
                min = Minor
                o   = Diminished
                +   = Augmented
                ø⁷  = Half diminished seventh
                Sus = Suspension
                """
            case .inversion:
                return "Whether the chord is in root position or is an inversion of the chord. Determined by the lowest (bass) note."
            case .normalForm:
                return """
                Normal form is the most compact ordering of the notes in a chord (or "collection," in music set theory).
                0 = C, 1 = C♯/D♭, 2 = D, 3 = D♯/E♭, 4 = E, 5 = F, 6 = F♯/G♭, 7 = G, 8 = G♯/A♭, 9 = A, t(10) = A♯/B♭, e(11) = B
                """
            case .primeForm:
                return "Prime form takes the collection's normal form, then transposes it so its first note is 0 and compares it against its inversion to find the most compact version. This classifies the collection in a more general form by its intervals. HarmonyCalc uses the Forte version of prime form."
            }
        }
    }

    private(set) lazy var definition: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = .white
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    var topic: Topic?

    override func loadView() {
        let rootView = UIView()
        rootView.backgroundColor = .white
        rootView.addSubview(definition)

        NSLayoutConstraint.activate([
            definition.topAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.topAnchor),
            definition.bottomAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.bottomAnchor),
            definition.leadingAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.leadingAnchor),
            definition.trailingAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.trailingAnchor)
        ])

        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if presentingViewController?.traitCollection.verticalSizeClass == .regular && presentingViewController?.traitCollection.horizontalSizeClass == .regular {
            definition.font = UIFont.systemFont(ofSize: 40)
        }

        if let topic = topic {
            definition.text = topic.text
        }
    }
}
