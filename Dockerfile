FROM archlinux:base-devel
LABEL maintainer="unknownjustuser <unknown.just.user@proton.me>"

SHELL [ "/bin/bash", "-c" ]

ENV PATH="/home/builder/bin:/home/builder/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/core_perl:$PATH"
ENV TERM=dumb
ENV LANG=en_US.UTF-8

# Configure environment
RUN pacman-key --init && \
  pacman -Syy && \
  pacman-key --keyserver hkp://keyserver.ubuntu.com:80 --recv-key 3056513887B78AEB && \
  pacman-key --lsign-key 3056513887B78AEB && \
  pacman --noconfirm -U 'https://geo-mirror.chaotic.cx/chaotic-aur/chaotic-'{keyring,mirrorlist}'.pkg.tar.zst' && \
  echo "[multilib]" >>/etc/pacman.conf && echo "Include = /etc/pacman.d/mirrorlist" >>/etc/pacman.conf && \
  echo -e "\\n[chaotic-aur]\\nInclude = /etc/pacman.d/chaotic-mirrorlist" >>/etc/pacman.conf && \
  echo "" >>/etc/pacman.conf

RUN pacman -Syy --noconfirm --needed --noprogressbar wget bash && \
  bash <(wget -qO- https://blackarch.org/strap.sh) && \
  pacman -Syyu --noconfirm --needed --noprogressbar

RUN pacman -Sy --noprogressbar --noconfirm yay archiso audit aurutils autoconf base base-devel cmake curl devtools docker docker-buildx docker-compose fakeroot glibc-locales gnupg grep gzip jq less make man namcap openssh openssl parallel pkgconf python python-apprise python-pip rsync squashfs-tools tar unzip vim wget yq zip paru reflector git-lfs openssh git namcap audit grep diffutils parallel cronie

RUN useradd -m -d /home/builder -s /bin/bash -G wheel builder && \
  sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers && \
  echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
  echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
  chown -R builder:builder /home/builder && \
  chgrp buidler /home/builder && \
  chmod g+ws /home/builder && \
  setfacl -m u::rwx,g::rwx /home/builder && \
  setfacl -d --set u::rwx,g::rwx,o::- /home/builder && \
  usermod -a -G docker builder && \
  systemctl enable docker

RUN	sudo -u builder mkdir /home/builder/bin
RUN	sudo -u builder mkdir -p /home/builder/.local/bin
RUN	sudo -u builder touch /home/builder/.gitconfig
RUN sudo -u builder mkdir -p /home/builder/.ssh
RUN sudo -u builder touch /home/builder/.ssh/config
RUN sudo -u builder touch /home/builder/.ssh/known_hosts
RUN sudo -u builder ssh-keyscan github.com >/home/builder/.ssh/known_hosts

# USER builder
# WORKDIR /home/builder
