//
//  ClientOfferView.swift
//  Any
//
//  Created by Arbaz  on 01/04/26.
//

import SwiftUI
import SwiftyJSON

struct ClientOfferView: View {
    
    @StateObject var viewModel = ClientOfferVM()
    @StateObject private var autoPlayer = BannerAutoPlayer()
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        let isClient = USER_DEFAULT.value(forKey: USER_TYPE) as! String == "Client"
        let dotCount = isClient ? viewModel.clientOffers.count : viewModel.offers.count

        VStack(spacing: 8) {
            GeometryReader { geo in
                let cardWidth = geo.size.width * 0.88
                let spacing: CGFloat = 12
                let sidePadding = (geo.size.width - cardWidth) / 2

                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: spacing) {
                            if isClient {
                                ForEach(Array(viewModel.clientOffers.enumerated()), id: \.1.id) { index, offer in
                                    ClientOfferCardView(vm: viewModel, obj: offer, cardWidth: cardWidth)
                                        .frame(width: cardWidth, height: 165)
                                        .id(index)
                                        .background(
                                            GeometryReader { g in
                                                Color.clear.preference(
                                                    key: CardPositionPreferenceKey.self,
                                                    value: [index: g.frame(in: .global).midX]
                                                )
                                            }
                                        )
                                }
                            } else {
                                ForEach(Array(viewModel.offers.enumerated()), id: \.1.id) { index, offer in
                                    OfferCardView(vm: viewModel, obj: offer, cardWidth: cardWidth)
                                        .frame(width: cardWidth, height: 165)
                                        .id(index)
                                        .background (
                                            GeometryReader { g in
                                                Color.clear.preference(
                                                    key: CardPositionPreferenceKey.self,
                                                    value: [index: g.frame(in: .global).midX]
                                                )
                                            }
                                        )
                                        .onTapGesture {
                                            if offer.type != "Shift" {
                                                openOfferDetail(offer)
                                            }
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, sidePadding)
                    }
                    .onChange(of: autoPlayer.index) { _, newIndex in
                        withAnimation(.easeInOut(duration: 0.4)) {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                    .onPreferenceChange(CardPositionPreferenceKey.self) { positions in
                        let screenCenter = UIScreen.main.bounds.width / 2
                        guard let closest = positions.min(by: {
                            abs($0.value - screenCenter) < abs($1.value - screenCenter)
                        }) else { return }

                        let newIndex = closest.key
                        if !autoPlayer.isAutoScrolling && newIndex != autoPlayer.index {
                            autoPlayer.index = newIndex
                            autoPlayer.notifyUserScrolled()
                        }
                    }
                    .simultaneousGesture (
                        DragGesture(minimumDistance: 5)
                            .onChanged { _ in autoPlayer.notifyUserScrolled() }
                    )
                }
            }
            .frame(height: 165)
            .onAppear { autoPlayer.start() }
            .onDisappear { autoPlayer.stop() }

            // ✅ Dots use correct count for both user types
            HStack(spacing: 6) {
                ForEach(0..<dotCount, id: \.self) { i in
                    Capsule()
                        .fill(i == autoPlayer.index ? Color.orange : Color.gray.opacity(0.35))
                        .frame(width: i == autoPlayer.index ? 24 : 6, height: 6)
                        .animation(.easeInOut(duration: 0.25), value: autoPlayer.index)
                }
            }
        }
        .task {
            if isClient {
                await viewModel.getClientBannerList()
                autoPlayer.bannerCount = viewModel.clientOffers.count
            } else {
                await viewModel.getBannerList()
                autoPlayer.bannerCount = viewModel.offers.count  // ✅ fixed
            }
            autoPlayer.start()
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background, .inactive: autoPlayer.suspend()
            case .active: autoPlayer.resume()
            @unknown default: break
            }
        }
    }
    
    func openOfferDetail(_ offer: Res_ClientOffer) {
        
        let vc = UIHostingController(rootView: OfferDetail(obj: offer))
        
        // ✅ Set title directly on the UIHostingController's navigationItem
        vc.hidesBottomBarWhenPushed = true
        
        if let topVC = UIApplication.topViewController(),
           let nav = topVC.navigationController {
            nav.pushViewController(vc, animated: true)
            }
    }
}

struct OfferCardView: View {
    
    let vm: ClientOfferVM
    let obj: Res_ClientOffer
    let cardWidth: CGFloat
    
