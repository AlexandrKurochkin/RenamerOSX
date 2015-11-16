//
//  ViewController.swift
//  ReName
//
//  Created by MaxVorobyov on 10/20/15.
//  Copyright (c) 2015 Head-System. All rights reserved.
//

import Cocoa

let kRFFileName     = "fileName"
let kRFFormat       = "format"
let kRFSize         = "size"
let kRFPath         = "path"
let kRFRemove       = "remove"
let kRFDefSavePath  = NSHomeDirectory() + "/Documents/Rename Format/"

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, RFDataControllerProtocol {
    /*
    *   MARK:Outlets
    */
    @IBOutlet weak var filesTable: NSTableView!
    @IBOutlet weak var formatField: NSTextField!
    @IBOutlet weak var pathField: NSTextField!
    @IBOutlet weak var saveToFormatCheckBox: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pathField.stringValue = kRFDefSavePath
        RFDataController.sharedInstance.dataDelegate = self
        //RFDataController.sharedInstance.alertAtText("test")
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    /*
    *   MARK: Actions
    */
    
    @IBAction func addFilesClick(sender: NSButton) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        
        panel.beginWithCompletionHandler { (result: Int) -> Void in
            //let dc = RFDataController.sharedInstance
            if(result == NSFileHandlingPanelOKButton){
                for url in panel.URLs {
                    RFDataController.sharedInstance.addFileAtUrl(url)
                }
            }
        }
    }
    
    @IBAction func startClick(sender: NSButton) {
        var url = self.pathField.stringValue
        if (self.saveToFormatCheckBox.state == NSOnState)&&(self.formatField!.stringValue != "") {
            url +=  self.formatField.stringValue + "/"
        }
        RFDataController.sharedInstance.copyFilesToFolder(url, format: self.formatField.stringValue)
    }
    
    @IBAction func cleanTableClick(sender: NSButton) {
        RFDataController.sharedInstance.cleanAllFiles()
        self.filesTable.reloadData()
    }
    
    @IBAction func savePathClick(sender: NSButton) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.beginWithCompletionHandler { (result: Int) -> Void in
            if(result == NSFileHandlingPanelOKButton){
                self.pathField.stringValue = (panel.URL?.path)!
            }
        }
    }
    
    
    /*
    *   MARK:Table View Data Source
    */
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return RFDataController.sharedInstance.files().count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellView: NSTableCellView
        let file:NSURL = RFDataController.sharedInstance.files().objectAtIndex(row) as! NSURL
        let filePath: String = file.path!
        var fileAttributes: NSDictionary
        
        do {
            fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(filePath)
        } catch {
            let error = "ERROR: Read failed: \(filePath)"
            print(error)
            RFDataController.sharedInstance.alertAtText(error)
            return tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        }
            switch tableColumn!.identifier {
                case kRFFileName: cellView = createTextCellWithStrind(file.lastPathComponent!, tableColumn: tableColumn!, tableView: tableView)
                
                case kRFPath: cellView = createTextCellWithStrind(file.path!, tableColumn: tableColumn!, tableView: tableView)
                case kRFSize: cellView = createTextCellWithStrind((fileAttributes.objectForKey(NSFileSize)?.stringValue)!, tableColumn: tableColumn!, tableView: tableView)
                case kRFFormat:
                    if (!file.lastPathComponent!.containsString(".")){
                        cellView = createTextCellWithStrind(" ", tableColumn: tableColumn!, tableView: tableView)
                    } else {
                        cellView = createTextCellWithStrind(file.lastPathComponent!.componentsSeparatedByString(".").last!, tableColumn: tableColumn!, tableView: tableView)
                    }
                
                case kRFRemove:
                    cellView = createRemoveCellWithURL(file, tableColumn: tableColumn!, tableView:tableView)
                
            default:
                cellView = createTextCellWithStrind(" ", tableColumn: tableColumn!, tableView:tableView)
            }
        
        return cellView
    }
    
    func createTextCellWithStrind(text: String, tableColumn: NSTableColumn, tableView:NSTableView) -> NSTableCellView{
        let cellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn.identifier, owner: self) as! NSTableCellView
        cellView.textField!.stringValue = text
        return cellView
    }
    
    func createRemoveCellWithURL(url: NSURL, tableColumn: NSTableColumn, tableView:NSTableView) -> NSTableCellView{
        let cellRemoveView: RFTableButtonCellView = tableView.makeViewWithIdentifier(tableColumn.identifier, owner: self) as! RFTableButtonCellView
        
        cellRemoveView.url = url
        return cellRemoveView
    }
    
    /*
    *   MARK:Table View Delegate
    */
    
    
    
    /*
    *   MARK:Data Controller Protocol
    */
    
    func dataController(dataController: RFDataController, addFileAtUrl: NSURL) {
        self.filesTable.reloadData()
    }
    
    func dataController(dataController: RFDataController, removeFileAtUrl: NSURL) {
        self.filesTable.reloadData()
    }
    
    func dataController(dataController: RFDataController, errorInFileAtUrl: NSURL, textError: String) {
        
    }

}

