# ruby
Rubyで作成したスクリプト集

## 目次

[movie_on_playing.rb](#movie_on_playing.rb)

[onsen_list.rb](#onsen_list.rb)

## movie_on_playing.rb
個々に撮影した演奏動画を結合．

使い方：

　侍り社 movie_on_playing　http://haverisxa.web.fc2.com/haverisxa/ruby/movie_on_playing.htm

Codeの説明：

　Qiita Rubyを使ってffmpegによる演奏動画の編集を簡単に　https://qiita.com/haverisxa/items/af459c0ba7876e7cf9be

## onsen_list.rb
インターネットラジオサイト 音泉 https://www.onsen.ag/ の，番組のタイトルとURL一覧を取得．2020年8月から変更された仕様に対応．

実行方法1：　ruby onsen_list.rb

　→　今日(実行した日)に更新された番組一覧を表示

実行方法1：　ruby onsen_list.rb 8/3

　→　1つ目の引数の日(例では8月3日)に更新された番組一覧を表示

出力形式：

　■ 番組名1 第n回 20xx年xx月xx日 放送

　　https://onsen......./playlist.m3u8
  
　■ 番組名2 第n回 20xx年xx月xx日 放送

　　https://onsen......./playlist.m3u8

その他：

　下記のコマンドにて，ffmpegでダウンロード．

　　ffmpeg -y -i "https://onsen......./playlist.m3u8" -vcodec copy -acodec copy -bsf:a aac_adtstoasc "output.mp4"

## test
