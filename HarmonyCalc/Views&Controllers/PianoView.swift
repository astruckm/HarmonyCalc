//
//  PianoView.swift
//  HarmonyCalc
//
//  Created by ASM on 3/4/18.
//  Copyright © 2018 ASM. All rights reserved.
//
//White key short widths of 3/4 and 2/3 uses "B/12 solution" from:
//http://www.mathpages.com/home/kmath043.htm
//set c=d=e=(W-2B/3) and f=g=a=b=(W-3B/4)
//

import UIKit


class PianoView: UIView, NoteInputSource {
    //***************************************************
    //MARK: Layout observers
    //***************************************************
    private var isCompactHeight = UIScreen.main.traitCollection.verticalSizeClass == .compact
    private var isCompactWidth = UIScreen.main.traitCollection.horizontalSizeClass == .compact

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let newIsCompactHeight = traitCollection.verticalSizeClass == .compact
        let newIsCompactWidth = traitCollection.horizontalSizeClass == .compact
        // Only the size class changes the key count/layout.
        guard newIsCompactHeight != isCompactHeight || newIsCompactWidth != isCompactWidth else { return }
        isCompactHeight = newIsCompactHeight
        isCompactWidth = newIsCompactWidth
        touchedNotes = []
        setNeedsLayout()
    }
    
    //***************************************************
    //MARK: Properties
    //Define number of keys and their geometric relations
    //***************************************************
    private let whiteKeyBottomWidthToBlackKeyWidthRatio: CGFloat = (23.5 / 13.7) //Ratio according to wikipedia
    
    //Only draw an octave if in portrait on an iPhone
    private var numberOfWhiteKeys: Int {
        if !isCompactWidth || (isCompactWidth && isCompactHeight) {
            return 14
        } else {
            return 7
        }
    }
    private let spaceBetweenKeys: CGFloat = 0.5
    private var boundsWidthUse: CGFloat { return (bounds.width - (2 * spaceBetweenKeys)) } //spaceBetweenKeys also b/w far left and far right
    
    private var whiteKeyHeight: CGFloat { return bounds.height }
    private var blackKeyHeight: CGFloat { return bounds.height / 1.5 }
    private var whiteKeyBottomWidth: CGFloat { return ((boundsWidthUse - (CGFloat(numberOfWhiteKeys-1) * spaceBetweenKeys))  /  CGFloat(numberOfWhiteKeys)) }
    private var whiteKeyTopWidthCDE: CGFloat { return whiteKeyBottomWidth - (blackKeyWidth * 2 / 3) }
    private var whiteKeyTopWidthFGAB: CGFloat { return whiteKeyBottomWidth - (blackKeyWidth * 3 / 4) }
    private var blackKeyWidth: CGFloat { return whiteKeyBottomWidth / whiteKeyBottomWidthToBlackKeyWidthRatio }
    
    //Generate all keys based on numberOfWhiteKeys, starting at middle C (MIDI 60)
    private var arrayOfKeys: [Note] {
        var keysArray: [Note] = []
        var whiteKeysDrawn = 0
        var midiNoteNumber = 60
        while whiteKeysDrawn < numberOfWhiteKeys {
            if let note = Note(midiNoteNumber: midiNoteNumber) {
                keysArray.append(note)
                if !note.pitchClass.isBlackKey { whiteKeysDrawn += 1 }
            }
            midiNoteNumber += 1
        }
        return keysArray
    }
    //To map a touch's area in layer to its note
    var keyAreas: [(path: UIBezierPath, key: Note)] = []
    weak var inputDelegate: NoteInputDelegate?

    //Presentational highlight set, driven by the state owner (HarmonySession)
    var touchedNotes: [Note] = [] { didSet { setNeedsDisplay() } }

    //***************************************************
    //MARK: Touch events
    //***************************************************
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            checkIfPathContains(location)
        }
    }
        
    //Check if touched area is within a key
    private func checkIfPathContains(_ location: CGPoint) {
        for keyArea in keyAreas {
            if keyArea.path.contains(location) {
                reportTouch(for: keyArea.key)
                break
            }
        }
    }

    //Emit note off if already held, otherwise note on; the delegate owns the held set
    private func reportTouch(for note: Note) {
        if touchedNotes.contains(note) {
            inputDelegate?.noteInput(self, noteOff: note)
        } else {
            inputDelegate?.noteInput(self, noteOn: note)
        }
    }

    //***************************************************
    //MARK: Build key geometry
    //***************************************************
    override func layoutSubviews() {
        super.layoutSubviews()
        rebuildKeyAreas()
        setNeedsDisplay()
    }
    
    private func rebuildKeyAreas() {
        keyAreas = []
        var numberOfWhiteKeysDrawn = 0
        var startingXValue: CGFloat = bounds.minX + spaceBetweenKeys
        var incrementer: CGFloat = 0.0
        var leftMostX: CGFloat = 0.0
        
        for key in arrayOfKeys {
            let path: UIBezierPath
            switch key.pitchClass {
            case .c, .f:
                //Ensure first .c startingXValue isn't 0
                if numberOfWhiteKeysDrawn != 0 {
                    leftMostX = CGFloat(numberOfWhiteKeysDrawn) * (whiteKeyBottomWidth + CGFloat(spaceBetweenKeys))
                    startingXValue = leftMostX //Align it back with bottom of keyboard counter
                }
                let topWidth = key.pitchClass == .c ? whiteKeyTopWidthCDE : whiteKeyTopWidthFGAB
                path = whiteKeyPathCF(startingX: startingXValue, topWidth: topWidth)
                numberOfWhiteKeysDrawn += 1
                incrementer = topWidth + spaceBetweenKeys
            case .d, .g, .a:
                let topWidth = key.pitchClass == .d ? whiteKeyTopWidthCDE : whiteKeyTopWidthFGAB
                leftMostX = CGFloat(numberOfWhiteKeysDrawn) * (whiteKeyBottomWidth + CGFloat(spaceBetweenKeys))
                path = whiteKeyPathDGA(startingX: startingXValue, topWidth: topWidth, leftMostX: leftMostX)
                numberOfWhiteKeysDrawn += 1
                incrementer = topWidth + spaceBetweenKeys
            case .e, .b:
                let topWidth = key.pitchClass == .e ? whiteKeyTopWidthCDE : whiteKeyTopWidthFGAB
                leftMostX = CGFloat(numberOfWhiteKeysDrawn) * (whiteKeyBottomWidth + CGFloat(spaceBetweenKeys))
                path = whiteKeyPathEB(startingX: startingXValue, topWidth: topWidth, leftMostX: leftMostX)
                numberOfWhiteKeysDrawn += 1
                incrementer = topWidth + spaceBetweenKeys
            default:
                path = blackKeyPath(startingX: startingXValue)
                incrementer = blackKeyWidth + spaceBetweenKeys
            }
            keyAreas.append((path: path, key: key))
            startingXValue += incrementer
        }
    }
    
    //***************************************************
    //MARK: Draw all the keys
    //***************************************************
    override func draw(_ rect: CGRect) {
        for keyArea in keyAreas {
            let keyWasTouched = touchedNotes.contains(where: {$0 == keyArea.key})
            if keyArea.key.pitchClass.isBlackKey {
                fillBlackKey(keyArea.path, keyWasTouched: keyWasTouched)
            } else {
                strokeAndFillPath(keyArea.path, keyWasTouched: keyWasTouched)
            }
        }
    }
    
    
    //Path-building helper functions
    private func blackKeyPath(startingX: CGFloat) -> UIBezierPath {
        let startingPoint = CGPoint(x: startingX, y: bounds.minY)
        let path = UIBezierPath()
        
        path.move(to: startingPoint)
        path.addLine(to: CGPoint(x: startingPoint.x, y: startingPoint.y + blackKeyHeight))
        path.addLine(to: CGPoint(x: startingPoint.x + blackKeyWidth, y: startingPoint.y + blackKeyHeight))
        path.addLine(to: CGPoint(x: startingPoint.x + blackKeyWidth, y: startingPoint.y))
        path.addLine(to: startingPoint)
        path.close()
        return path
    }
    
    private func whiteKeyPathCF(startingX: CGFloat, topWidth: CGFloat) -> UIBezierPath {
        let startingPoint = CGPoint(x: startingX, y: bounds.minY)
        let path = UIBezierPath()
        
        path.move(to: startingPoint)
        path.addLine(to: CGPoint(x: startingPoint.x, y: whiteKeyHeight))
        path.addLine(to: CGPoint(x: startingPoint.x + whiteKeyBottomWidth, y: whiteKeyHeight))
        path.addLine(to: CGPoint(x: startingPoint.x + whiteKeyBottomWidth, y: blackKeyHeight + spaceBetweenKeys))
        path.addLine(to: CGPoint(x: startingPoint.x + topWidth, y: blackKeyHeight + spaceBetweenKeys))
        path.addLine(to: CGPoint(x: startingPoint.x + topWidth, y: startingPoint.y))
        path.addLine(to: startingPoint)
        path.close()
        return path
    }
    
    private func whiteKeyPathDGA(startingX: CGFloat, topWidth: CGFloat, leftMostX: CGFloat) -> UIBezierPath {
        let startingPoint = CGPoint(x: startingX, y: bounds.minY)
        let path = UIBezierPath()
        
        path.move(to: startingPoint)
        path.addLine(to: CGPoint(x: startingPoint.x, y: blackKeyHeight + spaceBetweenKeys))
        path.addLine(to: CGPoint(x: leftMostX, y: blackKeyHeight + spaceBetweenKeys))
        path.addLine(to: CGPoint(x: leftMostX, y: whiteKeyHeight))
        path.addLine(to: CGPoint(x: leftMostX + whiteKeyBottomWidth, y: whiteKeyHeight))
        path.addLine(to: CGPoint(x: leftMostX + whiteKeyBottomWidth, y: blackKeyHeight + spaceBetweenKeys))
        path.addLine(to: CGPoint(x: startingPoint.x + topWidth, y: blackKeyHeight + spaceBetweenKeys))
        path.addLine(to: CGPoint(x: startingPoint.x + topWidth, y: startingPoint.y))
        path.addLine(to: startingPoint)
        path.close()
        return path
    }
    
    private func whiteKeyPathEB(startingX: CGFloat, topWidth: CGFloat, leftMostX: CGFloat) -> UIBezierPath {
        let startingPoint = CGPoint(x: startingX, y: bounds.minY)
        let path = UIBezierPath()
        
        path.move(to: startingPoint)
        path.addLine(to: CGPoint(x: startingPoint.x, y: blackKeyHeight + spaceBetweenKeys))
        path.addLine(to: CGPoint(x: leftMostX, y: blackKeyHeight + spaceBetweenKeys))
        path.addLine(to: CGPoint(x: leftMostX, y: whiteKeyHeight))
        path.addLine(to: CGPoint(x: leftMostX + whiteKeyBottomWidth, y: whiteKeyHeight))
        path.addLine(to: CGPoint(x: leftMostX + whiteKeyBottomWidth, y: startingPoint.y))
        path.addLine(to: startingPoint)
        path.close()
        return path
    }
    
    //Rendering helper functions
    private func fillBlackKey(_ path: UIBezierPath, keyWasTouched: Bool) {
        if keyWasTouched { Colors.blueBlue.setFill() } else { UIColor.black.setFill() }
        path.fill()
    }
    
    private func strokeAndFillPath(_ path: UIBezierPath, keyWasTouched: Bool) {
        path.lineWidth = 0.3
        UIColor.black.setStroke()
        if keyWasTouched { Colors.blueBlue.setFill() } else { UIColor.white.setFill() }
        path.fill()
        path.stroke()
    }
    
}




