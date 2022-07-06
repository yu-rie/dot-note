#!/bin/bash

# workspace 全体を定期的に commit する為のスクリプトです。
# sh .note.sh (GitHub) ("コメント") ※ ()はオプション。

# 退避時のディレクトリ名は .gitignore にも書いています。
# 変更したら .gitignore も確認してください。

# crontab -e にこんな感じで書いて定期的にバックアップしています。
# 0/15 * * * * cd /Users/ユーザ名/workspace && sh .note.sh
# * 1 * * * cd /Users/ユーザ名/workspace && sh .note.sh GitHub

# git 管理用のディレクトリを退避させる時の設定
# gitdtr:	git の保存ディレクトリ名
# retreatdir:	退避時ディレクトリ名
gitdir=".git"
retreatdir=".retreat"
github="FALSE"

# 待ち時間（一応）
waittime=0

# git とか date コマンドを使う設定。
export PATH=$PATH:/usr/local/bin
export LANG=ja_JP.UTF-8
git config --local push.default current

# GitHub オプションがあれば GitHub に保存
if [ -n "$1" ];then
  if [ "$1" = "GitHub" ]; then
    github="TRUE"
    gitcomment="$2"
  else
    gitcomment="$1"
  fi
fi
gitcomment=${gitcomment:+"$gitcomment \n"}


# ディレクトリ名を入れ替える関数です。
dirrename() {
	gitlist=$(find ./* -name "$1" 2> /dev/null)
for el in $gitlist; do
        directry=$(dirname "$el")
	mv "$el"  "$directry/$2"
done
}

# カレントディレクトリより深い所にある .git ディレクトリの名前を変えて退避します。
dirrename $gitdir $retreatdir

# いったんキャッシュを消して .gitignore の変更に対応。
# &> /dev/null は、出力を捨てて非表示にしてるだけ。
git rm -r --cached . &> /dev/null
git add --all

# git status を確認。変更されたファイルがあると gstatus に変更のあったファイル名が入ります。
gstatus=$(git status --porcelain)

# もし変更されたファイルがあれば...
if [ -n "$gstatus" ]
then
  # コミットする時のメッセージ
  timestamp=$(date +"%Y %_m/%_d(%a) %_I:%M %p")
  gitmessage=$(echo "$gitcomment $timestamp > \n$gstatus" | sed 's/^M/💬/g'| sed 's/^A/🐣/g'| sed 's/^D/👻/g'| sed 's/^R/📛/g'| sed 's/^C/🐑/g')

  # コミットする（メッセージ非表示）
  sleep $waittime
  git commit -m "$gitmessage" &> /dev/null
  
  # 手動で動かした時は、git status -porcelain の結果を表示
  echo
  echo "$gitmessage"
  echo

# 変更されたファイルが無かった時。
else

  # 手動で動かした時の表示
  echo
  echo "変更はありませんでした";
  echo
fi

# github に保存するオプションがあれば
if [ $github = "TRUE" ]; then
  # ツリーをキレイにする（非表示)
  sleep $waittime
  git pull --rebase &> /dev/null

  # GitHub とかにプッシュしてバックアップ（非表示）
  sleep $waittime
  git push &> /dev/null
fi

# 退避させておいた .git/ のディレクトリ名を戻す
dirrename $retreatdir $gitdir

