--"ABC-QWERTZ" => "ABC - QWERTZ"
--"US Extended" => "ABC（扩展）"
--"US" => "美国"  "ABC" => "ABC"
--"USInternational-PC" => "美国（国际 - PC）"
--"TibetanOtaniUS" => "藏文（Otani）"
--"ABC-AZERTY" => "ABC - AZERTY"


set info to do shell script "plutil -p '/System/Library/Keyboard Layouts/AppleKeyboardLayouts.bundle/Contents/Resources/zh_CN.lproj/InfoPlist.strings' | grep 'ABC\\|US'"

display dialog info
