//
//  NoteViewController.swift
//  Chord Calculator
//
//  Created by ASM on 2/24/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import UIKit
import AVFoundation

class NoteViewController: UIViewController, DisplaysNotes, PlaysNotes, UIPopoverPresentationControllerDelegate {
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
    
    @IBOutlet weak var audioOnOff: UIButton!
    @IBOutlet weak var reset: UIButton!
    @IBOutlet weak var piano: PianoView! {
        didSet {
            piano.noteNameDelegate = self
            piano.playNoteDelegate = self
        }
    }
    
    //*****************************************
    //MARK: Properties
    //*****************************************
    let colors = Colors()
    var harmonyModel = HarmonyModel()
    var collectionUsesSharps = true
    var audioIsOn = true
    let audioOn = UIImage(named: "audio on black.png")
    let audioOff = UIImage(named: "audio off black.png")
    
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
            let pitchClass = keyPressed.0
            let note = pitchClass.isBlackKey ? pitchClass.possibleSpellings[1] : pitchClass.possibleSpellings[0]
            let keyValue = harmonyModel.keyValue(pitch: keyPressed)
            let octave = String((keyValue / 12) + 4)
            let soundFileName = note + octave
        
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
            let pitchClass = touchedKey.0
            let note = pitchClass.isBlackKey ? pitchClass.possibleSpellings[1] : pitchClass.possibleSpellings[0]
            let keyValue = harmonyModel.keyValue(pitch: touchedKey)
            let octave = String((keyValue / 12) + 4)
            let soundFileName = note + octave
            soundFileNames.append(soundFileName)
        }
        if audioIsOn {
            audioEngine.playSounds(soundFileNames: soundFileNames)
        }
    }
    
    func noteOff(keyOff: (PitchClass, Octave)) {
        return
    }
    
    func allNotesOff(keysOff: [(PitchClass, Octave)]) {
        return
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
        
        if audioIsOn {
            audioOnOff.setImage(audioOn, for: .normal)
        } else {
            audioOnOff.setImage(audioOff, for: .normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        piano.noteByPathArea = [:]
        piano.setNeedsDisplay()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        view.layer.sublayers?.first?.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height) //TODO: THIS IS VERY HACK-Y!!!! Need some way to get what view.bounds WILL BE
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        resetNotes()
    }
    
    //*****************************************
    //MARK: Navigation
    //*****************************************
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DefinitionsViewController
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
            controller?.sourceView = chordButton
            controller?.sourceRect = chordButton.frame
            popOverSize.height = view.bounds.height / 3
        case "Inversion":
            controller?.sourceView = inversionButton
            controller?.sourceRect = inversionButton.frame
            popOverSize.height = view.bounds.height / 5
        case "Normal Form":
            controller?.sourceView = normalFormButton
            controller?.sourceRect = normalFormButton.frame
            popOverSize.height = view.bounds.height / 1.5
        case "Prime Form":
            controller?.sourceView = primeFormButton
            controller?.sourceRect = primeFormButton.frame
            popOverSize.height = view.bounds.height / 1.8
        default: break
        }
        vc.preferredContentSize = popOverSize
        print("popOverSize equals \(popOverSize)")
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
    }
    
    @IBAction func resetNotes(_ sender: UIButton) {
        resetNotes()
    }
    
    @IBAction func playChord(_ sender: UIButton) {
        playAllNotes()
    }
    
    @IBAction func switchFlatSharp(_ sender: UIButton) {
        collectionUsesSharps = collectionUsesSharps == true ? false : true
        noteDisplayNeedsUpdate()
    }
    
    func resetNotes() {
        piano.noteByPathArea = [:]
        piano.touchedKeys = []
        noteName.text = " "
        self.touchedKeys = []
        updateCollectionLabels()
        audioEngine.players = [:]
    }
    
    //TODO: Persist audioIsOn and collectionUsesSharps
    
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
                //There are 3 possibilities: white key, sharp, or flat. If !isBlackKey then [0]; if .isBlackKey, [0] if collectionUsesSharps, [1] if not.
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
            newPopOverSize = CGSize(width: popOverWidth / 0.9, height: popOverHeight)
        case (.compact, .regular):
            newPopOverSize = CGSize(width: popOverWidth / 1.1, height: popOverHeight)
        case (.regular, .compact):
            newPopOverSize = CGSize(width: popOverWidth / 1.0, height: popOverHeight)
        case (.regular, .regular):
            newPopOverSize = CGSize(width: popOverWidth / 0.7, height: popOverHeight)
        default:
            newPopOverSize = CGSize(width: popOverWidth, height: popOverHeight)
        }
        
        return newPopOverSize
    }
}




