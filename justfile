import? 'xcode.just'

target := 'HoloBar'

fetch:
   curl https://raw.githubusercontent.com/Fuwn/justfiles/refs/heads/main/xcode.just > xcode.just

format:
	just _format {{target}}

build:
	just _build {{target}}

open:
	just _open {{target}}
