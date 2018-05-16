#!/bin/sh

# v20160907 - modified original script for schema changes in dCache >2.15
#             thomas.hartmann@desy.de, lusine.yakovleva@desy.de

set -e 

PORT=5432
DATABASE="chimera"

usage() {
    echo "Usage: $0 [-h HOSTNAME] [-p PORT] [-d DBNAME] [-U USERNAME] [-D DATE] [-l LIMIT] [-s] FILENAME [ROOT [PREFIX]]"
    echo
    echo "Options:"
    echo "  -h Specifies the host name of the machine on which postgresql is running. Defaults"
    echo "     to connecting over a Unix-domain socket."
    echo "  -p Specifies the TCP port on which the postgresql server is listening for connections."
    echo "     Only used with -h. Defaults to 5432."
    echo "  -d Specifies the name of the database to connect to. Defaults to chimera."
    echo "  -U Connect to the database as the user username instead of the default."
    echo "  -D Specifies a cutoff date. Files created after this date are not included."
    echo "     Relative dates are allowed. Default is '1 day ago'."
    echo "  -l Specifies a limit on how many files to include. Mainly useful for testing."
    echo "  -s Include the size of each file in the dump."
    echo
    echo "FILENAME is the output file name. User - to output to STDOUT. ROOT is the root of the"
    echo "directory tree to dump. ROOT defaults to /. PREFIX is a path PREFIX to place in front"
    echo "of paths after ROOT has been striped off. Defaults to the value of ROOT."
    echo 
    echo "Output is sorted unless a limit has been specified."
    exit 1
}

EXTRA_COLS=""

while getopts h:p:d:U:D:l:s f; do
  case "$f" in
  h) HOST="$OPTARG";;
  p) PORT="$OPTARG";;
  d) DATABASE="$OPTARG";;
  U) USERNAME="$OPTARG";;
  D) DATE="$OPTARG";;
  l) LIMIT="$OPTARG";;
  s) EXTRA_COLS="${EXTRA_COLS}, i.isize";;
  \?) usage;;
  esac
done

DATE="${DATE:-1 day ago}"
DATE="$(date --date="${DATE}" --iso-8601=seconds)"

shift `expr $OPTIND - 1`

if [ $# -eq 0 -o $# -gt 3 ]; then
  usage
fi

OUTPUT="$1"
ROOT="${2%/}"
PREFIX="${3:-$ROOT}"

if [ "$OUTPUT" = "-" ]; then
  OUTPUT=""
fi

# if [ -z "$ROOT" ]; then
#   START="('000000000000000000000000000000000000', '${PREFIX%/}')"
# else
#   START="(path2inode('000000000000000000000000000000000000', '${ROOT#/}'), '${PREFIX%/}')"
# fi

echo "psql ${HOST:+-h $HOST} ${PORT:+-p $PORT} -t -A $DATABASE $USERNAME" >> ./chimera_find.log

ROOTINUMBER=$(psql ${HOST:+-h $HOST} ${PORT:+-p $PORT} -t -A $DATABASE $USERNAME <<EOF
SELECT iparent FROM t_dirs WHERE iname = 'pnfs';
EOF
)

if [ -z "$ROOT" ]; then
  START="(${ROOTINUMBER}, '${PREFIX%/}')"
else
  START="(path2inumber(${ROOTINUMBER}, '${ROOT#/}'), '${PREFIX%/}')"
fi


if [ -z "$LIMIT" ]; then
  ORDER="path"
fi

psql ${HOST:+-h $HOST} ${PORT:+-p $PORT} ${OUTPUT:+-o "$OUTPUT"} -t -A -f - $DATABASE $USERNAME <<EOF
WITH RECURSIVE paths(inumber, path) AS (
     VALUES $START
   UNION
     SELECT d.ichild, p.path||'/'||d.iname
     FROM t_dirs d, paths p
     WHERE p.inumber = d.iparent AND d.iname != '.' AND d.iname != '..' 
)
SELECT p.path${EXTRA_COLS} FROM t_inodes i, paths p
WHERE i.inumber = p.inumber ${DATE:+AND i.icrtime <= '$DATE'} AND i.itype = 32768 ${ORDER:+ORDER BY $ORDER} ${LIMIT:+LIMIT ${LIMIT}};
EOF

# psql ${HOST:+-h $HOST} ${PORT:+-p $PORT} ${OUTPUT:+-o "$OUTPUT"} -t -A -f - $DATABASE $USERNAME <<EOF
# WITH RECURSIVE paths(pnfsid, path) AS (
#      VALUES $START
#    UNION
#      SELECT d.ipnfsid, p.path||'/'||d.iname
#      FROM t_dirs d, paths p
#      WHERE p.pnfsid = d.iparent AND d.iname != '.' AND d.iname != '..' 
# )
# SELECT p.path${EXTRA_COLS} FROM t_inodes i, paths p
# WHERE i.ipnfsid = p.pnfsid ${DATE:+AND i.icrtime <= '$DATE'} AND i.itype = 32768 ${ORDER:+ORDER BY $ORDER} ${LIMIT:+LIMIT ${LIMIT}};
# EOF



