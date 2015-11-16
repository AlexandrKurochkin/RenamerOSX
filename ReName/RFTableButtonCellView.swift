//
//  RFTableButtonCellView.swift
//  ReName
//
//  Created by MaxVorobyov on 10/23/15.
//  Copyright © 2015 Head-System. All rights reserved.
//

import Cocoa

class RFTableButtonCellView: NSTableCellView {

    var url: NSURL?
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    @IBAction func removeClick(sender: AnyObject) {
        RFDataController.sharedInstance.removeFileAtUrl(url)
    }
    
}
