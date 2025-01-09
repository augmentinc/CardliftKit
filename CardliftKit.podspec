Pod::Spec.new do |spec|
  spec.name         = "CardliftKit"
  spec.version      = "1.0.0"
  spec.summary      = "CardliftKit SDK for iOS apps and Safari extensions"
  spec.description  = <<-DESC
                     The CardliftKit SDK is a comprehensive framework designed to simplify form data management, 
                     validation, and secure storage for apps and Safari web extensions. It provides shared data 
                     configuration, web extension handlers, form data validation, and metadata parsing capabilities.
                     DESC
  spec.homepage     = "https://github.com/augmentinc/CardliftKit"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Augment" => "support@augment.inc" }
  
  spec.platform     = :ios, "15.0"
  spec.swift_version = "5.0"
  
  spec.source       = { 
    :git => "https://github.com/augmentinc/CardliftKit.git",
    :branch => "main"
  }
  
  spec.source_files = "Sources/CardliftKit/**/*.swift"
  spec.framework    = "Foundation"
  
  spec.requires_arc = true
end 
