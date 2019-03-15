--BAB-软连接

----set sourceFolder to the POSIX path of (target of front window as alias)
----set targetFolder to the POSIX path of (target of front window as alias)
--set sourceFolder to (POSIX path of (the selection as alias))
--set targetFolder to (POSIX path of (the selection as alias))
--set finderSelection to (POSIX path of (the selection as alias))
-- Symbolic Link
--do shell script "ln -s " & sourceFolder & targetFolder

tell application "System Events"
	-- tell application id "com.apple.finder"
	tell application "Finder"
		set theItems to selection
		set filePath to (POSIX path of (the selection as alias))
	end tell
	set the clipboard to filePath
end tell
--do shell script "path=$(pbpaste);ln -s $path $path"
do shell script "path=$(pbpaste);chmod a+x $path;cd ..;ln -s " & filePath & " " & filePath
