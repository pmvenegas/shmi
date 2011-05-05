#!/bin/sh
#
# shmi - ssh, more info
#
# pvenegas@gmail.com

[ -z $STY ] && { echo "`basename $0` is meant to be used from within screen"; exit 1; }
[ -z $* ] && { echo "Usage: `basename $0` [usual ssh options]"; exit 1; }

OPTS="$*"
DEFSTATUS=`whoami`@`hostname`

# start side-channel
# - add your own calls here, but beware when using backtick evals, as
#   they will be evaluated once, on the first call
ssh $OPTS 'sh -c "echo $$ > .shmi.pid && while true
  do
    {
      echo `whoami`@`hostname` -
      uptime | sed s/.*average://
    } | xargs echo
    sleep 5
  done"' | while read title
do
  printf "\033k%s\033\\" "$title"
  screen -X hstatus "$title"
done &

SCHAN=$!

# start main session
ssh $OPTS

# cleanup side
kill $SCHAN
ssh $OPTS 'sh -c "kill `cat .shmi.pid && rm -f .shmi.pid`"'

# reset this properly as you will
screen -X title "$DEFSTATUS"
screen -X hstatus "$DEFSTATUS"
