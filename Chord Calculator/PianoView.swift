//
//  PianoView.swift
//  Chord Calculator
//
//  Created by ASM on 3/4/18.
//  Copyright © 2018 ASM. All rights reserved.
//
//White key short widths of 3/4 and 2/3 uses "B/12 solution" from:
//http://www.mathpages.com/home/kmath043.htm
//set c=d=e=(W-2B/3) and f=g=a=b=(W-3B/4)
//

import UIKit

protocol DisplaysNotes {
    var noteNames: String { get set }
    var touchedKeys: [(PitchClass, Octave)] { get set }
    func noteDisplayNeedsUpdate()
}

protocol PlaysNotes {
    func noteOn(keyPressed: (PitchClass, Octave))
    func noteOff(keyOff: (PitchClass, Octave))
    func allNotesOff(keysOff: [(PitchClass, Octave)])
}

class PianoView: UIView {
    //***************************************************
    //MARK: Layout observers
    //***************************************************
    private var isCompactHeight = false
    private var isCompactWidth = false
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        isCompactHeight = traitCollection.verticalSizeClass == .compact ? true : false
        isCompactWidth = traitCollection.horizontalSizeClass == .compact ? true : false
        touchedKeys = []
        noteByPathArea = [:]
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
    
    private var whiteKeyHeight: CGFloat { return bounds.height }
    private var blackKeyHeight: CGFloat { return bounds.height / 1.5 }
    private var whiteKeyBottomWidth: CGFloat { return ((bounds.width - (CGFloat(numberOfWhiteKeys-1) * spaceBetweenKeys))  /  CGFloat(numberOfWhiteKeys)) } //Octave plus a fifth, encompasses bounds' whole span
    private var whiteKeyTopWidthCDE: CGFloat { return whiteKeyBottomWidth - (blackKeyWidth * 2 / 3) }
    private var whiteKeyTopWidthFGAB: CGFloat { return whiteKeyBottomWidth - (blackKeyWidth * 3 / 4) }
    private var blackKeyWidth: CGFloat { return whiteKeyBottomWidth / whiteKeyBottomWidthToBlackKeyWidthRatio }
    
    //Generate all keys based on numberOfWhiteKeys
    private var arrayOfKeys: [(PitchClass, Octave)] {
        var decrementer = numberOfWhiteKeys
        var keysArray: [(PitchClass, Octave)] = []
        var noteValue = 0
        var octave: Octave = .zero
        while decrementer > 0 {
            if noteValue == 12 {
                noteValue -= 12
                octave = .one
            }
            if let pitchClass = PitchClass(rawValue: noteValue) {
                noteValue += 1
                keysArray.append((pitchClass, octave))
                if !pitchClass.isBlackKey { decrementer -= 1 }
            }
        }
        return keysArray
    }
    //To map a touch's area in layer to its note
    private var currentPath: UIBezierPath? = nil
    var noteByPathArea = [UIBezierPath: (PitchClass, Octave)]()
    var noteNameDelegate: DisplaysNotes?
    var playNoteDelegate: PlaysNotes?
    
    var touchedKeys: [(PitchClass, Octave)] = [] { didSet { setNeedsDisplay() } }
    var keyWasTouched = false
    let colors = Colors()
    
