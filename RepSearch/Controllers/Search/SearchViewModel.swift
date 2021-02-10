//
//  SearchViewModel.swift
//  RepSearch
//
//  Created by  Елена on 04.02.2021.
//

import Foundation
import RealmSwift

protocol SearchViewModelDelegate: class {
    
  func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
  func onFetchFailed(with error: DataResponseError)
    
}

//MARK:- SearchViewModelProtocol:
protocol SearchViewModelProtocol {
    
    var lastQuery : String { get set }
    var totalCount: Int { get }
    var currentCount: Int { get }
    func repository(at indexPath: IndexPath) -> Repository
    func emptyCellViewModel() -> RepositoryCellViewModelProtocol?
    func cellViewModel(at indexPath: IndexPath) -> RepositoryCellViewModelProtocol?
    func fetchNewRepositories(with search: String, completion: @escaping (Result<[IndexPath], DataResponseError>) -> Void)
    func fetchRepositories(with search: String)
    func viewModelForSelectedRow(at indexPath: IndexPath) -> RepositoryViewModelProtocol?
    func selectedViewModel() -> SelectedViewModelProtocol? 
    func isLoadingCell(for indexPath: IndexPath) -> Bool
    
}

//MARK:- SearchViewModel:
class SearchViewModel : SearchViewModelProtocol {
    
    private weak var delegate: SearchViewModelDelegate?
    
    private var repositories: [Repository] = []
    private var currentPage = 1
    private var total = 0
    private var isFetchInProgress = false
    private let networkManager = NetworkManager()
    
    var lastQuery : String = ""
    
    var totalCount: Int {
        return total
    }
    
    var currentCount: Int {
        return repositories.count
    }
    
    func repository(at indexPath: IndexPath) -> Repository {
        return repositories[indexPath.row]
    }
    
    func emptyCellViewModel() -> RepositoryCellViewModelProtocol? {
        return RepositoryCellViewModel(repository: .none)
    }
    
    func cellViewModel(at indexPath: IndexPath) -> RepositoryCellViewModelProtocol? {
        let repository = repositories[indexPath.row]
        return RepositoryCellViewModel(repository: repository)
    }
    
    func viewModelForSelectedRow(at indexPath: IndexPath) -> RepositoryViewModelProtocol? {
        let repository = repositories[indexPath.row]
        return RepositoryViewModel(repository: repository)
    }
    
    func selectedViewModel() -> SelectedViewModelProtocol? {
        return SelectedViewModel()
    }
    
    init(delegate: SearchViewModelDelegate) {
      self.delegate = delegate
    }
    
}

//MARK:- Fetch new repositories / Pull To Refresh Implementation:
extension SearchViewModel {
    
    func fetchNewRepositories(with search: String, completion: @escaping (Result<[IndexPath], DataResponseError>) -> Void)  {
        
        guard !isFetchInProgress else {
            return
        }
        isFetchInProgress = true
        networkManager.fetchRepositories(with: search, page: 0) {[weak self] result in
            
            guard let self = self else {
                return
            }
            self.isFetchInProgress = false
            
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            case .success(let response):
                let newRepositories = self.new(from: response.repositories)
                self.repositories = newRepositories + self.repositories
                let newIndexPaths = self.indexPaths(for: newRepositories)
                DispatchQueue.main.async {
                    completion(.success(newIndexPaths))
                }
            }
        }
    }
    
    func new(from fetchedRepositories: [Repository]) -> [Repository] {
        
        let fetchedSet = Set(fetchedRepositories)
        let set = Set(repositories)
        let new = Array(fetchedSet.subtracting(set))
        return new
        
    }
    
    func indexPaths(for newRepositories: [Repository]) -> [IndexPath] {
        let rows = Array(0 ..< newRepositories.count)
        return rows.map({ IndexPath(row: $0, section: 0)})
    }
    
}

//MARK:- Fetch new repositories from next pages / Infinite Scrolling (Pagination) Implementation:
extension SearchViewModel {
    
    func fetchRepositories(with search: String)  {
        
        guard !isFetchInProgress else {
            return
        }
        
        networkManager.fetchRepositories(with: search, page: currentPage) {[weak self] result in
            
            guard let self = self else {
                return
            }
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isFetchInProgress = false
                    self.delegate?.onFetchFailed(with: error)
                }
            case .success(let response):
                DispatchQueue.main.async {
                self.currentPage += 1
                self.isFetchInProgress = false
                self.total = response.total
                self.repositories.append(contentsOf: response.repositories)
                    if self.currentPage > 2 {
                      let indexPathsToReload = self.calculateIndexPathsToReload(from: response.repositories)
                      self.delegate?.onFetchCompleted(with: indexPathsToReload)
                    } else {
                      self.delegate?.onFetchCompleted(with: .none)
                    }
                }
            }
        }
    }
    
    private func calculateIndexPathsToReload(from newRepositories: [Repository]) -> [IndexPath] {
        let startIndex = repositories.count - newRepositories.count
        let endIndex = startIndex + newRepositories.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= currentCount
    }
    
}
