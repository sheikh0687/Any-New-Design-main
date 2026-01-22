import Foundation
import Alamofire
import SwiftyJSON
import UIKit

class CommunicationManager {
    
    // MARK: - Shared Session
    private static let session: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 120
        return Session(configuration: configuration)
    }()

    // MARK: - POST API Request
    class func callPostService(
        apiUrl urlString: String,
        parameters params: [String: Any]?,
        parentViewController parentVC: UIViewController,
        successBlock success: @escaping (_ responseData: AnyObject, _ message: String) -> Void,
        failureBlock failure: @escaping (_ error: Error) -> Void
    ) {
        guard Utility.checkNetworkConnectivityWithDisplayAlert(isShowAlert: true) else {
            parentVC.hideProgressBar()
            Utility.showAlertMessage(withTitle: "", message: NETWORK_ERROR_MSG, delegate: nil, parentViewController: parentVC)
            return
        }
        
        let urlWithParams = params?.map { "\($0.key)=\($0.value)" }.joined(separator: "&") ?? ""
        print("FULL_API_FOR_BROWSER ************************************************************************************************** \n\(urlString)\(urlWithParams)")
        
        session.request(urlString, method: .get, parameters: params)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let json = try JSON(data: data)
                        success(json.object as AnyObject, "Successful")
                    } catch {
                        print("JSON Parse Error: \(error.localizedDescription)")
                        failure(error)
                    }
                case .failure(let error):
                    print("API Error: \(error.localizedDescription)")
                    failure(error)
                }
            }
    }
    
    // MARK: - Multipart: Upload Images & Data
    class func uploadImagesAndData (
        apiUrl urlString: String,
        params: [String: String]?,
        imageParam: [String: UIImage?]?,
        videoParam: [String: Data?]?,
        parentViewController parentVC: UIViewController,
        successBlock success: @escaping (_ responseData: AnyObject, _ message: String) -> Void,
        failureBlock failure: @escaping (_ error: Error) -> Void
    ) {
        guard Utility.checkNetworkConnectivityWithDisplayAlert(isShowAlert: true) else {
            parentVC.hideProgressBar()
            Utility.showAlertMessage(withTitle: "", message: NETWORK_ERROR_MSG, delegate: nil, parentViewController: parentVC)
            return
        }
        
        parentVC.showProgressBar()
        
        AF.upload(multipartFormData: { multipartFormData in
            if let params = params {
                for (key, value) in params {
                    if let data = value.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }
            
            if let imageParam = imageParam {
                for (key, image) in imageParam {
                    if let imageData = image?.jpegData(compressionQuality: 0.5) {
                        multipartFormData.append(imageData, withName: key, fileName: "\(key).jpg", mimeType: "image/jpeg")
                    }
                }
            }
            
            if let videoParam = videoParam {
                for (key, data) in videoParam {
                    if let data = data {
                        multipartFormData.append(data, withName: key, fileName: "\(key).mp4", mimeType: "video/mp4")
                    }
                }
            }
        }, to: urlString)
        .uploadProgress { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        }
        .validate()
        .responseData { response in
            parentVC.hideProgressBar()
            switch response.result {
            case .success(let data):
                do {
                    // Try to parse JSON data to SwiftyJSON
                    let json = try JSON(data: data)
                    success(json.object as AnyObject, "Successful")
                } catch {
                    print("JSON Parse Error: \(error.localizedDescription)")
                    failure(error)
                }
            case .failure(let error):
                print("Upload Error: \(error.localizedDescription)")
                failure(error)
            }
        }
    }
}
