//
//  PriceView.swift
//  CryptoRate
//
//  Created by Joseph Bourjeli on 6/27/19.
//  Copyright © 2019 Work Smarter Computing LLC. All rights reserved.
//

import Cocoa

class PriceView: NSView {

    @IBOutlet weak var priceUSD: NSTextField!
    @IBOutlet weak var lastUpdatedTextField: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    func update(price: CurrentPrice) {
        let updatedDate = ISO8601DateFormatter().date(from: price.time.updatedISO)!

        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        self.lastUpdatedTextField.stringValue = df.string(from: updatedDate)
        self.priceUSD.stringValue = Formatters.currencyFormatter().string(from: price.bpi.USD.rate_float as NSNumber) ?? price.bpi.USD.rate
    }
}
