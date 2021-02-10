//
//  SelectedViewModel.swift
//  RepSearch
//
//  Created by  Елена on 04.02.2021.
//

import RealmSwift
import UIKit

//MARK:- SelectedViewModelProtocol:
protocol SelectedViewModelProtocol {
    
    var isEmpty: Bool { get }
    var currentCount: Int { get }
    func repository(at indexPath: IndexPath) -> Repository
    func cellViewModel(at indexPath: IndexPath) -> SelectedCellViewModelProtocol?
    func viewModelForSelectedRow(at indexPath: IndexPath) -> RepositoryViewModelProtocol?
    func remove(at indexPath: IndexPath)
    func updateSelected()
    
}

class SelectedViewModel : SelectedViewModelProtocol {
    
    private let container = try! Container()
    private var selected = [Repository]()
    
    var isEmpty: Bool {
        return selected.isEmpty
    }
    
    var currentCount: Int {
        return selected.count
    }
    
    func repository(at indexPath: IndexPath) -> Repository {
        return selected[indexPath.row]
    }
    
    func cellViewModel(at indexPath: IndexPath) -> SelectedCellViewModelProtocol? {
        let repository = selected[indexPath.row]
        return SelectedCellViewModel(repository: repository)
    }
    
    func viewModelForSelectedRow(at indexPath: IndexPath) -> RepositoryViewModelProtocol? {
        let repository = selected[indexPath.row]
        return RepositoryViewModel(repository: repository)
    }
    
    init() {
        updateSelected()
    }
    
}

//MARK:- Methods:
extension SelectedViewModel {
    
    func updateSelected() {
        selected = container.selected()
    }
    
    func remove(at indexPath: IndexPath) {
        
        let repository = selected[indexPath.row]
        selected.remove(at: indexPath.row)
        try! container.write { transaction in
            transaction.delete(repository)
        }
        
    }
    
}
