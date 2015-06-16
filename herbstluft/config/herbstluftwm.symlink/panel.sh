#!/bin/bash

hc() { "${herbstclient_command[@]:-herbstclient}" "$@" ;}
monitor=${1:-0}
geometry=( $(herbstclient monitor_rect "$monitor") )
if [ -z "$geometry" ] ;then
    echo "Invalid monitor $monitor"
    exit 1
fi
# geometry has the format W H X Y
x=${geometry[0]}
y=${geometry[1]}
panel_width=${geometry[2]}
panel_height=16

font="-*-fixed-medium-*-*-*-12-*-*-*-*-*-*-*"
bgcolor=$(hc get frame_border_normal_color)
selbg=$(hc get window_border_active_color)
selfg='#101010'

FG='white'
BG='black'

textwidth="dzen2-textwidth";
function uniq_linebuffered() {
  awk -W interactive '$0 != l { print ; l=$0 ; fflush(); }' "$@"
}

hc pad $monitor $panel_height

{
    ### Event generator ###
    # based on different input data (mpc, date, hlwm hooks, ...) this generates events, formed like this:
    #   <eventname>\t<data> [...]
    # e.g.
    #   date    ^fg(#efefef)18:33^fg(#909090), 2013-10-^fg(#efefef)29

    # while true ; do
    #   # "date" output is checked once a second, but an event is only
    #   # generated if the output changed compared to the previous run.
    #   date +$'date\t^fg(#efefef)%H:%M^fg(#909090), %Y-%m-^fg(#efefef)%d'
    #   sleep 1 || break
    # done > >(uniq_linebuffered) &
    # datepid=$!

    conky -c conkyrc | while read -r; do
       echo -e "conky\t$REPLY"
    done &
    conkypid=$!

    hc --idle

    kill $conkypid
} 2> /dev/null | {
    IFS=$'\t' read -ra tags <<< "$(hc tag_status $monitor)"
    visible=true
    conky=""
    windowtitle=""
    while true ; do

        ### Output ###
        # This part prints dzen data based on the _previous_ data handling run,
        # and then waits for the next event to happen.

        bordercolor="#26221C"
        separator="^bg()^fg($selbg)|"
        # draw tags
        for i in "${tags[@]}" ; do
            case ${i:0:1} in
                '#')
                    echo -n "^bg($selbg)^fg($selfg)"
                    ;;
                '+')
                    echo -n "^bg(#9CA668)^fg(#141414)"
                    ;;
                ':')
                    echo -n "^bg()^fg(#ffffff)"
                    ;;
                '!')
                    echo -n "^bg(#FF0675)^fg(#141414)"
                    ;;
                *)
                    echo -n "^bg()^fg(#ababab)"
                    ;;
            esac
            # clickable tags
            echo -n "^ca(1,\"${herbstclient_command[@]:-herbstclient}\" "
            echo -n "focus_monitor \"$monitor\" && "
            echo -n "\"${herbstclient_command[@]:-herbstclient}\" "
            echo -n "use \"${i:1}\") ${i:1} ^ca()"
        done
        echo -n "$separator"
        echo -n "^bg()^fg() ${windowtitle//^/^^}"
        # small adjustments
        right="^bg() ^fg() $conky"
        # right_text_only=$(echo -n "$right" | sed 's.\^[^(]*([^)]*)..g')
        # get width of right aligned text.. and add some space..
        width=$($textwidth "$font" "$right")
        echo -n "^pa($(($panel_width - $width)))$right"
        echo

        ### Data handling ###
        # This part handles the events generated in the event loop, and sets
        # internal variables based on them. The event and its arguments are
        # read into the array cmd, then action is taken depending on the event
        # name.
        # "Special" events (quit_panel/togglehidepanel/reload) are also handled
        # here.

        # wait for next event
        IFS=$'\t' read -ra cmd || break
        # find out event origin
        case "${cmd[0]}" in
            tag*)
                #echo "resetting tags" >&2
                IFS=$'\t' read -ra tags <<< "$(hc tag_status $monitor)"
                ;;
            quit_panel)
                exit
                ;;
            togglehidepanel)
                currentmonidx=$(hc list_monitors | sed -n '/\[FOCUS\]$/s/:.*//p')
                if [ "${cmd[1]}" -ne "$monitor" ] ; then
                    continue
                fi
                if [ "${cmd[1]}" = "current" ] && [ "$currentmonidx" -ne "$monitor" ] ; then
                    continue
                fi
                echo "^togglehide()"
                if $visible ; then
                    visible=false
                    hc pad $monitor 0
                else
                    visible=true
                    hc pad $monitor $panel_height
                fi
                ;;
            reload)
                exit
                ;;
            focus_changed|window_title_changed)
                windowtitle="${cmd[@]:2}"
                ;;
            date)
                date="${cmd[@]:1}"
                ;;
            conky)
                conky="${cmd[@]:1}"
                ;;
        esac
    done

    ### dzen2 ###
    # After the data is gathered and processed, the output of the previous block
    # gets piped to dzen2.

} 2> /dev/null | dzen2 -w $panel_width -x $x -y $y -fn "$font" -h $panel_height \
    -e 'button3=' \
    -ta l -bg "$bgcolor" -fg '#efefef'
