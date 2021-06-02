//
//  SearchResult.swift
//  GameQ
//
//  Created by Ahmed Abdalla on 11/25/20.
//

import Foundation

class ResultArray: Codable {
    var count = 0                   // Number of results
    var next: String? = ""          // Link to next page
    var previous: String? = ""      // Link to previous page
    var results = [SearchResult]()  // Array of result objects
}

class SearchResult: Codable, CustomStringConvertible {
    var gameSlug: String = ""
    var gameName: String = ""
    
    enum CodingKeys: String, CodingKey {
        case gameSlug = "slug"
        case gameName = "name"
    }
    
    // Describe result object
    var description: String {
        return "Game: \(gameName)"
    }
}
