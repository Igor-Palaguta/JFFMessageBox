Pod::Spec.new do |s|
  s.name         = "JFFMessageBox"
  s.version      = "0.1.0"
  s.summary      = "AlertView/ActionSheet wrappers with useful functionality"
  s.homepage     = "http://spangleapp.com"
  s.license      = 'MIT'
  s.author       = { "Igor Palaguta" => "igor.palaguta@gmail.com" }

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.header_mappings_dir = 'JFFMessageBox'

  s.source_files = 'JFFMessageBox/**/*.{h,m}'
end
