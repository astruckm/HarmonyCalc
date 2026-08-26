//
//  MainViewController.swift
//  HarmonyCalc
//
//  Created by ASM on 2/24/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, NoteInputDelegate, HarmonySessionObserver, UIPopoverPresentationControllerDelegate {
    //*****************************************
    //MARK: Views
    //*****************************************
    private(set) var chordButton = UIButton(type: .system)
    private(set) var inversionButton = UIButton(type: .system)
    private(set) var normalFormButton = UIButton(type: .system)
    private(set) var primeFormButton = UIButton(type: .system)

    private(set) var noteName = UILabel()
    private(set) var chord = UILabel()
    private(set) var inversion = UILabel()
    private(set) var normalForm = UILabel()
    private(set) var primeForm = UILabel()

    private(set) var flatSharp = UIButton(type: .system)
    private(set) var audioOnOff = UIButton(type: .custom)
    private(set) var reset = UIButton(type: .system)
    private let playButton = UIButton(type: .system)
    private(set) var piano = PianoView()

    private let labelsStack = UIStackView()
    private let collectionsStack = UIStackView()
    private let tonalStack = UIStackView()
    private let atonalStack = UIStackView()
    private let chordStack = UIStackView()
    private let inversionStack = UIStackView()
    private let normalFormStack = UIStackView()
    private let primeFormStack = UIStackView()
    private let controlsStack = UIStackView()

    private var pianoTopConstraint: NSLayoutConstraint?
    private var pianoHeightConstraint: NSLayoutConstraint?
    private var noteNameHeightConstraint: NSLayoutConstraint?
    private var labelsStackTopConstraint: NSLayoutConstraint?
    private var labelsStackHeightConstraint: NSLayoutConstraint?
    private var controlsTopConstraint: NSLayoutConstraint?
    private var controlsLeadingConstraint: NSLayoutConstraint?
    private var controlsTrailingConstraint: NSLayoutConstraint?
    private var controlsBottomConstraint: NSLayoutConstraint?
    private var controlsHeightConstraint: NSLayoutConstraint?
    private var audioWidthConstraint: NSLayoutConstraint?
    private var playWidthConstraint: NSLayoutConstraint?

    //*****************************************
    //MARK: Properties
    //*****************************************
    let session = HarmonySession(harmonyModel: HarmonyModel(maxNotesInCollection: 7))
    var collectionUsesSharps = true
    var audioIsOn = true
    let audioOn = UIImage(named: "audio on black.png")
    let audioOff = UIImage(named: "audio off black.png")
    var defaults: Defaults = Defaults()

    //*****************************************
    //NoteInputDelegate
    //*****************************************
    let audioEngine = Audio.sharedInstance

    func noteInput(_ source: NoteInputSource, noteOn note: Note) {
        playNote(note)
        session.add(note)
    }

    func noteInput(_ source: NoteInputSource, noteOff note: Note) {
        stopNote(note)
        session.remove(note)
    }

    func noteInputDidClear(_ source: NoteInputSource) {
        session.clear()
    }

    //*****************************************
    //HarmonySessionObserver
    //*****************************************
    func harmonySessionDidChange(_ session: HarmonySession) {
        piano.touchedNotes = session.sortedNotes
        noteName.text = session.noteNames(usingSharps: collectionUsesSharps)
        updateCollectionLabels(usingSharps: collectionUsesSharps)
    }

    //*****************************************
    //MARK: Audio
    //*****************************************
    private func playNote(_ note: Note) {
        let soundFileName = getSoundFileName(of: note)

        if audioIsOn {
            audioEngine.playSound(soundFileName: soundFileName)
        } else {
            let url = audioEngine.urlLookUp(of: soundFileName)
            if let url = url {
                audioEngine.loadSound(at: url)
            }
        }
    }

    func playAllNotes() {
        if audioIsOn {
            audioEngine.playSounds()
        }
    }

    private func stopNote(_ note: Note) {
        let soundFileName = getSoundFileName(of: note)
        let url = audioEngine.urlLookUp(of: soundFileName)
        if let url = url {
            audioEngine.removeSound(at: url)
        }
    }

    private func getSoundFileName(of note: Note) -> String {
        let pitchClass = note.pitchClass
        let spelling = pitchClass.isBlackKey ? pitchClass.possibleSpellings[1] : pitchClass.possibleSpellings[0]
        let octave = String(note.octave) ///Middle C (MIDI 60) is octave 4
        let soundFileName = spelling + octave

        return soundFileName
    }

    //*****************************************
    //MARK: ViewController lifecycle
    //*****************************************
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        buildViewHierarchy()
        activateConstraints()
        wireActions()
        piano.inputDelegate = self
        session.observer = self

        view.addGradientBackground(colorOne: Colors.heavy, colorTwo: Colors.rain)
        view.isMultipleTouchEnabled = true
        piano.isUserInteractionEnabled = true
        piano.isMultipleTouchEnabled = true
        piano.backgroundColor = .darkGray
        reset.setTitle("Clear", for: .normal)

        audioIsOn = defaults.readAudioSetting()
        collectionUsesSharps = defaults.readCollectionUsesSharps()

        let audioImage: UIImage? = audioIsOn ? audioOn : audioOff
        audioOnOff.setImage(audioImage, for: .normal)

        applyTraitBasedLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.sublayers?.first?.frame = view.bounds
        piano.setNeedsDisplay()
        reset.layer.borderWidth = 2.0
        reset.layer.cornerRadius = 5
        flatSharp.layer.borderWidth = 2.0
        flatSharp.layer.cornerRadius = 5
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        view.layer.sublayers?.first?.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height) //TODO: Perhaps there is some less hacky-y way to get what view.bounds WILL BE
        super.viewWillTransition(to: size, with: coordinator)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTraitBasedLayout()
        resetNotes()
    }

    //*****************************************
    //MARK: View setup
    //*****************************************
    private func buildViewHierarchy() {
        chordButton.setTitle("Chord:", for: .normal)
        inversionButton.setTitle("Inversion:", for: .normal)
        normalFormButton.setTitle("Normal:", for: .normal)
        primeFormButton.setTitle("Prime:", for: .normal)
        for button in [chordButton, inversionButton, normalFormButton, primeFormButton] {
            button.setTitleColor(.black, for: .normal)
            button.contentHorizontalAlignment = .leading
            button.titleLabel?.lineBreakMode = .byTruncatingMiddle
        }

        noteName.textAlignment = .center
        for label in [noteName, chord, inversion, normalForm, primeForm] {
            label.textColor = .black
        }

        flatSharp.setTitle("♯ / ♭", for: .normal)
        reset.setTitle("Clear", for: .normal)
        for button in [flatSharp, reset] {
            button.setTitleColor(.black, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        }
        audioOnOff.clipsToBounds = true
        audioOnOff.setImage(audioOff, for: .normal)
        playButton.tintColor = .black
        playButton.setImage(UIImage(named: "Black Play Button 1x"), for: .normal)

        configureStack(chordStack, axis: .horizontal, distribution: .fillEqually, spacing: 10, arranged: [chordButton, chord])
        configureStack(inversionStack, axis: .horizontal, distribution: .fillEqually, spacing: 10, arranged: [inversionButton, inversion])
        configureStack(normalFormStack, axis: .horizontal, distribution: .fillEqually, spacing: 10, arranged: [normalFormButton, normalForm])
        configureStack(primeFormStack, axis: .horizontal, distribution: .fillEqually, spacing: 10, arranged: [primeFormButton, primeForm])
        configureStack(tonalStack, axis: .vertical, distribution: .fillEqually, spacing: 3, arranged: [chordStack, inversionStack])
        configureStack(atonalStack, axis: .vertical, distribution: .fillEqually, spacing: 3, arranged: [normalFormStack, primeFormStack])
        configureStack(collectionsStack, axis: .vertical, distribution: .fill, spacing: 3, arranged: [tonalStack, atonalStack])
        configureStack(labelsStack, axis: .vertical, distribution: .fill, spacing: 5, arranged: [noteName, collectionsStack])
        configureStack(controlsStack, axis: .horizontal, distribution: .equalCentering, spacing: 20, arranged: [flatSharp, audioOnOff, playButton, reset])

        piano.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(piano)
        view.addSubview(labelsStack)
        view.addSubview(controlsStack)
    }

    private func configureStack(_ stack: UIStackView, axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution, spacing: CGFloat, arranged: [UIView]) {
        stack.axis = axis
        stack.distribution = distribution
        stack.spacing = spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        arranged.forEach { stack.addArrangedSubview($0) }
    }

    private func activateConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        let pianoTop = piano.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20)
        let pianoHeight = piano.heightAnchor.constraint(greaterThanOrEqualToConstant: 192)
        let noteNameHeight = noteName.heightAnchor.constraint(equalToConstant: 33.5)
        let labelsStackTop = labelsStack.topAnchor.constraint(equalTo: piano.bottomAnchor, constant: 12)
        let labelsStackHeight = labelsStack.heightAnchor.constraint(equalToConstant: 180)
        let controlsTop = controlsStack.topAnchor.constraint(equalTo: labelsStack.bottomAnchor, constant: 15)
        let controlsLeading = controlsStack.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20)
        let controlsTrailing = safeArea.trailingAnchor.constraint(equalTo: controlsStack.trailingAnchor, constant: 20)
        let controlsBottom = safeArea.bottomAnchor.constraint(equalTo: controlsStack.bottomAnchor, constant: 10)
        let controlsHeight = controlsStack.heightAnchor.constraint(equalToConstant: 40)
        let audioWidth = audioOnOff.widthAnchor.constraint(lessThanOrEqualToConstant: 55)
        let playWidth = playButton.widthAnchor.constraint(lessThanOrEqualToConstant: 40)

        NSLayoutConstraint.activate([
            piano.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            safeArea.trailingAnchor.constraint(equalTo: piano.trailingAnchor, constant: 20),
            pianoTop,
            pianoHeight,

            noteNameHeight,
            labelsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelsStack.leadingAnchor.constraint(equalTo: controlsStack.leadingAnchor),
            labelsStackTop,
            labelsStackHeight,
            atonalStack.heightAnchor.constraint(equalTo: tonalStack.heightAnchor),

            controlsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlsLeading,
            controlsTrailing,
            controlsTop,
            controlsBottom,
            controlsHeight,
            audioWidth,
            playWidth
        ])

        pianoTopConstraint = pianoTop
        pianoHeightConstraint = pianoHeight
        noteNameHeightConstraint = noteNameHeight
        labelsStackTopConstraint = labelsStackTop
        labelsStackHeightConstraint = labelsStackHeight
        controlsTopConstraint = controlsTop
        controlsLeadingConstraint = controlsLeading
        controlsTrailingConstraint = controlsTrailing
        controlsBottomConstraint = controlsBottom
        controlsHeightConstraint = controlsHeight
        audioWidthConstraint = audioWidth
        playWidthConstraint = playWidth
    }

    private func wireActions() {
        chordButton.addTarget(self, action: #selector(showChordDefinition), for: .touchUpInside)
        inversionButton.addTarget(self, action: #selector(showInversionDefinition), for: .touchUpInside)
        normalFormButton.addTarget(self, action: #selector(showNormalFormDefinition), for: .touchUpInside)
        primeFormButton.addTarget(self, action: #selector(showPrimeFormDefinition), for: .touchUpInside)
        flatSharp.addTarget(self, action: #selector(switchFlatSharp(_:)), for: .touchUpInside)
        audioOnOff.addTarget(self, action: #selector(audioOnOff(_:)), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playChord(_:)), for: .touchUpInside)
        reset.addTarget(self, action: #selector(resetNotes(_:)), for: .touchUpInside)
    }

    private func applyTraitBasedLayout() {
        let compactHeight = traitCollection.verticalSizeClass == .compact
        let compactWidth = traitCollection.horizontalSizeClass == .compact
        let isRegular = traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .regular
        let isCompact = compactHeight && compactWidth
        let isPhonePortrait = traitCollection.verticalSizeClass == .regular && compactWidth

        let collectionFontSize: CGFloat = isRegular ? 52 : (isCompact ? 24 : 28)
        noteName.font = UIFont.italicSystemFont(ofSize: collectionFontSize)
        for button in [chordButton, inversionButton, normalFormButton, primeFormButton] {
            button.titleLabel?.font = UIFont.systemFont(ofSize: collectionFontSize)
        }
        for label in [chord, inversion, normalForm, primeForm] {
            label.font = UIFont.systemFont(ofSize: collectionFontSize)
        }
        let controlFontSize: CGFloat = isRegular ? 40 : 26
        flatSharp.titleLabel?.font = UIFont.systemFont(ofSize: controlFontSize)
        reset.titleLabel?.font = UIFont.systemFont(ofSize: controlFontSize)

        labelsStack.spacing = isRegular ? 20 : 5
        tonalStack.spacing = isRegular ? 10 : 3
        atonalStack.spacing = isRegular ? 10 : 3
        let innerSpacing: CGFloat = compactWidth ? 5 : 10
        for stack in [chordStack, inversionStack, normalFormStack, primeFormStack] {
            stack.spacing = innerSpacing
        }
        controlsStack.spacing = isPhonePortrait ? 15 : 20
        if compactHeight {
            collectionsStack.axis = .horizontal
            collectionsStack.distribution = .equalSpacing
        } else {
            collectionsStack.axis = .vertical
            collectionsStack.distribution = .fill
        }

        pianoTopConstraint?.constant = isRegular ? 40 : 20
        pianoHeightConstraint?.constant = compactHeight ? 124 : (isPhonePortrait ? 144 : 192)
        noteNameHeightConstraint?.constant = isRegular ? 52 : (isCompact ? 24 : 33.5)
        labelsStackTopConstraint?.constant = compactHeight ? 5 : (isRegular ? 40 : 12)
        labelsStackHeightConstraint?.constant = compactHeight ? 104 : (isRegular ? 300 : 180)
        controlsTopConstraint?.constant = isRegular ? 40 : 15
        controlsLeadingConstraint?.constant = compactHeight ? 40 : (isRegular ? 120 : 20)
        controlsTrailingConstraint?.constant = compactHeight ? 40 : (isRegular ? 120 : 20)
        controlsBottomConstraint?.constant = isRegular ? 40 : 10
        controlsHeightConstraint?.constant = isRegular ? 60 : 40
        audioWidthConstraint?.constant = isRegular ? 75 : 55
        playWidthConstraint?.constant = isRegular ? 55 : 40
    }

    //*****************************************
    //MARK: Navigation (Popovers)
    //*****************************************
    @objc private func showChordDefinition() {
        showDefinition(for: .chord, from: chordButton)
    }

    @objc private func showInversionDefinition() {
        showDefinition(for: .inversion, from: inversionButton)
    }

    @objc private func showNormalFormDefinition() {
        showDefinition(for: .normalForm, from: normalFormButton)
    }

    @objc private func showPrimeFormDefinition() {
        showDefinition(for: .primeForm, from: primeFormButton)
    }

    private func showDefinition(for topic: DefinitionsViewController.Topic, from button: UIButton) {
        let vc = DefinitionsViewController()
        vc.topic = topic
        vc.modalPresentationStyle = .popover

        var popOverSize = CGSize(width: view.bounds.width/2, height: view.bounds.height/2)
        let sizeClass = self.sizeClass()
        popOverSize = changePopoverSize(popOverWidth: popOverSize.width, popOverHeight: popOverSize.height, sizeClass: sizeClass)

        switch topic {
        case .chord: popOverSize.height = view.bounds.height / 2.1
        case .inversion: popOverSize.height = view.bounds.height / 4.6
        case .normalForm: popOverSize.height = view.bounds.height / 1.4
        case .primeForm: popOverSize.height = view.bounds.height / 1.5
        }
        vc.preferredContentSize = popOverSize

        let controller = vc.popoverPresentationController
        controller?.delegate = self
        controller?.permittedArrowDirections = .down
        controller?.sourceView = button
        controller?.sourceRect = button.bounds

        present(vc, animated: true)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    //*****************************************
    //MARK: Actions
    //*****************************************
    @objc func audioOnOff(_ sender: UIButton) {
        let audioOnOrOffImage = audioIsOn ? audioOff : audioOn
        audioOnOff.setImage(audioOnOrOffImage, for: .normal)
        audioIsOn.toggle()
        defaults.writeAudioSetting(audioIsOn)
    }

    @objc func resetNotes(_ sender: UIButton) {
        resetNotes()
    }

    @objc func playChord(_ sender: UIButton) {
        playAllNotes()
    }

    @objc func switchFlatSharp(_ sender: UIButton) {
        collectionUsesSharps.toggle()
        defaults.writeCollectionUsesSharps(collectionUsesSharps)
        noteName.text = session.noteNames(usingSharps: collectionUsesSharps)
        updateCollectionLabels(usingSharps: collectionUsesSharps)
    }

    func resetNotes() {
        session.clear()
        piano.touchedNotes = []
        audioEngine.players = [:]
        noteName.text = " "
        updateCollectionLabels(usingSharps: collectionUsesSharps)
    }

    //*****************************************
    //MARK: Get chords/collections
    //*****************************************
    func updateCollectionLabels(usingSharps: Bool) {
        let normalFormText: String
        let primeFormText: String
        let chordText: String
        let inversionText: String

        if session.pitchClasses.count > 1 {
            let normalFormPC = session.normalForm
            let normalFormAsString = normalFormPC.map { element -> String in
                if element.rawValue == 10 { return "t" }
                else if element.rawValue == 11 { return "e" }
                else { return String(element.rawValue) } }
            normalFormText = "[" + normalFormAsString.joined(separator: ",") + "]"

            let primeFormPC = session.primeForm
            let primeFormAsString = primeFormPC.map({String($0)})
            primeFormText = "(" + primeFormAsString.joined() + ")"

            if let chordInfo = session.chord() {
                let chordRoot = chordInfo.root
                //There are 3 possibilities: white key, sharp, or flat.
                let chordRootAsString = chordRoot.spelling(usingSharps: usingSharps)
                chordText = chordRootAsString + chordInfo.quality
                inversionText = chordInfo.inversion
            } else {
                chordText = " "
                inversionText = " "
            }
        } else {
            normalFormText = " "
            primeFormText = " "
            chordText = " "
            inversionText = " "
        }

        normalForm.text = normalFormText
        primeForm.text = primeFormText
        chord.text = chordText
        inversion.text = inversionText
    }
}


extension MainViewController {
    func sizeClass() -> (UIUserInterfaceSizeClass, UIUserInterfaceSizeClass) {
        return (self.traitCollection.horizontalSizeClass, self.traitCollection.verticalSizeClass)
    }

    func changePopoverSize(popOverWidth: CGFloat, popOverHeight: CGFloat, sizeClass: (UIUserInterfaceSizeClass, UIUserInterfaceSizeClass)) -> CGSize {
        let newPopOverSize: CGSize
        switch sizeClass {
        case (.compact, .compact):
            newPopOverSize = CGSize(width: popOverWidth / 0.7, height: popOverHeight / 0.8)
        case (.compact, .regular):
            newPopOverSize = CGSize(width: popOverWidth / 0.8, height: popOverHeight / 1.2)
        case (.regular, .compact):
            newPopOverSize = CGSize(width: popOverWidth / 1.0, height: popOverHeight)
        case (.regular, .regular):
            newPopOverSize = CGSize(width: popOverWidth / 0.8, height: popOverHeight / 1.6)
        default:
            newPopOverSize = CGSize(width: popOverWidth, height: popOverHeight)
        }

        return newPopOverSize
    }
}
