Pod::Spec.new do |s|
  s.name             = 'tesseract-objc'
  s.version          = '0.1.0'
  s.summary          = 'Tesseract OCR Objective-C bindings'
  s.description      = <<-DESC
tesseract-objc contains:
* ObjC API with handy blocks
* Pre-built static libraries: libleptonica, libtesseract
* English tessdata for recognition as optional subspec
* Shell script to rebuild static libraries from official repos via git submodules
                       DESC

  s.homepage         = 'https://github.com/stefan-sedlak/tesseract-objc'
  s.license          = { :type => '2-BSD', :file => 'LICENSE' }
  s.author           = { 'Stefan Sedlak' => 'stefan@sedlak.eu' }
  s.source           = { :git => 'https://github.com/stefan-sedlak/tesseract-objc.git', :tag => s.version.to_s }

  s.module_name      = 'Tesseract'
  s.ios.deployment_target = '9.0'

  s.subspec 'code' do |ss|
    ss.source_files = 'tesseract-objc/Classes/**/*', 'tesseract-objc/Libraries/include/**/*.h'
    ss.public_header_files = 'tesseract-objc/Classes/Tesseract.h'
    ss.ios.vendored_libraries = 'tesseract-objc/Libraries/lib/ios/libleptonica.a', 'tesseract-objc/Libraries/lib/ios/libtesseract.a'
    ss.ios.frameworks = 'UIKit'
    ss.libraries = 'c++'
  end

  s.subspec 'eng' do |ss|
    ss.dependency 'tesseract-objc/code'
    ss.resource_bundles = {
      'tesseract-eng' => ['tesseract-objc/Assets/eng/tessdata']
    }
  end

  s.default_subspec = 'code'
end
