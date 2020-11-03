//
//  ViewController.swift
//  Maze Generator
//
//  Created by Stephen Plevier on 24/10/20.
//  Copyright © 2020 Stephen Plevier. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBOutlet weak var textMazeName: NSTextField!
    @IBOutlet weak var textSeed: NSTextField!
    @IBOutlet weak var textNumLevels: NSTextField!
    @IBOutlet weak var textNumRows: NSTextField!
    @IBOutlet weak var textNumColumns: NSTextField!
    @IBOutlet weak var checkRoofCovered: NSButton!
    @IBOutlet weak var checkLighting: NSButton!
    @IBOutlet weak var checkKsar: NSButton!
    @IBOutlet weak var checkExitRoof: NSButton!
    
    @IBAction func generateClick(_ sender: Any) {
        
        let vrndseed: UInt64 = UInt64(textSeed!.intValue)
        let vnumlevels: Int = Int(textNumLevels!.intValue)
        let vnumrows: Int = Int(textNumRows!.intValue)
        let vnumcolumns: Int = Int(textNumColumns!.intValue)
        let vroofcovered: Bool = (checkRoofCovered!.state == NSControl.StateValue.on)
        
        let vlighting: Bool = (checkLighting!.state == NSControl.StateValue.on)
        let vmazesign: String = String(textMazeName!.stringValue)
        let vmazename: String = vmazesign.lowercased()
        
        let vmazeskin: String
        
        if (checkKsar!.state == NSControl.StateValue.on) {
            vmazeskin = "moroccan"
        } else {
            vmazeskin = "none"
        }
        
        let vmazeexit: String
        
        if (checkExitRoof!.state == NSControl.StateValue.on) {
            vmazeexit = "roof"
        } else {
            vmazeexit = "back"
        }

        generateMaze(rndseed: vrndseed, numlevels: vnumlevels, numrows: vnumrows, numcolumns: vnumcolumns, roofcovered: vroofcovered, lighting: vlighting, mazename: vmazename, mazesign: vmazesign, mazeskin: vmazeskin, mazeexit: vmazeexit)
    }
}

