scenegifanizer
==============

A short Ruby script that analyses the frames of your video, infers the frames where a scene transition occur and save all the identified scenes as a separate gif animation.

Requirements
------------

- Ruby (tested with 1.9.1 on Arch Linux @ Raspberry Pi, meaning the ARM build)
- Ruby Chunky-PNG compatible library (I use Oily-PNG for the superb speedup - gem install oily_png)
- ffmpeg with the codec required for the video you want to *gifanize*
- imagemagick to animate the gif from the pngs

Usage
-----

    gifanize video.mp4
