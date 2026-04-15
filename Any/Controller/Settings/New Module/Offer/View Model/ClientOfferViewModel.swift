//
//  ClientOfferViewModel.swift
//  Any
//
//  Created by Arbaz  on 01/04/26.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
class ClientOfferVM: ObservableObject {
    
    @Published var offers: [Res_ClientOffer] = []
    @Published var isLoading = false
    @Published var showOfferDetail = false
    
    @Published var resObj: Res_ClientOffer?
    
    func getBannerList() async {
        isLoading = true
        
        let paramsDict:[String:AnyObject] = [:]
        
        do {
            let json = try await CommunicationManager.callPostServiceAsync (
                apiUrl: Router.get_banner_list.url(),
                parameters: paramsDict,
                parentViewController: nil
            )
            
            // Convert SwiftyJSON -> Data -> Codable model
            let data = try json.rawData()
            let decoded = try JSONDecoder().decode(Api_ClientOffer.self, from: data)
            
            if decoded.status == "1" {
                self.offers = decoded.result ?? []
            } else {
                self.offers = []
            }
            
        } catch {
            print("API ERROR:", error.localizedDescription)
        }
        
        isLoading = false
    }
}
