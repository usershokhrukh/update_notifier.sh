#!/bin/bash

# --- CONFIGURATION ---
LAST_UPDATE_FILE="/tmp/last_arch_update_check"
TODAY=$(date +%Y-%m-%d)
NOTIF_ID=1001  # Barcha xabarlar shu ID bilan bir-birini almashtiradi
SCREEN_NAME="arch_update"

# Xabarni yuborish funksiyasi (vaqtinchalik xabarlar uchun 0 - o'chmaydi)
send_notif() { notify-send -r "$NOTIF_ID" -a "System" "$@"; }

# Cleanup on startup
screen -wipe > /dev/null 2>&1
rm -f /tmp/screen_out
last_status=""

send_notif -t 3000 "System Startup" "Update notifier is active."

while true; do
    until wget -q --spider http://google.com; do sleep 5; done

    updates_raw=$(checkupdates 2>/dev/null)
    updates_count=$(echo "$updates_raw" | grep -v '^$' | wc -l)

    if [ "$updates_count" -eq 0 ]; then
        if [ "$last_status" != "UP_TO_DATE" ]; then
            send_notif -t 5000 "No Updates Found" "Your system is up to date."
            last_status="UP_TO_DATE"
        fi
        echo "$TODAY" > "$LAST_UPDATE_FILE"
    else
        package_preview=$(echo "$updates_raw" | awk '{print $1}' | head -n 5 | tr '\n' ', ' | sed 's/, $//')...
        current_step="MAIN_MENU"

        while [ "$current_step" != "FINISHED" ]; do
            if [ "$current_step" == "MAIN_MENU" ]; then
                res=$(send_notif -u critical --action="y=Start Update" --action="t=View List" --action="d=Dismiss" "Updates Available: $updates_count" "$package_preview")
                case "$res" in
                    "y") 
                        screen -S "$SCREEN_NAME" -X quit > /dev/null 2>&1
                        screen -S "$SCREEN_NAME" -d -m sh -c "sudo pacman -Syu --needed && echo $TODAY > $LAST_UPDATE_FILE"
                        sleep 1
                        kitty --title "ArchUpdateAuth" sh -c "screen -r $SCREEN_NAME"
                        current_step="INSTALL_CHECK"
                        last_status="STARTING" ;;
                    "t") kitty --title "List" sh -c "checkupdates; read" ;;
                    "d") send_notif -t 3000 "Postponed" "Check again later."; break 2 ;; 
                esac

            elif [ "$current_step" == "INSTALL_CHECK" ]; then
                if screen -list | grep -q "$SCREEN_NAME"; then
                    screen -S "$SCREEN_NAME" -X hardcopy /tmp/screen_out
                    
                    # 1. Agar Y/n kiritish kerak bo'lsa
                    if grep -q "\[Y/n\]" /tmp/screen_out; then
                        if [ "$last_status" != "WAITING_Y" ]; then
                            # -t 0 qilingan, foydalanuvchi bosmaguncha o'chmaydi
                            res=$(send_notif -u critical -t 0 --action="t=Open Terminal" --action="d=Dismiss" "ACTION REQUIRED!" "Terminal is waiting for Y/n input...")
                            last_status="WAITING_Y"
                        fi
                    # 2. Agar yuklash yoki o'rnatish ketayotgan bo'lsa
                    elif grep -q -E "downloading|installing|checking|upgrading|%|Total" /tmp/screen_out; then
                        if [ "$last_status" != "INSTALLING" ]; then
                            # Jarayon tugaguncha turadi, yangi xaba kelsa o'chadi
                            res=$(send_notif -u normal -t 0 --action="t=View Progress" --action="d=Dismiss" "Update in Progress" "Packages are being installed. Please wait...")
                            last_status="INSTALLING"
                        fi
                    fi
                    
                    # Agar bildirishnomadan Terminal ochish bosilsa
                    [[ "$res" == "t" ]] && kitty --title "ArchUpdate" sh -c "screen -r $SCREEN_NAME"
                    res="" # Resni tozalash
                else
                    # Screen yopildi (Jarayon tugadi)
                    if [[ -f "$LAST_UPDATE_FILE" ]] && [[ "$(cat $LAST_UPDATE_FILE)" == "$TODAY" ]]; then
                        send_notif -t 6000 "Update Complete" "Success! Your system is now up to date."
                        current_step="FINISHED"
                    else
                        # Kutilmagan yopilish
                        send_notif -t 4000 "Update Interrupted" "Process ended unexpectedly. Check manually."
                        current_step="FINISHED"
                    fi
                fi
            fi
            sleep 5
        done
    fi

    trap "last_status='FORCE_CHECK'" SIGUSR1
    sleep 10800 & 
    wait $!
done