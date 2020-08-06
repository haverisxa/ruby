
require 'open-uri'
require 'openssl'
require 'kconv'

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
    # d = d.tosjis
    d_year = Time.now.strftime("%Y")
    d_month = d.split("/")[0].rjust(2,"0")
    d_day = d.split("/")[1].rjust(2,"0")
    return "#{d_year}îN#{d_month}åé#{d_day}ì˙ ï˙ëó"
end

if( ARGV[0] == nil )
    p_day = Time.now.strftime("%-m/%-d")
else
    p_day = ARGV[0]
end

url_n = "https://www.onsen.ag/web_api/programs"

begin
    source_c = open(url_n, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read
rescue
    puts "#{url_n} open error."
    exit
end

titlef = false
title = ""
b_num = ""
b_date = ""

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
    end
    if(ss.include?("playlist.m3u8"))
        s_url = rkey(ss, "streaming_url")
        if(p_day == b_date)
            puts "#{"Å°".tosjis} #{title} #{b_num} #{date_tr(b_date).tosjis}"
            puts "  #{s_url}"
        end
    end
end
