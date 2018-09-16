//
//  NoteViewController.swift
//  Chord Calculator
//
//  Created by ASM on 2/24/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import UIKit
import AVFoundation

class NoteViewController: UIViewController, NoteCollectionConstraints, DisplaysNotes, PlaysNotes, UIPopoverPresentationControllerDelegate {
    //*****************************************
    //MARK: Outlets
    //*****************************************
    @IBOutlet weak var chordButton: UIButton!
    @IBOutlet weak var inversionButton: UIButton!
    @IBOutlet weak var normalFormButton: UIButton!
    @IBOutlet weak var primeFormButton: UIButton!
    
    @IBOutlet weak var noteName: UILabel!
    @IBOutlet weak var chord: UILabel!
    @IBOutlet weak var inversion: UILabel!
    @IBOutlet weak var normalForm: UILabel!
    @IBOutlet weak var primeForm: UILabel!
    
    @IBOutlet weak var flatSharp: UIButton!
    @IBOutlet weak var audioOnOff: UIButton!
    @IBOutlet weak var reset: UIButton!
    @IBOutlet weak var piano: PianoView! {
        didSet {
            piano.noteCollectionDelegate = self
            piano.noteNameDelegate = self
            piano.playNoteDelegate = self
        }
    }
    
    //*****************************************
    //MARK: Properties
    //*****************************************
    let colors = Colors()
    var harmonyModel = HarmonyModel(maxNotesInCollection: 6)
    var collectionUsesSharps = true
    var audioIsOn = true
    let audioOn = UIImage(named: "audio on black.png")
    let audioOff = UIImage(named: "audio off black.png")
    let defaults = Defaults()
    
    //*****************************************
    //NoteCollectionConstraints
    //*****************************************

    var maxTouchableNotes: Int { return harmonyModel.maxNotes }
    
    //*****************************************
    //DisplaysNotes
    //*****************************************
    var touchedKeys: [(PitchClass, Octave)] = []
    var pitchClasses: [PitchClass] { return Array(Set(touchedKeys.map{$0.0})).sorted(by: <) }
    var possibleNoteNames: [[String]] {
        return pitchClasses.map{$0.possibleSpellings} }
    func noteDisplayNeedsUpdate() {
        updateCollectionLabels()
        if collectionUsesSharps {
            let arrayOfNoteNames = possibleNoteNames.map{$0[0]}
            noteNames = arrayOfNoteNames.joined(separator: ", ")
        } else {
            var arrayOfNoteNames = [String]()
            for pitchClass in pitchClasses {
                if pitchClass.isBlackKey {
                arrayOfNoteNames.append(pitchClass.possibleSpellings[1])
                } else {
                arrayOfNoteNames.append(pitchClass.possibleSpellings[0])
                }
            }
            noteNames = arrayOfNoteNames.joined(separator: ", ")
        }
    }
    var noteNames: String {
        get {
            return noteName.text ?? " "
        }
        set {
            noteName.text = newValue
        }
    }
    
    //*****************************************
    //PlaysNotes
    //*****************************************
    let audioEngine = Audio.sharedInstance
    var player: AVAudioPlayer?
    
    func noteOn(keyPressed: (PitchClass, Octave)) {
        let soundFileName = getSoundFileName(ofKey: keyPressed)
        
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
        var soundFileNames = [String]()
        for touchedKey in touchedKeys {
            let soundFileName = getSoundFileName(ofKey: touchedKey)
            soundFileNames.append(soundFileName)
        }
        if audioIsOn {
            audioEngine.playSounds(soundFileNames: soundFileNames)
        }
    }
    
    func noteOff(keyOff: (PitchClass, Octave)) {
        let soundFileName = getSoundFileName(ofKey: keyOff)
        let url = audioEngine.urlLookUp(of: soundFileName)
        if let url = url {
            audioEngine.removeSound(at: url)
        }
    }
    
    func allNotesOff(keysOff: [(PitchClass, Octave)]) {
        return
    }
    
    private func getSoundFileName(ofKey key: (PitchClass, Octave)) -> String {
        let pitchClass = key.0
        let note = pitchClass.isBlackKey ? pitchClass.possibleSpellings[1] : pitchClass.possibleSpellings[0]
        let keysValue = keyValue(pitch: key)
        let octave = String((keysValue / 12) + 4) ///+4 b/c C0 is C4 (i.e. middle C)
        let soundFileName = note + octave
        
        return soundFileName
    }
    
    //*****************************************
    //MARK: ViewController lifecycle
    //*****************************************
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGradientBackground(colorOne: colors.heavy, colorTwo: colors.rain)
        view.addSubview(piano)
        view.isMultipleTouchEnabled = true
        piano.isUserInteractionEnabled = true
        piano.isMultipleTouchEnabled = true
        piano.backgroundColor = .darkGray
        reset.setTitle("Clear", for: .normal)
        
