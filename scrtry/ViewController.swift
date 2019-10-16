//
//  ViewController.swift
//  scrtry
//
//  Created by badi3 on 10/5/19.
//  Copyright © 2019 Badi3. All rights reserved.
//

import Cocoa
import SQLite3

class ImageAspectFillView: NSImageView {
    
    
    
    override var image: NSImage? {
        
        set {
            
            self.layer = CALayer()
            
            self.layer?.contentsGravity = CALayerContentsGravity.resizeAspectFill
            
            self.layer?.contents = newValue
            
            self.wantsLayer = true
            
            
            
            super.image = newValue
            
        }
        
        
        
        get {
            
            return super.image
            
        }
        
    }
    
    
    
    
    
}

class ViewController: NSViewController {
    
    
  
    var preloadedImage : NSImage?
    @IBOutlet weak var theImage: NSImageView!
    @IBOutlet weak var imageCell: NSImageCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let preloadedImage = self.preloadedImage{
            theImage.image = preloadedImage
        }
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        if(preloadedImage == nil){
            //view.window!.styleMask.remove(.resizable)
        }

    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func setBGAction(_ sender: NSButton) {
        
        
        
        getCurrentDesktop()
        
        let random = randomString(length: 10)
        sender.title = random
        let workspace = NSWorkspace.shared
        let screens = NSScreen.screens
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!

        
        let oldBackground = screens
        
//        let fakeVC = self.storyboard!.instantiateController(withIdentifier: "ViewController") as! ViewController
//        fakeVC.preloadedImage = self.theImage.image
        let newRect = NSRect(x:0,y:0,width:1920,height:1080)
        self.view.window?.setFrame(newRect, display: true)
        
        

        let screenShot = NSImage.init(data: self.view.dataWithPDF(inside: self.view.bounds))!
        
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let result = screenShot.save(as: random)
        print(url)
        print(result)
        let imageURL = result.1!
        print(imageURL)

        for aScreen in screens{
            try! workspace.setDesktopImageURL(imageURL, for: aScreen, options: [:])
            
        }
        
        
        
    }
    
    
    func getCurrentDesktop(){
        
        var sqliteData : [String] = []
        
        let paths: [String] = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory,
                                                                  .userDomainMask, true)
        let appSup: String = paths.first!
        let dbPath: String = (appSup as NSString).appendingPathComponent("Dock/desktoppicture.db")
        
        var db: OpaquePointer? = nil
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            
            let sql = "SELECT * FROM data"
            var sel : OpaquePointer? = nil
            
            if(sqlite3_prepare_v2(db, sql, -1, &sel, nil) == SQLITE_OK) {
                
                while(sqlite3_step(sel) == SQLITE_ROW) {
                    var something = String(cString: sqlite3_column_text(sel, 0))
                    
                    var data = String.init(utf8String: something)
                    sqliteData.append(data!)
                }
            }
            
        }
        
        var cnt = sqliteData.count - 1;
        print("Desktop Picture \(sqliteData[cnt])")
        //print("sqliteData  \(sqliteData)")
        
        let fileURL = URL.init(fileURLWithPath: (sqliteData[cnt] as NSString).expandingTildeInPath)
        do {
            let imageData = try Data(contentsOf: fileURL)
            let image = NSImage(data: imageData)
            self.theImage.image = image
        } catch {
            print("Error loading image : \(error)")
        }
        
        
        sqlite3_close(db)
        
        
    }

    
}


//-(void)getCurrentDesktop {
//
//    NSMutableArray *sqliteData = [[NSMutableArray alloc] init];
//
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
//    NSString *appSup = [paths firstObject];
//    NSString *dbPath = [appSup stringByAppendingPathComponent:@"Dock/desktoppicture.db"];
//
//    sqlite3 *database;
//    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
//
//        const char *sql = "SELECT * FROM data";
//        sqlite3_stmt *sel;
//        if(sqlite3_prepare_v2(database, sql, -1, &sel, NULL) == SQLITE_OK) {
//
//            while(sqlite3_step(sel) == SQLITE_ROW) {
//                NSString *data = [NSString stringWithUTF8String:(char *)sqlite3_column_text(sel, 0)];
//                [sqliteData addObject:data];
//            }
//        }
//    }
//    NSUInteger cnt = [sqliteData count] - 1;
//    NSLog(@"Desktop Picture: %@", sqliteData[cnt]);
//    NSLog(@"%@",sqliteData);
//
//    sqlite3_close(database);
//}

func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
}

public class UIGraphicsImageRenderer {
    let size: CGSize
    
    init(size: CGSize) {
        self.size = size
    }
    
    func image(actions: (CGContext) -> Void) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocusFlipped(true)
        actions(NSGraphicsContext.current!.cgContext)
        image.unlockFocus()
        return image
    }
}

extension NSImage {
    @objc var CGImage: CGImage? {
        get {
            guard let imageData = self.tiffRepresentation else { return nil }
            guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
            return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
        }
    }
}


extension NSImage {
    func save(as fileName: String, fileType: NSBitmapImageRep.FileType = .jpeg, at directory: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)) -> (Bool, URL?) {
        guard let tiffRepresentation = tiffRepresentation, directory.hasDirectoryPath, !fileName.isEmpty else {
            
            
            
            return (false, nil) }
        do {
            let theURL = directory.appendingPathComponent(fileName).appendingPathExtension(fileType.pathExtension)
            try NSBitmapImageRep(data: tiffRepresentation)?
                .representation(using: fileType, properties: [:])?
                .write(to: theURL)
            return (true, theURL)
        } catch {

            print(error)
            
            return (false, nil)
        }
        
}


}

extension NSBitmapImageRep.FileType {
    var pathExtension: String {
        switch self {
        case .bmp:
            return "bmp"
        case .gif:
            return "gif"
        case .jpeg:
            return "jpg"
        case .jpeg2000:
            return "jp2"
        case .png:
            return "png"
        case .tiff:
            return "tif"
        }
    }
}
