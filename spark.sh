#!/bin/bash

update_func() {
    (
        # =================================================================
        echo "# Updating packages (APT)"
        sleep 2
        # Command for first task goes on this line.
        zenity --password --title="Enter your password for sudo" | sudo -S apt-get update -y

        # =================================================================
        echo "25"
        echo "# Running apt upgrade"
        sleep 2
        # Command for second task goes on this line.
        sudo -S apt upgrade -y

        # =================================================================
        echo "50"
        echo "# Removing unused packages (APT)"
        sleep 2
        sudo -S apt-get autoremove -y

        # =================================================================
        echo "75"
        echo "# Updating FlatPak"
        sleep 2
        # Command for fourth task goes on this line.
        sudo -S flatpak update -y

        # =================================================================
        echo "# All finished."
        echo "100"
        sleep 2

    ) |
        zenity --progress \
            --title="Progress Status" \
            --text="Updating..." \
            --percentage=0 \
            --auto-close \
            --auto-kill

    (($? != 0)) && zenity --error --text="Error in zenity command."
}

# Function to display system information
show_sys_info() {
    sysopt=$(zenity --list --radiolist --title="Choose an Option" \
        --text="Choose a task:" \
        --column="Select" --column="Action" \
        TRUE "Update System" \
        FALSE "Reboot")
    echo $sysopt
    case $sysopt in
    "Update System")
        update_func
        return
        ;;
    "Reboot")
        zenity --password --title="Enter your password for sudo" | sudo -S reboot
        ;;
    *)
        echo "Invalid choice, please try again."
        ;;
    esac
}

# Function to manage Packages (Uses APT and FlatPak)
pkg_srvc() {
    pkgopt=$(zenity --list --radiolist --title="Choose an Option" \
        --text="Choose a task: (NOTE: THIS RUNS IN THE BACKGROUND)" \
        --column="Select" --column="Action" \
        TRUE "Install Package (Apt)" \
        FALSE "Uninstall Package (Apt)" \
        FALSE "Install Package (FlatPak)" \
        FALSE "Uninstall Package (FlatPak)")
    echo $pkgopt
    case $pkgopt in
    "Install Package (Apt)")
        pkg=$(zenity --entry --title="Spark Package Manager" --text="Please input a package you wish to install")
        zenity --password --title="Enter your password for sudo" | sudo -S apt-get install $pkg -y
        return
        ;;
    "Uninstall Package (Apt)")
        pkg=$(zenity --entry --title="Spark Package Manager" --text="Please input a package you wish to remove")
        zenity --password --title="Enter your password for sudo" | sudo -S apt-get remove $pkg -y
        return
        ;;
    "Install Package (FlatPak)")
        pkg=$(zenity --entry --title="Spark Package Manager" --text="Please input a package you wish to install")
        zenity --password --title="Enter your password for sudo" | sudo -S flatpak install $pkg -y
        return
        ;;
    "Uninstall Package (FlatPak)")
        pkg=$(zenity --entry --title="Spark Package Manager" --text="Please input a package you wish to remove")
        zenity --password --title="Enter your password for sudo" | sudo -S flatpak uninstall $pkg -y
        return
        ;;
    *)
        echo "Invalid choice, please try again."
        ;;
    esac
    return
}