    var body: some View {
        ZStack(alignment: .leading) {
            if obj.type == "Shift" {
                Image("Offer")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 165)
                    .overlay (
                        LinearGradient (
                            colors: [
                                Color.orange.opacity(0.95),
                                Color.orange.opacity(0.75)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            } else {
                AsyncImage(url: URL(string: obj.image ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
//                        .imageScale(.large)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 165)
                .overlay (
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.gray, lineWidth: 0.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
//                .shadow(radius: 2)
            }
                   
            if obj.type == "Shift" {
                
                // SHIFT CARD (keep left layout)
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: obj.client_details?.business_logo ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: { ProgressView() }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white.opacity(0.8), lineWidth: 2))
                    .shadow(radius: 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(obj.client_details?.business_name ?? "")
                                .font(.system(size: 18, weight: .bold))
                                .lineLimit(2)
                            
                            Text("• \(obj.shift_details?.job_type ?? "")")
                            Text("• \(obj.shift_details?.date ?? "")")
                            Text("• \(obj.shift_details?.currency_symbol ?? "")\(obj.shift_details?.shift_rate ?? "")/hour")
                            Text("• \(obj.shift_details?.start_time ?? "") - \(obj.shift_details?.end_time ?? "")")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        
                        Button {
                            openBooking(obj: obj)
                        } label: {
                            Text("View Offer")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(24)
                        }
                    }
                }
                .padding(24)
                
            } else {
                // ⭐️ NON-SHIFT CARD (NEW CENTERED LAYOUT)
//                VStack(alignment: .leading, spacing: 8) {
//                    Text(obj.title ?? "")
//                        .font(.system(size: 18, weight: .bold))
//                        .lineLimit(2)
//
//                    Text(obj.description ?? "")
//                        .font(.system(size: 18, weight: .bold))
//                        .lineLimit(2)
//                }
//                .foregroundColor(.white)
//                .padding(20)
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
        .frame(width: cardWidth, height: 165)
    }
    
    private func openBooking(obj: Res_ClientOffer) {
        let vc = kStoryboardMain.instantiateViewController(withIdentifier: "BookingRequestVC") as! BookingRequestVC
        if let client = obj.client_details {
            do {
                let data = try JSONEncoder().encode(client)   // Model → Data
                let json = try JSON(data: data)               // Data → SwiftyJSON
                vc.dicClinetDetail = json                     // ✅ PASS JSON
            } catch {
                print("JSON conversion failed:", error)
            }
        }
        vc.strDate = obj.shift_details?.date ?? ""
        vc.strFrom = "Shift"
        let strContainDate = obj.shift_details?.date ?? ""
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = .current
        formatter.dateFormat = "yyyy-MM-dd"
        vc.strDateOnly = formatter.date(from: strContainDate)
        
        if let topVC = UIApplication.topViewController() {
            topVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

struct ClientOfferCardView: View {
    
    let vm: ClientOfferVM
    let obj: Res_ClientBannerList
    let cardWidth: CGFloat
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image("Offer")
                .resizable()
                .scaledToFill()
                .frame(height: 165)
                .overlay (
                    LinearGradient (
                        colors: [
                            Color.orange.opacity(0.95),
                            Color.orange.opacity(0.75)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))

            HStack(spacing: 12) {
                AsyncImage(url: URL(string: obj.image ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: { ProgressView() }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(.white.opacity(0.8), lineWidth: 2))
                .shadow(radius: 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(obj.title ?? "")
                            .font(.system(size: 18, weight: .bold))
                            .lineLimit(2)
                        
                        Text("• \(obj.description ?? "")")
                        Text("• \(obj.date_time ?? "")")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    
                    Button {
//                        openBooking(obj: obj)
                    } label: {
                        Text("View Offer")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .cornerRadius(24)
                    }
                }
            }
            .padding(24)        }
        .frame(width: cardWidth, height: 165)
    }
    
//    private func openBooking(obj: Res_ClientOffer) {
//        let vc = kStoryboardMain.instantiateViewController(withIdentifier: "BookingRequestVC") as! BookingRequestVC
//        if let client = obj.client_details {
//            do {
//                let data = try JSONEncoder().encode(client)   // Model → Data
//                let json = try JSON(data: data)               // Data → SwiftyJSON
//                vc.dicClinetDetail = json                     // ✅ PASS JSON
//            } catch {
//                print("JSON conversion failed:", error)
//            }
//        }
//        vc.strDate = obj.shift_details?.date ?? ""
//        vc.strFrom = "Shift"
//        let strContainDate = obj.shift_details?.date ?? ""
//        let formatter = DateFormatter()
//        formatter.timeZone = TimeZone.current
//        formatter.locale = .current
//        formatter.dateFormat = "yyyy-MM-dd"
//        vc.strDateOnly = formatter.date(from: strContainDate)
//        
//        if let topVC = UIApplication.topViewController() {
//            topVC.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
}

struct CardPositionPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    
    static func reduce(value: inout [Int : CGFloat], nextValue: () -> [Int : CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

#Preview {
    ClientOfferView()
}
