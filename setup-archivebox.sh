#!/bin/bash
mkdir priv/static/archive

cd priv/static/archive

archivebox init --setup

archivebox config --set \
    USE_COLOR=FALSE \
    SHOW_PROGRESS=FALSE \
    SAVE_WARC=FALSE \
    SAVE_FAVICON=FALSE \
    SAVE_DOM=FALSE \
    SAVE_SINGLEFILE=FALSE \
    SAVE_READABILITY=FALSE \
    SAVE_GIT=FALSE \
    SAVE_MEDIA=FALSE \
    SAVE_ARCHIVE_DOT_ORG=FALSE \
    CHECK_SSL_VALIDITY=FALSE \
    SAVE_MERCURY=FALSE \
    IS_TTY=FALSE