# nhkradio-russian-record
NHKラジオFM ロシア語講座録音

- これはラジオ「NHK ONE らじる★らじる」(FM放送）の「ロシア語講座番組」を**自動録音**するものです。
- [まいにちロシア語【初級編】【応用編】](https://www.nhk.jp/p/rs/YRLK72JZ7Q/) //www.nhk.jp/p/rs/YRLK72JZ7Q/  
 [ NHK=>語学](https://www.nhk.jp/g/gogaku/) //www.nhk.jp/g/gogaku/
- 当スクリプトで他の語学番組等も録音可能ですが、[nhkradio-langs-record](https://github.com/ru-museum/nhkradio-langs-record) 及び [nhkradio-record](https://github.com/ru-museum/nhkradio-record) とを別途提供しています。

### 【注意】  
- 2026年度の番組改定（3月30日）に依る再編（2波体制）が行われ**第２放送**は**NHK-FM**へと移行されました。  
[ラジオ再編](https://www.nhk.or.jp/radio/saihen/)

### NHK-FM まいにちロシア語 番組表
|編|曜日|放送時刻|放送時間|
|---|---|:---:|:---:|
|初級編|月～水|2:30|15分|
|応用編|木・金|2:30|15分|

## 語学番組表
2026/03/30 改定
|ID|講座名|放送波|放送日|編別|放送時刻|時間|CRON曜日|
|:---:|---|---|---|---|---|---|---|
|1|まいにちロシア語|FM|月〜金|初/応|2:30|15|1-5|
|2|まいにちイタリア語|FM|月〜金|初/応|2:15|15|1-5|
|3|まいにちスペイン語|FM|月〜金|初/応|1:45|15|1-5|
|4|まいにち中国語|FM|月〜金||1:15|15|1-5|
|5|まいにちドイツ語|FM|月〜金|初/応|1:30|15|1-5|
|6|まいにちハングル講座|FM|月〜金||1:00|15|1-5|
|7|まいにちフランス語|FM|月〜金|初/応|2:00|15|1-5|
|8|ポルトガル語|FM|日||1:00|15|0|  
|9|英会話タイムトライアル|FM|月〜金||23:50|10|1-5|
|10|エンジョイ・シンプル・イングリッシュ|FM|月〜金||6:00|05|1-5|
|11|小学生の基礎英語|FM|月〜金||6:05|10|1-5|
|12|基礎英語-レベル1|FM|月〜金||6:15|15|1-5|
|13|基礎英語-レベル2|FM|月〜金||6:30|15|1-5|
|14|ニュースで学ぶ「現代英語」|FM|月〜金||23:35|15|1-5|
|15|ラジオ英会話|FM|月〜金||6:45|15|1-5|
|16|ラジオビジネス英語|FM|月〜金||23:20|15|1-5|

※ ポルトガル語講座は、月により以下の編別に自動で振分けられます。<br>
　・ 入門（４月〜９月）<br>
　・ ステップアップ（１０月〜３月）  

# 動作環境  
- Linux（Debian: **bash** 使用）
- ffmpeg のインストールが必要です。
``` 
# apt-get install ffmpeg
```
# 使用オプション
|オプション|コマンド|説明|
|:---|:---|:---|
|ヘルプ|-h|ヘルプ及び「番組表」を表示します。|
|録音する番組|-i [ ID ]|「番組表」より録音する番組の「ID番号」を指定します。<br>【例】-i 12<br>※ 指定の無い場合「NHKラジオ放送番組」が設定されます。|
|放送波（チャンネル）|-w [ am \| fm ]|録音するNHKラジオ放送のチャンネルを指定します。<br>NHK-AM：am<br>NHK-FM：fm<br>※ デフォルト(未入力)は NHK-FM （fm）が設定されます。|
|録音時間|-r [ 00:00:00 ]|録音する時間を指定します。<br>【例】-r　00:30:00 （30分）<br>※ デフォルト(未入力)は15分|
|番組タイトル|-t [ タイトル ]|録音する番組タイトル名。<br>【例】-t NHKきょうのニュース<br>※ 無記入の場合は「NHKAM放送番組」が設定されます。|
|保存ディレクトリ|-d [ directory ]|保存ディレクトリ名を指定します。<br>【例】-d audio<br>※ 指定の無い場合は「ID番組名」か直下に保存されます。|
|開始時刻の遅延|-s [ 60 \| 1h50m30s ]|開始時刻を遅延させます（予約的機能として使用されます）<br>【例】-s 60s (or 60) ：60秒後に録音開始<br>-s 1h5m30s　：1時間5分30秒後に録音開始<br>※ "h" "m" "s" の間には「スペース」を挟みません。<br>※ スクリプト上では「sleep 1h 5m 30s」と表記します。|

# 定時録音
- CRON を使い自動的に定時録音が可能です。
- **username** には通常 root か ユーザー名 が入ります。  
- シェルは **bash** を指定して下さい。
### （0）環境構築   
- 作業フォルダに nhkradio-russian-record.sh を置きアクセス権限を変更します。  
```
$ chmod 744(or 755)  nhkradio-russian-record.sh　（-rwxr--r-- or -rwxr-xr-x）
```
- 作業フォルダでヘルプを表示させ、録音する講座の **ID 番号**を確認します。  
```
$ ./nhkradio-russian-record.sh -h
```

### （１）/etc/crontab の編集   
- 曜日は番組表の「CRON曜日」(例：1-5）を参考にして下さい。
- 初級編・応用編のある講座は曜日で振分けられます。

| 指定項目 | 設定値 |
| :---    | :---  |
| 講座ID  | -i 1 |
| 録音時刻 | 30 2（2時30分）|
| 曜日    | 1-5（月〜金）<br>初級編のみ：1-3（月〜水）<br>応用編のみ：4,5（木・金）|

##### 曜日対応表
|日|月|火|水|木|金|土|
| :---: | :---: |:---: |:---: |:---: |:---: |:---: |
|0|1|2|3|4|5|6|

```
# 「まいにちロシア語」（ID-1）の設定例：　
30 2 * * 1-5 username bash /your/directory/nhkradio-russian-record.sh -i 1
　　⇨ /まいにちロシア語/まいにちロシア語:初級編-20260331(火)02:30.m4a として保存されます。

# 保存ディレクトリの指定：　
30 2 * * 1-5 username bash /your/directory/nhkradio-russian-record.sh -i 1 -d nhk
　　⇨ /nhk/まいにちロシア語:初級編-20260331(火)02:30.m4a として保存されます。

# 遅延の設定例：
# 当方の環境では50秒程の遅延が必要でした(NURO光2ギガ:東京都)　
# sleep の表記は「;」に注意して下さい。
30 2 * * 1-5 sleep 50; username bash /your/directory/nhkradio-russian-langs-record.sh -i 1

 【注意】   
  "sleep 50;" の記法で以下のエラーが出て録音に失敗する場合は、オプション -s を使用して下さい。  
    Error: bad username; while reading /etc/crontab
  30 2 * * 1-5 username bash /your/directory/nhkradio-russian-record.sh -i 14 -s 50
```
### （２）CRONの再起動   
```
# /etc/init.d/cron restart  // Debian
 ⇨ Restarting cron (via systemctl): cron.service.

或いは:
# crontab -e  // 編集
# service crond restart
```
### （３）録音開始時間の微調整   
- ライブストリーミングは、インターネット配信を行う過程で放送より遅延が生じます。  
  参照：[らじる★らじる とは？](https://www.nhk.or.jp/radio/info/about.html) 
- 回線状況や配信（放送時刻）とPCの時計の時刻が正確に合致していない場合など、録音開始時間に**誤差**の生じる場合があります。  
- 当方の PC の内蔵時計では日本標準時との誤差は 0.2 秒でしたが、およそ**50秒**の遅延調整が必要でした。  
　　[情報通信研究機構/日本標準時](https://www.nict.go.jp/JST/JST5.html)

**(A)** 開始時刻を遅らせる場合：録音開始時間調整の　**sleep** の値を変更します（初期値：0）。  

　【例】開始時刻を**50秒**遅らせる  
- オプションで指定する場合：-s **50**  
　　……/nhkradio-russian-record.sh ……… **-s 50**  

- 直接スクリプトを書き換える場合：
```
SLPSECONDS=50 # 開始時刻遅延初期値： 秒

或いは、

sleep 50　  
```
- CRON でも時間の**ずれ**を修正することが出来ます。  
　**50** 秒を設定する場合：**sleep 50;**（<strong>；</strong>に注意）  
 ```
// 月〜金曜日 7 時 50 分に起動、50 秒後に開始し 8 分間録音する。　
50 7 * * 1-5 sleep 50; username bash /your/directory/nhkradio-russian-record.sh …………  
```

**(B)** 開始時刻を早める場合（稀なケース）： CRON で行います（CRON の再起動が必要）。  
　例：録音開始時刻を**20秒**早める：開始時刻を**1分**早め（初期値：50 ⇒ 49）開始時刻まで**40秒** sleep させます。
```
sleep 40

# CRON
49 8 * * 1-5 sleep 40; username bash /your/directory/nhkradio-russian-record.sh ………… 
```
### (４) 番組表以外の録音：   
- 番組表以外の番組(AM/FM)の録音が出来ます。
```
# 30分後AM放送を「NHKニュース」として10分間録音し「audio」ディレクトリに保存：　
$ bash ./nhkradio-russian-record.sh -w am -r 00:10:00 -t NHKニュース -d audio -s 30m
　　⇨ /audio/NHKニュース-＜日付＞(＜曜日＞)＜時刻＞.m4a として保存されます。
```

# 実働前テスト  
- 録音時間を**10秒**程度に設定し実動前のテストを行って下さい。  
 　※ シェルは **bash** を使用して下さい。
```
$ bash ./nhkradio-russian-record.sh -i 14 -r 00:00:10
 　⇨ 直下に「まいにちロシア語:＜編＞-＜日付＞(＜曜日＞)＜時刻＞.m4a」が保存されれば正常終了です。
```
# 録音ファイル  

- 録音データファイルは指定の無い場合、スクリプトファイルのあるディレクトリに保存されます。  
- 保存された **m4a** は音声データフォーマットであり、iTunes や通常のプレイヤーで視聴出来ます。 

<!--
## 　Demo
- 以下で公開用テンプレートをご覧頂けます（**/docs** を参照しています) 。
- サンプルのダミーファイル（【初級編】第１課、【応用編】第1課）を試聴出来ます。 
- 操作方法等はアプリの「視聴方法」に詳しく解説しています。
- 2023年度10月からの新シリーズに対応しています。
- **セキュリティ上ダウンロード後でなくてはデータは読み込み出来ません**。   
  
　　[GitHub Pages: nhkradio-langs-record](https://ru-museum.github.io/nhkradio-russian-record/)  
　　[https://ru-museum.github.io/nhkradio-langs-record/](https://ru-museum.github.io/nhkradio-russian-record/)  
-->

# 注意  
- ストリーミング配信URLは変更されています。  
　【東京の場合】  
　　　AM: https://simul.drdi.st.nhk/live/3/joined/master.m3u8  
　　　FM: https://simul.drdi.st.nhk/live/5/joined/master.m3u8  
  　　※ 回線の都合等、他地域からの配信が必要な場合は、以下でURIを取得出来ます。  
    　　　ソース内の**番号部分**を変更して下さい。  
  　　　https://www.nhk.or.jp/radio/config/config_web.xml

- **録音データは著作権上私的利用のみに限定されていますのでご注意下さい。**