        audioIsOn = defaults.userDefaults.bool(forKey: defaults.audioIsOn)
        collectionUsesSharps = defaults.userDefaults.bool(forKey: defaults.collectionUsesSharps)

        let audioImage: UIImage? = audioIsOn ? audioOn : audioOff
        audioOnOff.setImage(audioImage, for: .normal)        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        piano.keyByPathArea = [:]
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
        resetNotes()
    }
    
    //*****************************************
    //MARK: Navigation (Popovers)
    //*****************************************
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DefinitionsViewController {
            let identifier = segue.identifier
            vc.chordType = identifier
            
            var popOverSize = CGSize(width: view.bounds.width/2, height: view.bounds.height/2)
            let sizeClass = self.sizeClass()
            popOverSize = changePopoverSize(popOverWidth: popOverSize.width, popOverHeight: popOverSize.height, sizeClass: sizeClass)
            
            let controller = vc.popoverPresentationController
            controller?.delegate = self
            controller?.permittedArrowDirections = .down
            switch identifier {
            case "Chord":
                assignPopOverSource(to: controller, with: chordButton)
                popOverSize.height = view.bounds.height / 2.1
            case "Inversion":
                assignPopOverSource(to: controller, with: inversionButton)
                popOverSize.height = view.bounds.height / 4.6
            case "Normal Form":
                assignPopOverSource(to: controller, with: normalFormButton)
                popOverSize.height = view.bounds.height / 1.4
            case "Prime Form":
                assignPopOverSource(to: controller, with: primeFormButton)
                popOverSize.height = view.bounds.height / 1.5
            default: break
            }
            vc.preferredContentSize = popOverSize
        }
    }
    
    private func assignPopOverSource(to controller: UIPopoverPresentationController?, with button: UIButton) {
        controller?.sourceView = button
        controller?.sourceRect = button.frame
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    //*****************************************
    //MARK: Actions
    //*****************************************
    @IBAction func audioOnOff(_ sender: UIButton) {
        if audioIsOn {
            audioOnOff.setImage(audioOff, for: .normal)
            audioIsOn = false
        } else {
            audioOnOff.setImage(audioOn, for: .normal)
            audioIsOn = true
        }
        defaults.writeAudioSetting(audioIsOn)
    }
    
    @IBAction func resetNotes(_ sender: UIButton) {
        resetNotes()
    }
    
    @IBAction func playChord(_ sender: UIButton) {
        playAllNotes()
    }
    
    @IBAction func switchFlatSharp(_ sender: UIButton) {
        collectionUsesSharps = collectionUsesSharps == true ? false : true
        defaults.writeCollectionUsesSharps(collectionUsesSharps)
        noteDisplayNeedsUpdate()
    }
    
    func resetNotes() {
        piano.keyByPathArea = [:]
        piano.touchedKeys = []
        audioEngine.players = [:]
        noteName.text = " "
        self.touchedKeys = []
        updateCollectionLabels()
    }
    
    //*****************************************
    //MARK: Get chords/collections
    //*****************************************
    func updateCollectionLabels() {
        let normalFormText: String
        let primeFormText: String
        let chordText: String
        let inversionText: String
        
        if pitchClasses.count > 1 {
            let normalFormPC = harmonyModel.normalForm(of: pitchClasses)
            let normalFormAsString = normalFormPC.map { element -> String in
                if element.rawValue == 10 { return "t" }
                else if element.rawValue == 11 { return "e" }
                else { return String(element.rawValue) } }
            normalFormText = "[" + normalFormAsString.joined(separator: ",") + "]"
            
            let primeFormPC = harmonyModel.primeForm(of: pitchClasses)
            let primeFormAsString = primeFormPC.map({String($0)})
            primeFormText = "(" + primeFormAsString.joined() + ")"
            
            if let chordPC = harmonyModel.getChordIdentity(of: pitchClasses) {
                let chordRoot = chordPC.0
                //There are 3 possibilities: white key, sharp, or flat.
                let chordRootAsString = (chordRoot.isBlackKey && !collectionUsesSharps) ? chordRoot.possibleSpellings[1] : chordRoot.possibleSpellings[0]
                let chordQualityAsString = chordPC.1.rawValue
                chordText = chordRootAsString + chordQualityAsString
            } else {
                chordText = " "
                chord.text = chordText
            }
            
            if let chordInversion = harmonyModel.getChordInversion(of: touchedKeys) {
                inversionText = chordInversion
            } else {
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


extension NoteViewController {
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




