init:
	mkdir -p work

build: init
	docker build -t ffmpeg:openh264 .
