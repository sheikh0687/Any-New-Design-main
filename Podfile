# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Any' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Any

#pod 'IQKeyboardManagerSwift'
pod 'IQKeyboardManagerSwift', '6.3.0'
pod 'SwiftyJSON'
pod 'DropDown'
pod 'SDWebImage/WebP'
pod 'SVProgressHUD'
pod 'Cosmos'
#pod 'SlideMenuControllerSwift'
pod 'Firebase/Messaging'
pod 'InputMask'
#pod 'FSCalendar'
pod 'OTPFieldView'

pod 'R.swift', '~> 5.4.0'

pod 'CountryPickerView'

pod 'Alamofire'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    # Fix libarclite_xxx.a file not found.
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
