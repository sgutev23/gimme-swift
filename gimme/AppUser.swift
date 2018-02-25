//
//  Friend.swift
//  gimme
//
//  Created by Stan Gutev on 25.02.18.
//  Copyright © 2018 lepookey. All rights reserved.
//

import Foundation
class AppUser {
    var email: String?
    var profileImageUrl: String?
    var name: String?
    var identifier: String?
    var isFollowing: Bool?
    
    public init(identifier: String, name: String, email:String, profileImageUrl: String) {
        self.identifier = identifier
        self.name = name
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.isFollowing = false
    }
}
