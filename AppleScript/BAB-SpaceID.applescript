--SpaceID 是 BAB 预设的一个参数,表示第几个桌面
--这样你自己可以做出在不同桌面做相对应的动作的 Applescript.

--现在这个AppleScript的功能:转到下一桌面

tell application "System Events"
	key code 19 using control down
end tell
