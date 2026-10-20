platform :ios, '15.6'

target 'PipelineAlertManagerDemo' do
  use_frameworks!

  pod 'PipelineAlertManager', :path=> './PipelineAlertManager'
  pod 'SnapKit'
  pod 'MyBaseExtension'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.6'
    end
  end
end
