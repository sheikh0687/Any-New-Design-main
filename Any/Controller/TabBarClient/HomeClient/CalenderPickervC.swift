//
//  CalenderPickervC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 23/09/25.
//

import UIKit

class CalenderPickervC: UIViewController {

    @IBOutlet weak var date: UIDatePicker!
    
    var cloCancel: (() -> Void)?
    var cloOk: ((_ currentdate: String) -> Void)?
    @objc var selectedDate:String = ""
    
    var dateformate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        date.datePickerMode = .date
//      
//        if let oneWeeksFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date()) {
//            date.date = oneWeeksFromNow
//            self.date.minimumDate = oneWeeksFromNow
//        }
//        
//        // Optionally, you can add a target to respond to date changes
//        date.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        self.date.minimumDate = Date()
        self.dateformate = Utility.getCurrentShortDateNew()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
         // Handle date changes here if needed
         let selectedDate = sender.date
         print("Selected Date: \(selectedDate)")
     }
    
    @IBAction func btnOk(_ sender: UIButton) {
        if self.dateformate == "" {
            self.alert(alertmessage: "Please select the date!")
        } else {
            self.cloOk?(self.dateformate)
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func Datepicker(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        self.dateformate = dateformatter.string(from: selectedDate)
        print(dateformate)
    }
    
    @IBAction func btnCancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
