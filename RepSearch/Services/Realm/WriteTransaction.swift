//
//  WriteTransaction.swift
//  RepSearch
//
//  Created by  Елена on 08.02.2021.
//
import RealmSwift

public final class WriteTransaction {
    private let realm: Realm
    private lazy var selected: Results<RepositoryObject> = { self.realm.objects(RepositoryObject.self) }()

    internal init(realm: Realm) {
        self.realm = realm
    }
    func add(_ value: Repository) {
        realm.add(value.managedObject(), update: .modified)
    }
    
    func delete(_ value: Repository) {
        if let storedObject = selected.filter({$0.id == value.id}).first {
            realm.delete(storedObject)
        }
    }
    
}
