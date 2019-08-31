//
//  TendermintRequester.swift
//  Async
//
//  Created by Leandro Costa on 31/08/2019.
//

import Foundation

class TendermintRequester {

    static func transfer(woloxCoins: Int, to: String, origin: String, restManager: RestManager) {
        guard let url = URL(string: "https://reqres.in/api/users") else { return }
        
//        restManager.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
//        restManager.httpBodyParameters.add(value: String(woloxCoins), forKey: "quantity")
        restManager.httpBodyParameters.add(value: "John", forKey: "name")
        restManager.httpBodyParameters.add(value: "Developer", forKey: "job")
        restManager.httpBodyParameters.add(value: to, forKey: "target")
        
        restManager.makeRequest(toURL: url, withHttpMethod: .post) { (results) in
            guard let response = results.response else { return }
            if response.httpStatusCode == 201 {
                print("Everything OK")
                // guard let data = results.data else { return }
                // let decoder = JSONDecoder()
                // TODO: Do something with the response
            }
        }
    }



    static func getWoloxCoins(from: String,  restManager: RestManager) {
        guard let url = URL(string: "https://reqres.in/api/users/1") else { return }
        
        restManager.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            print("Everything OK")
            //if let data = results.data {
            //    let decoder = JSONDecoder()
            //    decoder.keyDecodingStrategy = .convertFromSnakeCase
            //}
            // TODO: Transform the tendermint response
        }
    }
}
