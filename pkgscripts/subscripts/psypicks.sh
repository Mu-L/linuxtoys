#!/bin/bash
# functions
get_heroic () {

    local tag=$(curl -s https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    local ver="${tag#v}"
    if command -v dnf &> /dev/null; then
        if ! rpm -qi "heroic" 2>/dev/null; then
            wget "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/${tag}/Heroic-${ver}-linux-x86_64.rpm"
            sudo dnf in -y "Heroic-${ver}-linux-x86_64.rpm" || { echo "Heroic installation failed"; rm -f "Heroic-${ver}-linux-x86_64.rpm"; return 1; }
            rm "Heroic-${ver}-linux-x86_64.rpm"
        else
            # update if already installed
            local hostver=$(rpm -qi "heroic" 2>/dev/null | grep "^Version" | awk '{print $3}')
            if [[ "$hostver" != "$ver" ]]; then
                wget "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/${tag}/Heroic-${ver}-linux-x86_64.rpm"
                sudo dnf remove -y heroic
                sudo dnf in -y "Heroic-${ver}-linux-x86_64.rpm" || { echo "Heroic update failed"; rm -f "Heroic-${ver}-linux-x86_64.rpm"; return 1; }
                rm "Heroic-${ver}-linux-x86_64.rpm"
            else
                zenity --info --text "$msg281" --height=300 --width=300
            fi
        fi
    elif command -v apt &> /dev/null; then
        if ! dpkg -s "heroic" 2>/dev/null 1>&2; then
            wget "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/${tag}/Heroic-${ver}-linux-amd64.deb"
            sudo apt install -y "Heroic-${ver}-linux-amd64.deb" || { echo "Heroic installation failed"; rm -f "Heroic-${ver}-linux-amd64.deb"; return 1; }
            rm "Heroic-${ver}-linux-amd64.deb"
        else
            local hostver=$(dpkg -l heroic 2>/dev/null | grep "^ii" | awk '{print $3}'| cut -d'-' -f1)
            if [[ "$hostver" != "$ver" ]]; then
                wget "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/${tag}/Heroic-${ver}-linux-amd64.deb"
                sudo apt remove -y heroic
                sudo apt install -y "Heroic-${ver}-linux-amd64.deb" || { echo "Heroic installation failed"; rm -f "Heroic-${ver}-linux-amd64.deb"; return 1; }
                rm "Heroic-${ver}-linux-amd64.deb"
            else
                zenity --info --text "$msg281" --height=300 --width=300
            fi
        fi
    elif command -v pacman &> /dev/null; then
        if ! pacman -Qi "heroic" 2>/dev/null 1>&2; then
            wget "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/${tag}/Heroic-${ver}-linux-x64.pacman"
            sudo pacman -U --noconfirm "Heroic-${ver}-linux-x64.pacman"
            rm "Heroic-${ver}-linux-x64.pacman"
        else
            local hostver=$(pacman -Q "heroic" 2>/dev/null | awk '{print $2}' | cut -d'-' -f1)
            if [[ "$hostver" != "$ver" ]]; then
                wget "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/${tag}/Heroic-${ver}-linux-x64.pacman"
                sudo pacman -R --noconfirm heroic
                sudo pacman -U --noconfirm "Heroic-${ver}-linux-x64.pacman"
                rm "Heroic-${ver}-linux-x64.pacman"
            else
                zenity --info --text "$msg281" --height=300 --width=300
            fi
        fi
    elif command -v zypper &> /dev/null; then
        if ! rpm -qi "heroic" 2>/dev/null; then
            wget "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/${tag}/Heroic-${ver}-linux-x86_64.rpm"
            sudo zypper in -y "Heroic-${ver}-linux-x86_64.rpm" || { echo "Heroic installation failed"; rm -f "Heroic-${ver}-linux-x86_64.rpm"; return 1; }
            rm "Heroic-${ver}-linux-x86_64.rpm"
        else
            # update if already installed
            local hostver=$(rpm -qi "heroic" 2>/dev/null | grep "^Version" | awk '{print $3}')
            if [[ "$hostver" != "$ver" ]]; then
                wget "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/${tag}/Heroic-${ver}-linux-x86_64.rpm"
                sudo zypper remove -y heroic
                sudo zypper in -y "Heroic-${ver}-linux-x86_64.rpm" || { echo "Heroic update failed"; rm -f "Heroic-${ver}-linux-x86_64.rpm"; return 1; }
                rm "Heroic-${ver}-linux-x86_64.rpm"
            else
                zenity --info --text "$msg281" --height=300 --width=300
            fi
        fi
    fi

}

# obs pipewire audio capture plugin installation
obs_pipe () {

    if [ ! -d "$HOME/.var/app/com.obsproject.Studio/config/obs-studio/plugins/linux-pipewire-audio" ]; then
        local ver=$(curl -s "https://api.github.com/repos/dimtpap/obs-pipewire-audio-capture/releases/latest" | grep -oP '"tag_name": "\K(.*)(?=")')
        mkdir obspipe
        cd obspipe
        wget https://github.com/dimtpap/obs-pipewire-audio-capture/releases/download/${ver}/linux-pipewire-audio-${ver}-flatpak-30.tar.gz || { echo "Download failed"; cd ..; rm -rf obspipe; return 1; }
        tar xvzf linux-pipewire-audio-${ver}-flatpak-30.tar.gz
        mkdir -p $HOME/.var/app/com.obsproject.Studio/config/obs-studio/plugins/linux-pipewire-audio
        cp -rf linux-pipewire-audio/* $HOME/.var/app/com.obsproject.Studio/config/obs-studio/plugins/linux-pipewire-audio/
        sudo flatpak override --filesystem=xdg-run/pipewire-0 com.obsproject.Studio
        cd ..
        rm -rf obspipe
    else
        local ver=$(curl -s "https://api.github.com/repos/dimtpap/obs-pipewire-audio-capture/releases/latest" | grep -oP '"tag_name": "\K(.*)(?=")')
        mkdir obspipe
        cd obspipe
        wget https://github.com/dimtpap/obs-pipewire-audio-capture/releases/download/${ver}/linux-pipewire-audio-${ver}-flatpak-30.tar.gz || { echo "Download failed"; cd ..; rm -rf obspipe; return 1; }
        tar xvzf linux-pipewire-audio-${ver}-flatpak-30.tar.gz
        mkdir -p $HOME/.var/app/com.obsproject.Studio/config/obs-studio/plugins/linux-pipewire-audio
        cp -rf linux-pipewire-audio/* $HOME/.var/app/com.obsproject.Studio/config/obs-studio/plugins/linux-pipewire-audio/
        cd ..
        rm -rf obspipe
    fi

}

# runtime
. /etc/os-release
source /usr/bin/linuxtoys/linuxtoys.lib
_lang_
source /usr/bin/linuxtoys/${langfile}
if zenity --question --text "$msg280" --height=300 --width=300; then
    if command -v flatpak &> /dev/null && command -v dnf &> /dev/null || command -v flatpak &> /dev/null && command -v apt &> /dev/null || command -v flatpak &> /dev/null && command -v zypper &> /dev/null || command -v flatpak &> /dev/null && command -v pacman &> /dev/null; then
        cd $HOME
        mkdir psypicks || exit 1
        cd psypicks || exit 1
        # enable RPMFusion non-free repositories for Fedora
        if command -v dnf &> /dev/null; then
            sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
            sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
        fi
        # package setup
        if command -v dnf &> /dev/null || command -v zypper &> /dev/null; then
            packages=(steam steam-devices lutris vlc)
        elif command -v apt &> /dev/null; then
            packages=(steam-devices vlc)
        elif command -v pacman &> /dev/null; then
            sudo sed -i -e '/^#\[multilib\]$/s/^#//' -e '/^#Include = \/etc\/pacman\.d\/mirrorlist$/s/^#//' /etc/pacman.conf
            sudo pacman -Syu
            packages=(steam steam-devices lutris vlc)
        fi
        if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
            packages+=(gnome-tweaks)
        fi
        _install_
        get_heroic
        # flatpak setup
        flatpaks=(org.prismlauncher.PrismLauncher io.missioncenter.MissionCenter com.github.tchx84.Flatseal com.vysp3r.ProtonPlus com.dec05eba.gpu_screen_recorder com.github.Matoking.protontricks com.obsproject.Studio com.discordapp.Discord)
        if command -v apt &> /dev/null; then
            flatpaks+=(com.valvesoftware.Steam)
        fi
        if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
            flatpaks+=(com.mattjakeman.ExtensionManager)
        fi
        _flatpak_
        obs_pipe
        zenity --info --text "$msg036" --height=300 --width=300
    else
        if command -v dnf &> /dev/null || command -v apt &> /dev/null || command -v zypper &> /dev/null || command -v pacman &> /dev/null; then
            if zenity --question --text "$msg012" --width 360 --height 300; then
                flatpak_in_lib
                if [ "$ID" == "ubuntu" ]; then
                    insta gnome-software gnome-software-plugin-flatpak gnome-software-plugin-snap
                fi
                cd $HOME
                mkdir psypicks || exit 1
                cd psypicks || exit 1
                # enable RPMFusion non-free repositories for Fedora
                if command -v dnf &> /dev/null; then
                    sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
                    sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
                fi
                # package setup
                if command -v dnf &> /dev/null || command -v zypper &> /dev/null; then
                    packages=(steam steam-devices lutris vlc)
                elif command -v apt &> /dev/null; then
                    packages=(steam-devices vlc)
                elif command -v pacman &> /dev/null; then
                    sudo sed -i -e '/^#\[multilib\]$/s/^#//' -e '/^#Include = \/etc\/pacman\.d\/mirrorlist$/s/^#//' /etc/pacman.conf
                    sudo pacman -Syu
                    packages=(steam steam-devices lutris vlc)
                fi
                if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
                    packages+=(gnome-tweaks)
                fi
                _install_
                get_heroic
                # flatpak setup
                flatpaks=(org.prismlauncher.PrismLauncher io.missioncenter.MissionCenter com.github.tchx84.Flatseal com.vysp3r.ProtonPlus com.dec05eba.gpu_screen_recorder com.github.Matoking.protontricks com.obsproject.Studio com.discordapp.Discord)
                if command -v apt &> /dev/null; then
                    flatpaks+=(com.valvesoftware.Steam)
                fi
                if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
                    flatpaks+=(com.mattjakeman.ExtensionManager)
                fi
                _flatpak_
                obs_pipe
                zenity --info --text "$msg036" --height=300 --width=300
            else
                nonfatal "$msg077"
            fi
        else
            nonfatal "$msg077"
        fi
    fi
fi