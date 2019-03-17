--发送选中的文件到 Yoink
--建议作为文件跳窗插件使用
tell application "System Events"
	-- tell application id "com.apple.finder"
	tell application "Finder"
		set theItems to selection
		set filePath to (POSIX path of (the selection as alias))
	end tell
	set the clipboard to filePath
	delay 0.1
	do shell script "path=$(pbpaste);open -a Yoink $path"
end tell