#!/bin/sh
# =====================================================================
# install_reader_manager.sh
# ---------------------------------------------------------------------
# ReaderManager installation script for Enigma2 devices
#
# Features:
#   - Detects the correct Enigma2 restart method ONCE at startup
#   - Uses it directly instead of trying all methods sequentially
#   - Handles archives that preserve full paths
#   - Automatic backup & restore on failure
# =====================================================================

if [ -t 1 ]; then
    C_RED="\033[1;31m"; C_GREEN="\033[1;32m"; C_YELLOW="\033[1;33m"
    C_BLUE="\033[1;34m"; C_CYAN="\033[1;36m"; C_RESET="\033[0m"
else
    C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_CYAN=""; C_RESET=""
fi

info() { printf "${C_CYAN}[INFO]${C_RESET}  %s\n" "$1"; }
ok()   { printf "${C_GREEN}[ OK ]${C_RESET}  %s\n" "$1"; }
warn() { printf "${C_YELLOW}[WARN]${C_RESET}  %s\n" "$1"; }
err()  { printf "${C_RED}[FAIL]${C_RESET}  %s\n" "$1"; }
die()  { err "$1"; exit 1; }

# =====================================================================
#  Configuration
# =====================================================================
PLUGIN_NAME="ReaderManager"
PLUGIN_PARENT="/usr/lib/enigma2/python/Plugins/Extensions"
PLUGIN_DIR="${PLUGIN_PARENT}/${PLUGIN_NAME}"
PLUGIN_REL_PATH="usr/lib/enigma2/python/Plugins/Extensions/${PLUGIN_NAME}"

DOWNLOAD_URL="https://github.com/ismail9875/ReaderManager/raw/refs/heads/main/ReaderManager.tar.gz"

TMP_DIR="/tmp/rm_install"
TMP_ARCHIVE="${TMP_DIR}/ReaderManager.tar.gz"
TMP_EXTRACT="${TMP_DIR}/extract"

# Global: restart method detected at startup
RESTART_METHOD=""      # "systemd" | "init" | "killall" | "unknown"
RESTART_CMD_STOP=""
RESTART_CMD_START=""

# =====================================================================
#  Restart method detection (runs ONCE at startup)
# =====================================================================
detect_restart_method() {
    info "Detecting Enigma2 restart method..."

    # ─── Priority 1: systemd ───
    if command -v systemctl >/dev/null 2>&1; then
        # Check if enigma2 is a known systemd unit
        if systemctl list-unit-files 2>/dev/null | \
             grep -q "^enigma2\."; then
            RESTART_METHOD="systemd"
            RESTART_CMD_STOP="systemctl stop enigma2"
            RESTART_CMD_START="systemctl start enigma2"
            ok "Restart method: systemd"
            return 0
        fi
    fi

    # ─── Priority 2: init (Enigma2 classic) ───
    if command -v init >/dev/null 2>&1; then
        # Verify that 'init' responds (some minimal systems don't support runlevels)
        if init --help >/dev/null 2>&1 || [ -x /sbin/init ]; then
            RESTART_METHOD="init"
            RESTART_CMD_STOP="init 4"
            RESTART_CMD_START="init 3"
            ok "Restart method: init (runlevel 4/3)"
            return 0
        fi
    fi

    # ─── Priority 3: killall (last resort) ───
    if command -v killall >/dev/null 2>&1; then
        RESTART_METHOD="killall"
        RESTART_CMD_STOP="killall -9 enigma2"
        RESTART_CMD_START=""    # killall relies on init to auto-restart
        ok "Restart method: killall -9"
        return 0
    fi

    # ─── Nothing worked ───
    RESTART_METHOD="unknown"
    warn "Could not detect a restart method"
    return 1
}

