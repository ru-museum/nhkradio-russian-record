#!/bin/bash

# --------------------------------------------------
#
# NHKラジオ放送番組録音（AM/FM）
#      ロシア語講座版  2026/04/09 
#
# --------------------------------------------------
#【注記】
# 現行のラジオ3波（第1、第2、FM）は、2026年度の番組改定(3月30日)と共に、
# 「NHK AM」と「NHK FM」の2波に再編され、従来の「第2」は大体が「FM」へ
# と移行しています。
# 
# ストリーミング配信URI（東京）
#  AM: https://simul.drdi.st.nhk/live/3/joined/master.m3u8
#  FM: https://simul.drdi.st.nhk/live/5/joined/master.m3u8
# 回線状況等の理由で東京以外の放送波のURLが必要な場合は以下を参照して下さい。
#  https://www.nhk.or.jp/radio/config/config_web.xml
#  => /live/* 各地域での番号が異なります

# エラーハンドリング
set -Ceuo pipefail

# 曜日設定 
getDateTime() {
  arr=("日" "月" "火" "水" "木" "金" "土")
  DAY=`date '+%w'`
  _DAY="(${arr[$DAY]})"
  YEAR=`date '+%Y'`
  DATE1=`date '+%m%d'`
  DATE2=`date '+%H:%M'`
  echo "${YEAR}${DATE1}${_DAY}${DATE2}"
}

# 初級編・応用編のある語学
# 月火水木金土日 = 1234567
setEdition(){
  local ed=""
  local d=`date '+%w'`

  # 月火水: 123 => 初級編
  if test $d -gt 0 -a $d -lt 4 ; then
     ed=":初級編"
  # 木金: 45 => 応用編
  elif test $d -eq 4 -o $d -eq 5 ; then
     ed=":応用編"
  fi

  echo $ed
}

# ポルトガル語講座別処理：入門, ステップアップ
setPortuguese(){
  local ed=""
  local d=`date '+%-m'`
  #  "ポルトガル語入門" 4月 - 9月
  if [[ "${d}" -gt 3 ]] || [[ "${d}" -lt 10 ]]; then 
    ed="入門"
  fi
  #  "ポルトガル語ステップアップ" 10月 - 3月
  if [[ "${d}" -lt 4 ]] || [[ "${d}" -gt 9 ]]; then 
    ed="ステップアップ"
  fi
  echo $ed
}

# HELP「番組表」用データ配列：
# ・データは自由に追加・削除出来ます。
# ・右端縦罫線の表示は配列要素(,)の追加で調整
# ・中央揃えは空白の追加で調整
# ・「半角空白」は column のトークンとなっている為に使用不可 => 「全角空白」
# ・編別の表記：「,,」(null値)は不可 => 「,-,」
# ・録音時間は2桁ゼロパディング（例： 05）表記
PROGRAMS=(
  "ID,　　　　　　　　講座名,放送波,放送日,編別,放送時刻,時間,CRON曜日,"
  "--,---------------------------------------,------,------,-----,--------,----,--------,"
  "　,語学,　,　,　,　,　,　,"
  "--,---------------------------------------,------,------,-----,--------,----,--------,"
  "1,まいにちロシア語,FM,月〜金,初/応,2:30,15,1-5,"
  "2,まいにちイタリア語,FM,月〜金,初/応,2:15,15,1-5,"
  "3,まいにちスペイン語,FM,月〜金,初/応,1:45,15,1-5,"
  "4,まいにち中国語,FM,月〜金,-,1:15,15,1-5,"
  "5,まいにちドイツ語,FM,月〜金,初/応,1:30,15,1-5,"
  "6,まいにちハングル講座,FM,月〜金,-,1:00,15,1-5,"
  "7,まいにちフランス語,FM,月〜金,初/応,2:00,15,1-5,"
  "8,ポルトガル語,FM,日,-,1:00,15,0,"
  "9,英会話タイムトライアル,FM,月〜金,-,23:50,10,1-5,"
  "10,エンジョイ・シンプル・イングリッシュ,FM,月〜金,-,6:00,05,1-5,"
  "12,小学生の基礎英語,FM,月〜金,-,6:05,10,1-5,"
  "13,基礎英語-レベル1,FM,月〜金,-,6:15,15,1-5,"
  "14,基礎英語-レベル2,FM,月〜金,-,6:30,15,1-5,"
  "15,ニュースで学ぶ「現代英語」,FM,月〜金,-,23:35,15,1-5,"
  "16,ラジオ英会話,FM,月〜金,-,6:45,15,1-5,"
  "17,ラジオビジネス英語,FM,月〜金,-,23:20,15,1-5,"
)

