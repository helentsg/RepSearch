//
//  HTTPURLResponse.swift
//  RepSearch
//
//  Created by  Елена on 04.02.2021.
//

import Foundation

extension HTTPURLResponse {
    var hasSuccessStatusCode: Bool {
        return 200...299 ~= statusCode
    }
}
