// Pre-configure all packages with debconf before they are installed.
// If you don't like it, comment it out.
DPkg::Pre-Install-Pkgs {"/usr/sbin/dpkg-preconfigure --apt || true";};

// per: https://bugs.launchpad.net/ubuntu/+source/debconf/+bug/90085
DPkg::Pre-Invoke {"mount -o remount,exec /tmp";};
DPkg::Post-Invoke {"mount -o remount /tmp";};
