//
//  ClientJobViewModel.swift
//  Any
//
//  Created by Arbaz on 02/01/26.
//

import Foundation
import SwiftyJSON

final class ClientJobViewModel {

    // MARK: - Exposed state (for VC)
    private(set) var manpower: [JSON] = []
    private(set) var weeklyJobTypes: [JSON] = []
    private(set) var upcomingShifts: [JSON] = []
    private(set) var outlets: [JSON] = []

    var weekRanges: [(start: Date, end: Date)] = []
    var currentWeekIndex: Int = 0

    var weeklyReqCount: Int = 0
    var dailyReqCount: Int = 0
    var jobTypeAndDescription: String = ""

    // Callbacks
    var didUpdateUI: (() -> Void)?
    var didShowError: ((String) -> Void)?
    var isLoadingChanged: ((Bool) -> Void)?

    private let calendar = Calendar.current

    // MARK: - Public API

    func configureWeeks() {
        weekRanges.removeAll()

        let lastDay = calendar.date(byAdding: .day, value: 100, to: Date())!
        var currentDate = Date()

        let df = DateFormatter()
        df.dateFormat = "ccc"
        let dayOfWeek = df.string(from: currentDate)

        let hour = calendar.component(.hour, from: currentDate)
        if hour >= 0 && hour < 6 {
            currentDate = calendar.date(byAdding: .hour, value: 8, to: currentDate)!
        }

        while currentDate < lastDay {
            let start: Date
            let end: Date

            if dayOfWeek == "Mon" {
                start = currentDate
            } else {
                start = currentDate.previous(.monday)
            }

            if dayOfWeek == "Sun" {
                end = currentDate
            } else {
                end = currentDate.next(.sunday)
            }

            weekRanges.append((start: start, end: end))
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
        }
    }

    func weekDatesForCurrentWeek() -> [Date] {
        guard !weekRanges.isEmpty else { return [] }
        let range = weekRanges[currentWeekIndex]
        var days: [Date] = []
        var d = range.start
        while d <= range.end {
            days.append(d)
            d = calendar.date(byAdding: .day, value: 1, to: d)!
        }
        return days
    }

    func loadInitialData(parentVC: UIViewController) {
        configureWeeks()
        fetchOutlets(parentVC: parentVC)
        fetchNotificationCount(parentVC: parentVC)
        fetchManpower(parentVC: parentVC)
    }

    func goToPreviousWeek(parentVC: UIViewController) {
        guard currentWeekIndex > 0 else { return }
        currentWeekIndex -= 1
        fetchWeeklyReport(parentVC: parentVC)
        didUpdateUI?()
    }

    func goToNextWeek(parentVC: UIViewController) {
        guard currentWeekIndex + 1 < weekRanges.count else { return }
        currentWeekIndex += 1
        fetchWeeklyReport(parentVC: parentVC)
        didUpdateUI?()
    }

    func didSelectOutlet(index: Int, parentVC: UIViewController) {
        guard index < outlets.count else { return }
        let outlet = outlets[index]
        USER_DEFAULT.set(outlet["id"].stringValue, forKey: CLIENTID)
        USER_DEFAULT.set(outlet["business_name"].stringValue, forKey: OUTLET_NAME)
        USER_DEFAULT.set(outlet["business_logo"].stringValue, forKey: OUTLET_IMAGE)
        fetchManpower(parentVC: parentVC)
        fetchUpcomingShifts(parentVC: parentVC)
        didUpdateUI?()
    }

    // MARK: - Networking

    private func setLoading(_ value: Bool) {
        DispatchQueue.main.async { self.isLoadingChanged?(value) }
    }

    private func fetchNotificationCount(parentVC: UIViewController) {
        var params: [String: Any] = [:]
        params["user_id"] = USER_DEFAULT.value(forKey: USERID) as Any

        CommunicationManager.callPostService(
            apiUrl: Router.get_notification_count.url(),
            parameters: params,
            parentViewController: parentVC
        ) { response, _ in
            let json = JSON(response)
            guard json["status"].stringValue == "1" else { return }

            let notificationData: [String: NSNumber] = [
                "chatCount": json["chat_count"].numberValue,
                "requestCount": json["request"].numberValue
            ]
            NotificationCenter.default.post(
                name: NSNotification.Name("badgeCount"),
                object: "On Ride",
                userInfo: notificationData
            )

            DispatchQueue.main.async {
                NotificationCenter.default.post (
                    name: NSNotification.Name("ReloadCount"),
                    object: nil
                )
            }

            self.fetchWeeklyReport(parentVC: parentVC)
        } failureBlock: { error in
            self.didShowError?(error.localizedDescription)
        }
    }