# Function to manage users (add/remove/etc)
show_usr_mgmt() {

    usropt=$(zenity --list --radiolist --title="Choose an Option" \
        --text="Choose a task:" \
        --column="Select" --column="Action" \
        TRUE "Add User" \
        FALSE "Remove User" \
        FALSE "Update User")
    echo $usropt

    case $usropt in
    "Add User")
        # Collect the user data using Zenity forms
        datafill=$(zenity --forms \
            --title="Spark User Management" \
            --text="Fill data" \
            --add-entry="Enter username" \
            --add-password="Add password" \
            --add-password="Confirm password" \
            --separator="|")

        echo $datafill

        # Split the data into individual variables
        IFS='|' read -r username password1 password2 <<<"$datafill"
        echo $username
        echo $password1
        echo $password2

        # Compare the passwords
        if [[ "$password1" == "$password2" ]] && [[ "$password2" =~ [a-z] && "$password2" =~ [A-Z] && "$password2" =~ [0-9] && ${#password2} -ge 8 ]]; then
            echo "PASSCHECK CHECKPOINT"
            # Check if password is strong enough
            # Ask for sudo password
            sudo_pass=$(zenity --password --title="Enter your password for sudo")

            # Create user using useradd (without -D)
            echo "$sudo_pass" | sudo -S useradd -m -s /bin/bash "$username"

            # Set the password using passwd
            # shellcheck disable=SC2259
            echo "$password1" | sudo -S passwd "$username" <<<"$password1"

            zenity --info --text="User $username created successfully!"
        else
            zenity --error --text="Password is too weak! It must contain at least 8 characters, including uppercase, lowercase, and a number."
        fi
        ;;
    "Remove User")
        username_to_delete=$(zenity --entry --title="Delete User" --text="Enter the username of the user to delete:")

        if [[ -n "$username_to_delete" ]]; then
            # Confirm the deletion
            confirm_deletion=$(zenity --question --title="Confirm Deletion" \
                --text="Are you sure you want to delete the user $username_to_delete and their home directory?" \
                --ok-label="Yes" --cancel-label="No")
            echo $confirm_deletion

            if [[ $? -eq 0 ]]; then
                # Ask for sudo password to delete the user
                sudo_pass=$(zenity --password --title="Enter your password for sudo")

                # Delete the user and their home directory
                echo "$sudo_pass" | sudo -S userdel -r "$username_to_delete"

                if [[ $? -eq 0 ]]; then
                    zenity --info --text="User $username_to_delete and their home directory have been successfully deleted!"
                else
                    zenity --error --text="An error occurred while deleting the user $username_to_delete."
                fi
            else
                zenity --info --text="User deletion canceled."
            fi
        else
            zenity --error --text="No username entered. Deletion canceled."
        fi
        ;;
    "Update User")
        # Update User Info (Change Password or Username)
        update_option=$(zenity --list --radiolist --title="Choose an Option" \
        --text="Choose a task:" \
        --column="Select" --column="Action" \
        TRUE "Update Password" \
        FALSE "Update Username")
        case $update_option in
        "Update Password")
            username_to_update=$(zenity --entry --title="Change Password" --text="Enter the username whose password you want to change:")

            if [[ -n "$username_to_update" ]]; then
                # Ask for current password and new password
                current_password=$(zenity --password --title="Enter current password for $username_to_update")
                new_password=$(zenity --password --title="Enter new password")
                confirm_password=$(zenity --password --title="Confirm new password")

                # Check if new password matches confirm password

                if [[ "$new_password" == "$confirm_password" ]]; then
                    # Check if password is strong enough
                    if ! echo "$new_password" | grep -qE "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).{8,}$"; then
                        # If password doesn't meet the requirements, show an error
                        zenity --error --text="Password is too weak! It must contain at least 8 characters, including uppercase, lowercase, and a number."
                    else
                        # Ask for sudo password to change password
                        sudo_pass=$(zenity --password --title="Enter your password for sudo")

                        # Change the password using `passwd`
                        # shellcheck disable=SC2259
                        echo "$sudo_pass" | sudo -S passwd "$username_to_update" <<<"$new_password"

                        # Check for password change failure
                        if [[ $? -ne 0 ]]; then
                            zenity --error --text="Failed to update the password. The password may not meet the system's requirements."
                        else
                            zenity --info --text="Password for $username_to_update has been successfully updated!"
                        fi
                    fi
                else
                    zenity --error --text="New password and confirmation do not match!"
                fi
            else
                zenity --error --text="No username entered. Password change canceled."
            fi
            ;;

        "Update Username")
            old_username=$(zenity --entry --title="Change Username" --text="Enter the current username:")

            if [[ -n "$old_username" ]]; then
                new_username=$(zenity --entry --title="New Username" --text="Enter the new username:")

                if [[ -n "$new_username" ]]; then
                    # Ask for sudo password to change username
                    sudo_pass=$(zenity --password --title="Enter your password for sudo")

                    # Change the username using usermod
                    echo "$sudo_pass" | sudo -S usermod -l "$new_username" "$old_username"

                    # Rename the user''s home directory
                    echo "$sudo_pass" | sudo -S mv "/home/$old_username" "/home/$new_username"

                    zenity --info --text="Username for $old_username has been successfully updated to $new_username!"
                else
                    zenity --error --text="New username cannot be empty. Username change canceled."
                fi
            else
                zenity --error --text="No username entered. Username change canceled."
            fi
            ;;
        *)
            zenity --error --text="Invalid option selected for updating user!"
            ;;
        esac
        ;;
    *)
        zenity --error --text="Invalid option selected!"
        ;;
    esac
}

# Function to manage services (start/stop/status)
manage_services() {
    # Ask for the service name using Zenity input dialog
    service=$(zenity --entry --title="Enter Service Name" --text="Enter the name of the service (e.g., apache2, nginx, etc.):")

    # If user presses Cancel or leaves the field empty, exit the script
    if [ -z "$service" ]; then
        zenity --error --text="No service name entered. Exiting."
        exit 1
    fi

    # Ask for the action to perform on the service using a Zenity menu
    service_choice=$(zenity --list --radiolist --title="Choose an Option" \
        --text="Choose an option for service $service:" \
        --column="Select" --column="Action" \
        TRUE "Start Service" \
        FALSE "Stop Service" \
        FALSE "Check Service Status" \
        FALSE "Go back")

    # Handle the service choice
    case $service_choice in
    "Start Service")
        zenity --password --title="Enter your password for sudo" | sudo -S systemctl start "$service"
        zenity --info --text="Service $service started."
        ;;
    "Stop Service")
        zenity --password --title="Enter your password for sudo" | sudo -S systemctl stop "$service"
        zenity --info --text="Service $service stopped."
        ;;
    "Check Service Status")
        status=$(zenity --password --title="Enter your password for sudo" | sudo -S systemctl status "$service" | zenity --text-info --title="Service Status" --width=600 --height=400)
        ;;
    "Go back")
        exit 0
        ;;
    *)
        zenity --error --text="Invalid choice. Please try again."
        ;;
    esac
}

# Main menu
main_menu() {
        mainopt=$(zenity --list --radiolist --title="Choose an Option" \
        --text="Choose a task:" \
        --column="Select" --column="Action" \
        TRUE "System Management Panel" \
        FALSE "Package Management Panel" \
        FALSE "Service Management Panel" \
        FALSE "User Management Panel" \
        FALSE "Iptables Management Panel")
    echo $mainopt
    case $mainopt in
    "System Management Panel")
        show_sys_info
        ;;
    "Package Management Panel")
        pkg_srvc
        ;;
    "Service Management Panel")
        manage_services
        ;;
    "User Management Panel")
        show_usr_mgmt
        ;;
    "Iptables Management Panel")
        bash iptables_manager.sh
        ;;
    *)
        exit 0
        ;;
    esac
}

while true; do
    if sudo -n true; then
        main_menu
    else
        zenity --password --title="This program uses SUDO. Please enter your password." | sudo -S -v
    fi
done
