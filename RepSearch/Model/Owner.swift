//
//  Owner.swift
//  RepSearch
//
//  Created by  Елена on 04.02.2021.
//

import Foundation
import RealmSwift

struct Owner {
    
    public let urlString : String
    public var name : String
    public var email : String
    
    init(urlString: String, name: String = "", email: String = "") {
        self.urlString = urlString
        self.name = name
        self.email = email
    }

}

extension Owner : Hashable {
    
    static func == (lhs: Owner, rhs: Owner) -> Bool {
        lhs.urlString == rhs.urlString
    }
    
}

final class OwnerObject: Object {
    
    @objc dynamic var urlString = ""
    @objc dynamic var name = ""
    @objc dynamic var email = ""
    
    override static func primaryKey() -> String? {
        return "urlString"
    }
    
}

extension Owner: Persistable {
    public init(managedObject: OwnerObject) {
        urlString = managedObject.urlString
        name = managedObject.name
        email = managedObject.email
    }
    public func managedObject() -> OwnerObject {
        let owner = OwnerObject()
        owner.urlString = urlString
        owner.name = name
        owner.email = email
        return owner
    }
    
}
