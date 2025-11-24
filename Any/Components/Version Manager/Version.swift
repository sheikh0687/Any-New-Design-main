//
//  Version.swift
//  Any
//
//  Created by Techimmense Software Solutions on 28/04/25.
//

import Foundation
import UIKit

class VersionManager {
    
    static let shared = VersionManager()
    
    func checkAppVersion() {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=1576680333") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let appStoreVersion = results.first?["version"] as? String {
                    
                    print("App Store Version: \(appStoreVersion)")
                    
                    if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        print("Current Installed Version: \(currentVersion)")
                        
                        if currentVersion.compare(appStoreVersion, options: .numeric) == .orderedAscending {
                            // New version available
                            DispatchQueue.main.async {
                                self.showUpdateAlert()
                            }
                        } else {
                            print("App is up-to-date.")
                        }
                    }
                }
            } catch {
                print("Failed to parse JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func showUpdateAlert() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            let alert = UIAlertController(title: "Update Available",
                                          message: "A new version of the app is available. Please update to continue.",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
                if let url = URL(string: "https://apps.apple.com/us/app/anytime-work/id1576680333") {
                    UIApplication.shared.open(url)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            rootVC.present(alert, animated: true, completion: nil)
        }
    }
}