# =====================================================================
#  Stop Enigma2 (using detected method)
# =====================================================================
stop_enigma2() {
    # If not running, nothing to do
    if ! pidof enigma2 >/dev/null 2>&1; then
        info "Enigma2 is not running"
        return 1   # Return 1 = was not running
    fi

    info "Stopping Enigma2 via ${RESTART_METHOD}..."

    case "${RESTART_METHOD}" in
        systemd)
            systemctl stop enigma2 2>/dev/null
            ;;
        init)
            init 4 2>/dev/null
            ;;
        killall)
            killall -9 enigma2 2>/dev/null
            ;;
        *)
            # Fallback chain (only reached if detection failed)
            init 4 2>/dev/null || killall -9 enigma2 2>/dev/null
            ;;
    esac

    # Wait up to 5 seconds for Enigma2 to actually stop
    WAIT=0
    while [ "${WAIT}" -lt 10 ]; do
        if ! pidof enigma2 >/dev/null 2>&1; then
            ok "Enigma2 stopped"
            return 0   # Return 0 = was running, now stopped
        fi
        sleep 0.5
        WAIT=$((WAIT + 1))
    done

    warn "Enigma2 did not stop within 5 seconds"
    return 0
}

# =====================================================================
#  Start Enigma2 (using detected method)
# =====================================================================
start_enigma2() {
    info "Starting Enigma2 via ${RESTART_METHOD}..."

    case "${RESTART_METHOD}" in
        systemd)
            systemctl start enigma2 2>/dev/null
            ;;
        init)
            init 3 2>/dev/null
            ;;
        killall)
            # killall method relies on init to auto-restart
            # If nothing auto-starts it, we try init 3
            init 3 2>/dev/null || true
            ;;
        *)
            init 3 2>/dev/null || true
            ;;
    esac

    # Wait up to 10 seconds for Enigma2 to come back
    WAIT=0
    while [ "${WAIT}" -lt 20 ]; do
        if pidof enigma2 >/dev/null 2>&1; then
            ok "Enigma2 started"
            return 0
        fi
        sleep 0.5
        WAIT=$((WAIT + 1))
    done

    err "Enigma2 did not start within 10 seconds"
    return 1
}

# =====================================================================
#  Full restart (stop + start)
# =====================================================================
restart_enigma2() {
    info "Restarting Enigma2..."

    # Stop
    WAS_RUNNING=0
    if stop_enigma2; then
        WAS_RUNNING=1
    fi

    # Small delay between stop/start
    sleep 1

    # Start
    if [ "${WAS_RUNNING}" = "1" ] || [ "${RESTART_METHOD}" = "init" ]; then
        start_enigma2
    else
        # Enigma2 wasn't running and we're not on init → try to start it anyway
        start_enigma2
    fi
}

# =====================================================================
#  1) Detect environment & restart method FIRST
# =====================================================================
printf "\n${C_BLUE}=========================================================${C_RESET}\n"
printf "${C_BLUE}   ReaderManager Installer for Enigma2${C_RESET}\n"
printf "${C_BLUE}=========================================================${C_RESET}\n\n"

info "Checking Enigma2 environment..."
[ -d "/usr/lib/enigma2" ] || die "Not an Enigma2 device"
[ -d "${PLUGIN_PARENT}" ] || die "Plugins dir missing: ${PLUGIN_PARENT}"
ok "Enigma2 detected"

# ─── Detect restart method EARLY ───
detect_restart_method || warn "Will use fallback methods at restart time"

# ─── Download tool ───
if command -v wget >/dev/null 2>&1; then
    DL="wget"
elif command -v curl >/dev/null 2>&1; then
    DL="curl"
else
    die "No wget/curl available"
fi
ok "Downloader: ${DL}"

command -v tar >/dev/null 2>&1 || die "tar not found"
command -v gzip >/dev/null 2>&1 || die "gzip not found"

# =====================================================================
#  2) Backup existing installation
# =====================================================================
BACKUP_PATH=""
if [ -d "${PLUGIN_DIR}" ]; then
    BACKUP_PATH="/tmp/${PLUGIN_NAME}.bak.$(date +%Y%m%d_%H%M%S)"
    info "Backing up existing install..."
    if cp -a "${PLUGIN_DIR}" "${BACKUP_PATH}" 2>/dev/null; then
        ok "Backup: ${BACKUP_PATH}"
    else
        warn "Backup failed"
        BACKUP_PATH=""
    fi
fi

# =====================================================================
#  3) Prepare temp directory
# =====================================================================
rm -rf "${TMP_DIR}"
mkdir -p "${TMP_EXTRACT}" || die "mkdir failed"
ok "Temp: ${TMP_DIR}"

# =====================================================================
#  4) Download
# =====================================================================
info "Downloading..."
info "  ${DOWNLOAD_URL}"

cd "${TMP_DIR}" || die "cd failed"

