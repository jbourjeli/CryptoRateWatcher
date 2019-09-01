//
//  StatusMenuController.swift
//  CryptoRate
//
//  Created by Joseph Bourjeli on 6/27/19.
//  Copyright © 2019 Work Smarter Computing LLC. All rights reserved.
//

import Cocoa

class StatusMenuController: NSViewController {

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var rateUSD: NSMenuItem!
    @IBOutlet weak var priceView: PriceView!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let coindeskClient = CoindeskClientApi()
    var aboutWindow: AboutWindow!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func awakeFromNib() {
        if let statusItemButton = statusItem.button {
            let icon = NSImage(named: "StatusIcon")
            icon?.isTemplate = true // best for dark mode
            

            statusItemButton.imagePosition = NSControl.ImagePosition.imageLeft;
            statusItemButton.alignment = NSTextAlignment.left
            statusItemButton.image = icon
        }

        statusItem.menu = statusMenu

        if let priceMenuItem = statusMenu.item(withTitle: "Price") {
            priceMenuItem.view = priceView
        }

        self.updateRates()

        self.aboutWindow = AboutWindow()
    }
    
    func updateRates() {
        coindeskClient.fetchCurrentPrice(resolve: { [unowned self] currentPrice in
            DispatchQueue.main.async {
                self.priceView.update(price: currentPrice)
                self.statusItem.button?.title = Formatters.currencyFormatter().string(from: currentPrice.bpi.USD.rate_float as NSNumber) ?? currentPrice.bpi.USD.rate
            }
        }, reject: { error in
            print("Error: \(error)")
        })
    }

    // MARK: - IBActions
    @IBAction func aboutAction(_ sender: NSMenuItem) {
        self.aboutWindow.showWindow(nil)
    }

    @IBAction func updateAction(_ sender: NSMenuItem) {
        self.updateRates()
    }

    @IBAction func showHistory(_ sender: NSMenuItem) {
        let historyWindow = HistoryWindow();
        historyWindow.coindeskClient = self.coindeskClient
        historyWindow.showWindow(nil)
    }

    @IBAction func quitAction(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}
