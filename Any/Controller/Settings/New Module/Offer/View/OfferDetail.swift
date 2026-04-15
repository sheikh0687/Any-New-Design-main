//
//  OfferDetail.swift
//  Any
//
//  Created by Arbaz  on 01/04/26.
//

import SwiftUI

//struct OfferDetail: View {
//    
//    @Environment(\.dismiss) var dismiss
//    var obj: Res_ClientOffer
//    
//    var body: some View {
//        ZStack(alignment: .top) {
//            VStack(spacing: 24) {
//                
//                headerText
//                
//                // MARK: Top Image
//                AsyncImage(url: URL(string: obj.image ?? "")) { image in
//                    image
//                        .resizable()
//                        .scaledToFill()        // keep full logo visible
//                        .padding(.top, 20)
//                        .padding(.bottom, 10)
//                } placeholder: {
//                    ProgressView()
//                }
//                .frame(maxWidth: .infinity)
//                .frame(height: 160)
//                .background(Color.orange.opacity(0.08)) // fills empty space nicely
//                
//                // MARK: Card Content
//                ScrollView(showsIndicators: false) {
//                    VStack(alignment: .leading, spacing: 16) {
//                        
//                        Text(obj.title ?? "")
//                            .font(.title3)
//                            .fontWeight(.semibold)
//                        
//                        Divider()
//                        
//                        Text(obj.description ?? "")
//                            .foregroundColor(.secondary)
//                            .fixedSize(horizontal: false, vertical: true)
//                        
//                        Spacer()
//                    }
//                    .padding(20)
//                    .background (
//                        RoundedRectangle(cornerRadius: 26)
//                            .fill(Color.white)
//                            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
//                    )
//                    .padding(.horizontal)
//                }
//                
////                Spacer()
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//    
//    private var headerText: some View {
//        HStack(spacing: 16) {
//            Button {
//                dismiss()
//            } label: {
//                Image(systemName: "chevron.left")
//                    .font(.system(size: 20, weight: .medium))
//                    .foregroundColor(.black)
//            }
//            
//            Text("Offer Detail")
//                .font(.title)
//                .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//
//    
//    private func setNavTitle(_ title: String) {
//        DispatchQueue.main.async {
//            UIApplication.topViewController()?.navigationItem.title = title
//        }
//    }
//}

struct OfferDetail: View {
    
    @Environment(\.dismiss) var dismiss
    var obj: Res_ClientOffer
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: Custom Nav Header
            HStack(spacing: 16) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }

                Text("Offer Detail")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)

            Divider()

            // MARK: Top Image
            AsyncImage(url: URL(string: obj.image ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
            .clipped()
            .background(Color.orange.opacity(0.08))

            // MARK: Card Content
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {

                    Text(obj.title ?? "")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Divider()

                    Text(obj.description ?? "")
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background (
                    RoundedRectangle(cornerRadius: 26)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
                )
                .padding(.horizontal)
                .padding(.top, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }
}

//#Preview {
//    OfferDetail()
//}
