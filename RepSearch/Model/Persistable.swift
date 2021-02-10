//
//  Persistable.swift
//  RepSearch
//
//  Created by  Елена on 08.02.2021.
//
import RealmSwift

public protocol Persistable {
    associatedtype ManagedObject: RealmSwift.Object
    init(managedObject: ManagedObject)
    func managedObject() -> ManagedObject
}
