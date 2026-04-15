//
//  ClientJobViewModel.swift
//  Any
//
//  Created by Arbaz on 02/01/26.
//

import Foundation
import SwiftyJSON
import DropDown

@MainActor
final class ClientJobViewModel {
    
    // MARK: - Bindings
    var onNotificationUpdated: ((Int) -> Void)?
    var onWeeklyReportUpdated: (() -> Void)?
    var onManpowerUpdated: (() -> Void)?
    var onUpcomingShiftUpdated: (() -> Void)?
    var onOutletUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?

    // MARK: - Data Sources
    private(set) var arrayForJobTypes: [JSON] = []
    private(set) var arrayManPowerReq: [JSON] = []
    private(set) var arrayForUpcomingShift: [JSON] = []
    private(set) var arrayOfOutlet: [JSON] = []

    private let calendar = Calendar.current
    private var arrWeekStartToEnd: [String] = []
    private var arrDateStart: [Date] = []
    private var arrDateEnd: [Date] = []
    
    var currentWeek: Int = 0
    var arrWeekDays: [Date] = []
    var arrWeekName:[String] = ["MON","TUE","WED","THU","FRI","SAT","SUN"]
    
    init() {
        generateWeeks()
    }
}

extension ClientJobViewModel {
    
    private func generateWeeks() {
        let lastDay = Calendar.current.date(byAdding: .day, value: 100, to: Date())!
        var currentDate = Date()
        
        while currentDate < lastDay {
            let start = currentDate.previous(.monday).formatted()
            let end = currentDate.next(.sunday).formatted()
            
            arrWeekStartToEnd.append("\(start),\(end)")
            arrDateStart.append(Utility.getDate(strDte: start)!)
            arrDateEnd.append(Utility.getDate(strDte: end)!)
            
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
        }
        
        loadCurrentWeek()
    }
    
    func loadCurrentWeek() {
        arrWeekDays.removeAll()
        var date = arrDateStart[currentWeek]
        
        while date <= arrDateEnd[currentWeek] {
            arrWeekDays.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
    }
    
    func nextWeek() {
        currentWeek += 1
        loadCurrentWeek()
    }
    
    func previousWeek() {
        guard currentWeek > 0 else { return }
        currentWeek -= 1
        loadCurrentWeek()
    }
}

extension ClientJobViewModel {
    
    func getNotificationCount(vC: UIViewController) async {
        
        var params: [String: AnyObject] = [:]
        params["user_id"] = USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        do {
            let json = try await CommunicationManager.callPostServiceAsync(
                apiUrl: Router.get_notification_count.url(),
                parameters: params,
                parentViewController: vC
            )
            
            if json["status"].stringValue == "1" {
                let requestCount = json["request"].intValue
                onNotificationUpdated?(requestCount)
            }
            
        } catch {
            onError?(error.localizedDescription)
        }
    }
    
    func getWeeklyReportList(vC: UIViewController) async {
        
        var params: [String: AnyObject] = [:]
        params["user_id"] = USER_DEFAULT.value(forKey: CLIENTID) as AnyObject
        
        let strDat = arrWeekStartToEnd[currentWeek]
        let arr = strDat.components(separatedBy: ",")
        print(strDat)
        params["start_date"]  =  arr[0] as AnyObject
        params["end_date"]  =   arr[1] as AnyObject
        
        do {
            let json = try await CommunicationManager.callPostServiceAsync (
                apiUrl: Router.get_set_shift_book_client_side.url(),
                parameters: params,
                parentViewController: vC
            )
            
            if json["status"].stringValue == "1" {
                arrayForJobTypes = json["result"].arrayValue
            } else {
                arrayForJobTypes = []
            }
            
            onWeeklyReportUpdated?()
            
        } catch {
            onError?(error.localizedDescription)
        }
    }


    func getManpowerJobRequests(vC: UIViewController) async {
        
        var params: [String: AnyObject] = [:]
        params["user_id"] = USER_DEFAULT.value(forKey: CLIENTID) as AnyObject
        params["today_date"] = Utility.getCurrentShortDateNew() as AnyObject
        params["today_day_name"] = Utility.getCurrentDay() as AnyObject
        
        do {
            let json = try await CommunicationManager.callPostServiceAsync(
                apiUrl: Router.get_client_shift_by_date.url(),
                parameters: params,
                parentViewController: vC
            )
            
            if json["status"].stringValue == "1" {
                arrayManPowerReq = json["result"]["worker_details"].arrayValue
            } else {
                arrayManPowerReq = []
            }
            
            onManpowerUpdated?()
            
        } catch {
            onError?(error.localizedDescription)
        }
    }
    
    func getUpcomingShifts(vC: UIViewController) async {
        
        var params: [String: AnyObject] = [:]
        params["user_id"] = USER_DEFAULT.value(forKey: CLIENTID) as AnyObject
        
        do {
            let json = try await CommunicationManager.callPostServiceAsync (
                apiUrl: Router.get_shift_by_10day_count.url(),
                parameters: params,
                parentViewController: vC
            )
            
            if json["status"].stringValue == "1" {
                arrayForUpcomingShift = json["result"].arrayValue
            } else {
                arrayForUpcomingShift = []
            }
            
            onUpcomingShiftUpdated?()
            
        } catch {
            onError?(error.localizedDescription)
        }
    }

    func getOutlets(vC: UIViewController) async {
        
        onLoading?(true)
        
        var params: [String: AnyObject] = [:]
        params["client_id"] = USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        do {
            let json = try await CommunicationManager.callPostServiceAsync(
                apiUrl: Router.get_Outlet.url(),
                parameters: params,
                parentViewController: vC
            )
            
            if json["status"].stringValue == "1" {
                arrayOfOutlet = json["result"].arrayValue
            } else {
                arrayOfOutlet = []
            }
            
            onOutletUpdated?()
            
        } catch {
            onError?(error.localizedDescription)
        }
        
        onLoading?(false)
    }
    
    func calculateUpcomingTableHeight() -> CGFloat {
        var total = 0
        
        for val in arrayForUpcomingShift {
            let shiftCount = val["shift_details"].count
            
            if shiftCount > 0 {
                if val["shift_details"]["worker_details"].count > 0 {
                    total += 60 + (shiftCount * 310)
                } else {
                    total += 60 + (shiftCount * 220)
                }
            } else {
                total += 60
            }
        }
        
        return CGFloat(total)
    }
}
