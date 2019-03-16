on run argv
	
	set account to item 1 of argv
	set is_match_on to item 2 of argv
	
	# get account password from Keychain
	set _password to do shell script "/usr/bin/security find-generic-password -l 'Apple Account Switcher' -a " & account & " -w || echo denied"
	
	# failed to get password
	if _password is "denied" then
		display dialog "Failed to get the password of '" & account & "' from Keychain" buttons {"OK"}
		return
	end if
	
	# get current application
	tell application "System Events"
		# frontmost application
		set current_app to first item of (get name of processes whose frontmost is true)
		if current_app is not in {"iTunes", "iBooks", "App Store"} then
			set current_app to "iTunes"
			tell application "iTunes" to activate
			delay 1
		end if
		if current_app is not "iTunes" then
			set is_match_on to "false"
		end if
	end tell
	
	# get localized title
	set l10n_folder to (getWorkflowFolder() & "/lang.lproj")
	set locale to user locale of (get system info)
	set locale to text 1 thru 2 of locale
	set t_account to sl10n("Account", current_app, l10n_folder, locale)
	set t_store to sl10n("Store", current_app, l10n_folder, locale)
	set t_signout to sl10n("Sign Outÿ", current_app, l10n_folder, locale)
	set t_signin to sl10n("Sign Inÿ", current_app, l10n_folder, locale)
	set t_icloudmusic to sl10n("iCloud Music Library", current_app, l10n_folder, locale)
	set t_turnon to sl10n("Turn On iTunes Match", current_app, l10n_folder, locale)
	set t_imatch to sl10n("iTunes Match", current_app, l10n_folder, locale)
	
	tell application "System Events"
		tell process current_app
			set frontmost to true
			
			# check store menu title
			set store_item to a reference to menu bar item t_store of menu bar 1
			if not (exists store_item) then
				set t_store to t_account
			end if
			
			# try to sign out first
			set signin_item_old to a reference to menu item t_signin of menu t_store of menu bar item t_store of menu bar 1
			set signout_item_old to a reference to menu item t_signout of menu t_store of menu bar item t_store of menu bar 1
			if not (exists signin_item_old) then
				if not (exists signout_item_old) then
					display dialog "signout_item doesn't exist, you may need to update the alfred workflow " buttons {"OK"}
					return
				end if
			end if
			try
				click menu item t_signout of menu t_store of menu bar item t_store of menu bar 1
			end try
			
			# wait until sign in menu item available
			set signin_item to a reference to menu item t_signin of menu t_store of menu bar item t_store of menu bar 1
			set is_error to true
			repeat 20 times
				if (exists signin_item) then
					set is_error to false
					click signin_item
					exit repeat
				end if
				delay 0.1
			end repeat
			if is_error then
				display dialog "Failed to switch account, no signin menu, you might need to relaunch " & current_app buttons {"OK"}
				return
			end if
			
			# wait until login panel shows up
			set is_error to true
			repeat 50 times
				try
					# try to get frontmost panel
					set pre_element to window 1
					set element to window 1
					# repeat to get last element
					repeat
						set ref_element to a reference to last UI element of element
						# last element
						if not (exists ref_element) then
							exit repeat
						end if
						set pre_element to element
						set element to last UI element of element
					end repeat
					set frontmost_panel to pre_element
					
					# login panel has 7 buttons
					set button_count to count of (every button of frontmost_panel)
					if current_app is not "iTunes" then
						set button_number to 5
					else
						set button_number to 4
					end if
					if button_count is button_number then
						set is_error to false
						exit repeat
					end if
				end try
				delay 0.2
			end repeat
			#if is_error is false then
			#	display dialog "Success to switch account, login panel shows up " buttons {"OK"}
			#end if
			if is_error then
				display dialog "Failed to switch account, no login panel, you might need to relaunch " & current_app buttons {"OK"}
				return
			end if
			
			# focus to apple id input field
			set apple_id to first item of ((text fields of frontmost_panel) whose subrole is not "AXSecureTextField")
			set value of attribute "AXFocused" of apple_id to true
			
			# enter account and password
			keystroke account
			keystroke tab
			keystroke _password
			keystroke return
			
			# wait until sign out menu item available to make sure login successfully
			set signout_item to a reference to menu item t_signout of menu t_store of menu bar item t_store of menu bar 1
			set login_timeout to true
			set ok1 to false
			set ok2 to false
			repeat 20 times
				try
					# try to get frontmost panel
					set pre_element to window 1
					set element to window 1
					# repeat to get last element
					repeat
						set ref_element to a reference to last UI element of element
						# last element
						if not (exists ref_element) then
							exit repeat
						end if
						set pre_element to element
						set element to last UI element of element
					end repeat
					set frontmost_panel to pre_element
					
					# check whether "switch country" dialog shows up
					if not ok1 then
						# "switch country" dialog has 1 button and 1 image
						set button_count to count of (every button of frontmost_panel)
						if button_count is 1 then
							set image_count to count of (every image of frontmost_panel)
							if image_count is 1 then
								# press enter to confirm "switch country" dialog
								keystroke return
								set ok1 to true
							end if
						end if
					end if
					
					# check whether "iCloud session" dialog shows up
					if not ok2 then
						# "iCloud session" dialog has 4 buttons and 2 inputs
						set button_count to count of (every button of frontmost_panel)
						if button_count is 4 then
							set input_count to count of (every text field of frontmost_panel)
							if input_count is 2 then
								# press ESC to cancel "iCloud session" dialog
								key code 53
								set ok2 to true
							end if
						end if
					end if
					
					# check sign out menu
					if (exists signout_item) then
						set login_timeout to false
						exit repeat
					end if
				end try
				delay 0.1
			end repeat
			
			# iTunes Match
			if is_match_on is "True" then
				
				if login_timeout then
					display dialog "Failed to turn on iTunes Match
