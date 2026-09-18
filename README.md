ReaderManager — OSCam & NCam Reader Management Plugin for Enigma2

<p align="center">
  <img src="https://img.shields.io/badge/Enigma2-Plugin-blue" alt="Enigma2 Plugin">
  <img src="https://img.shields.io/badge/Python-2.7%20%7C%203.x-green" alt="Python">
  <img src="https://img.shields.io/badge/License-GPL--3.0-orange" alt="License">
  <img src="https://img.shields.io/badge/Version-1.0-brightgreen" alt="Version">
</p>

---

📖 Overview

ReaderManager is a complete plugin for Enigma2 devices that lets you manage OSCam and NCam readers directly from a modern graphical interface — no more editing config files by hand or typing commands in a terminal.

It combines:

· Reader management via the OSCam / NCam WebIF
· Emulator management from /usr/bin
· Config file editing (oscam.server / ncam.server) with a simplified UI
· Card / CAID / Provider details viewer

All wrapped in a sleek dark interface designed for remote control navigation.

---

✨ Key Features

🎛️ Readers Manager

Feature Description
Reader table Label / Host / Port / ON-OFF / Protocol / Cards / Status in one view
Quick toggle Press OK to switch a reader between ON ↔ OFF
Add reader Green button opens a full reader creation form
Delete reader Yellow button removes the selected reader
Edit reader Blue button modifies the current reader
Circular scroll At the first/last reader, Up/Down wraps around
OSCam / NCam switch Left / Right arrows switch between the two files
Reader details Info button opens a full card/CAID view

🔧 Emulator Manager

Feature Description
Auto-discovery Scans /usr/bin for all OSCam / NCam binaries
Version detection From filename, -V execution, or /tmp version files
Init script lookup Automatically finds /etc/init.d/softcam.<name>-<version>
Individual control Start / Stop each emulator independently
Restart Dedicated restart button for the selected emulator only
Mutual exclusion Starting one emulator stops all others automatically
State display RUNNING / STOPPED for each emulator

📝 Reader Editor

· Two modes: Simple (basic fields) and Advanced (all fields)
· Automatic masking for Password / DES Key / AES Key / PIN
· Per-field help on Info press
· Instant validation before saving
· Full protocol support: cccam, newcamd, mgcamd, cs378x, camd35, gbox, radegast, mouse, smartreader, pcsc, internal, constcw, cacheex, emu

🎬 Reader View

· Displays all CAIDs grouped by encryption system (Viaccess, Irdeto, Conax, …)
· Shows Providers per CAID with card counts
· Distinct color per encryption system
· Column / row navigation with arrows
· Quick actions: Close / ON-OFF / Edit / Delete

---

📸 Screenshots

ReaderManager Main Screen

```
┌─────────────────────────────────────────────────────────────────┐
│  Reader Manager                                     [OSCAM LOGO]│
├─────────────────────────────────────────────────────────────────┤
│  Label      Host      Port   ON/OFF  Protocol  Cards   Status   │
├─────────────────────────────────────────────────────────────────┤
│  emulator   *****     0      ON      emu       -       -        │
│  server1    *****     12000  ON      cccam     3       CONNECTED│
│  server2    *****     34000  OFF     newcamd   -       -        │
├─────────────────────────────────────────────────────────────────┤
│  [ Exit ]    [ Add ]    [ Delete ]    [ Edit ]                  │
└─────────────────────────────────────────────────────────────────┘
```

Emulator Manager Screen

```
┌─────────────────────────────────────────────────────────────────┐
│  Emulator Manager                                  2/3 running  │
├─────────────────────────────────────────────────────────────────┤
│  Name           Family   Version   Init Script    State         │
├─────────────────────────────────────────────────────────────────┤
│  oscam-11966    OSCAM    11966     softcam.os...  RUNNING       │
│  oscam-11718    OSCAM    11718     softcam.os...  STOPPED       │
│  ncam-13.5      NCAM     13.5      softcam.nc...  STOPPED       │
├─────────────────────────────────────────────────────────────────┤
│  [ Close ]    [ Start/Stop ]    [ Refresh ]    [ Restart ]      │
└─────────────────────────────────────────────────────────────────┘
```

---

🚀 Installation

Method 1: One-liner (recommended)

```bash
wget -qO- https://raw.githubusercontent.com/ismail9875/ReaderManager/main/installer.sh | /bin/sh

```
Method 2: Manual

```bash
# 1. Download archive
cd /tmp
wget --no-check-certificate -O ReaderManager.tar.gz \
  "https://github.com/ismail9875/ReaderManager/raw/refs/heads/main/ReaderManager.tar.gz"

# 2. Extract
tar -xzf ReaderManager.tar.gz -C /tmp/

# 3. Copy to plugins directory
mkdir -p /usr/lib/enigma2/python/Plugins/Extensions/OscamReaderManager
cp -a /tmp/OscamReaderManager/* \
      /usr/lib/enigma2/python/Plugins/Extensions/OscamReaderManager/

# 4. Set permissions
chmod -R 755 /usr/lib/enigma2/python/Plugins/Extensions/OscamReaderManager

# 5. Restart Enigma2
init 4 && init 3
```

Method 3: Automated install script

Download install_reader_manager.sh from the repo and run:

```bash
sh /tmp/install_reader_manager.sh
```

The script auto-detects full-path archives, handles backups, and falls back to init 4 && init 3 if systemd fails.

---

🎮 Usage

Opening the plugin

