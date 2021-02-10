//
//  RepositoryViewModel.swift
//  RepSearch
//
//  Created by  Елена on 04.02.2021.
//

import Foundation
import RealmSwift

//MARK:- SelectedViewModelProtocol:
protocol RepositoryViewModelProtocol {
    
    var repositoryName : String { get }
    var repositoryDescription : String { get }
    var ownerName : String { get }
    var ownerEmail: String { get }
    var isSelected : Bool! { get set }
    func save()
    func removeFromSelected()
    
}

class RepositoryViewModel : RepositoryViewModelProtocol {
    
    private let container = try! Container()
    private var selected = [Repository]()
    
    private var repository: Repository
    var repositoryName : String
    var repositoryDescription : String
    var ownerName : String
    var ownerEmail: String
    var isSelected : Bool!
    
    init(repository: Repository) {
        
        self.repository = repository
        self.repositoryName = !repository.name.isEmpty ? repository.name : "Нет данных"
        self.repositoryDescription = !repository.repositoryDescription.isEmpty ? repository.repositoryDescription : "Нет данных"
        self.ownerName = !repository.owner.name.isEmpty ? repository.owner.name : "Нет данных"
        self.ownerEmail = !repository.owner.email.isEmpty ? repository.owner.email : "Нет данных"
        
        selected = container.selected()
        self.isSelected = isSelected(repository)
        
    }
    
}

//MARK:- Methods:
extension RepositoryViewModel {
    
    func save() {
        
        try! container.write { transaction in
            transaction.add(repository)
        }
        
    }
    
    func removeFromSelected() {
        
        try! container.write { transaction in
            transaction.delete(repository)
        }
        
    }
    
    func isSelected(_ repository: Repository) -> Bool {
        
        selected.contains(repository)
        
    }
    
}