# 番組リスト(番組表)表示：column 6,7 は非表示
function dsp_list {
   echo " ● NHKラジオ番組表（2026/3/30 改定）"
   echo "   ※ 録音する番組の「ID番号」を指定します(例：-i 2)。"
   echo " ---------------------------------------------------------------------------------------"
   printf " |%s\t \n" "${PROGRAMS[@]}" | column -t -s ',' -o '|'
   echo " ---------------------------------------------------------------------------------------"
   echo " ※ 番組表は、NHKの番組改定・再編により随時変更されます。"
   echo " ※ 番組表は、自由に追加変更可能です。"
   echo " ※ ID指定の場合、録音ファイルは「番組タイトル名」のディレクトリに保存されます。"
   echo " ※ 「CRON曜日」設定での定時録音の方法については README.md を参照して下さい。"
   echo "  "
  exit 3
}

# --------------------------------------------------
# 無効オプションERROR表示
function usage(){
  cat <<EOM

  USAGE: \$ bash $0 -i [number] -w [am|fm] -r [00:00:00] -t [title] -d [directory] -s [00(秒)|00h00m00s]

  （A）CRON による定時録音：
      ※ ID 指定により番組を定時録音します。
      ※ 保存ディレクトリは -d オプションで指定出来ます（通常「番組名」ディレクトリ）。
      ※ CRON 設定の詳細は README.md を参照して下さい。
      ※ CRON 設定には「CRON曜日」を参考にして下さい。

  （B）講座 ID 指定による録音：
      ※ 「まいにちロシア語」以外の語学講座も録音可能です。
      ※ ID による番組を「個別」に予約録音します。
      ※ 録音時間は「番組表」の「時間」データに準じます（指定する場合：-r [00:00:00]）。
      ※ 保存ディレクトリは -d オプションで指定出来ます（通常「番組名」ディレクトリ）。
      ※ -s オプション(予約時間)例：-s 1h20m30s （h-m-s の間にスペースは挟みません）。
     【例】10分後に番組 ID-1(まいにちロシア語)を録音開始し「番組名」ディレクトリへ保存：
         \$ bash $0 -i 1 -s 10m
            => /まいにちロシア語/まいにちロシア語-20260405(日)06:54.m4a
        「audio」ディレクトリへ保存：
         \$ bash $0 -i 1 -s 10m -d audio 
            => /audio/まいにちロシア語-20260405(日)06:54.m4a

  （C）通常録音：
      ※ 番組表掲載の語学講座以外の通常番組も録音可能です。
      ※ タイトル指定（-t）の無い場合は、ファイルタイトル名は「NHKラジオ放送番組」となります。
      ※ -d オプション指定の無い場合は、スクリプト直下に保存されます。
     【例】AM放送を30秒後に15分間録音しタイトルを「NHKニュース」とし「audio」ディレクトリへ保存：
         \$ bash $0 -w am -r 00:15:00 -t NHKニュース -d audio -s 30
            => /audio/NHKニュース-20260405(日)06:34.m4a

EOM
}

