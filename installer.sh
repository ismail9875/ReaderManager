#!/bin/sh
# =====================================================================
# install_reader_manager.sh
# ---------------------------------------------------------------------
# تثبيت إضافة ReaderManager على أجهزة Enigma2
# - يكتشف الأرشيفات التي تحتفظ بالمسار الكامل
# - يعيد تشغيل Enigma2 بأربع طرق متتالية
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
#  الإعدادات
# =====================================================================
PLUGIN_NAME="ReaderManager"
PLUGIN_PARENT="/usr/lib/enigma2/python/Plugins/Extensions"
PLUGIN_DIR="${PLUGIN_PARENT}/${PLUGIN_NAME}"
PLUGIN_REL_PATH="usr/lib/enigma2/python/Plugins/Extensions/${PLUGIN_NAME}"

DOWNLOAD_URL="https://github.com/ismail9875/ReaderManager/raw/refs/heads/main/ReaderManager.tar.gz"

TMP_DIR="/tmp/rm_install"
TMP_ARCHIVE="${TMP_DIR}/ReaderManager.tar.gz"
TMP_EXTRACT="${TMP_DIR}/extract"

# =====================================================================
#  دوال إعادة التشغيل
# =====================================================================
_restart_via_systemctl() {
    if ! command -v systemctl >/dev/null 2>&1; then
        return 1
    fi
    if ! systemctl list-units --type=service 2>/dev/null | \
         grep -q "enigma2"; then
        # حتى لو لم تكن الوحدة معروفة، حاول
        :
    fi
    info "Trying: systemctl restart enigma2"
    systemctl stop enigma2 2>/dev/null
    sleep 1
    systemctl start enigma2 2>/dev/null
    if systemctl is-active --quiet enigma2 2>/dev/null; then
        return 0
    fi
    return 1
}

