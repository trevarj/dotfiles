
# Guix on Fedora Silverblue

## Installation

1. Enter toolbox
2. Download and run `install.sh` guix installer
3. Install custom systemd service on host (.config/systemd/user/guix-daemon.service)
4. In toolbox, run the below permissions changes
5. `systemctl --user enable guix-daemon.service --now`
6. Now you can `guix pull` from within the toolbox

## Permissions workarounds for running daemon as $USER

```sh
chown -R $USER:$USER /gnu /var/guix
chown -R root:root /var/guix/profiles/per-user/root # might need to skip?

mkdir -p /var/log/guix
chown $USER:$USER /var/log/guix
chmod 755 /var/log/guix
chmod 755 /etc/guix/acl
```

Run this script as root from inside the toolbox (extracted from `install.sh`)

```sh
create_account() {
  local user="$1"
  local group="$2"
  local supplementary_groups="$3"
  local comment="$4"

  if id "$user" &>/dev/null; then
    usermod -g "$group" -G "$supplementary_groups" \
      -d /var/empty -s "$(command -v nologin)" \
      -c "$comment" "$user"
  else
    useradd -g "$group" -G "$supplementary_groups" \
      -d /var/empty -s "$(command -v nologin)" \
      -c "$comment" --system "$user"
  fi
}

for i in $(seq -w 1 10); do
  create_account "guixbuilder${i}" "guixbuild" \
    "guixbuild${KVMGROUP}" \
    "Guix build user $i"
done
```

## Starting Guix Daemon Service

Now, you should be able on the host
```sh
systemctl --user start guix-daemon
```

and within the toolbox, do a `guix pull`
