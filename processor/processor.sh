#!/usr/bin/env bash
set -eu

cd /ytdlbot-media
Q_FILE=_queue.txt

OLD_IFS="$IFS"
IFS=$'\n\t'
read -r COLLECTION URL <"$Q_FILE" || URL=""
IFS="$OLD_IFS"
if [ -z "$URL" ]; then
  echo "$(date +%F_%T): $Q_FILE is empty; nothing to do"
  exit 0
fi
echo "$(date +%F_%T): downloading '$URL' to '$COLLECTION' ..."

VIDEO_ID=""
if [[ "$URL" =~ vimeo\.com/([0-9]+) ]]; then
  # Vimeo:
  VIDEO_ID=${BASH_REMATCH[1]}
elif [[ "$URL" =~ [\?\&]v=([_a-zA-Z0-9]+) ]]; then
  # YouTube:
  VIDEO_ID=${BASH_REMATCH[1]}
fi

if [[ -n "$VIDEO_ID" ]]; then
  EXISTS_AT=$(find . -name "*$VIDEO_ID*")
  if [[ -n "$EXISTS_AT" ]]; then
    echo "$(date +%F_%T): '$URL' appears to exist already at '$EXISTS_AT'"
    tail -n +2 "$Q_FILE" >"$Q_FILE.tmp" && mv "$Q_FILE.tmp" "$Q_FILE"
    exit 0
  fi
fi

RESULT_FILE=$(
  /usr/local/bin/yt-dlp \
    --quiet --abort-on-error --no-mtime --restrict-filenames --no-playlist -f mp4 --print after_move:filepath \
    -o "%(uploader)s - %(title)s %(upload_date)s (%(id)s).%(ext)s" \
    "$URL" ||
    (
      echo "$(date +%F_%T) $URL" >>_failures.txt &&
        tail -n +2 "$Q_FILE" >"$Q_FILE.tmp" && mv "$Q_FILE.tmp" "$Q_FILE" &&
        echo "$(date +%F_%T): download of '$URL' failed" &&
        exit 1
    )
)
RESULT_FILE=$(basename "$RESULT_FILE")
RESULT_FILE_NO_UPLOADER=$(echo "$RESULT_FILE" | perl -pe 's|.*? - ||')

UPLOADER_NAME=$(echo "$RESULT_FILE" | awk -F' - ' '{print $1}')
if [ -f /ytdlbot-media/_disambiguations.json ]; then
  if DISAMBIGUATED_UN=$(jq --exit-status ".[\"$UPLOADER_NAME\"]" </ytdlbot-media/_disambiguations.json); then
    UPLOADER_NAME="$DISAMBIGUATED_UN"
  fi
fi
UPLOADER_NAME_LC=$(echo "$UPLOADER_NAME" | tr '[:upper:]' '[:lower:]')

DEST_DIR="/ytdlbot-media/$COLLECTION"
DEST_FILE="$DEST_DIR/$RESULT_FILE"
if [[ "$UPLOADER_NAME_LC" == "unknown" ]]; then
  DEST_FILE="$DEST_DIR/$RESULT_FILE_NO_UPLOADER"
fi

if [[ "$ORGANIZE_BY_UPLOADER" != "false" ]] && [[ "$ORGANIZE_BY_UPLOADER" != "0" ]]; then
  if [[ "$SHARD_BY_UPLOADER" == "false" ]] || [[ "$SHARD_BY_UPLOADER" == "0" ]]; then
    DEST_DIR="/ytdlbot-media/$COLLECTION/$UPLOADER_NAME"
    DEST_FILE="$DEST_DIR/$RESULT_FILE"
  else
    DEST_DIR="/ytdlbot-media/$COLLECTION/$(dirshard -- "$UPLOADER_NAME")/$UPLOADER_NAME"
    DEST_FILE="$DEST_DIR/$RESULT_FILE"

    # prevent accumulating a bunch of files in ytdlbot-media/u/unknown, which woudl defeat the point of sharding:
    if [[ "$UPLOADER_NAME_LC" == "unknown" ]]; then
      DEST_DIR="/ytdlbot-media/$COLLECTION/by-title/$(dirshard -- "$RESULT_FILE_NO_UPLOADER")"
      DEST_FILE="$DEST_DIR/$RESULT_FILE_NO_UPLOADER"
    fi
  fi
fi

mkdir -p "$DEST_DIR"

if [ -e "$DEST_FILE" ]; then
  NEW_SIZE=$(stat -f "%z" ./"$RESULT_FILE")
  EXTANT_SIZE=$(stat -f "%z" "$DEST_FILE")
  if [ "$NEW_SIZE" -gt "$EXTANT_SIZE" ]; then
    echo "$(date +%F_%T): '$DEST_FILE' already exists but new download of '$URL' is larger; replacing preexisting file"
    mv ./"$RESULT_FILE" "$DEST_FILE"
  else
    echo "$(date +%F_%T): '$DEST_FILE' already exists and is larger than new download of '$URL'"
    rm ./"$RESULT_FILE"
  fi
else
  echo "$(date +%F_%T): filing under '$DEST_FILE'"
  mv ./"$RESULT_FILE" "$DEST_FILE"
fi

tail -n +2 "$Q_FILE" >"$Q_FILE.tmp" && mv "$Q_FILE.tmp" "$Q_FILE"