if [ "${DL}" = "wget" ]; then
    wget --no-check-certificate --timeout=30 --tries=3 \
         -O "${TMP_ARCHIVE}" "${DOWNLOAD_URL}"
    RC=$?
else
    curl -k -L --connect-timeout 30 --max-time 180 \
         -o "${TMP_ARCHIVE}" "${DOWNLOAD_URL}"
    RC=$?
fi

[ ${RC} -eq 0 ] && [ -f "${TMP_ARCHIVE}" ] || die "Download failed"

SIZE=$(wc -c < "${TMP_ARCHIVE}" 2>/dev/null)
info "Size: ${SIZE} bytes"

[ "${SIZE}" -ge 2048 ] || {
    err "File too small (likely 404 HTML)"
    head -c 200 "${TMP_ARCHIVE}"
    printf "\n"
    die "Aborting"
}

gzip -t "${TMP_ARCHIVE}" 2>/dev/null || die "Corrupted gzip"
ok "Archive valid"

# =====================================================================
#  5) Extract
# =====================================================================
info "Extracting..."
tar -xzf "${TMP_ARCHIVE}" -C "${TMP_EXTRACT}" 2>/dev/null || \
    die "Extraction failed"
ok "Extracted"

info "Extracted tree (max depth 5):"
find "${TMP_EXTRACT}" -maxdepth 5 -type d | head -20

# =====================================================================
#  6) Locate plugin root (multi-strategy)
# =====================================================================
info "Locating plugin root..."

FOUND=""

# Strategy 1: preserved full path
CANDIDATE="${TMP_EXTRACT}/${PLUGIN_REL_PATH}"
if [ -d "${CANDIDATE}" ] && [ -f "${CANDIDATE}/plugin.py" ]; then
    FOUND="${CANDIDATE}"
    ok "Found via full path"
fi

# Strategy 2: short relative path
if [ -z "${FOUND}" ]; then
    CANDIDATE="${TMP_EXTRACT}/usr/lib/enigma2/python/Plugins/Extensions/${PLUGIN_NAME}"
    if [ -d "${CANDIDATE}" ]; then
        FOUND="${CANDIDATE}"
        ok "Found via short relative path"
    fi
fi

# Strategy 3: find by directory name
if [ -z "${FOUND}" ]; then
    RESULT=$(find "${TMP_EXTRACT}" -type d -name "${PLUGIN_NAME}" 2>/dev/null | head -1)
    if [ -n "${RESULT}" ] && [ -f "${RESULT}/plugin.py" ]; then
        FOUND="${RESULT}"
        ok "Found via find (dir name)"
    fi
fi

# Strategy 4: find any plugin.py
if [ -z "${FOUND}" ]; then
    RESULT=$(find "${TMP_EXTRACT}" -name "plugin.py" -type f 2>/dev/null | head -1)
    if [ -n "${RESULT}" ]; then
        FOUND=$(dirname "${RESULT}")
        ok "Found via plugin.py search"
    fi
fi

# Strategy 5: files at extract root
if [ -z "${FOUND}" ] && [ -f "${TMP_EXTRACT}/plugin.py" ]; then
    FOUND="${TMP_EXTRACT}"
    ok "Found at extract root"
fi

# Strategy 6: __init__.py fallback
if [ -z "${FOUND}" ]; then
    RESULT=$(find "${TMP_EXTRACT}" -name "__init__.py" -type f 2>/dev/null | \
             grep -i "reader" | head -1)
    if [ -n "${RESULT}" ]; then
        FOUND=$(dirname "${RESULT}")
        ok "Found via __init__.py"
    fi
fi

if [ -z "${FOUND}" ] || [ ! -d "${FOUND}" ]; then
    err "Cannot locate plugin directory"
    info "Full extracted structure:"
    find "${TMP_EXTRACT}" -type f | head -50
    rm -rf "${TMP_DIR}" 2>/dev/null
    exit 1
fi

if [ ! -f "${FOUND}/plugin.py" ]; then
    err "plugin.py NOT found in ${FOUND}"
    ls -la "${FOUND}"
    rm -rf "${TMP_DIR}" 2>/dev/null
    exit 1
fi

ok "Plugin root: ${FOUND}"

# =====================================================================
#  7) Install
# =====================================================================
info "Installing to: ${PLUGIN_DIR}"

