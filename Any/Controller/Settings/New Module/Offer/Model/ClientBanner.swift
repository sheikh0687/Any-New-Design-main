//
//  ClientBanner.swift
//  Any
//
//  Created by Arbaz  on 15/05/26.
//

import Foundation

struct Api_ClientBannerList : Codable {
    let result : [Res_ClientBannerList]?
    let message : String?
    let status : String?

    enum CodingKeys: String, CodingKey {

        case result = "result"
        case message = "message"
        case status = "status"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        result = try values.decodeIfPresent([Res_ClientBannerList].self, forKey: .result)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        status = try values.decodeIfPresent(String.self, forKey: .status)
    }
}

struct Res_ClientBannerList : Codable {
    let id : String?
    let title : String?
    let description : String?
    let image : String?
    let exp_date : String?
    let date_time : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case title = "title"
        case description = "description"
        case image = "image"
        case exp_date = "exp_date"
        case date_time = "date_time"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        exp_date = try values.decodeIfPresent(String.self, forKey: .exp_date)
        date_time = try values.decodeIfPresent(String.self, forKey: .date_time)
    }

}
