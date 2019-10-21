//
//  DesktopWallpaperController.swift
//  scrtry
//
//  Created by badi3 on 10/20/19.
//  Copyright © 2019 Badi3. All rights reserved.
//

import Cocoa

class DesktopWallpaperController: NSViewController {

    
    @IBOutlet weak var theBGImageVIew: NSImageView!
    var preloadedImage : NSImage?

    @IBOutlet weak var container: ColoredView!{
        didSet{

        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        theBGImageVIew.image = preloadedImage
        
    }
    
}



@IBDesignable class ColoredView: NSView {
    @IBInspectable var backgroundColor: NSColor = .clear
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        backgroundColor.set()
        dirtyRect.fill()
    }
}