# ─── Stop Enigma2 using detected method ───
ENIGMA_WAS_RUNNING=0
if stop_enigma2; then
    ENIGMA_WAS_RUNNING=1
fi

# Remove old install
if [ -d "${PLUGIN_DIR}" ]; then
    rm -rf "${PLUGIN_DIR}" || {
        err "Cannot remove old install"
        [ "${ENIGMA_WAS_RUNNING}" = "1" ] && start_enigma2
        exit 1
    }
fi

mkdir -p "${PLUGIN_PARENT}" || die "mkdir parent failed"

# Copy
if ! cp -a "${FOUND}" "${PLUGIN_DIR}"; then
    err "Copy failed"
    if [ -n "${BACKUP_PATH}" ] && [ -d "${BACKUP_PATH}" ]; then
        warn "Restoring backup..."
        cp -a "${BACKUP_PATH}" "${PLUGIN_DIR}" 2>/dev/null
    fi
    [ "${ENIGMA_WAS_RUNNING}" = "1" ] && start_enigma2
    rm -rf "${TMP_DIR}" 2>/dev/null
    exit 1
fi
ok "Installed"

# =====================================================================
#  8) Permissions
# =====================================================================
info "Setting permissions..."
find "${PLUGIN_DIR}" -type d -exec chmod 755 {} \; 2>/dev/null
find "${PLUGIN_DIR}" -type f -exec chmod 644 {} \; 2>/dev/null
find "${PLUGIN_DIR}" -name "*.sh" -exec chmod 755 {} \; 2>/dev/null
ok "Permissions set"

# =====================================================================
#  9) Clear bytecode cache
# =====================================================================
find "${PLUGIN_DIR}" -name "*.pyc" -delete 2>/dev/null
find "${PLUGIN_DIR}" -name "*.pyo" -delete 2>/dev/null
find "${PLUGIN_DIR}" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
ok "Bytecode cleared"

# =====================================================================
#  10) Verify
# =====================================================================
info "Final verification..."
echo ""
ls -la "${PLUGIN_DIR}"
echo ""

CORE_MISSING=""
for f in plugin.py reader_parser.py paths.py logger.py; do
    [ -f "${PLUGIN_DIR}/${f}" ] || CORE_MISSING="${CORE_MISSING} ${f}"
done

if [ -n "${CORE_MISSING}" ]; then
    warn "Missing:${CORE_MISSING}"
else
    ok "All core files present"
fi

# =====================================================================
#  11) Restart Enigma2 using detected method
# =====================================================================
if [ "${ENIGMA_WAS_RUNNING}" = "1" ]; then
    restart_enigma2
else
    info "Enigma2 was not running before install"
    # Try to start it
    start_enigma2 || warn "Start Enigma2 manually: ${RESTART_CMD_START}"
fi

# =====================================================================
#  12) Cleanup
# =====================================================================
rm -rf "${TMP_DIR}" 2>/dev/null
ok "Temp cleaned"

# =====================================================================
#  13) Result
# =====================================================================
printf "\n${C_GREEN}=========================================================${C_RESET}\n"
printf "${C_GREEN}   Installation completed successfully${C_RESET}\n"
printf "${C_GREEN}=========================================================${C_RESET}\n\n"

printf "${C_CYAN}Plugin:${C_RESET}          ${PLUGIN_DIR}\n"
printf "${C_CYAN}Restart method:${C_RESET}  ${RESTART_METHOD}\n"
[ -n "${BACKUP_PATH}" ] && printf "${C_CYAN}Backup:${C_RESET}          ${BACKUP_PATH}\n"
printf "\n"

# ─── Final Enigma2 check ───
sleep 2
if pidof enigma2 >/dev/null 2>&1; then
    ok "Enigma2 is running"
else
    warn "Enigma2 is NOT running"
    printf "  Try: ${C_GREEN}%s${C_RESET}\n" "${RESTART_CMD_START:-init 3}"
    printf "  Or:  ${C_GREEN}reboot${C_RESET}\n"
fi

printf "\n${C_YELLOW}If the plugin does not appear in the menu:${C_RESET}\n"
printf "  Restart Enigma2 manually with your system method\n"
printf "  Or reboot the device:  ${C_GREEN}reboot${C_RESET}\n\n"

exit 0
