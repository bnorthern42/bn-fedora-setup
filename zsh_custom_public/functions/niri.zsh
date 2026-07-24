restart_noctalia() {
    echo "Killing Noctalia / Quickshell..."
    pkill -f 'qs.*noctalia-shell'
    pkill -f 'quickshell.*noctalia-shell'

    sleep 0.5

    echo "Reloading niri..."
    niri msg action do-screen-transition 2>/dev/null

    echo "Starting Noctalia through niri..."
    niri msg action spawn -- qs -c noctalia-shell

    echo "Done."
}
