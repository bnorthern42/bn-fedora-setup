## Display the status of a systemd service
status()
{
  sudo systemctl status $1
}

## Restart pipewire and pipewire-pulse services when they are being buggy
## and reload the user daemon configuration.
resetpipewire(){
  systemctl --user restart pipewire pipewire-pulse && systemctl --user daemon-reload
}