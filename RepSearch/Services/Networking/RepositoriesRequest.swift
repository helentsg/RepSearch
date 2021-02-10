//
//  RepositoriesRequest.swift
//  RepSearch
//
//  Created by  Елена on 04.02.2021.
//

import Foundation

struct RepositoriesRequest {
    
    var path: String {
        return "search/repositories"
    }
    let parameters: Parameters
    
    init(with search: String) {
        
        let defaultParameters = ["sort": "stars", "order": "desc"]
        let parameters = ["q": "\(search)"].merging(defaultParameters, uniquingKeysWith: +)
        self.parameters = parameters
        
    }
    
}
