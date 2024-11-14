#!/bin/bash
DATE="$(date '+%Y-%m-%d %H:%M:%S %z')"
TITLE="$@"
cd $(dirname $(realpath $0))

if [ ! -d _drafts ]
then
  mkdir _drafts
fi

cat <<EOF >_drafts/$(date '+%Y-%m-%d')-$(echo "$TITLE" | awk '{print tolower($0)}' | sed 's/ /-/g').markdown
---
date: $DATE
title: $TITLE
author: Don Grote
layout: post
---

EOF
