//
//  GameDetails.swift
//  GameQ
//
//  Created by Ahmed Abdalla on 12/2/20.
//

import Foundation

protocol GameDetailsDelegate: class {
    func getGameDetails(gameSlug: String)
}

weak var delegate: GameDetailsDelegate?

class GameDetails: Codable, CustomStringConvertible {
    
    var id: Int
    var slug: String = ""
    var name: String = ""
    var name_original: String = ""
    var description: String = ""
    var metacritic: Int?
    var metacritic_platforms: [metacritic_platform]?
    var released: String? = ""
    var background_image: String? = ""
    var website: String? = ""
    var rating: Double?
    var playtime: Int?
    var reddit_url: String? = ""
    var reddit_name: String? = ""
    var reddit_count: Int?
    var twitch_count: Int?
    var youtube_count: Int?
    var metacritic_url: String?
    var developers: [developer]?
    var platforms: [Platform]?
    var stores: [store]?
    var genres: [genre]?
    var publishers: [publisher]?
    var esrb_rating: rating?
    
    enum CodingKeys: String, CodingKey {
        case id, slug, name, name_original, description, metacritic,
             metacritic_platforms, released, background_image, website,
             rating, playtime, reddit_url, reddit_name, developers, platforms,
             stores, genres, publishers, esrb_rating, metacritic_url
    }
    
    struct meta_platform_details: Codable {
        var platform: Int
        var name: String
        var slug: String
    }
    
    struct platform_details: Codable {
        var id: Int
        var name: String
        var slug: String
        var Image: String?
        var year_end: Int?
        var year_start: Int?
        var games_count: Int?
        var image_background: String?
    }
    
    struct store_details: Codable {
        var id: Int
        var name: String
        var slug: String
        var domain: String
        var games_count: Int
        var image_background: String
    }
    
    struct requirement: Codable {
        var minimum: String?
        var recommended: String?
    }
    
    struct metacritic_platform: Codable {
        var metascore: Int
        var url: String
        var platform: meta_platform_details
    }
    
    struct developer: Codable {
        var id: Int
        var name: String
        var slug: String
        var games_count: Int
        var image_background: String
    }
    
    struct Platform: Codable {
        var platform: platform_details
        var released_at: String?
        var requirements: requirement?
    }
    
    struct store: Codable {
        var id: Int
        var url: String
        var store: store_details
    }
    
    struct genre: Codable {
        var id: Int
        var name: String
        var slug: String
        var games_count: Int
        var image_background: String
    }
    
    struct publisher: Codable {
        var id: Int
        var name: String
        var slug: String
        var games_count: Int
        var image_background: String
    }
    
    struct rating: Codable {
        var id: Int
        var name: String
        var slug: String
    }
}
