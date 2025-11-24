//
//  CountryPickerVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 28/02/25.
//

import UIKit
import CountryPickerView

class CountryPickerVC: UIViewController {
    
    weak var cpvTextField: CountryPickerView!
    var phoneKey:String! = ""
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
//    func configureCountryPicker(for txt_CountryPicker: UITextField)
//    {
//        let cp = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 80, height: 14))
//        cp.flagImageView.isHidden = true
//        txt_CountryPicker.rightView = cp
//        txt_CountryPicker.rightViewMode = .always
//        txt_CountryPicker.leftView = nil
//        txt_CountryPicker.leftViewMode = .never
//        cpvTextField = cp
//        let countryCode = "US"
//        cpvTextField.setCountryByCode(countryCode)
//        cp.delegate = self
//        [cp].forEach {
//            $0?.dataSource = self
//        }
//        phoneKey = cp.selectedCountry.phoneCode
//        cp.countryDetailsLabel.font = UIFont.systemFont(ofSize: 12)
//        cp.font = UIFont.systemFont(ofSize: 12)
//    }
}

//extension CountryPickerVC: CountryPickerViewDelegate, CountryPickerViewDataSource {
//    
//    func countryPickerView(_ countryPickerView: CountryPickerView.CountryPickerView, didSelectCountry country: CountryPickerView.Country) {
//        <#code#>
//    }
//    
//    
//    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
//        
//    }
//    
//    func preferredCountries(in countryPickerView: CountryPickerView) -> [Country] {
//        var countries = [Country]()
//        ["GB"].forEach { code in
//            if let country = countryPickerView.getCountryByCode(code) {
//                countries.append(country)
//            }
//        }
//        return countries
//    }
//    
//    func sectionTitleForPreferredCountries(in countryPickerView: CountryPickerView) -> String? {
//        return "Preferred title"
//    }
//    
//    func showOnlyPreferredSection(in countryPickerView: CountryPickerView) -> Bool {
//        return false
//    }
//    
//    func navigationTitle(in countryPickerView: CountryPickerView) -> String? {
//        return "Select a Country"
//    }
//}


