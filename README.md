# ruby
Rubyで作成したスクリプト集

## 目次

[movie_on_playing.rb](#movie_on_playingrb)

[onsen_list.rb](#onsen_listrb)

## movie_on_playing.rb
個々に撮影した演奏動画を結合．

使い方：

　侍り社 movie_on_playing　http://haverisxa.web.fc2.com/haverisxa/ruby/movie_on_playing.htm

Codeの説明：

　Qiita Rubyを使ってffmpegによる演奏動画の編集を簡単に　https://qiita.com/haverisxa/items/af459c0ba7876e7cf9be

## onsen_list.rb
インターネットラジオサイト 音泉 https://www.onsen.ag/ の，番組のタイトルとURL一覧を取得．2020年8月から変更された仕様に対応．

2020/08/17: GUI形式で番組名の一覧を表示し，番組名を選択→｢選択した番組をダウンロード｣にて自動でダウンロードする仕様に変更．一部，番組名の更新日の年の表記が正しくない場合あり．

事前準備：

　ファイル内の ffmpeg="" の行の，""にffmpegのファイルパスを記入して下さい．
 
 ＊Windowsの場合，\は\\と2重で書く必要があります．

実行方法：　ruby onsen_list.rb

　＊ダウンロードしたファイルは，スクリプトを実行した場所．
