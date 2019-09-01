//
//  CoindeskAPI.swift
//  CryptoRate
//
//  Created by Joseph Bourjeli on 6/27/19.
//  Copyright © 2019 Work Smarter Computing LLC. All rights reserved.
//

import Foundation

enum CoindeskClientError: Error {
    case HttpError(statusCode: Int, statusDescription: String)
    case NoHttpResponse
}

class CoindeskClientApi {
    let baseUrl = "https://api.coindesk.com/v1/bpi"

    func fetchCurrentPrice(resolve: @escaping (_ price: CurrentPrice) -> (), reject: @escaping (_ err:Error) -> ()?) {
        let session = URLSession.shared
        let url = URL(string: "\(baseUrl)/currentprice.json");

        session.dataTask(with: url!) { data, response, err in
            if let error = err {
                reject(error)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    if let data = data {
                        do {
                            let currentPrice = try JSONDecoder().decode(CurrentPrice.self, from: data)
                            resolve(currentPrice)
                        } catch let parseError {
                            reject(parseError)
                        }
                    }
                default:
                    reject(CoindeskClientError.HttpError(
                        statusCode: httpResponse.statusCode,
                        statusDescription: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)))
                }
            }
        }.resume()
    }
    
    func fetchHistory(between startDate: Date, and endDate: Date, resolve: @escaping (_ data: History) -> (), reject: @escaping (_ err: Error) -> ()?) {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let session = URLSession.shared
        let url = URL(string: "\(baseUrl)/historical/close.json?start=\(df.string(from: startDate))&end=\(df.string(from: endDate))")!

        session.dataTask(with: url) { data, response, err in
            do {
                let history = try self.processResponse(data: data, response: response, error: err)
                resolve(history)
            } catch let error {
                reject(error)
            }
        }.resume()
    }

    func fetchHistory(resolve: @escaping (_ data: History) -> (), reject: @escaping (_ err: Error) -> ()?) {
        let session = URLSession.shared
        let url = URL(string: "\(baseUrl)/historical/close.json")!

        session.dataTask(with: url) { data, response, err in
            if let error = err {
                reject(error)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    if let data = data {
                        do {
                            let history = try JSONDecoder().decode(History.self, from: data)
                            resolve(history)
                        } catch let parseError {
                            reject(parseError)
                        }
                    }
                default:
                    reject(CoindeskClientError.HttpError(
                        statusCode: httpResponse.statusCode,
                        statusDescription: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)))
                }
            }
        }.resume()
    }

    private func processResponse(data: Data?, response: URLResponse?, error: Error?) throws -> History {
        if let error = error {
            throw error
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200:
                if let data = data {
                    do {
                        let history = try JSONDecoder().decode(History.self, from: data)
                        return history
                    } catch let parseError {
                        throw parseError
                    }
                }
            default:
                throw CoindeskClientError.HttpError(
                    statusCode: httpResponse.statusCode,
                    statusDescription: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
            }
        }

        throw CoindeskClientError.NoHttpResponse
    }
}
