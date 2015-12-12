//
//  Token.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

struct Token: Decodable
{
    let tokenID: String
    let username: String
    let profilePic: String?
    
    static func decodeJSON(j: JSON) throws -> Token {
        return Token(
            tokenID: try decode(j, key: "access_token"),
            username: try decode(j, key: "userName"),
            profilePic: try decodeOptional(j, key: "profilePicURL")
        )
    }
}