    //***************************************************
    //MARK: Touch events
    //***************************************************
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            for path in noteByPathArea.keys {
                if path.contains(location) {
                    let note = noteByPathArea[path]
                    if let note = note {
                        //TODO: remove note from touchedKeys if touchedKeys contains note; then eliminate NOT .contains below
                        if touchedKeys.count < 6 && !touchedKeys.contains(where: {$0 == note}) { touchedKeys.append(note) }
                        noteNameDelegate?.touchedKeys = touchedKeys
                        noteNameDelegate?.noteDisplayNeedsUpdate()
                        playNoteDelegate?.noteOn(keyPressed: note)
                    }
                    break
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        return
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        return
    }
    
    //***************************************************
    //MARK: Draw all the keys
    //***************************************************
    override func draw(_ rect: CGRect) {
        var numberOfWhiteKeysDrawn = 0
        var startingXValue: CGFloat = bounds.minX
        var incrementer: CGFloat = 0.0
        var leftMostX: CGFloat = 0.0
        
        for key in arrayOfKeys[0..<(arrayOfKeys.count-1)] {
            keyWasTouched = touchedKeys.contains(where: {$0 == key}) ? true : false
            currentPath = nil
            switch key.0 {
            case .c, .f:
                leftMostX = CGFloat(numberOfWhiteKeysDrawn) * (whiteKeyBottomWidth + CGFloat(spaceBetweenKeys))
                startingXValue = leftMostX //Align it back with bottom of keyboard counter
                
                let topWidth = key.0 == .c ? whiteKeyTopWidthCDE : whiteKeyTopWidthFGAB
                drawWhiteKeysCF(startingX: startingXValue, topWidth: topWidth)
                numberOfWhiteKeysDrawn += 1
                incrementer = topWidth + spaceBetweenKeys
            case .d, .g, .a:
                let topWidth = key.0 == .d ? whiteKeyTopWidthCDE : whiteKeyTopWidthFGAB
                leftMostX = CGFloat(numberOfWhiteKeysDrawn) * (whiteKeyBottomWidth + CGFloat(spaceBetweenKeys))
                drawWhiteKeysDGA(startingX: startingXValue, topWidth: topWidth, leftMostX: leftMostX)
                numberOfWhiteKeysDrawn += 1
                incrementer = topWidth + spaceBetweenKeys
            case .e, .b:
                let topWidth = key.0 == .e ? whiteKeyTopWidthCDE : whiteKeyTopWidthFGAB
                leftMostX = CGFloat(numberOfWhiteKeysDrawn) * (whiteKeyBottomWidth + CGFloat(spaceBetweenKeys))
                drawWhiteKeysEB(startingX: startingXValue, topWidth: topWidth, leftMostX: leftMostX)
                numberOfWhiteKeysDrawn += 1
                incrementer = topWidth + spaceBetweenKeys
            default:
                drawBlackKey(startingX: startingXValue)
                incrementer = blackKeyWidth + spaceBetweenKeys
            }
            if let path = currentPath {
                noteByPathArea[path] = key
            }
            startingXValue += incrementer
        }
        //make final note fill out view, this code is deprecated, as final .b of octave will fill out view
        keyWasTouched = touchedKeys.contains(where: {$0 == arrayOfKeys[arrayOfKeys.count-1]}) ? true : false
        leftMostX = CGFloat(numberOfWhiteKeysDrawn) * (whiteKeyBottomWidth + CGFloat(spaceBetweenKeys))
        if numberOfWhiteKeys == 7 || numberOfWhiteKeys == 14 {
            let startingPoint = CGPoint(x: startingXValue, y: bounds.minY)
            let path = UIBezierPath()
            
            path.move(to: startingPoint)
            path.addLine(to: CGPoint(x: startingPoint.x, y: blackKeyHeight + spaceBetweenKeys))
            path.addLine(to: CGPoint(x: leftMostX, y: blackKeyHeight + spaceBetweenKeys))
            path.addLine(to: CGPoint(x: leftMostX, y: whiteKeyHeight))
            path.addLine(to: CGPoint(x: bounds.maxX-0.2, y: whiteKeyHeight))
            path.addLine(to: CGPoint(x: bounds.maxX-0.2, y: startingPoint.y))
            path.addLine(to: startingPoint)
            path.close()
            currentPath = path
            
            if keyWasTouched { colors.blueBlue.setFill() } else { UIColor.white.setFill() }
            
            path.fill()
        }
        if let path = currentPath {
            noteByPathArea[path] = arrayOfKeys[arrayOfKeys.count-1]
        }
    }
    
    
    //Drawing helper functions
    private func drawBlackKey(startingX: CGFloat) {
        let startingPoint = CGPoint(x: startingX, y: bounds.minY)
        let path = UIBezierPath()
        
        path.move(to: startingPoint)
        path.addLine(to: CGPoint(x: startingPoint.x, y: startingPoint.y + blackKeyHeight))
        path.addLine(to: CGPoint(x: startingPoint.x + blackKeyWidth, y: startingPoint.y + blackKeyHeight))
        path.addLine(to: CGPoint(x: startingPoint.x + blackKeyWidth, y: startingPoint.y))
        path.addLine(to: startingPoint)
        path.close()
        currentPath = path
        
        if keyWasTouched { colors.blueBlue.setFill() } else { UIColor.black.setFill() }
        
        path.fill()
    }
    
    private func drawWhiteKeysCF(startingX: CGFloat, topWidth: CGFloat) {
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
        currentPath = path
        
        strokeAndFillPath(path)
    }
    
    private func drawWhiteKeysDGA(startingX: CGFloat, topWidth: CGFloat, leftMostX: CGFloat) {
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
        currentPath = path
        
        strokeAndFillPath(path)
    }
    
    private func drawWhiteKeysEB(startingX: CGFloat, topWidth: CGFloat, leftMostX: CGFloat) {
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
        currentPath = path
        
        strokeAndFillPath(path)
    }
    
    //Helper function for drawing subfunctions
    private func strokeAndFillPath(_ path: UIBezierPath) {
        path.lineWidth = 0.3
        UIColor.black.setStroke()
        if keyWasTouched { colors.blueBlue.setFill() } else { UIColor.white.setFill() }
        path.fill()
        path.stroke()
    }
    
}




