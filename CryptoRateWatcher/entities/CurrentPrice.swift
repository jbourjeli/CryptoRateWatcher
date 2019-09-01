//
//  CurrentPrice.swift
//  CryptoRate
//
//  Created by Joseph Bourjeli on 6/27/19.
//  Copyright © 2019 Work Smarter Computing LLC. All rights reserved.
//

import Foundation

struct UpdatedTime: Decodable {
    var updated: String
    var updatedISO: String
    var updateduk: String?
}

struct Rate: Decodable {
    var code: String
    var symbol: String
    var rate: String
    var rate_float: Float
    var description: String
}

struct Price: Decodable {
    var USD: Rate
    var GBP: Rate
    var EUR: Rate
}

struct CurrentPrice: Decodable {
    var time: UpdatedTime
    var disclaimer: String
    var chartName: String
    var bpi: Price
}
