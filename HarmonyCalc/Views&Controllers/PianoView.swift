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


class PianoView: UIView {
    //***************************************************
    //MARK: Layout observers
    //***************************************************
    private var isCompactHeight = UIScreen.main.traitCollection.verticalSizeClass == .compact
    private var isCompactWidth = UIScreen.main.traitCollection.horizontalSizeClass == .compact
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        isCompactHeight = traitCollection.verticalSizeClass == .compact ? true : false
        isCompactWidth = traitCollection.horizontalSizeClass == .compact ? true : false
        touchedKeys = []
        keyByPathArea = [:]
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
    var keyByPathArea = [UIBezierPath: (PitchClass, Octave)]()
    var noteCollectionDelegate: NoteCollectionConstraintsDelegate?
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
            checkIfPathContains(location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }
    
    //Check if touched area is within a key
    private func checkIfPathContains(_ location: CGPoint) {
        for path in keyByPathArea.keys {
            if path.contains(location) {
                checkTouchedKeys(for: path)
                break
            }
        }
    }
    
    //Remove key if already touched, otherwise add it to chord
    private func checkTouchedKeys(for path: UIBezierPath) {
        if let key = keyByPathArea[path] {
            for (index, touchedKey) in touchedKeys.enumerated() {
                if touchedKey == key {
                    touchedKeys.remove(at: index)
                    updateNoteNameDelegate()
                    playNoteDelegate?.noteOff(keyOff: key)
                    return
                }
            }
            if let maxNotes = noteCollectionDelegate?.maxTouchableNotes, touchedKeys.count < maxNotes {
                touchedKeys.append(key)
            }
            updateNoteNameDelegate()
            playNoteDelegate?.noteOn(keyPressed: key)
        }
    }
    
    private func updateNoteNameDelegate() {
        noteNameDelegate?.touchedKeys = touchedKeys
        noteNameDelegate?.noteDisplayNeedsUpdate()
    }
    
    //***************************************************
    //MARK: Draw all the keys
    //***************************************************
    override func draw(_ rect: CGRect) {
        var numberOfWhiteKeysDrawn = 0
        var startingXValue: CGFloat = bounds.minX + spaceBetweenKeys
        var incrementer: CGFloat = 0.0
        var leftMostX: CGFloat = 0.0
        
        for key in arrayOfKeys[0..<(arrayOfKeys.count)] {
            keyWasTouched = touchedKeys.contains(where: {$0 == key}) ? true : false
            currentPath = nil
            switch key.0 {
            case .c, .f:
                //Ensure first .c startingXValue isn't 0
                if numberOfWhiteKeysDrawn != 0 {
                    leftMostX = CGFloat(numberOfWhiteKeysDrawn) * (whiteKeyBottomWidth + CGFloat(spaceBetweenKeys))
                    startingXValue = leftMostX //Align it back with bottom of keyboard counter
                }
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
                keyByPathArea[path] = key
            }
            startingXValue += incrementer
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




