# C# compilation and execution aliases
function csharp_compile() {
    echo "Compiling C# project..."
    dotnet build "$@"
}

function csharp_run() {
    echo "Running C# project..."
    dotnet run "$@"
}
# Converts a Windows path to a WSL path. If the path points to a file,
# it extracts the parent directory. Always prints the resulting WSL directory
# and changes into it unless explicitly disabled.
#
# Arguments:
#   $1 - Windows path (e.g., "C:\Users\...\file.zip") (Required)
#   $2 - Executes 'cd' if 'true' or empty. Skips 'cd' if 'false'. (Optional)
#
# Returns:
#   0 on success, 1 on missing arguments or failed cd.
# ==============================================================================
ccd() {
    if [ -z "$1" ]; then
        echo "Usage: ccd <windows_path> [true|false]"
        return 1
    fi

    local target
    target=$(wslpath -u "$1")

    if [ -f "$target" ]; then
        target=$(dirname "$target")
    fi

    echo "$target"

    local do_cd="${2:-true}"

    if [ "$do_cd" != "false" ]; then
        cd "$target" || return 1
    fi
}

# ==============================================================================
# ccp (Copy from Windows path to WSL destination)
# ==============================================================================
# Converts a Windows file path to a WSL path, verifies the file exists, 
# and copies it to a specified WSL destination directory or file name.
#
# Arguments:
#   $1 - Windows source file path (e.g., "C:\Users\...\file.zip") (Required)
#   $2 - WSL destination path (e.g., '.', '/tmp/') (Required)
#
# Returns:
#   0 on success, 1 on missing arguments or invalid source file.
# ==============================================================================
ccp() {
    if [ "$#" -lt 2 ]; then
        echo "Usage: ccp <windows_file_path> <destination_path>"
        return 1
    fi

    local source_file
    source_file=$(wslpath -u "$1")

    if [ ! -f "$source_file" ]; then
        echo "Error: Source file '$source_file' does not exist or is not a regular file."
        return 1
    fi

    cp "$source_file" "$2"
    echo "Copied: $source_file -> $2"
}