Main Menu → Plugins → Readers Manager

or:

Main Menu → Extensions → Readers Manager Settings

ReaderManager key map

Key Action
OK Toggle reader state (ON ↔ OFF) + restart SoftCam
Red Exit
Green Add new reader
Yellow Delete selected reader
Blue Edit selected reader
Menu Open settings menu
Info View reader details (CAIDs / Providers)
EPG Open debug log
Left / Right Switch between OSCam / NCam
Up / Down Navigate readers (with circular scroll)

Emulator Manager key map

Key Action
OK / Green Start / Stop the selected emulator
Blue Restart the selected emulator
Yellow Re-scan /usr/bin
Red Exit
Up / Down Navigate emulators (circular scroll)

---

⚙️ Settings

General Settings

Option Values
Poll Interval 3 – 120 seconds
Sort readers Alphabetical / File order
Editor Mode Simple / Advanced
Auto restart after changes Yes / No
Restart delay Immediate / 1s / 3s / 5s / 10s
Confirm before restart Yes / No

OSCam WebIF Settings

Option Description
Enable Enable/disable OSCam API
Auto-detect Detect from oscam.version
WebIF URL e.g. http://127.0.0.1:8888
Username / Password Login credentials
Timeout 1 – 30 seconds

NCam WebIF Settings

Same options with default URL http://127.0.0.1:8181.

---

🌍 Supported Protocols

Protocol Description
cccam CCcam network
newcamd Newcamd with DES key
mgcamd MgCamd (NCam only)
cs378x Cache-Exchange TCP
camd35 Camd 3.5
gbox GBox
radegast Radegast
mouse Serial / USB card reader
smartreader Smargo / SmartReader
pcsc PC/SC reader
internal Internal reader (DreamBox)
constcw Constant CW file
cacheex Cache-Exchange
emu Emulator (SoftCam.Key)

---

🔒 Security

· Automatic masking of Password / DES Key / AES Key / PIN
· Automatic backups (.bak) before every write
· Atomic writes to prevent file corruption
· Double verification after writing (re-reads the file to confirm)
· No data is sent to external servers

---

🗂️ File Structure

```
/usr/lib/enigma2/python/Plugins/Extensions/OscamReaderManager/
├── __init__.py
├── plugin.py              ← Main entry point
├── reader_parser.py       ← .server file parser/writer
├── reader_dialog.py       ← Reader editor
├── reader_view.py         ← Reader details screen
├── oscamapi.py            ← OSCam WebIF client
├── ncamapi.py             ← NCam WebIF client
├── emu_manager.py         ← Emulator manager (from /usr/bin)
├── test_queue.py          ← Reader test queue
├── restart_oscam.py       ← OSCam restart helper
├── restart_ncam.py        ← NCam restart helper
├── field_help.py          ← Per-field help database
├── logger.py              ← Logging
├── paths.py               ← Path management
├── images/
│   ├── oscam.png
│   ├── ncam.png
│   └── plugin.png
└── cache/
    └── restart_methods.json  ← Successful restart method cache
```

---

🛠️ Requirements

Requirement Version
Enigma2 Any recent build
Python 2.7 or 3.x
OSCam or NCam Any recent version
Disk space ~2 MB
Image DreamOS, OpenATV, OpenPLi, OpenVision, BlackHole, …

---

🐛 Troubleshooting

Plugin doesn't appear in the menu

```bash
init 4 && init 3
```

OSCam WebIF not responding

1. Open Settings → OSCam WebIF Settings
2. Press Yellow to test the connection
3. Verify:
   · WebIF URL (http://127.0.0.1:8888)
   · Username and password
   · WebIF is enabled in oscam.conf

Emulator not detected

```bash
# Check binaries exist
ls -la /usr/bin/oscam* /usr/bin/ncam*

# Check init scripts
ls -la /etc/init.d/softcam.*
```

Auto-restart failed

Open the Debug Log screen to view attempt details. The successful method is cached in cache/restart_methods.json.

---

📊 Changelog

v1.0 (current)

· ✅ OSCam and NCam reader management
· ✅ Emulator management from /usr/bin
· ✅ Mutual exclusion (only one emulator active)
· ✅ Reader editor with Simple/Advanced modes
· ✅ Reader view with CAIDs and Providers
· ✅ Smart restart with 4 fallback methods
· ✅ Automatic masking of sensitive data
· ✅ Automatic backups
· ✅ Circular scrolling in all lists

---

🤝 Contributing

Contributions are welcome! You can:

1. Fork the repository
2. Create a feature branch: git checkout -b feature/my-feature
3. Commit your changes: git commit -am 'Add new feature'
4. Push to the branch: git push origin feature/my-feature
5. Open a Pull Request

Code standards

· Python 2.7 / 3.x compatibility
· Use from __future__ import in every file
· No external dependencies (only Enigma2 built-ins)
· Comments in English or Arabic
· Test on a real device before opening a PR

---

📄 License

This project is licensed under GPL-3.0 — see the LICENSE file for details.

---

🙏 Credits

· OSCam team for the great protocol
· NCam team for continuous support
· Enigma2 community for tools and help
· Everyone who tested the plugin

---

📞 Contact

Channel Link
GitHub ismail9875/ReaderManager
Issues Report a bug
Discussions Ask questions

---

<p align="center">
  <b>ReaderManager</b> — Professional OSCam & NCam reader management for Enigma2<br>
  <i>Made with ❤️ for the Enigma2 community</i>
</p>
