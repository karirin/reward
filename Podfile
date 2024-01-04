# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'reward' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for prg
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Storage'
pod 'Firebase/Database'
pod 'FSCalendar'
pod 'SwiftLinkPreview'
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                xcconfig_path = config.base_configuration_reference.real_path
                xcconfig = File.read(xcconfig_path)
                xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
                File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
#                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.4'
               end
          end
   end
end
