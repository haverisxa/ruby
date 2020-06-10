
#########################
### movie_on_playing  ###
#########################

# haverisxa
#  http://haverisxa.web.fc2.com/

control_file = ARGV[0]
cfile = File.open(control_file, "r")

def system_log( exe, workd )
  fho = File.open("#{workd}\\log.txt", "a")
  fho.write("#{exe}\n")
  fho.close
  res = system( exe )
  unless(res)
    puts "# Error! ffmpeg failed. See #{workd}\\log.txt to confirm command."
    exit
  end
end

out_width  = 0
out_height = 0
movie      = []
resize     = []
volume     = []
fadein     = []
delay      = []
delay_f    = []
to_time    = []
blackf     = []
crop_xy    = []
crop_size  = []
skip       = []
row_div    = []
row_flag   = true
ri = 0

for s1 in cfile
  next if s1 =~ /^#/
  a1 = s1.chomp.split(" ")
  if(a1[0] == "ffmpeg")
    ffmpeg = a1[1]
    next
  end
  if(a1[0] == "work")
    workd = a1[1]
    next
  end
  if(a1[0] == "out")
    out_file_name = a1[1]
    system("title #{out_file_name}")
    next
  end
  if(a1[0] == "movie")
    movie << a1[1]
    next
  end
  if(a1[0] == "resize")
    resize << a1[1]
    next
  end
  if(a1[0] == "volume")
    volume << a1[1]
    next
  end
  if(a1[0] == "fadein")
    fadein << a1[1]
    next
  end
  if(a1[0] == "delay")
    delay << a1[1]
    delay_f << a1[2] if(a1[1].to_f > 0)
    next
  end
  if(a1[0] == "time")
    to_time << a1[1]
    next
  end
  if(a1[0] == "crop")
    crop_xy << a1[1]
    crop_size << a1[2]
    if(row_div.size == 0)
      out_width = out_width + a1[2].split("x")[0].to_i
    end
    if row_flag
      out_height = out_height + a1[2].split("x")[1].to_i
      row_flag = false
    end
    next
  end
  if(a1[0] == "skip")
    skip << a1[1]
    next
  end
  if(a1[0] == "row_div")
    row_div << movie.size
    row_flag = true
    next
  end
end

cfile.close

Dir.mkdir(workd) unless File.exist?(workd)
efile_mp4 = []
efile_mp3 = []
ovl_vx = 0
ovl_vy = 0
ovl_a = []

fho = File.open("#{workd}\\log.txt", "a")
fho.write("\n#{Time.now}\n")
fho.close

out_width_e = out_width
out_height_e = out_height
fi = 0
w_reset = false
row_div << 9999

