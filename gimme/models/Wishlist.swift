//
//  Wishlist.swift
//  gimme
//
//  Created by Daniel Mihai on 10/02/2018.
//  Copyright © 2018 lepookey. All rights reserved.
//

import Foundation

class Wishlist {
    let identifier: String
    let name: String
    let description: String
    
    public init(identifier: String, name: String, description: String) {
        self.identifier = identifier
        self.name = name
        self.description = description
    }
}
