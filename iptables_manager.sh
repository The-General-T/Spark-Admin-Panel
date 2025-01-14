#!/bin/bash

while true; do
    # Display the main menu using zenity
    CHOICE=$(zenity --list --title="IPTables Manager" --text="Select an action:" \
        --column="Action" \
        "Add Rule" \
        "Delete Rule" \
        "List Rules" \
        "Flush Rules" \
        "Exit" 2>/dev/null)

    case "$CHOICE" in
        "Add Rule")
            RULE=$(zenity --entry --title="Add Rule" \
                --text="Enter iptables rule (e.g., -A INPUT -p tcp --dport 80 -j ACCEPT):" 2>/dev/null)
            if [ -n "$RULE" ]; then
                status=$(zenity --password --title="Enter your password for sudo" | sudo -S  iptables $RULE)
                if [ $? -eq 0 ]; then
                    zenity --info --text="Rule added successfully." 2>/dev/null
                else
                    zenity --error --text="Failed to add rule." 2>/dev/null
                fi
            fi
            ;;
        "Delete Rule")
            RULE=$(zenity --entry --title="Delete Rule" \
                --text="Enter iptables rule to delete (e.g., -D INPUT -p tcp --dport 80 -j ACCEPT):" 2>/dev/null)
            if [ -n "$RULE" ]; then
                status=$(zenity --password --title="Enter your password for sudo" | sudo -S  iptables $RULE)
                if [ $? -eq 0 ]; then
                    zenity --info --text="Rule deleted successfully." 2>/dev/null
                else
                    zenity --error --text="Failed to delete rule." 2>/dev/null
                fi
            fi
            ;;
        "List Rules")
            RULES=$(zenity --password --title="Enter your password for sudo" | sudo iptables -L -v -n)
            zenity --text-info --title="List of Rules" --width=600 --height=400 --text="$RULES" 2>/dev/null
            ;;
        "Flush Rules")
            status=$(zenity --password --title="Enter your password for sudo" | sudo -S sudo iptables -F)
            if [ $? -eq 0 ]; then
                zenity --info --text="All rules flushed successfully." 2>/dev/null
            else
                zenity --error --text="Failed to flush rules." 2>/dev/null
            fi
            ;;
        "Exit")
            break
            ;;
        *)
            zenity --error --text="Invalid choice. Please try again." 2>/dev/null
            ;;
    esac
done