_restart_via_init() {
    if ! command -v init >/dev/null 2>&1; then
        return 1
    fi
    info "Trying: init 4 && init 3"
    init 4 2>/dev/null
    sleep 2
    init 3 2>/dev/null
    sleep 2
    # نتحقق أن enigma2 يعمل
    if pidof enigma2 >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

_restart_via_killall() {
    info "Trying: killall -9 enigma2"
    if ! pidof enigma2 >/dev/null 2>&1; then
        # إن لم يكن يعمل، لا فائدة
        return 1
    fi
    killall -9 enigma2 2>/dev/null
    sleep 3
    if pidof enigma2 >/dev/null 2>&1; then
        return 0
    fi
    # بعض الأنظمة تعيد التشغيل عبر init تلقائياً
    return 0
}

restart_enigma2() {
    info "Restarting Enigma2..."

    # ① systemctl
    if _restart_via_systemctl; then
        ok "Enigma2 restarted via systemctl"
        return 0
    fi
    warn "systemctl method failed — trying init"

    # ② init 4 && init 3
    if _restart_via_init; then
        ok "Enigma2 restarted via init 4 && init 3"
        return 0
    fi
    warn "init method failed — trying killall"

    # ③ killall -9
    if _restart_via_killall; then
        ok "Enigma2 restarted via killall"
        return 0
    fi

    # ④ فشل الكل
    err "All restart methods failed"
    warn "Please restart manually:"
    printf "    ${C_GREEN}init 4 && init 3${C_RESET}\n"
    printf "    ${C_GREEN}reboot${C_RESET}\n"
    return 1
}

# =====================================================================
#  1) فحص البيئة
# =====================================================================
printf "\n${C_BLUE}=========================================================${C_RESET}\n"
printf "${C_BLUE}   ReaderManager Installer for Enigma2${C_RESET}\n"
printf "${C_BLUE}=========================================================${C_RESET}\n\n"

info "Checking Enigma2 environment..."

[ -d "/usr/lib/enigma2" ] || die "Not an Enigma2 device"
[ -d "${PLUGIN_PARENT}" ] || die "Plugins dir missing: ${PLUGIN_PARENT}"
ok "Enigma2 detected"

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
#  2) نسخة احتياطية
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
#  3) مجلد مؤقت
# =====================================================================
rm -rf "${TMP_DIR}"
mkdir -p "${TMP_EXTRACT}" || die "mkdir failed"
ok "Temp: ${TMP_DIR}"

# =====================================================================
#  4) التنزيل
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
#  5) استخراج
# =====================================================================
info "Extracting..."
if ! tar -xzf "${TMP_ARCHIVE}" -C "${TMP_EXTRACT}" 2>/dev/null; then
    die "Extraction failed"
fi
ok "Extracted"

# ─── عرض البنية ───
info "Extracted tree (max depth 5):"
find "${TMP_EXTRACT}" -maxdepth 5 -type d | head -20

# =====================================================================
#  6) اكتشاف جذر الإضافة
# =====================================================================
info "Locating plugin root..."

FOUND=""

# ① المسار الكامل المحفوظ
CANDIDATE="${TMP_EXTRACT}/${PLUGIN_REL_PATH}"
if [ -d "${CANDIDATE}" ] && [ -f "${CANDIDATE}/plugin.py" ]; then
    FOUND="${CANDIDATE}"
    ok "Found via full path"
fi

# ② المسار النسبي المختصر
if [ -z "${FOUND}" ]; then
    CANDIDATE="${TMP_EXTRACT}/usr/lib/enigma2/python/Plugins/Extensions/${PLUGIN_NAME}"
    if [ -d "${CANDIDATE}" ]; then
        FOUND="${CANDIDATE}"
        ok "Found via short relative path"
    fi
fi

# ③ find بمجلد باسم OscamReaderManager
if [ -z "${FOUND}" ]; then
    RESULT=$(find "${TMP_EXTRACT}" -type d -name "${PLUGIN_NAME}" 2>/dev/null | head -1)
    if [ -n "${RESULT}" ] && [ -f "${RESULT}/plugin.py" ]; then
        FOUND="${RESULT}"
        ok "Found via find (dir name)"
    fi
fi

# ④ أي plugin.py
if [ -z "${FOUND}" ]; then
    RESULT=$(find "${TMP_EXTRACT}" -name "plugin.py" -type f 2>/dev/null | head -1)
    if [ -n "${RESULT}" ]; then
        FOUND=$(dirname "${RESULT}")
        ok "Found via plugin.py search"
    fi
fi

# ⑤ مباشرة في الجذر
if [ -z "${FOUND}" ] && [ -f "${TMP_EXTRACT}/plugin.py" ]; then
    FOUND="${TMP_EXTRACT}"
    ok "Found at extract root"
fi

# ⑥ __init__.py
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
#  7) التثبيت
# =====================================================================
info "Installing to: ${PLUGIN_DIR}"

# ─── إيقاف Enigma2 قبل النسخ ───
ENIGMA_STOPPED=0

# ① systemctl
if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet enigma2 2>/dev/null; then
        systemctl stop enigma2 2>/dev/null
        ENIGMA_STOPPED=1
        ok "Enigma2 stopped (systemctl)"
    fi
fi

# ② init 4 إن لم يُوقف
if [ "${ENIGMA_STOPPED}" = "0" ] && pidof enigma2 >/dev/null 2>&1; then
    info "Stopping Enigma2 via init 4..."
    init 4 2>/dev/null
    sleep 2
    ENIGMA_STOPPED=1
    ok "Enigma2 stopped (init 4)"
fi

# حذف القديم
if [ -d "${PLUGIN_DIR}" ]; then
    rm -rf "${PLUGIN_DIR}" || die "Cannot remove old install"
fi

mkdir -p "${PLUGIN_PARENT}" || die "mkdir parent failed"

# نسخ
if ! cp -a "${FOUND}" "${PLUGIN_DIR}"; then
    err "Copy failed"
    if [ -n "${BACKUP_PATH}" ] && [ -d "${BACKUP_PATH}" ]; then
        warn "Restoring backup..."
        cp -a "${BACKUP_PATH}" "${PLUGIN_DIR}" 2>/dev/null
    fi
    # حاول إعادة تشغيل Enigma2 حتى لو فشل النسخ
    [ "${ENIGMA_STOPPED}" = "1" ] && restart_enigma2
    rm -rf "${TMP_DIR}" 2>/dev/null
    exit 1
fi
ok "Installed"

# =====================================================================
#  8) الصلاحيات
# =====================================================================
info "Setting permissions..."
find "${PLUGIN_DIR}" -type d -exec chmod 755 {} \; 2>/dev/null
find "${PLUGIN_DIR}" -type f -exec chmod 644 {} \; 2>/dev/null
find "${PLUGIN_DIR}" -name "*.sh" -exec chmod 755 {} \; 2>/dev/null
ok "Permissions set"

# =====================================================================
#  9) مسح .pyc
# =====================================================================
find "${PLUGIN_DIR}" -name "*.pyc" -delete 2>/dev/null
find "${PLUGIN_DIR}" -name "*.pyo" -delete 2>/dev/null
find "${PLUGIN_DIR}" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
ok "Bytecode cleared"

# =====================================================================
#  10) التحقق
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
#  11) إعادة تشغيل Enigma2
# =====================================================================
if [ "${ENIGMA_STOPPED}" = "1" ]; then
    restart_enigma2
else
    info "Enigma2 was not running — attempting to start..."
    # حاول تشغيله بالطرق المتاحة
    if ! _restart_via_init; then
        if ! _restart_via_systemctl; then
            warn "Could not start Enigma2 automatically"
            printf "    Start manually: ${C_GREEN}init 3${C_RESET}\n"
        fi
    fi
fi

# =====================================================================
#  12) تنظيف
# =====================================================================
rm -rf "${TMP_DIR}" 2>/dev/null
ok "Temp cleaned"

# =====================================================================
#  13) النتيجة
# =====================================================================
printf "\n${C_GREEN}=========================================================${C_RESET}\n"
printf "${C_GREEN}   Installation completed successfully${C_RESET}\n"
printf "${C_GREEN}=========================================================${C_RESET}\n\n"

printf "${C_CYAN}Plugin:${C_RESET}  ${PLUGIN_DIR}\n"
[ -n "${BACKUP_PATH}" ] && printf "${C_CYAN}Backup:${C_RESET}  ${BACKUP_PATH}\n"
printf "\n"

# ─── تحقق نهائي من عمل Enigma2 ───
sleep 2
if pidof enigma2 >/dev/null 2>&1; then
    ok "Enigma2 is running"
else
    warn "Enigma2 is NOT running"
    printf "  Try: ${C_GREEN}init 3${C_RESET}\n"
    printf "  Or:  ${C_GREEN}reboot${C_RESET}\n"
fi

printf "\n${C_YELLOW}If the plugin does not appear in the menu:${C_RESET}\n"
printf "  Restart Enigma2 manually:  ${C_GREEN}init 4 && init 3${C_RESET}\n"
printf "  Or reboot the device:      ${C_GREEN}reboot${C_RESET}\n\n"

exit 0