//
//  History.swift
//  CryptoRate
//
//  Created by Joseph Bourjeli on 7/12/19.
//  Copyright © 2019 Work Smarter Computing LLC. All rights reserved.
//

import Foundation

struct History: Decodable {
    var bpi: [String:Double]
    var disclaimer: String
    var time: UpdatedTime
}
