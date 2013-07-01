require 'oily_png'
include ChunkyPNG::Color

def compare_frames(fname1 , fname2) 
	images = [
	  ChunkyPNG::Image.from_file(fname1),
	  ChunkyPNG::Image.from_file(fname2)
	]

	diff = 0 
	images.first.height.times do |y|
	  images.first.row(y).each_with_index do |pixel, x|
	      diff = diff + (r(images.first[x,y])-r(images.last[x,y])).abs ;
	      diff = diff + (g(images.first[x,y])-g(images.last[x,y])).abs ;
	      diff = diff + (b(images.first[x,y])-b(images.last[x,y])).abs ;
	  end
	end

	total_size = (images.first.height*images.first.width)
	difference = (diff/(total_size*255*3.0).to_f)*100.0
	puts "pixel diff:"+diff.to_s
	puts "%diff : "+("%.3f" % difference).to_s + "\%"
	return difference
	
end

# def profile_video(fname) 
# 	file = RVideo::Inspector.new(:file => "/root/ruby_miniprojects/expect.mp4", :ffmpeg_binary => "/usr/bin/ffmpeg")
#   puts file.valid?
#   puts file.video?
#   puts file.unreadable_file?
#   puts file.fps 
#   puts file.duration.to_s
#   puts "asd"
# end 

#profile_video 'expect.mp4'
#compare_frames '5.png','7.png'

def gif(fs, from, to)
	cmd = "convert -delay 5 -loop 0 "
	fs.each do |f|
		cmd += f + " "
	end
	
	cmd += " gif_from_#{from}_to_#{to}.gif"

	puts "Generating gif_from_#{from}_to_#{to}.gif ..."
	`#{cmd}` #generate gif with imagemagick
end

frames = []
Dir.foreach('.') do |item|
  next if item == '.' or item == '..' or !item.include?('frames')
  frames.push item
end

frames.sort!
#puts frames

fout = File.open("result.log","w")
start = 0
for i in (0..frames.length-1-1)
	#puts frames[i] + " - " + frames[i+1]
	next if i == start and i != 0
	puts "Comparing frame " + i.to_s + " with frame " + (i+1).to_s

	res = compare_frames(frames[i],frames[i+1])
	if res >= 25.0
		gif(frames.slice(start,i),start,i)
		start = i+1
	end
	#puts "\t" + res
	#puts " "
	fout.write ("%.3f" % res)+"\n"
end