
require 'open-uri'
require 'openssl'
require 'kconv'
require 'tk'

ffmpeg = "C:\\Programs\\ffmpeg-4.2.2-win64-static\\bin\\ffmpeg.exe"
opt = "-vcodec copy -acodec copy -bsf:a aac_adtstoasc"

def rkey(s, key)
    sa = s.split(",")
    for s1 in sa
        if (s1.include?(key))
            s1.gsub!("https:","https")
            s1o = s1.split(":")[1]
            s1o.gsub!("https","https:")
            return s1o.gsub("\"","")
        end
    end
end

def date_tr(d)
    d_year = Time.now.strftime("%Y")
    if(d == "null")
        d = "0/0"
    end
    if(d)
        d_month = d.split("/")[0].rjust(2,"0")
        d_day = d.split("/")[1].rjust(2,"0")
    else
        d_month = "00"
        d_day = "00"
    end
        return "#{d_year}�N#{d_month}��#{d_day}�� ����"
end

url_n = "https://www.onsen.ag/web_api/programs"

begin
    puts "# Obtaining Program list ..."
    source_c = open(url_n, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read
rescue
    puts "#{url_n} open error."
    exit
end

titlef = false
title = ""
b_num = ""
b_date = ""
b_list = []

puts "# Making GUI ..."

for s in source_c.split("{")
    ss = s.tosjis
    if(ss.include?("\display\":true,\"title\":\""))
        title = rkey(ss, "title")
        titlef = true
    end
    if(titlef && ss.include?("program_id"))
        b_num = rkey(ss, "title")
        titlef = false
    end
    if(ss.include?("updated"))
        b_date = rkey(ss, "updated")
        #puts b_date
    end
    if(ss.include?("playlist.m3u8"))
        s_url = rkey(ss, "streaming_url")
        b_date = "0/0" if(b_date == "null")
        b_date_m = b_date.split("/")[0]
        b_date_d = b_date.split("/")[1]
        b_date_m = "0" unless(b_date_m)
        b_date_d = "0" unless(b_date_d)
        b_list << ["#{b_date_m.rjust(2,"0")}/#{b_date_d.rjust(2,"0")}", "#{title} #{b_num} #{date_tr(b_date).tosjis}", s_url]
    end
end

b_list.sort!{ |a, b| b[0] <=> a[0] }

TkRoot.new do
	title( "onsen list" )
end

frame = TkFrame.new(nil).pack
scrollbar = TkScrollbar.new(frame)

listbox = TkListbox.new(frame, height: 20, width: 80, selectmode: 'multiple', yscrollcommand: proc{|first, last|scrollbar.set(first, last)}).pack(side: 'left', fill: 'both')

scrollbar.command(proc{|first,last| listbox.yview(first,last)}).pack(side: 'right', fill: 'y')

for list_line in b_list
    listbox.insert 'end', "#{list_line[0]}:  #{list_line[1]}"
end
   
TkButton.new(nil, text: '�I�������ԑg���_�E�����[�h', command: proc{(listbox.curselection).each{|i|
    puts "# Downloading: #{b_list[i][1]}"
    system("#{ffmpeg} -y -i \"#{b_list[i][2]}\" #{opt} \"#{b_list[i][1]}.mp4\"")
    puts "# Download completed"
}}).pack

Tk.mainloop
