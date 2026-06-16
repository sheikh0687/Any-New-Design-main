//
//  CurrentShiftViewModel.swift
//  Any
//
//  Created by Arbaz  on 15/04/26.
//

import SwiftyJSON

class CurrentShiftViewModel: ObservableObject {
 
    @Published var shiftList: [JSON] = []
    @Published var isLoading = false
    @Published var isCloseAllBookings = false
    @Published var isAutoApproval = false
    @Published var errorMessage: String?
 
    // MARK: Fetch Shifts
    @MainActor
    func getShiftList() async {
        isLoading = true
        defer { isLoading = false }
 
        var params: [String: AnyObject] = [:]
        params["user_id"]    = USER_DEFAULT.value(forKey: USERID) as AnyObject
        params["shift_type"] = "Normal" as AnyObject
 
        print(params)
        
        do {
            let json = try await CommunicationManager.callPostServiceAsync (
                apiUrl: Router.get_my_set_shift.url(),
                parameters: params,
                parentViewController: nil
            )
            if json["status"].stringValue == "1" {
                shiftList = json["result"].arrayValue
            } else {
                shiftList = []
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
 
    // MARK: Fetch Profile (for toggle states)
    @MainActor
    func getProfile() async {
        var params: [String: AnyObject] = [:]
        params["user_id"]   = USER_DEFAULT.value(forKey: USERID) as AnyObject
        params["device_id"] = USER_DEFAULT.value(forKey: IOS_TOKEN) as AnyObject
 
        do {
            let json = try await CommunicationManager.callPostServiceAsync(
                apiUrl: Router.get_profile.url(),
                parameters: params,
                parentViewController: nil
            )
            if json["status"].stringValue == "1" {
                let dic = json["result"]
                kappDelegate.dicProdile = dic
                isCloseAllBookings = dic["booking_status"].stringValue == "Close"
                isAutoApproval     = dic["shift_autoapproval"].stringValue == "Yes"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
 
    // MARK: Toggle Close All Bookings
    @MainActor
    func updateBookingStatus(close: Bool) async {
        var params: [String: AnyObject] = [:]
        params["user_id"]        = USER_DEFAULT.value(forKey: USERID) as AnyObject
        params["booking_status"] = (close ? "Close" : "Open") as AnyObject
 
        print(params)
        
        do {
            let json = try await CommunicationManager.callPostServiceAsync(
                apiUrl: Router.update_booking_status_profile.url(),
                parameters: params,
                parentViewController: nil
            )
            if json["status"].stringValue == "1" {
                await getProfile()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
 
    // MARK: Toggle Auto Approval
 
    @MainActor
    func updateAutoApproval(enabled: Bool) async {
        var params: [String: AnyObject] = [:]
        params["user_id"]            = USER_DEFAULT.value(forKey: USERID) as AnyObject
        params["shift_autoapproval"] = (enabled ? "Yes" : "No") as AnyObject
 
        print(params)
        
        do {
            let json = try await CommunicationManager.callPostServiceAsync (
                apiUrl: Router.set_shift_autoapproval_status.url(),
                parameters: params,
                parentViewController: nil
            )
            await getProfile()
            if json["status"].stringValue != "1" {
                errorMessage = json["message"].stringValue
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
 
    // MARK: Delete Shift
 
    @MainActor
    func deleteShift(id: String) async {
        var params: [String: AnyObject] = [:]
        params["id"] = id as AnyObject
 
        print(params)
        
        do {
            let json = try await CommunicationManager.callPostServiceAsync(
                apiUrl: Router.delete_my_shifts.url(),
                parameters: params,
                parentViewController: nil
            )
            if json["status"].stringValue == "1" {
                await getShiftList()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
