//
//  StackExchangeClient.swift
//  RepSearch
//
//  Created by  Елена on 04.02.2021.
//

import Foundation
import SwiftyJSON

final class NetworkManager {
    
    private lazy var baseURL: URL = {
        return URL(string: "https://api.github.com")!
    }()
    
    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func fetchRepositories(with search: String, page: Int, completion: @escaping (Result<PagedRepositoryResponse, DataResponseError>) -> Void) {
        
        let request = RepositoriesRequest(with: search)
        let urlRequest = URLRequest(url: baseURL.appendingPathComponent(request.path))
        let parameters = ["page": "\(page)"].merging(request.parameters, uniquingKeysWith: +)
        let encodedURLRequest = urlRequest.encode(with: parameters)
        
        session.dataTask(with: encodedURLRequest, completionHandler: {[weak self] data, response, error in
            
            guard let self = self else {
                return
            }
            
            if let error = error {
                /// No Internet Connection
                if error._code == NSURLErrorNotConnectedToInternet {
                    completion(.failure(.offline))
                    return
                    
                } else {
                    completion(.failure(.error(description: error.localizedDescription)))
                    return
                }
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.hasSuccessStatusCode,
                  let data = data,
                  let json = try? JSON(data: data)
            else {
                completion(.failure(DataResponseError.network))
                return
            }
            
            self.decode(json, completion: completion)
            
        }).resume()
    }
    
    func decode(_ json: JSON, completion: @escaping (Result<PagedRepositoryResponse, DataResponseError>) -> Void) {
        
        let repositories : [Repository] = json["items"].arrayValue.map { repositoryJSON in
            
            let ownerJSON = repositoryJSON["owner"]
            let owner = Owner(urlString: ownerJSON["url"].stringValue)
            
            let repository = Repository(id: repositoryJSON["id"].intValue,
                                        name: repositoryJSON["full_name"].stringValue,
                                        repositoryDescription: repositoryJSON["description"].stringValue,
                                        owner: owner)
            return repository
        }
        
        let total: Int = json["total_count"].intValue
        guard let incompleteResults = json["incomplete_results"].bool else {
            completion(.failure(DataResponseError.decoding))
            return
        }
        let hasMore : Bool = !incompleteResults
        
        fetchMissingOwnerDetails(for: repositories) { (result) in
            switch result {
            case .success(let fetchedRepositories):
                let pagedRepositoryResponse = PagedRepositoryResponse(repositories: fetchedRepositories,
                                                                      total: total,
                                                                      hasMore: hasMore)
                completion(.success(pagedRepositoryResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    func fetchMissingOwnerDetails(for repositories: [Repository], completion: @escaping (Result<[Repository], DataResponseError>) -> Void) {
        
        var resultRepositories = [Repository]()
        
        let serialQueue = DispatchQueue(label: "com.elenatsegelnik.serialQueue", qos: .userInitiated)
        
        serialQueue.sync() { [weak self] in
            
            guard let self = self else {
                return
            }
            
            for repository in repositories {
                
                guard let url = URL(string:repository.owner.urlString) else {
                    completion(.failure(DataResponseError.network))
                    return
                }
                
                self.session.dataTask(with: url, completionHandler: { data, response, error in
                    
                    
                    if let error = error {
                        /// No Internet Connection
                        if error._code == NSURLErrorNotConnectedToInternet {
                            
                            completion(.failure(.offline))
                            return
                            
                        } else {
                            
                            completion(.failure(.error(description: error.localizedDescription)))
                            return
                        }
                    }
                    
                    // API Errors (Limit Exceeded or something else)
                    if let httpResponse = response as? HTTPURLResponse,
                       !httpResponse.hasSuccessStatusCode,
                       let data = data,
                       let json = try? JSON(data: data) {
                        let message = json["message"].stringValue
                        let isLimitError = message.contains("API rate limit exceeded")
                        let error : DataResponseError = isLimitError ? .limit : .error(description: message)
                        
                        completion(.failure(error))
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.hasSuccessStatusCode,
                          let data = data,
                          let json = try? JSON(data: data)
                    else {
                        
                        completion(.failure(DataResponseError.network))
                        return
                    }
                    
                    let ownerFetched = Owner(urlString: repository.owner.urlString, name: json["name"].stringValue, email: json["email"].stringValue)
                    
                    let repositoryFetched = Repository(id: repository.id,
                                                       name: repository.name,
                                                       repositoryDescription: repository.repositoryDescription,
                                                       owner : ownerFetched )
                    
                    resultRepositories.append(repositoryFetched)
                    
                    if resultRepositories.count == repositories.count {
                        completion(.success(resultRepositories))
                    }
                    
                }).resume()
            }
            
        }
        
    }
    
}

