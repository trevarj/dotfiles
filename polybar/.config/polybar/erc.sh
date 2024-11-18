#!/bin/sh

FIFO=/tmp/erc-track.fifo
if [ ! -p $FIFO ]; then
  mkfifo $FIFO
fi
tail -F $FIFO 2>/dev/null
