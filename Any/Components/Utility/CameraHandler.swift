
import Foundation
import UIKit


class CameraHandler: NSObject{
    
    fileprivate var currentVC: UIViewController!
    
    var media = [String]()
    
    static let sharedInstance:CameraHandler = {
        let instance = CameraHandler()
        return instance
    }()
    
    //MARK: Internal Properties
    var imagePickedBlock: ((UIImage) -> Void)?
    
    var videoPickedBlock: ((URL) -> Void)?
    
    func camera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
    }

    func photoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
//            myPickerController.mediaTypes = self.media
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
    }
    
//    func showActionSheet(vc: UIViewController) {
//        currentVC = vc
//        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        
//        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
//            self.camera()
//        }))
//        
//        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
//            self.photoLibrary()
//        }))
//        
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        vc.present(actionSheet, animated: true, completion: nil)
//    }
    func showActionSheet(vc: UIViewController, sender: UIView? = nil) {
        currentVC = vc
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // ✅ iPad popover config
        if let popoverController = actionSheet.popoverPresentationController {
            if let source = sender {
                popoverController.sourceView = source
                popoverController.sourceRect = source.bounds
            } else {
                popoverController.sourceView = vc.view
                popoverController.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
            }
            popoverController.permittedArrowDirections = []
        }

        vc.present(actionSheet, animated: true, completion: nil)
    }
}


extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imagePickedBlock?(image)
        } else {
                   print("Something went wrong")
        }
        if let video = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            self.videoPickedBlock?(video)
        }
        currentVC.dismiss(animated: true, completion: nil)
    }    
}