    func fetchWeeklyReport(parentVC: UIViewController) {
        guard !weekRanges.isEmpty else { return }
        setLoading(true)

        let range = weekRanges[currentWeekIndex]
        let start = range.start.formatted()
        let end = range.end.formatted()

        var params: [String: Any] = [:]
        params["user_id"] = USER_DEFAULT.value(forKey: CLIENTID) as Any
        params["start_date"] = start
        params["end_date"] = end

        CommunicationManager.callPostService(
            apiUrl: Router.get_set_shift_book_client_side.url(),
            parameters: params,
            parentViewController: parentVC
        ) { response, _ in
            self.setLoading(false)
            let json = JSON(response)
            if json["status"].stringValue == "1" {
                self.weeklyJobTypes = json["result"].arrayValue
            } else {
                self.weeklyJobTypes = []
            }
            self.didUpdateUI?()
        } failureBlock: { error in
            self.setLoading(false)
            self.didShowError?(error.localizedDescription)
        }
    }

    func fetchManpower(parentVC: UIViewController) {
        setLoading(true)
        var params: [String: Any] = [:]
        params["user_id"] = USER_DEFAULT.value(forKey: CLIENTID) as Any
        params["today_date"] = Utility.getCurrentShortDateNew()
        params["today_day_name"] = Utility.getCurrentDay()

        CommunicationManager.callPostService(
            apiUrl: Router.get_client_shift_by_date.url(),
            parameters: params,
            parentViewController: parentVC
        ) { response, _ in
            self.setLoading(false)
            let json = JSON(response)
            if json["status"].stringValue == "1" {
                let result = json["result"]
                self.manpower = result["worker_details"].arrayValue
                self.jobTypeAndDescription =
                    "\(result["shift_name"].stringValue)\n\(result["shift_description"].stringValue)"

                self.weeklyReqCount = json["pending_shift_count"].intValue
                self.dailyReqCount = json["today_pending_shift_count"].intValue
            } else {
                self.manpower = []
                self.weeklyReqCount = 0
                self.dailyReqCount = 0
                self.jobTypeAndDescription = ""
            }
            self.didUpdateUI?()
        } failureBlock: { error in
            self.setLoading(false)
            self.didShowError?(error.localizedDescription)
        }
    }

    func fetchUpcomingShifts(parentVC: UIViewController) {
        setLoading(true)
        var params: [String: Any] = [:]
        params["user_id"] = USER_DEFAULT.value(forKey: CLIENTID) as Any

        CommunicationManager.callPostService(
            apiUrl: Router.get_shift_by_10day_count.url(),
            parameters: params,
            parentViewController: parentVC
        ) { response, _ in
            self.setLoading(false)
            let json = JSON(response)
            if json["status"].stringValue == "1" {
                self.upcomingShifts = json["result"].arrayValue
            } else {
                self.upcomingShifts = []
            }
            self.didUpdateUI?()
        } failureBlock: { error in
            self.setLoading(false)
            self.didShowError?(error.localizedDescription)
        }
    }

    func fetchOutlets(parentVC: UIViewController) {
        setLoading(true)
        var params: [String: Any] = [:]
        params["client_id"] = USER_DEFAULT.value(forKey: USERID) as Any

        CommunicationManager.callPostService(
            apiUrl: Router.get_Outlet.url(),
            parameters: params,
            parentViewController: parentVC
        ) { response, _ in
            self.setLoading(false)
            let json = JSON(response)
            if json["status"].stringValue == "1" {
                self.outlets = json["result"].arrayValue

                let defaultOutlet: JSON = [
                    "id": USER_DEFAULT.value(forKey: USERID) as? String ?? "",
                    "business_name": USER_DEFAULT.value(forKey: BUSINESS_NAME) as? String ?? "My Business",
                    "business_logo": USER_DEFAULT.value(forKey: BUSINESS_LOGO) as? String ?? ""
                ]
                if self.outlets.first?["id"].stringValue != defaultOutlet["id"].stringValue {
                    self.outlets.insert(defaultOutlet, at: 0)
                }
            } else {
                self.outlets = []
            }
            self.didUpdateUI?()
        } failureBlock: { error in
            self.setLoading(false)
            self.didShowError?(error.localizedDescription)
        }
    }

    // Helper used by VC to compute upcoming table height
    func upcomingTableHeight(rowHeader: Int = 60, rowHeight: Int = 190) -> CGFloat {
        var total = 0
        for val in upcomingShifts {
            if val["shift_details"].count > 0 {
                let c = val["shift_details"].count
                total += rowHeader + c * rowHeight
            } else {
                total += rowHeader
            }
        }
        return CGFloat(total)
    }
}
