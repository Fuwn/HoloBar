.PHONY: default lint format clean build

default: format lint build

format:
	swiftformat .

lint:
	swiftlint

clean:
	xcodebuild clean

build:
	xcodebuild -configuration Release -scheme HoloBar clean build

