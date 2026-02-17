
#!/bin/bash

TITLE="NHKまいにちロシア語"

# 東京 NHK第二放送
# 放送波URL: 以下で取得出来ます（2021）。 
# https://www.nhk.or.jp/radio/config/config_web.xml

# ストリーミング配信 URL
# 2026年2月現在 URL は変更されています。
# M3U8URL="https://radio-stream.nhk.jp/hls/live/2023501/nhkradiruakr2/master.m3u8"
M3U8URL="https://simul.drdi.st.nhk/live/5/joined/master.m3u8"

# 曜日設定
arr=("日" "月" "火" "水" "木" "金" "土")
DAY=`date '+%w'`
_DAY="(${arr[$DAY]})"
YEAR=`date '+%Y'`
DATE1=`date '+%m%d'`
DATE2=`date '+%H:%M'`
DATE="${YEAR}${DATE1}${_DAY}-${DATE2}"

# 録音時間設定 ： 15分
REC_TIME="00:15:00" 

# 録音開始時間調整： 秒
sleep 0

# 録音データ保存フォルダ名：絶対PATHを指定
MY_OUTDIR="/your/directory/name/NHKロシア語講座"

# 録音講座の振り分け：【初級編】【応用編】（番組表参照）
COURSE=""
if [ "$DAY" -eq 4 -o "$DAY" -eq 5 ]; then
  COURSE="【応用編】"
else
  COURSE="【初級編】"
fi

# 録音 ⇒ 保存処理 ⇒ ファイル名: NHKまいにちロシア語【初級編】-20210913(月)-08:50.m4a
# M4A: 音声ファイルのみのフォーマットで iTunes などで再生出来ます。
ffmpeg -i "${M3U8URL}" -t "${REC_TIME}" -c copy "${MY_OUTDIR}/${TITLE}${COURSE}-${DATE}".m4a

exit
