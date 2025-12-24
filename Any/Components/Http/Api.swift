//
//  Api.swift
//  Any
//
//  Created by Techimmense Software Solutions on 19/04/24.
//

import Foundation
import UIKit
import Network

class Api: NSObject {
    
    static let shared = Api()
    
    private override init(){}
    
    func add_Card(_ vc: UIViewController, _ params: [String: Any], _ success: @escaping(_ responseData : Any) -> Void) {
        CommunicationManager.callPostService(apiUrl: Router.save_CardStripe.url(), parameters: params, parentViewController: vc, successBlock: { response, message in
            success(response)
        }) { error in
            vc.alert(alertmessage: error.localizedDescription)
        }
    }
    
    func delete_SavedCard(_ vc: UIViewController, _ params: [String: Any], _ success: @escaping(_ responseData : Any) -> Void) {
        CommunicationManager.callPostService(apiUrl: Router.delete_SaveCard.url(), parameters: params, parentViewController: vc, successBlock: { response, message in
            success(response)
        }) { error in
            vc.alert(alertmessage: error.localizedDescription)
        }
    }
}
