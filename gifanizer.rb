require 'oily_png'
include ChunkyPNG::Color

$frame_prefix = "scene_frame_"

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

def go() 
	frames = []
	Dir.foreach('.') do |item|
	  next if item == '.' or item == '..' or !item.include?(frame_prefix)
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
end

def reputs( str )
    puts "\e[0K" + str
    #puts str
    `tput cuu1`
end

def extract_frames(fname, from = "", to = "")
	if(from != "")
		from = "-ss #{from}"
	end
	if(to != "")
		to = "-t #{to}"
	end

	get_frames_cmd = "ffmpeg #{from} #{to} -i #{fname} -vcodec copy -acodec copy -f null /dev/null 2>&1 | grep 'frame='"#{}" | cut -f 2 -d ' '"
	pipe = IO.popen(get_frames_cmd)
	total_frames = pipe.gets
	if /frame=\s+(\d+)/.match(total_frames) then
		total_frames = "#{$1}"
	end
	
	puts "num frames:#{total_frames}"

	cmd = "ffmpeg #{from} #{to} -i #{fname} -s sqcif -vcodec png #{$frame_prefix}%8d.png 3>&1 2>&1"
	puts "Extracting frames from video... ('#{cmd}')"
	pipe = IO.popen(cmd, "w+")
	pipe.puts "c"
	started = false
	while(line = pipe.gets)
		#match = line.match /frame=\s+(\d+)/
		#puts "line:#{line}"
		if /frame=\s+(\d+)/.match(line) then
			started = true
			reputs "Frame #{$1} of #{total_frames}"
		end
		if started
			pipe.flush
			#puts "waitning..."
			sleep(0.5)
			#puts "waited!"
		end
		begin
			pipe.puts "c"

		rescue 

		end
	end
	#{}`#{cmd}`
end

extract_frames("expect.mp4",0,100000)
#extract_frames("expect.mp4")



