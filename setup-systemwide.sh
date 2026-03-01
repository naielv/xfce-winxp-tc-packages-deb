#!/usr/bin/env bash

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo ./setup-wintc-system.sh"
  exit 1
fi

echo "== WinTC System-Wide Setup =="

#################################
# SYSTEM-WIDE XFCE DEFAULTS
#################################

echo "Creating system-wide XFCE defaults..."

mkdir -p /etc/xdg/xfce4/xfconf/xfce-perchannel-xml

#################################
# xsettings (GTK, icons, fonts, sound)
#################################

cat > /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Windows XP Luna"/>
    <property name="IconThemeName" type="string" value="Windows XP Icons"/>
    <property name="EnableEventSounds" type="bool" value="true"/>
    <property name="EnableInputFeedbackSounds" type="bool" value="true"/>
    <property name="SoundThemeName" type="string" value="Windows XP Default"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="Tahoma 8"/>
    <property name="CursorThemeName" type="string" value="Windows XP Cursors"/>
  </property>
  <property name="Xft" type="empty">
    <property name="Antialias" type="int" value="1"/>
    <property name="HintStyle" type="string" value="hintfull"/>
  </property>
</channel>
EOF

#################################
# xfwm4 (window manager)
#################################

cat > /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="Windows XP"/>
    <property name="title_font" type="string" value="Tahoma Bold 8"/>
    <property name="title_alignment" type="string" value="left"/>
    <property name="button_layout" type="string" value="O|HMC"/>
    <property name="use_compositing" type="bool" value="false"/>
  </property>
</channel>
EOF

#################################
# KEYBOARD SHORTCUTS (default)
#################################

cat > /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-keyboard-shortcuts" version="1.0">
  <property name="commands" type="empty">
    <property name="custom" type="empty">
      <property name="<Super>r" type="string" value="run"/>
      <property name="<Alt>F1" type="string" value="wintc-taskband --start"/>
    </property>
  </property>
</channel>
EOF

#################################
# SYSTEM-WIDE AUTOSTART
#################################

echo "Creating system-wide autostart entries..."

mkdir -p /etc/xdg/autostart

cat > /etc/xdg/autostart/wintc-desktop.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=wintc-desktop
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=WinTC Desktop
EOF

cat > /etc/xdg/autostart/wintc-taskband.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=wintc-taskband
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=WinTC Taskband
EOF

cat > /etc/xdg/autostart/xcape.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=xcape -e 'Super_L=Alt_L|F1'
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Xcape Super Key Fix
EOF

#################################
# INSTALL Xcape
#################################

if command -v apt >/dev/null; then
  apt update
  apt install -y xcape
fi

#################################
# LIGHTDM GREETER
#################################

echo "Configuring LightDM..."

if [ -f /etc/lightdm/lightdm.conf ]; then
  sed -i 's/^#\?greeter-session=.*/greeter-session=wintc-logonui/' /etc/lightdm/lightdm.conf
else
  echo "LightDM config not found."
fi

#################################
# PLYMOUTH BOOT SPLASH
#################################

if command -v plymouth-set-default-theme >/dev/null; then
  sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/' /etc/default/grub
  plymouth-set-default-theme -R bootvid
  update-grub
fi

echo ""
echo "======================================"
echo "System-wide WinTC setup complete."
echo "Reboot required."
echo "======================================"
