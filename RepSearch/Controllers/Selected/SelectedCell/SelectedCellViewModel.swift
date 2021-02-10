//
//  SelectedCellViewModel.swift
//  RepSearch
//
//  Created by  Елена on 07.02.2021.
//

import UIKit

protocol SelectedCellViewModelProtocol {
    
    var name : String? { get }
    
}

class SelectedCellViewModel: SelectedCellViewModelProtocol {
    
    var name : String?
    
    required init(repository: Repository?) {
        
        self.name = repository?.name
        
    }

}


