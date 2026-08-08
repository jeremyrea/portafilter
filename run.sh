#!/bin/sh
set -eu

## TODO
# check if fetchmailrc was provided and use that
# if not, write default template with env variables and ${VARIABLE:-default} default values

RUNTIME_DIR="/tmp/portafilter"
RC_FILE="${RUNTIME_DIR}/.fetchmailrc"
OUTPUT_DIR="/output"

mkdir -p "$RUNTIME_DIR"

cat >${RC_FILE} <<EOL
set daemon 300
set no bouncemail

poll ${IMAP_SERVER} protocol IMAP
    service 993
    user ${IMAP_USERNAME}, with password ${IMAP_PASSWORD}, is portafilter here
    ssl
    idle
    nokeep
    folder ${LISTEN_FOLDER}
    mda "ripmime -i - -d ${OUTPUT_DIR} --no-nameless --postfix -q || true"
EOL

chmod 600 "$RC_FILE"

exec fetchmail -f "$RC_FILE" --nodetach --nosyslog -v
