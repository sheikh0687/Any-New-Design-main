//
//  CurrentShiftAlert.swift
//  Any
//
//  Created by Arbaz  on 15/04/26.
//

import Foundation
import SwiftyJSON

enum CurrentShiftAlert: Identifiable {
    case confirmDelete(JSON)
    case confirmUpdate(JSON)
    case error(String)
 
    var id: String {
        switch self {
        case .confirmDelete(let j): return "delete-\(j["id"].stringValue)"
        case .confirmUpdate(let j): return "update-\(j["id"].stringValue)"
        case .error(let m):         return "error-\(m)"
        }
    }
}