for i in 0...movie.size
  filen = movie[i].split("\\")[-1].split(".")[0]
  filee = movie[i].split("\\")[-1].split(".")[1]
  file_rsz = "#{filen}_#{resize[i]}"
  rx = resize[i].split("x")[0]
  ry = resize[i].split("x")[1]
  ####################
  #### resize part ###
  ####################
  if(delay[i].to_f > 0.0)
    fade_time = 0
  else
    fade_time = -1 * delay[i].to_f
  end
  if(delay[i].to_f > 0)
    if(fadein[i].to_i > 0)
      fade_in = "fade=in:0:#{fadein[i]},"
    else
      fade_in = ""
    end
    system_log( "#{ffmpeg} -y -i \"#{movie[i]}\" -vf \"#{fade_in}scale=#{rx}:#{ry}\" \"#{workd}\\#{file_rsz}.#{filee}\"", workd ) if(skip[i] == "off")
  else
    system_log( "#{ffmpeg} -y -i \"#{movie[i]}\" -vf \"scale=#{rx}:#{ry}\" \"#{workd}\\#{file_rsz}.#{filee}\"", workd ) if(skip[i] == "off")
  end
  ######################
  ### black mov part ###
  ######################
  if(delay[i].to_f > 0.0)
    dname = delay[i].gsub(".","p")
    bfile = "black_#{resize[i]}_#{dname}.#{filee}"
    if(delay_f[fi] == nil)
      frate = "30000/1001"
    else
      frate = delay_f[fi]
    end
    system_log( "#{ffmpeg} -y -f lavfi -i \"color=c=black:s=#{resize[i]}:r=#{frate}:d=#{delay[i]}\" -f lavfi -i \"aevalsrc=0|0:c=stereo:s=44100:d=#{delay[i]}\" \"#{workd}\\#{bfile}\"", workd ) if(skip[i] == "off")
    blackf << bfile
    fi = fi + 1
  else
    blackf << "black_0"
  end
  #######################
  ### concat/cut part ###
  #######################
  if(blackf[i] != "black_0")
    # add plus delay
    con_filen = "#{workd}\\concat_#{i}.txt"
    con_file = File.open(con_filen, "w")
    con_file.write("file #{workd}/#{blackf[i]}\n")
    con_file.write("file #{workd}/#{file_rsz}.#{filee}\n")
    con_file.close
    file_cn = "#{file_rsz}_con"
    system_log( "#{ffmpeg} -y -safe 0 -f concat -i \"#{con_filen}\" -c:v copy -c:a copy -map 0:v -map 0:a \"#{workd}\\#{file_cn}.#{filee}\"", workd ) if(skip[i] == "off")
  elsif(delay[i].to_f < 0)
    # add minus delay
    cut_time = -1 * delay[i].to_f
    file_ct  = "#{filen}_cut"
    system_log( "#{ffmpeg} -y -i \"#{workd}\\#{file_rsz}.#{filee}\" -ss #{cut_time} \"#{workd}\\#{file_ct}.#{filee}\"", workd ) if(skip[i] == "off")
    file_cn = file_ct
  else
    # not add delay
    file_cn = file_rsz
  end
  ###########################
  ### fade, crop, to part ###
  ###########################

  crop_x = crop_xy[i].split("x")[0]
  crop_y = crop_xy[i].split("x")[1]
  crop_w = crop_size[i].split("x")[0]
  crop_h = crop_size[i].split("x")[1]
  cropt = "crop=#{crop_w}:#{crop_h}:#{crop_x}:#{crop_y}"
  
  if(w_reset)
    out_width_e = out_width
    out_height_e = out_height_e - crop_h.to_i
    w_reset = false
  end

  if( out_width_e - crop_w.to_i > 0 || out_height_e - crop_h.to_i > 0)
    padt = ",pad=#{out_width_e}:#{out_height_e}:0:0"
  else
    padt = ""
  end
  if(to_time[i].to_f > 0)
    tot = "-to #{to_time[i].to_f + delay[i].to_f}"
  else
    tot = ""
  end
  file_crp = "#{file_rsz}_cropped"
  if(delay[i].to_f > 0)
    system_log( "#{ffmpeg} -y -i \"#{workd}\\#{file_cn}.#{filee}\" -vf \"#{cropt}#{padt}\" #{tot} \"#{workd}\\#{file_crp}.#{filee}\"", workd ) if(skip[i] == "off")
  else
    if(fadein[i].to_i > 0)
      fade_in = "fade=in:0:#{fadein[i]},"
    else
      fade_in = ""
    end
    system_log( "#{ffmpeg} -y -i \"#{workd}\\#{file_cn}.#{filee}\" -vf \"#{fade_in}#{cropt}#{padt}\" #{tot} \"#{workd}\\#{file_crp}.#{filee}\"", workd ) if(skip[i] == "off")
  end
  
  out_width_e = out_width_e - crop_w.to_i
  if(row_div.size > 0)
    if(i == row_div[ri] - 1)
      ovl_vx = 0
      ovl_vy = ovl_vy + crop_h.to_i
      ri = ri + 1
      w_reset = true
    else
      ovl_vx = ovl_vx + crop_w.to_i
    end
  else
    ovl_vx = ovl_vx + crop_w.to_i
  end
  ovl_a << [ovl_vx, ovl_vy]
  ############################
  ### mp3 out, volume part ###
  ############################
  vol_e = volume[i].to_f / 100
  system_log( "#{ffmpeg} -y -i \"#{workd}\\#{file_crp}.#{filee}\" -vn -acodec libmp3lame -ar 44100 -ab 256k -af \"volume=#{vol_e}\" \"#{workd}\\#{filen}.mp3\"", workd ) if(skip[i] == "off")
  efile_mp3 << "#{workd}\\#{filen}.mp3"
  efile_mp4 << "#{workd}\\#{file_crp}.#{filee}"
end

####################
### overlay part ###
####################
in_file = ""
for efile in efile_mp4
  in_file = "#{in_file} -i \"#{efile}\""
end
ovlt = ""
for i in 0...ovl_a.size - 1
  if(ovlt == "")
    ovlt = "overlay=x=#{ovl_a[i][0]}:y=#{ovl_a[i][1]}"
  else
    ovlt = "#{ovlt},overlay=x=#{ovl_a[i][0]}:y=#{ovl_a[i][1]}"
  end
end
system_log( "#{ffmpeg} -y#{in_file} -filter_complex \"#{ovlt}\" -an \"#{workd}\\out_movie.#{filee}\"", workd )
######################
### add audio part ###
######################
in_file = ""
for efile in efile_mp3
  in_file = "#{in_file} -i \"#{efile}\""
end
system_log( "#{ffmpeg} -y -i \"#{workd}\\out_movie.#{filee}\" #{in_file} -filter_complex \"amix=inputs=#{efile_mp3.size}:duration=longest:dropout_transition=2\" \"#{out_file_name}\"", workd )

