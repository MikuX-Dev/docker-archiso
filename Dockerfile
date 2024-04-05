# Use the Arch Linux base image with development tools
FROM docker.io/library/archlinux:base-devel
LABEL maintainer="unknownjustuser <unknown.just.user@proton.me>"

SHELL [ "/bin/bash", "-c" ]

ENV PATH="/home/builder/bin:/home/builder/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/core_perl:$PATH"
ENV TERM=dumb

RUN sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen && \
    locale-gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    echo 'KEYMAP=us' > /etc/vconsole.conf

RUN \
  pacman -Syy && \
  pacman-key --init && \
  pacman-key --keyserver keyserver.ubuntu.com --recv-key 3056513887B78AEB && \
  pacman-key --lsign-key 3056513887B78AEB && \
  pacman --noconfirm -U 'https://geo-mirror.chaotic.cx/chaotic-aur/chaotic-'{keyring,mirrorlist}'.pkg.tar.zst' && \
  echo "[multilib]" >>/etc/pacman.conf && echo "Include = /etc/pacman.d/mirrorlist" >>/etc/pacman.conf && \
  echo -e "\\n[chaotic-aur]\\nInclude = /etc/pacman.d/chaotic-mirrorlist" >>/etc/pacman.conf && \
  echo "" >>/etc/pacman.conf && \
  pacman -Syy --noconfirm --quiet wget && \
  bash <(wget -qO- https://blackarch.org/strap.sh)

RUN pacman -Syyu --noconfirm --quiet --needed archlinux-keyring blackarch-keyring yay archiso audit aurutils cmake curl devtools libinput docker docker-buildx docker-compose glibc-locales gnupg grep gzip jq less make man namcap openssh openssl parallel pkgconf python python-apprise python-pip rsync squashfs-tools tar unzip vim wget yq zip paru reflector git-lfs openssh git namcap audit grep diffutils parallel cronie

# Add builder User
RUN useradd -m -d /home/builder -s /bin/bash -G wheel builder && \
    sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    usermod -a -G docker builder && \
    usermod -a -G libinput builder && \
    systemctl enable docker

# chown user
RUN chown -R builder:builder /home/builder/

USER builder
WORKDIR /home/builder