(Taking too long to sign in)" buttons {"OK"}
					return
				end if
				
				# check iTunes version
				set theVersion to version of application "iTunes"
				considering numeric strings
					if theVersion ¡Ý "12.2" then
						set newMethod to true
					else
						set newMethod to false
					end if
				end considering
				
				#try to turn on iTunes Match
				if newMethod then
					# for iTunes 12.2 and later
					set is_error to true
					try
						# use shortcut to open iTunes Preferences
						keystroke "," using command down
						
						# get all checkboxes in Preferences dialog
						try
							set theCheckboxes to checkboxes of group 1 of window 1
						on error
							# try again after 0.5s if error occurs
							delay 0.5
							set theCheckboxes to checkboxes of group 1 of window 1
						end try
						
						repeat with theCheckbox in theCheckboxes
							# find out which checkbox is to turn on iTunes Match
							if title of theCheckbox contains t_icloudmusic then
								tell theCheckbox
									# click on the checkbox if it's not selected
									if not (its value as boolean) then click theCheckbox
								end tell
								set is_error to false
								exit repeat
							end if
						end repeat
						# press enter to confirm preferences
						keystroke return
					end try
					if is_error then
						display dialog "Failed to turn on iTunes Match" buttons {"OK"}
						return
					end if
				else
					# for older version of iTunes
					try
						click menu item t_turnon of menu t_store of menu bar item t_store of menu bar 1
						
						# wait until iTunes Match page available
						set target_item to a reference to UI element t_imatch of UI element 1 of scroll area 1 of splitter group 1 of window 1
						set is_error to true
						repeat 50 times
							if (exists target_item) then
								set is_error to false
								# click add button
								click last button of UI element 1 of scroll area 1 of splitter group 1 of window 1
								exit repeat
							end if
							delay 0.2
						end repeat
						if is_error then
							display dialog "Failed to turn on iTunes Match" buttons {"OK"}
							return
						end if
						# enter password
						keystroke _password
						keystroke return
						# wait until iTunes Match begin
						set target_item to a reference to UI element t_imatch of group 1 of UI element 1 of scroll area 1 of splitter group 1 of window 1
						repeat 30 times
							if (exists target_item) then
								exit repeat
							end if
							delay 0.2
						end repeat
						keystroke "h" using {command down, shift down}
					end try
				end if
			end if
		end tell
	end tell
	
	return "Done"
end run

# method to get localized string from app_name
on sl10n(en_key, app_name, l10n_folder, locale)
	if locale is "en" then
		return en_key
	end if
	
	set app_path to "//Applications/" & app_name & ".app/"
	
	tell application "System Events"
		set l10n_key to localized string of en_key from table app_name in bundle l10n_folder
		# if l10n_key is not available in current app's dictionary, then get localized string from iBooks
		if l10n_key is "N/A" then
			set l10n_key to localized string of en_key from table "iBooks" in bundle l10n_folder
			set localized_str to localized string of l10n_key from table "Localizable" in bundle "//Applications/iBooks.app"
			return localized_str
		end if
		set table_name to localized string of "table" from table app_name in bundle l10n_folder
		set localized_str to localized string of l10n_key from table table_name in bundle app_path
		return localized_str
	end tell
end sl10n

on getWorkflowFolder()
	set workflowFolder to do shell script "pwd"
	return workflowFolder
end getWorkflowFolder