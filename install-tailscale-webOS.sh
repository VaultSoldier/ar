#!/bin/sh

# Quit if not running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Refer to https://www.webosbrew.org/guides/rooting/ for more information."
    exit 1
fi

# Quit if not running on webOS
if [ ! -f /etc/starfish-release ]; then
    echo "This script is intended for webOS devices only."
    exit 1
fi

TAILSCALE_DIST=tailscale_1.82.0_arm
TAILSCALE_TARBALL="https://github.com/VaultSoldier/ar/raw/refs/heads/main/${TAILSCALE_DIST}.tgz"
INSTALL_BINDIR=/media/developer/bin/

mkdir -p "$INSTALL_BINDIR"

echo "Downloading Tailscale..."
# Extract tailscaled, tailscale from the pipe
curl -SL $TAILSCALE_TARBALL | tar -xz -C $INSTALL_BINDIR $TAILSCALE_DIST/tailscaled $TAILSCALE_DIST/tailscale --strip-components=1

echo "Adding tailscaled to init.d..."

cat <<EOF > /var/lib/webosbrew/init.d/tailscaled
#!/bin/sh

export PATH=/media/developer/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Make /etc/resolv.conf writable with bind-mount
cp /etc/resolv.conf /tmp/resolv.conf
mount -o bind /tmp/resolv.conf /etc/resolv.conf

/media/developer/bin/tailscaled &> /tmp/tailscaled.log &
EOF
chmod +x /var/lib/webosbrew/init.d/tailscaled

echo "Setting up PATH..."
# Add INSTALL_BINDIR to PATH if not already present
if ! grep -q "$INSTALL_BINDIR" /home/root/.profile; then
    echo "export PATH=\$PATH:$INSTALL_BINDIR" >> /home/root/.profile
fi

echo "Done! Reboot the TV with reboot command, and run tailscale command for usage."

