FROM archlinux:base-devel

RUN pacman-key --init && \
    pacman-key --populate 

RUN \ 
if grep -q "\[multilib\]" /etc/pacman.conf; then \
    sed -i '/^\[multilib\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; \
else \
    echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf; \
fi

RUN \ 
if grep -q "\[community\]" /etc/pacman.conf; then \
    sed -i '/^\[community\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; \
else \
    echo -e "[community]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf; \
fi

RUN sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen && \
    locale-gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf

RUN echo 'KEYMAP=us' > /etc/vconsole.conf

RUN curl https://raw.githubusercontent.com/MikuX-Dev/docker-archiso/main/blackarch-mirrorlist -o /etc/pacman.d/blackarch-mirrorlist && \
    curl https://raw.githubusercontent.com/MikuX-Dev/docker-archiso/main/mirrorlist -o /etc/pacman.d/mirrorlist

RUN curl -O https://blackarch.org/strap.sh && \
    bash strap.sh --noconfirm --quiet 

RUN pacman -Fyy --noconfirm --quiet && \
    pacman -Syy --noconfirm --quiet archlinux-keyring blackarch-keyring
    
RUN pacman -Syyu --noconfirm --quiet --needed base base-devel archiso mkinitcpio-archiso devtools dosfstools mtools fakeroot fakechroot yay vim lhasa linux-firmware network-manager-applet net-tools networkmanager ntp

#RUN useradd -m builder && echo "builder:builder" | chpasswd
#USER builder

#WORKDIR /home/builder

CMD ["/bin/bash"]
