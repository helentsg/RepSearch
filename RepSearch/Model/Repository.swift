//
//  Repository.swift
//  RepSearch
//
//  Created by  Елена on 04.02.2021.
//

import Foundation
import RealmSwift

struct Repository {
    
    public let id : Int
    public let name : String
    public let repositoryDescription : String
    
    public var owner: Owner
    
}

extension Repository : Hashable {
    
    static func == (lhs: Repository, rhs: Repository) -> Bool {
        lhs.id == rhs.id && lhs.owner == rhs.owner
    }
    
}

final class RepositoryObject: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var repositoryDescription = ""
    
    @objc dynamic var owner: OwnerObject!
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Repository: Persistable {
    
    public init(managedObject: RepositoryObject) {
        id = managedObject.id
        name = managedObject.name
        repositoryDescription = managedObject.repositoryDescription
        owner = Owner(urlString: managedObject.owner.urlString,
                                      name: managedObject.owner.name,
                                      email: managedObject.owner.email)
    }
    
    public func managedObject() -> RepositoryObject {
        let ownerObject = OwnerObject(value: [
            "urlString" : owner.urlString,
            "name"      : owner.name,
            "email"     : owner.email
        ])
        
        let repositoryObject = RepositoryObject(value:[
            "id"        : id,
            "name"      : name,
            "repositoryDescription" : repositoryDescription,
            "owner"     : ownerObject
        ])
        return repositoryObject
    }
    
}