# --------------------------------------------------
# HELPの表示 
function dspHelp {
# オプション
usage 
  cat <<EOM

  -------------------------------------------------------------------------------------------------
  -h           ヘルプ（この画面）を表示します。

  -i [VALUE]   番組表から録音する番組のID番号を指定します。
               【例】-i 3      (基礎英語 レベル1)
                ※ このオプションを指定すると全てが優先されます。

  -w [VALUE]   録音するNHKラジオ放送のチャンネル(放送波)を指定します。
               [設定値]  NHK-AM：am
                         NHK-FM：fm (default)
               【例】-w am
                ※ デフォルト(未入力)は fm（NHK-FM）が設定されます。

  -d [VALUE]   録音データファイルの保存ディレクトリ名を指定します。
               【例】-d NHK番組
                ※ 指定の無い場合は、現ディレクトリへ保存されます。
                ※ ID指定の場合は、番組名のディレクトリへ保存されます。

  -r [VALUE]   録音する時間を指定します。
               【例】-r 00:30:00   （30分）
                ※ デフォルト(未入力)は15分

  -t [VALUE]   録音する番組タイトル名。
               【例】-t NHKきょうのニュース
                ※ 指定の無い場合は「NHK放送番組」が設定されます。

  -s [VALUE]   開始時刻を遅延させます（予約録音として機能します）。
               【例】-s 60s(or 60)：60秒後に録音開始
                     -s 5m30s     ：5分30秒後に録音開始
                     -s 1h10m30s  ：1時間10分30秒後に録音開始
                ※ オプションで指定する場合、"h" と "m" の後には[スペース]を挿みません。
                ※ スクリプトで直接指定する場合は、"sleep 1h 10m 30s" と[スペース]を入れて記述します。

EOM
   dsp_list # 番組リスト表示
   exit 2
}

# 変数初期値 -------------------------------------
PROGRAMID=""  # -i: 指定講座 ID の OPTION 入力値
PROGRNAME="NHKラジオ放送番組" # 番組名(default)
_PROGRNAME="" # -t: 番組名(個別に番組を録音する時)
DIRNAME=""    # -d: 保存ディレクトリ名指定
RECTIMES="00:15:00" # 録音時間(default)
_RECTIMES=""  # -r: 録音時間(buff)
SLPSECONDS=0  # -s: 開始時刻遅延の OPTION 入力値
WAVE=""       # -w: 放送波の指定：AM / FM(default)
WAVENUM="5"   # 放送波設定値：AM: 3 FM: 5(default)
SCRIPT_DIR="" # 保存ディレクトリPATH
EDITION=""    # 初級編・応用編：番組ファイル名に付加
# ----------------------------------------------

# オプション指定コマンド
while getopts ":i:d:r:t:s:w:h" optKey; do
  case "$optKey" in
    i)
      PROGRAMID="${OPTARG}"  # 番組指定 ID 入力値
      ;;
    d)
      DIRNAME="${OPTARG}"    # 保存ディレクトリ(USER)
      ;;
    r)
      _RECTIMES="${OPTARG}"  # 録音時間(USER)
      ;;
    t)
      _PROGRNAME="${OPTARG}" # 番組タイトル(USER)
      ;;
    s)
      # 開始時刻遅延入力値(USER)の書式変換： 0h0m0s => 0h 0m 0s
      s=" " # space      
      str=${OPTARG};str=${str/h/h$s};str=${str/m/m$s}
      SLPSECONDS="${str}"
      ;;
    w)
      WAVE="${OPTARG}"        # 放送波指定：AM/FM(USER)
      ;;
    h)
      dspHelp
      exit 0
      ;;
    \?)
      echo "ERROR: 不正なオプション指定です -$OPTARG"
      usage
      exit 1
      ;;
    :)
      echo "ERROR: オプション -$OPTARG には引数が必要です[ヘルプ参照 -h]。"
      usage
      exit 1
      ;;
  esac
done

