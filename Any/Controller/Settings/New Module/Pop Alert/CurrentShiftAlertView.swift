//
//  CurrentShiftAlertView.swift
//  Any
//
//  Created by Arbaz  on 28/01/26.
//

import SwiftUI

//struct CurrentShiftAlertView: View {
//    
//    var popFor: String
//    var cloIsPaymentComplete: ((Bool) -> Void)?
//    
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.2)
//                .ignoresSafeArea()
//            
//            Spacer()
//            VStack(spacing: 16) {
//                
//                Text (
//                    popFor == "Update"
//                    ? "Are you sure you want to update this shift? This change may affect your other scheduled shifts."
//                    : "Are you sure you want to delete this shift? This action may affect your other scheduled shifts."
//                )
//                .font(.system(size: 14))
//                .foregroundColor(.black)
//                .multilineTextAlignment(.center)
//                
//                HStack {
//                    Button {
//                        print("Call Closure")
//                    } label: {
//                        Text("Yes")
//                            .font(.system(size: 14))
//                            .foregroundColor(.white) // ✅ Use dynamic color
//                            .padding(.vertical, 8)
//                            .padding(.horizontal, 20)
//                            .background(Color("BUTTON_COLOR"))
//                            .cornerRadius(18)
//                    }
//                    
//                    Button {
//                        print("Call Closure")
//                    } label: {
//                        Text("No")
//                            .font(.system(size: 14))
//                            .foregroundColor(.white) // ✅ Use dynamic color
//                            .padding(.vertical, 8)
//                            .padding(.horizontal, 20)
//                            .background(Color("BUTTON_COLOR"))
//                            .cornerRadius(18)
//                    }
//                }
//                .padding(.horizontal)
//            } // MAIN VSTACK
//            .padding(16)
//            .background (
//                RoundedRectangle(cornerRadius: 11)
//                    .stroke(Color.gray, lineWidth: 0.5)
//                    .background(RoundedRectangle(cornerRadius: 10)
//                        .fill(Color(.white)))
//            )
//            .padding(.horizontal, 24)
//            
//            Spacer()
//        }
//    }
//    
//}

struct CurrentShiftAlertView: View {

    var popFor: String
    var cloIsShift: ((Bool) -> Void)?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            VStack(spacing: 24) {
                
                VStack(spacing: 8) {
                    Text(popFor == "Update" ? "Confirm shift change" : "Cancel shift?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text (
                        popFor == "Update"
                        ? "Have you notified the worker via the in‑app message about these changes, and has the worker agreed?"
                        : "Are you sure you want to cancel this shift? Penalties may apply for approved shifts starting in less than 24 hours. If you have questions, kindly message Customer Service in the app."
                    )
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                }

                HStack(spacing: 12) {

                    Button {
                        dismiss()
                        cloIsShift?(true)
                    } label: {
                        Text(popFor == "Update" ? "Proceed" : "Yes, cancel")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color("BUTTON_COLOR"))
                            .cornerRadius(18)
                    }
                    
                    Button {
                        dismiss()
                        cloIsShift?(false)
                    } label: {
                        Text(popFor == "Update" ? "Cancel" : "Keep shift")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(18)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 20)
            .background (
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    CurrentShiftAlertView(popFor: "Update")
}
