Pod::Spec.new do |spec|
  spec.name         = "CoastAudio"
  spec.version      = "1.0.0"
  spec.summary      = "coast_audio native library"
  spec.description  = "coast_audio native library"
  spec.homepage     = "https://github.com/SKKbySSK/coast_audio"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "kaisei-sunaga" => "skkbyssk@gmail.com" }
  spec.source       = { :git => "https://github.com/SKKbySSK/coast_audio.git" }

  spec.osx.deployment_target = '10.14'
  spec.ios.deployment_target = '12.0'
  spec.ios.frameworks = 'AVFoundation', 'AudioToolbox'

  spec.vendored_frameworks = ["native/prebuilt/apple/coast_audio.xcframework"]
  spec.source_files = "native/src/SymbolKeeper.swift"
end
