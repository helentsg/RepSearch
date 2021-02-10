//
//  Container.swift
//  RepSearch
//
//  Created by  Елена on 08.02.2021.
//

import RealmSwift

public final class Container {
    
    private let realm: Realm
    private lazy var selectedObjects: Results<RepositoryObject> = { self.realm.objects(RepositoryObject.self) }()
    
    public convenience init() throws {
        try self.init(realm: Realm())
    }
    internal init(realm: Realm) {
        self.realm = realm
        
    }
    public func write(_ block: (WriteTransaction) throws -> Void)
    throws {
        let transaction = WriteTransaction(realm: realm)
        try realm.write {
            try block(transaction)
        }
    }
    
    func selected() -> [Repository] {
        selectedObjects.map({Repository(managedObject: $0)})
    }
    
}