# <ID> 指定の場合(-i) 
# データ例："14,まいにちロシア語,FM,月〜金,初/応,2:30,15,1-5,"
if [[ "${PROGRAMID}" != "" ]]; then

    # CSVデータを配列に格納
    for prog in ${PROGRAMS[@]}; do
        a=(${prog//,/ })

        # IDの指示する配列行
        if [[ "${a[0]}" = $PROGRAMID ]]; then

              # 番組名を設定 
              PROGRNAME="${a[1]}"

              # 放送波の選択：AM/FM
              if   [[ "${a[2]}" = "FM" ]]; then 
                    WAVE="fm"
                    WAVENUM="5"
              elif [[ "${a[2]}" = "AM" ]]; then 
                    WAVE="am"
                    WAVENUM="3"
              fi

              # + 初級編・応用編別処理 => ファイル名へ付加  
              # まいにちイタリア語, まいにちスペイン語, まいにちドイツ語,
              # まいにちフランス語, まいにちロシア語
              if [[ "${a[4]}" = "初/応" ]]; then 
                  EDITION=`setEdition`
              fi

              # ポルトガル語講座別処理：入門, ステップアップ
              if [[ "${a[0]}" = "15" ]]; then 
                 EDITION=`setPortuguese`
              fi

              # 録音時間の設定：-r での指定の場合は置換する
              RECTIMES="00:${a[6]}:00"
        fi
    done

# <ID> 指定の無い場合
elif [[ "${PROGRAMID}" = "" ]]; then
  # 放送波の選択(-w)：AM/FM
  if   [[ "${WAVE}" = "fm" ]]; then WAVENUM="5"
  elif [[ "${WAVE}" = "am" ]]; then WAVENUM="3"
  fi
else
  echo "ERROR：何らかのエラーが発生しました"
  exit 1
fi

# USERオプション指定
# -r: 録音時間の指定の場合は置換
# 録音時間設定： 時：分：秒 
# 秒で設定する場合： "900"（15分 x 60秒） 
# REC_TIME="00:15:00"(default) 
if [[ "${_RECTIMES}" != "" ]]; then
  RECTIMES="${_RECTIMES}"
fi
# -t 指定がされた場合 => 番組名を置換
if [[ "${_PROGRNAME}" != "" ]];then
  PROGRNAME=$_PROGRNAME
fi

# ストリーミング配信 URI
M3U8URL="https://simul.drdi.st.nhk/live/$WAVENUM/joined/master.m3u8"

# 作業ディレクトリ PATH
_SCRIPT_DIR=$(cd $(dirname $0) && pwd)

# 保存ディレクトリが無ければ作成。
function makeDirctory(){
  if [[ ! -e $1 ]]; then
      mkdir $1
      echo "directory made:$1" 1>&2
  elif [[ ! -d $1 ]]; then
      echo "$1 already exists but is not a directory" 1>&2
  fi
}

# 
# SCRIPT_DIR のオプション有無
# ID指定
if [[ "${PROGRAMID}" != "" ]];then
  SCRIPT_DIR="$_SCRIPT_DIR/$PROGRNAME"

  # -d dir_name
  if [[ "${DIRNAME}" != "" ]]; then
    SCRIPT_DIR="$_SCRIPT_DIR/$DIRNAME"
  fi

# ID無指定 -d dir_name
elif [[ "${DIRNAME}" != "" ]]; then
  SCRIPT_DIR="$_SCRIPT_DIR/$DIRNAME"
fi

# 開始時刻を遅延させる： 秒
# sleep 1h 5m 50s （時間：分：秒）
# -s 1h5m50s で変更可能: オプションの場合は「スペース」を挿入しない
sleep $SLPSECONDS

DATE="$(getDateTime)" # `getDateTime`
slash="/"  # 保存ディレクトリ接続区切り
type="m4a" # 音源ファイルタイプ 

# $SCRIPT_DIR != ""  => 保存ディレクトリ作成
if [ -n "$SCRIPT_DIR" ]; then # 文字列の長さが0より大きければ真
  makeDirctory $SCRIPT_DIR # 保存ディレクトリ作成
  echo "保存ディレクトリ: ${SCRIPT_DIR} が作成されました"
else
  slash=""
fi

# 保存ディレクトリPATH + ファイル名
SAVEFILE_NAME="${SCRIPT_DIR}${slash}${PROGRNAME}${EDITION}-${DATE}.${type}"

# 録音しファイルを保存
if [[ "${SAVEFILE_NAME}" ]];then
  # 開始時刻を遅延させる： 秒
  # sleep 1h 5m 50s （時間：分：秒）
  # -s 1h5m50s で変更可能: オプションの場合は「スペース」を挿入しない
  sleep $SLPSECONDS

  echo ""
  echo "録音を開始しました......"
  ffmpeg -i "${M3U8URL}" -t "${RECTIMES}" -c copy "${SAVEFILE_NAME}"
  echo "録音を終了しました。"
  echo ""
else
  echo "ERROR：何らかのエラーが発生しました"
  exit 1
fi

exit 0
