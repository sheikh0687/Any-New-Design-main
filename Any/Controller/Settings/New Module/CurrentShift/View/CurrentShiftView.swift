//
//  CurrentShiftView.swift
//  Any
//
//  Created by Arbaz  on 15/04/26.
//

import SwiftUI
import SwiftyJSON

struct CurrentShiftView: View {
 
    @StateObject private var viewModel = CurrentShiftViewModel()
    @State private var activeAlert: CurrentShiftAlert?
    @Environment(\.dismiss) private var dismiss
 
    var body: some View {
        VStack(spacing: 0) {
 
            // MARK: Toggles Section
            VStack(spacing: 0) {
                toggleRow (
                    title: "Close All Bookings",
                    isOn: $viewModel.isCloseAllBookings
                ) { newVal in
                    Task { await viewModel.updateBookingStatus(close: newVal) }
                }
 
                Divider().padding(.leading, 16)
 
                toggleRow (
                    title: "Auto Approval Shift",
                    isOn: $viewModel.isAutoApproval
                ) { newVal in
                    Task { await viewModel.updateAutoApproval(enabled: newVal) }
                }
            }
            .padding(.top, 8)
 
            // MARK: Admin / Approver Buttons
            HStack(spacing: 12) {
                adminButton (
                    title: "Outlet Admin",
                    systemIcon: "outletadmin",
                    iconColor: .teal
                ) {
                    navigateTo("OutletAdmin")
                }
 
                adminButton (
                    title: "Authorised Approver",
                    systemIcon: "authorisedapprvar",
                    iconColor: .teal
                ) {
                    navigateTo("AuthrisedApprover")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
 
            // MARK: Section Header
            HStack {
                Text("Current Shifts")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
 
            Divider()
 
            // MARK: Shift List
            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading shifts...")
                Spacer()
            } else if viewModel.shiftList.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No Shifts At The Moment")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                List {
                    ForEach(Array(viewModel.shiftList.enumerated()), id: \.offset) { _, dic in
                        CurrentShiftRow(dic: dic) {
                            activeAlert = .confirmUpdate(dic)
                        } onDelete: {
                            activeAlert = .confirmDelete(dic)
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.getShiftList()
                }
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Current Shifts")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(false)
        .task {
            await viewModel.getShiftList()
            await viewModel.getProfile()
        }
        .alert(item: $activeAlert) { alert in
            buildAlert(for: alert)
        }
    }
 
    // MARK: - Alert Builder
 
    private func buildAlert(for alert: CurrentShiftAlert) -> Alert {
        switch alert {
        case .confirmUpdate(let dic):
            return Alert (
                title: Text("Confirm shift change"),
                message: Text("Have you notified the worker via the in‑app message about these changes, and has the worker agreed?"),
                primaryButton: .default(Text("Proceed")) {
                    navigateToUpdate(dic: dic)
                },
                secondaryButton: .default(Text("Cancel"))
            )
        case .confirmDelete(let dic):
            return Alert(
                title: Text("Cancel Shift?"),
                message: Text("Are you sure you want to cancel this shift? Penalties may apply for approved shifts starting in less than 24 hours. If you have questions, kindly message Customer Service in the app."),
                primaryButton: .destructive(Text("Yes, Proceed")) {
                    Task { await viewModel.deleteShift(id: dic["id"].stringValue) }
                },
                secondaryButton: .default(Text("Keep Shift"))
            )
        case .error(let message):
            return Alert(
                title: Text("Error"),
                message: Text(message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
 
    // MARK: - Subviews
    private func toggleRow(title: String, isOn: Binding<Bool>, onChange: @escaping (Bool) -> Void) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .onChange(of: isOn.wrappedValue, perform: onChange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
 
    private func adminButton(title: String, systemIcon: String, iconColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
 
    // MARK: - Navigation Helpers
    private func navigateTo(_ type: String) {
        guard let topVC = UIApplication.topViewController(),
              let nav = topVC.navigationController else { return }
        let vc = R.storyboard.main.listAdminVC()!
        vc.strType = type
        nav.pushViewController(vc, animated: true)
    }
 
    private func navigateToUpdate(dic: JSON) {
        guard let topVC = UIApplication.topViewController(),
              let nav = topVC.navigationController else { return }
        let vc = R.storyboard.main.updateJobPublishVC()!
        vc.shift_iD     = dic["id"].stringValue
        vc.strOutletiD  = dic["outlet_id"].stringValue
        vc.strOutletName = dic["business_name"].stringValue
        nav.pushViewController(vc, animated: true)
    }
}
 
// MARK: - Shift Cell
struct CurrentShiftRow: View {

    let dic: JSON
    var onUpdate: () -> Void
    var onDelete: () -> Void

    private var displayDay: String {
        switch dic["shift_type"].stringValue {
        case "Normal":     return dic["day_name"].stringValue
        case "SingleDate": return dic["single_date"].stringValue
        default:           return "Urgent"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: Top Row — Shift time + vertical menu
            HStack(alignment: .top) {
                VStack(alignment: .center, spacing: 2) {
                    Text("Shift")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    Text("\(dic["start_time"].stringValue) to \(dic["end_time"].stringValue)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer()

                // ✅ Vertical three-dot menu
                Menu {
                    Button { onUpdate() } label: {
                        Label("Update", systemImage: "pencil")
                    }
                    Button(role: .destructive) { onDelete() } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .rotationEffect(.degrees(90)) // ✅ Makes it vertical
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            Divider()
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            // MARK: Middle Row — Job Type / Meals / Break (centered, dynamic)
            HStack(alignment: .top, spacing: 0) {
                infoColumn(label: "Job Type",
                           value: dic["job_type"].stringValue.isEmpty ? "-" : dic["job_type"].stringValue)

                Divider().frame(height: 50)

                infoColumn(label: "Meals",
                           value: dic["meals"].stringValue.isEmpty ? "Not Provided" : dic["meals"].stringValue)

                Divider().frame(height: 50)

                infoColumn(label: "Break",
                           value: dic["break_type"].stringValue.isEmpty ? "-" : dic["break_type"].stringValue)
            }
            // ✅ No horizontal padding so dividers stretch edge-to-edge inside card
            .frame(maxWidth: .infinity)

            Divider()
                .padding(.vertical, 10)

            // MARK: Bottom — Day + Business name inside card
            VStack(alignment: .center, spacing: 4) {
                Text(displayDay)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text(dic["business_name"].stringValue)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay (
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }

    // ✅ alignment: .top so longer text doesn't push short labels off-center
    private func infoColumn(label: String, value: String) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true) // ✅ Prevents clipping
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CurrentShiftView()
    }
}
