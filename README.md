# Spark

Spark is a BASH script GUI utility panel designed to simplify various backend actions on Linux-based systems. With an easy-to-use graphical interface, users can manage system tasks, user accounts, and packages efficiently. Whether you're a beginner or a seasoned sysadmin, Spark streamlines essential maintenance and management processes.

## Features

- **User Management**
  - Add, remove, or modify user accounts.
  - Configure user privileges and groups.

- **System Management**
  - Reboot the system.
  - Perform system updates (install, upgrade, and clean).
  - Manage system services.

- **Package Management**
  - Install, remove, or update packages using APT.
  - Manage FlatPak applications.

## Installation

### Prerequisites

Ensure that the following packages are installed on your system:

- `bash`
- `zenity` (for GUI dialogs)
- `apt` (for package management)
- `flatpak` (for FlatPak package management)

### Clone the repository

1. Clone the Spark repository to your local machine:

   ```bash
   git clone https://github.com/the-general-t/spark.git
   ```

2. Navigate to the project directory:

   ```bash
   cd spark
   ```

3. Make the script executable:

   ```bash
   chmod +x spark.sh
   ```

4. (Optional) Create a symlink to access Spark from anywhere:

   ```bash
   sudo ln -s /path/to/spark/spark.sh /usr/local/bin/spark
   ```

   This allows you to run Spark using the `spark` command in any terminal.

## Usage

To launch Spark, run the script:

```bash
./spark.sh
```

Or, if you created a symlink:

```bash
spark
```

A graphical interface will open, offering the following options:

- **Manage Users**: Add, remove, or modify user accounts.
- **System Management**: Reboot the system or update it.
- **Package Management**: Manage packages via APT or FlatPak.

### Example Command Usage

- To add a new user, select **Manage Users** > **Add User**.
- To update the system, choose **System Management** > **Update System**.
- To install a FlatPak application, select **Package Management** > **Install Package (FlatPak)**.

## Contributing

If you'd like to contribute to Spark, feel free to fork the repository and submit pull requests. Contributions are welcome!

### Bug Reporting

If you encounter any issues with Spark, please open an issue on the [GitHub Issues page](https://github.com/the-general-t/spark/issues).

## License

Spark is released under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Acknowledgments

- This project uses `zenity` for the graphical interface.
- Inspired by various system administration tools that aim to make backend tasks more accessible.

