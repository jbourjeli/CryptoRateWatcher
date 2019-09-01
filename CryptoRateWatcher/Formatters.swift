//
//  Formatters.swift
//  CryptoRate
//
//  Created by Joseph Bourjeli on 6/27/19.
//  Copyright © 2019 Work Smarter Computing LLC. All rights reserved.
//

import Foundation

class Formatters {
    static func currencyFormatter() -> NumberFormatter {
        let cf = NumberFormatter()
        cf.locale = Locale.current
        cf.numberStyle = .currency
        
        return cf
    }
}
