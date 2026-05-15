//
//  OfferDetail.swift
//  Any
//
//  Created by Arbaz  on 01/04/26.
//

import SwiftUI

struct OfferDetail: View {
    
    @Environment(\.dismiss) var dismiss
    var obj: Res_ClientOffer
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Custom Navigation Bar
            customNavBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: - Header Image Section
                    headerImageSection
                    
                    // MARK: - Content Card
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Type and Date
                        HStack {
                            if let type = obj.type {
                                Text(type.uppercased())
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color("BUTTON_COLOR").opacity(0.1))
                                    .foregroundColor(Color("BUTTON_COLOR"))
                                    .cornerRadius(8)
                            }
                            
                            Spacer()
                            
                            if let dateTime = obj.date_time {
                                Text(dateTime)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Title
                        Text(obj.title ?? "Offer Detail")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("BLACK"))
                        
                        Divider()
                        
                        // Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(Color("BLACK"))
                            
                            Text(obj.description ?? "No description available.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                        
                        // Shift Details (if applicable)
//                        if obj.type == "Shift", let shift = obj.shift_details {
//                            shiftDetailsSection(shift)
//                        }
                        
                        // Client Details
//                        if let client = obj.client_details {
//                            clientDetailsSection(client)
//                        }
                        
                        // Action Button
//                        actionButton
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(32, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
                }
            }
            .background(Color("BG_COLOR"))
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea())
    }
    
    // MARK: - Subviews
    
    private var customNavBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color("BG_COLOR").opacity(0.5)))
            }
            
            Text("Offer Detail")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Placeholder for symmetry
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    private var headerImageSection: some View {
        ZStack {
            Color.white // Background for the image area
            
            AsyncImage(url: URL(string: obj.image ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 200, maxHeight: 300)
        .background(Color.white)
    }
    
//    private func shiftDetailsSection(_ shift: Shift_details) -> some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Shift Information")
//                .font(.headline)
//                .foregroundColor(Color("BLACK"))
//            
//            VStack(spacing: 12) {
//                detailRow(icon: "calendar", title: "Date", value: shift.date ?? "N/A")
//                detailRow(icon: "clock", title: "Time", value: "\(shift.start_time ?? "") - \(shift.end_time ?? "")")
//                detailRow(icon: "dollarsign.circle", title: "Rate", value: "\(shift.currency_symbol ?? "")\(shift.shift_rate ?? "")/hour")
//                detailRow(icon: "mappin.and.ellipse", title: "Location", value: shift.address ?? "N/A")
//            }
//            .padding()
//            .background(Color("BG_COLOR").opacity(0.3))
//            .cornerRadius(16)
//        }
//        .padding(.top, 10)
//    }
    
//    private func clientDetailsSection(_ client: Client_details) -> some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Business Information")
//                .font(.headline)
//                .foregroundColor(Color("BLACK"))
//            
//            HStack(spacing: 15) {
//                AsyncImage(url: URL(string: client.business_logo ?? "")) { image in
//                    image.resizable().scaledToFill()
//                } placeholder: {
//                    Image(systemName: "building.2.fill")
//                        .foregroundColor(.gray)
//                }
//                .frame(width: 50, height: 50)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
//                
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(client.business_name ?? "Unknown Business")
//                        .font(.subheadline)
//                        .fontWeight(.bold)
//                    
//                    Text(client.business_address ?? "No address provided")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                        .lineLimit(2)
//                }
//            }
//            .padding()
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .background(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
//        }
//        .padding(.top, 10)
//    }
    
//    private var actionButton: some View {
//        Group {
//            if let link = obj.link, !link.isEmpty {
//                Button {
//                    if let url = URL(string: link) {
//                        UIApplication.shared.open(url)
//                    }
//                } label: {
//                    Text("Learn More")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 56)
//                        .background(Color("BUTTON_COLOR"))
//                        .cornerRadius(16)
//                        .shadow(color: Color("BUTTON_COLOR").opacity(0.3), radius: 8, x: 0, y: 4)
//                }
//            } else if obj.type == "Shift" {
//                Button {
//                    // Booking logic placeholder
//                } label: {
//                    Text("View Shift Details")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 56)
//                        .background(Color("BUTTON_COLOR"))
//                        .cornerRadius(16)
//                        .shadow(color: Color("BUTTON_COLOR").opacity(0.3), radius: 8, x: 0, y: 4)
//                }
//            }
//        }
//        .padding(.top, 20)
//    }
    
//    private func detailRow(icon: String, title: String, value: String) -> some View {
//        HStack(spacing: 12) {
//            Image(systemName: icon)
//                .foregroundColor(Color("BUTTON_COLOR"))
//                .frame(width: 24)
//            
//            VStack(alignment: .leading, spacing: 2) {
//                Text(title)
//                    .font(.caption2)
//                    .foregroundColor(.secondary)
//                Text(value)
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(Color("BLACK"))
//            }
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
}

// MARK: - View Extension for Corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
