#!/bin/bash

# --- CONFIGURATION ---
LAST_UPDATE_FILE="/tmp/last_arch_update_check"
TODAY=$(date +%Y-%m-%d)
NOTIF_ID=1001
SCREEN_NAME="arch_update"

send_notif() { notify-send -r "$NOTIF_ID" -a "System" "$@"; }

# Cleanup on startup
screen -wipe > /dev/null 2>&1
rm -f /tmp/screen_out

send_notif -t 3000 "System Startup" "Update notifier is active."

while true; do
    until wget -q --spider [http://google.com](http://google.com); do sleep 5; done

    updates_raw=$(checkupdates 2>/dev/null)
    updates_count=$(echo "$updates_raw" | grep -v '^$' | wc -l)

    if [ "$updates_count" -eq 0 ]; then
        res=$(send_notif -t 5000 --action="t=View Terminal" --action="d=Dismiss" "No Updates Found" "Your system is up to date.")
        case "$res" in
            "t") kitty --title "Check" sh -c "sudo pacman -Sy > /dev/null && echo 'Clean.'; read" ;;
            *) send_notif -t 3000 "Finished" "System check done." ;;
        esac
        echo "$TODAY" > "$LAST_UPDATE_FILE"
    else
        package_preview=$(echo "$updates_raw" | awk '{print $1}' | head -n 5 | tr '\n' ', ' | sed 's/, $//')...
        current_step="MAIN_MENU"
        while [ "$current_step" != "FINISHED" ]; do
            if [ "$current_step" == "MAIN_MENU" ]; then
                res=$(send_notif -u critical --action="y=Start Update" --action="t=View List" --action="d=Dismiss" "Updates: $updates_count" "$package_preview")
                case "$res" in
                    "y") 
                        screen -S "$SCREEN_NAME" -X quit > /dev/null 2>&1
                        screen -S "$SCREEN_NAME" -d -m sh -c "sudo pacman -Syu --needed && echo $TODAY > $LAST_UPDATE_FILE"
                        sleep 1
                        kitty --title "ArchUpdateAuth" sh -c "screen -r $SCREEN_NAME || screen -x $SCREEN_NAME"
                        current_step="INSTALL_CHECK" ;;
                    "t") kitty --title "List" sh -c "checkupdates; read" ;;
                    "d") send_notif -t 3000 "Postponed" "Check again later."; break 2 ;; 
                esac
            elif [ "$current_step" == "INSTALL_CHECK" ]; then
                if screen -list | grep -q "$SCREEN_NAME"; then
                    screen -S "$SCREEN_NAME" -X hardcopy /tmp/screen_out
                    if grep -q "\[Y/n\]" /tmp/screen_out; then
                        status=$(send_notif -u critical --action="t=Open Terminal" "ACTION REQUIRED!" "Waiting for Y/n...")
                    else
                        status=$(send_notif -t 2000 --action="t=Open Terminal" "Update in Progress" "Installing...")
                    fi
                    [[ "$status" == "t" ]] && kitty --title "ArchUpdate" sh -c "screen -r $SCREEN_NAME"
                else
                    if [[ -f "$LAST_UPDATE_FILE" ]] && [[ "$(cat $LAST_UPDATE_FILE)" == "$TODAY" ]]; then
                        send_notif -t 5000 "Update Complete" "Success!"
                        current_step="FINISHED"
                    else
                        current_step="MAIN_MENU"
                    fi
                fi
            fi
            sleep 2
        done
    fi

    # Sleep 3 hours OR wait for SUPER+U signal (SIGUSR1)
    trap "echo 'Forced check...'" SIGUSR1
    sleep 10800 & 
    wait $!
done
