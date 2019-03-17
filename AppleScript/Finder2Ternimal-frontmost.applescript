try
	
	tell application "Finder"
		if (front window exists) and (front window's name starts with "Searching “") then
			error "Error:" & linefeed & linefeed & "Front window is a Spotlight Search window!"
		else
			set tScript to "cd " & quoted form of (POSIX path of (insertion location as text))
		end if
	end tell
	
	tell application "Terminal"
		tell selected tab of front window
			if its busy = false then
				do script tScript in it
			else
				do script tScript
			end if
		end tell
	end tell
	
on error e number n
	set e to e & return & return & "Num: " & n
	if n ≠ -128 then
		try
			tell application (path to frontmost application as text) to set ddButton to button returned of ¬
				(display dialog e with title "ERROR!" buttons {"Copy Error Message", "Cancel", "OK"} ¬
					default button "OK" giving up after 30)
			if ddButton = "Copy Error Message" then set the clipboard to e
		end try
	end if
end try