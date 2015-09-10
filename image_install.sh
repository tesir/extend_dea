#!/bin/bash -ex

apt-get update

# emulating stemcell_builder/stages/image_install_grub/apply.sh
if [ `lsb_release -cs` ==  "trusty" ]; then
    if (sed -i -e 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' /etc/default/grub); then
        update-grub
    else
        echo Your /etc/default/grub is modified from the default
        exit 1
    fi
fi

# stemcell_builder/stages/base_apt/apply.sh
DEBIAN_FRONTEND=noninteractive apt-get install -o Dpkg::Options::="--force-confnew" -f -y \
--force-yes --no-install-recommends \
build-essential libssl-dev lsof \
strace bind9-host dnsutils tcpdump iputils-arping \
curl wget libcurl3 libcurl3-dev bison libreadline6-dev \
libxml2 libxml2-dev libxslt1.1 libxslt1-dev zip unzip \
nfs-common flex psmisc apparmor-utils iptables sysstat \
rsync openssh-server traceroute libncurses5-dev quota \
libaio1 gdb tripwire libcap2-bin libyaml-dev

# stemcell_builder/stages/bosh_monit/apply.sh
DEBIAN_FRONTEND=noninteractive apt-get install -o Dpkg::Options::="--force-confnew" -f -y \
--force-yes --no-install-recommends runit

# installed somewhere else
DEBIAN_FRONTEND=noninteractive apt-get install -o Dpkg::Options::="--force-confnew" -f -y \
--force-yes --no-install-recommends gettext

# bosh_agent/lib/bosh_agent/platform/ubuntu/templates/logrotate.erb
cat <<EOF > /etc/logrotate.d/nise_bosh
/var/vcap/sys/log/*.log /var/vcap/sys/log/*/*.log /var/vcap/sys/log/*/*/*.log {
  missingok
  rotate 7
  compress
  delaycompress
  copytruncate
  size=100M
}
EOF

# stemcell_builder/stages/bosh_users/apply.sh
if [ `cat /etc/passwd | cut -f1 -d ":" | grep "^vcap$" -c` -eq 0 ]; then
    addgroup --system admin
    adduser --disabled-password --gecos Ubuntu vcap

    for grp in admin adm audio cdrom dialout floppy video plugdev dip
    do
        adduser vcap $grp
    done
else
    echo "User vcap exists already, skippking adduser..."
fi

# stemcell_builder/stages/system_kernel/apply.sh
if [ -d /boot/grub ]; then
    if [ `lsb_release -cs` ==  "lucid" ]; then
        variant="lts-backport-oneiric"

        # Headers are needed for open-vm-tools
        DEBIAN_FRONTEND=noninteractive apt-get install -o Dpkg::Options::="--force-confnew" -y -f \
            linux-image-virtual-${variant} linux-headers-virtual-${variant}
    else
        DEBIAN_FRONTEND=noninteractive apt-get install -o Dpkg::Options::="--force-confnew" -y -f \
            linux-image-virtual linux-image-extra-virtual
    fi
fi

echo Done.
