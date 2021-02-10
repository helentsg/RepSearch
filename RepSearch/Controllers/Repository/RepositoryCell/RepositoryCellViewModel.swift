//
//  RepositoryCellViewModel.swift
//  RepSearch
//
//  Created by  Елена on 04.02.2021.
//

import UIKit

protocol RepositoryCellViewModelProtocol {
    
    var name : String? { get }
    
}

class RepositoryCellViewModel: RepositoryCellViewModelProtocol {
    
    var name : String?
    
    required init(repository: Repository?) {
        
        self.name = repository?.name
        
    }

}




