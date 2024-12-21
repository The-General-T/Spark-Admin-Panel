#!/bin/bash

update_func() {
    (
        # =================================================================
        echo "# Running First Task."
        sleep 2
        # Command for first task goes on this line.
        zenity --password --title="Enter your password for sudo" | sudo -S apt-get update -y

        # =================================================================
        echo "25"
        echo "# Running Second Task."
        sleep 2
        # Command for second task goes on this line.
        sudo -S apt upgrade -y

        # =================================================================
        echo "50"
        echo "# Running Third Task."
        sleep 2
        sudo -S apt-get autoremove -y

        # =================================================================
        echo "75"
        echo "# Running Fourth Task."
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
            --text="First Task." \
            --percentage=0 \
            --auto-close \
            --auto-kill

    (($? != 0)) && zenity --error --text="Error in zenity command."
}

# Function to display system information
show_sys_info() {
    sysopt=$(zenity --list \
        --title="Spark System Management" \
        --column="Bug Number" --column="Description" --hide-header \
        1 "Update System" \
        2 "Reboot")
    echo $sysopt
    case $sysopt in
    1)
        update_func
        return
        ;;
    2)
        zenity --password --title="Enter your password for sudo" | sudo -S reboot
        ;;
    3)
        pkg_srvc
        ;;
    4)
        show_usr_mgmt
        ;;
    5)
        return
        ;;
    *)
        echo "Invalid choice, please try again."
        ;;
    esac
}

# Function to manage Packages (Uses APT and FlatPak)
pkg_srvc() {
    pkgopt=$(zenity --list \
        --title="Spark Utility Panel" \
        --column="Bug Number" --column="Description" --hide-header \
        1 "Install Package (Apt)" \
        2 "Uninstall Package (Apt)" \
        3 "Install Package (FlatPak)" \
        4 "Uninstall Package (FlatPak)")
    echo $pkgopt
    case $pkgopt in
    1)
        pkg=$(zenity --entry --title="Spark Package Manager" --text="Please input a package you wish to install")
        zenity --password --title="Enter your password for sudo" | sudo -S apt-get install $pkg -y
        return
        ;;
    2)
        pkg=$(zenity --entry --title="Spark Package Manager" --text="Please input a package you wish to remove")
        zenity --password --title="Enter your password for sudo" | sudo -S apt-get remove $pkg -y
        return
        ;;
    3)
        pkg=$(zenity --entry --title="Spark Package Manager" --text="Please input a package you wish to install")
        zenity --password --title="Enter your password for sudo" | sudo -S flatpak install $pkg -y
        return
        ;;
    4)
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

    usropt=$(zenity --list \
        --title="Spark User Management" \
        --column="Bug Number" --column="Description" --hide-header \
        1 "Add User" \
        2 "Delete User" \
        3 "Update User Info")
    echo $usropt

    case $usropt in
    1)
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
    2)
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
    3)
        # Update User Info (Change Password or Username)
        update_option=$(zenity --list \
            --title="Update User Info" \
            --column="Option" --column="Description" \
            1 "Change Password" \
            2 "Change Username" \
            --hide-header)

        case $update_option in
        1)
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

        2)
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
    echo "Enter the name of the service (e.g., apache2, nginx, etc.):"
    read service
    echo "Choose an option:"
    echo "1. Start Service"
    echo "2. Stop Service"
    echo "3. Check Service Status"
    echo "4. Go back"
    read service_choice

    case $service_choice in
    1)
        sudo systemctl start "$service"
        echo "Service $service started."
        ;;
    2)
        sudo systemctl stop "$service"
        echo "Service $service stopped."
        ;;
    3)
        sudo systemctl status "$service"
        ;;
    4)
        return
        ;;
    *)
        zenity --error --text="Invalid choice."
        ;;
    esac
    echo
}

# Main menu
main_menu() {
    mainopt=$(zenity --list \
        --title="Spark Utility Panel" \
        --column="Bug Number" --column="Description" --hide-header \
        1 "System Management Panel" \
        2 "Package Management Panel" \
        3 "Service Management Panel" \
        4 "User Management Panel")
    echo $mainopt
    case $mainopt in
    1)
        show_sys_info
        ;;
    2)
        pkg_srvc
        ;;
    3)
        manage_services
        ;;
    4)
        show_usr_mgmt
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
        zenity --password | sudo -S -v
    fi
done