# mk - A multi-purpose helper function for common development tasks.
#
# Usage:
#   mk exe [file...]   - Makes specified files (or all .sh files in CWD) executable.
#   mk clean           - Removes common build artifacts (*.o, *.out).
#   mk run             - Compiles using 'make' and executes the resulting a.out.
#   mk serve [port]    - Starts a basic web server in the current directory (default: 8000).
#   mk kill <port>     - Kills the process running on the specified port.
#   mk commit <msg>    - Stages all files and commits with a message.
#
# Arguments:
#   $1: The command to execute (exe, clean, run, serve, update, touch, kill, commit).
mk() {
  local cmd="$1"; shift

  case "$cmd" in
    exe)
      # if files passed → use them
      if [ "$#" -gt 0 ]; then
        chmod u+x "$@"
      else
        # fallback: all .sh in cwd
        find . -maxdepth 1 -type f -name "*.sh" -exec chmod u+x {} +
      fi
      ;;
    clean)
      rm -f *.o *.out
      ;;
    run)
      make && ./a.out
      ;;
    mix)
        mix deps.get && mix run
        ;;
    iex)
        iex -S mix
        ;;
    pho)
        #phoenix
        (
        sleep 2
        xdg-open http://localhost:4000
        ) &
        mix phx.server
    ;;
    serve)
      # Starts a simple python http server in the current directory.
      # Defaults to port 7000.
      local port="${1:-7000}"
      echo "Serving HTTP on port ${port}..."
      python3 -m http.server "${port}"
      ;;
    kill)
      # Kills the process listening on the specified port.
      if [ -z "$1" ]; then
        echo "mk kill: missing port number" >&2
        return 1
      fi
      local pid
      pid=$(lsof -t -i:"$1" 2>/dev/null)
      if [ -n "$pid" ]; then
        echo "Killing process $pid on port $1..."
        kill "$pid"
      else
        echo "mk kill: no process found on port $1" >&2
        return 1
      fi
      ;;
    commit)
      # Stages all changes and commits with a message.
      if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "mk commit: not a git repository" >&2
        return 1
      fi
      if [ -z "$1" ]; then
        echo "mk commit: missing commit message" >&2
        return 1
      fi
      git add . && git commit -m "$1"
      ;;
   float)
        local app_id="$1"
    local config="$HOME/.config/niri/config.kdl"

    if grep -qF "match app-id=\"$app_id\"" "$config"; then
        echo "niri rule for app-id '$app_id' already exists"
        return 0
    fi

    perl -i -pe '
        print "\nwindow-rule {\n    match app-id=\"'"$app_id"'\"\n    open-floating true\n}\n"
        if $. == 196
    ' "$config"

    echo "added floating niri rule for app-id '$app_id'"
    ;;
    *)
      echo "mk: unknown command '$cmd'" >&2
      return 1
      ;;
  esac
}
