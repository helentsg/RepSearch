//
//  PagedRepositoryResponse.swift
//  RepSearch
//
//  Created by  Елена on 04.02.2021.
//

import Foundation

struct PagedRepositoryResponse {
    
    let repositories: [Repository]
    let total: Int
    let hasMore : Bool
    
}

