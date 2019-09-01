//
//  AboutWindow.swift
//  CryptoRate
//
//  Created by Joseph Bourjeli on 7/10/19.
//  Copyright © 2019 Work Smarter Computing LLC. All rights reserved.
//

import Cocoa

class AboutWindow: NSWindowController {

    @IBOutlet weak var versionLabel: NSTextField!

    var version = "1.0.0"
    
    override var windowNibName : String! {
        return "AboutWindow"
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.title = "About CryptoRateWatcher"
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.versionLabel.stringValue = "v\(self.version)"
    }    
}
