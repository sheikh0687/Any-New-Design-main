//
//  PopDocView.swift
//  Any
//
//  Created by Arbaz  on 04/02/26.
//

import SwiftUI

struct PopDocView: View {
    
    var countryName: String
    var cloSubmit: ((UIImage) -> Void)?
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            VStack(alignment: .center, spacing: 16) {
                if countryName == "Singapore" {
                    Text("NRIC Verification Required")
                        .font(.system(size: 18, weight: .semibold))
                } else {
                    Text("ID Verification Required")
                        .font(.system(size: 18, weight: .semibold))
                }
                
                if countryName == "Singapore" {
                    Text("To complete your first booking, please upload a clear photo of your NRIC for identity verification.")
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.center)
                } else {
                    Text("To complete your first booking, please upload a clear photo of your valid ID. This is a one-time requirement to keep our platform safe and secure.")
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.center)
                }
                
                Text("Your information will be kept confidential and used only for verification")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                
                if countryName == "Singapore" {
                    Text("Front Page NRIC Picture")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    VStack(spacing: 4) {
                        Text("Front of ID Photo")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if countryName == "India" {
                            Text("(Aadhaar, PAN, Driving Licence, Voter ID, Passport)")
                                .font(.system(size: 12, weight: .regular))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else if countryName == "Malaysia" {
                            Text("(MyKad, Passport, Driving Licence)")
                                .font(.system(size: 12, weight: .regular))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else if countryName == "Philippines" {
                            Text("(PhilSys ID, Passport, Driver’s License, UMID)")
                                .font(.system(size: 12, weight: .regular))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        .frame(height: 120)

                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 100)
                            .clipped()
                    }
                    
                    Button {
                        openCameraPicker()
                    } label: {
                        Text(selectedImage == nil ? "Upload a photo" : "Change photo")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(selectedImage == nil ? Color("BUTTON_COLOR") : Color("BUTTON_COLOR").opacity(0.75))
                            .cornerRadius(6)
                    }
                }

                HStack(spacing: 12) {

                    Button {
                        dismiss()
                        self.cloSubmit?(selectedImage!)
                    } label: {
                        Text("Submit")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedImage != nil ? Color("BUTTON_COLOR") : Color.gray)
                            .cornerRadius(18)
                    }
                    .disabled(selectedImage == nil)
                    .opacity(selectedImage == nil ? 0.6 : 1.0)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Back")
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
            .padding()
            .background (
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .padding(.horizontal, 16)
        }
    }
    
    private func openCameraPicker() {
        guard let topVC = UIApplication.topViewController() else { return }
        
        CameraHandler.sharedInstance.showActionSheet(vc: topVC)
        CameraHandler.sharedInstance.imagePickedBlock = { img in
            selectedImage = img
        }
    }
}

#Preview {
    PopDocView(countryName: "India")
}
