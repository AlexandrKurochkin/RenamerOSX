//
//  RFDataController.swift
//  ReName
//
//  Created by MaxVorobyov on 10/20/15.
//  Copyright © 2015 Head-System. All rights reserved.
//

import Cocoa

internal class RFDataController {
    static let sharedInstance = RFDataController()
    
    /*
    * MARK: internal
    */
    internal var dataDelegate: RFDataControllerProtocol?
    
    
    internal func addFileAtUrl(file: NSURL){
        do {
            let filePath: String = file.path!
            let fileAttributes: NSDictionary = try self.fileManager.attributesOfItemAtPath(filePath)
            let type = fileAttributes.objectForKey(NSFileType)
            if ( type?.isEqualToString(NSFileTypeDirectory)  == true) {
                let files = try self.fileManager.contentsOfDirectoryAtURL(file, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
                for url: NSURL in files {
                    self.addFileAtUrl(url)
                }
            } else {
                self.filesArray.addObject(file);
                if(self.dataDelegate  != nil){
                    self.dataDelegate?.dataController(self, addFileAtUrl: file)
                }
            }
        } catch {
            if(self.dataDelegate  != nil){
                self.dataDelegate?.dataController(self, errorInFileAtUrl: file, textError: "Error")
            }
        }
    }
    
    
    internal func removeFileAtUrl(file: NSURL?){
        if ((file) != nil){
            self.filesArray.removeObject(file!)
            self.dataDelegate?.dataController(self, removeFileAtUrl: file!)
        }
    }
    
    internal func cleanAllFiles(){
        self.filesArray.removeAllObjects();
    }
    
    internal func alertAtText(text:String){
        let alert = NSAlert()
        alert.messageText = text
        alert.beginSheetModalForWindow(NSApp.windows.first!, completionHandler: nil)
    }
    
    internal func files() -> NSArray{
        let array:NSArray = NSArray(array: self.filesArray)
        return array
    }
    

    internal func copyFilesToFolder(fURL:String, format:String){
        
        do{
            try self.fileManager.createDirectoryAtPath(fURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            let error = "ERROR: Folder \(fURL) no created"
            print(error)
            self.alertAtText(error)
            return
        }
        
        
        for var i = 0; i<self.filesArray.count; ++i{
            
            let fileURL: NSURL = self.filesArray[i] as! NSURL
            
            let fileName: NSString = fileURL.lastPathComponent!
            let components: NSMutableArray = NSMutableArray(array: fileName.componentsSeparatedByString("."))
            
            let fileNameAndOldFormat: NSString = fileName
            
            if (fileName.containsString(".")){
                
                components.removeLastObject()
            }
            
            
           
            
            components.addObject(format)
            let fileNameAndNewFormat = components.componentsJoinedByString(".")
            var newPath: String

            if (self.fileManager.fileExistsAtPath(NSString(format: "%@%@", fURL, fileNameAndNewFormat).description)) {
                newPath = NSString(format: "%@%@.%@", fURL, fileNameAndOldFormat, format).description
            } else {
                newPath = NSString(format: "%@%@", fURL, fileNameAndNewFormat).description
            }
            
            //print(stringPath.description)
            print("AT:  \(fileURL)")
            print("TO:  " + newPath)
            let newLink: NSURL = NSURL(fileURLWithPath: newPath)
            
            do{
                try self.fileManager.copyItemAtURL(fileURL, toURL: newLink)
            } catch {
                let error = "ERROR: File \(newLink) no created"
                print(error)
                self.alertAtText(error)
                return
            }
            
            self.filesArray[i] = newLink
            self.dataDelegate?.dataController(self, addFileAtUrl: newLink)
            print("+")
        }
        
    }
    
    /*
    * MARK: private
    */
    
    private let filesArray: NSMutableArray = NSMutableArray()
    private let fileManager: NSFileManager = NSFileManager.defaultManager()
}

internal protocol RFDataControllerProtocol{
    
    func dataController(dataController: RFDataController, addFileAtUrl: NSURL)
    
    func dataController(dataController: RFDataController, removeFileAtUrl: NSURL)
    
    func dataController(dataController: RFDataController, errorInFileAtUrl: NSURL, textError: String)
}
