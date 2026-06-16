//
//  OfferDetail.swift
//  Any
//
//  Created by Arbaz  on 01/04/26.
//

import SwiftUI

struct OfferDetail: View {
    
    @Environment(\.dismiss) var dismiss
    
    // ✅ Flat properties — works for both Worker and Client
    var image: String?
    var title: String?
    var descriptionText: String?
    var type: String?
    var dateTime: String?
    
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
                            if let type = type {
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
                            
                            if let dateTime = dateTime {
                                Text(dateTime)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Title
                        Text(title ?? "Offer Detail")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("BLACK"))
                        
                        Divider()
                        
                        // Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(Color("BLACK"))
                            
                            Text(descriptionText ?? "No description available.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(32, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
                }
            }
//            .background(Color("BG_COLOR"))
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
            
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    private var headerImageSection: some View {
        ZStack {
            Color.white
            
            AsyncImage(url: URL(string: image ?? "")) { img in
                img
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
}

// MARK: - Convenience Initializers

extension OfferDetail {
    
    // ✅ Worker — Res_ClientOffer
    init(obj: Res_ClientOffer) {
        self.image           = obj.image
        self.title           = obj.title
        self.descriptionText = obj.description
        self.type            = obj.type
        self.dateTime        = obj.exp_date
    }
    
    // ✅ Client — Res_ClientBannerList
    init(obj: Res_ClientBannerList) {
        self.image           = obj.image
        self.title           = obj.title
        self.descriptionText = obj.description
//        self.type            = obj.type
        self.dateTime        = obj.exp_date
    }
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
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
