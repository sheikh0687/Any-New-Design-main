//
//  PopNRIC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 25/09/25.
//

import UIKit

class PopNRIC: UIViewController {
    
    @IBOutlet weak var imgNRIC: UIImageView!
    
    var cloSubmit: ((UIImage) -> Void)?
    var workerDoc:UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func btn_Cancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btn_UploadDoc(_ sender: UIButton) {
        CameraHandler.sharedInstance.showActionSheet(vc: self)
        CameraHandler.sharedInstance.imagePickedBlock = { [weak self] (image) in
            guard let self else { return }
            self.imgNRIC.isHidden = false
            self.imgNRIC.image = image
            workerDoc = image
        }
    }
    
    @IBAction func btn_Submit(_ sender: UIButton) {
        if workerDoc == nil {
            self.alert(alertmessage: "Please select the document")
        } else {
            self.dismiss(animated: true) {
                self.cloSubmit?(self.workerDoc!)
            }
        }
    }
    
    @IBAction func btn_Back(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
