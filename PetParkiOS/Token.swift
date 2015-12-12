//
//  Token.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

final class Token: Decodable
{
    let tokenID: String
    let username: String
    let profilePic: String?
    
    init(tokenID: String, username: String, profilePic: String?) {
        self.tokenID = tokenID
        self.username = username
        self.profilePic = profilePic
    }
    
    static func decodeJSON(j: JSON) throws -> Token {
        return Token(
            tokenID: try decode(j, key: "access_token"),
            username: try decode(j, key: "userName"),
            profilePic: try decodeOptional(j, key: "profilePicURL")
        )
    }
}