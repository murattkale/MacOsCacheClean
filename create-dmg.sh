#!/bin/bash

# CacheCleaner DMG Oluşturma Script'i
# Bu script export edilmiş .app dosyasından DMG oluşturur

set -e

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Ayarlar
DMG_NAME="CacheCleaner"
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" CacheCleaner/Info.plist 2>/dev/null || echo "1.0")
BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" CacheCleaner/Info.plist 2>/dev/null || echo "1")

# .app dosyasını bul
APP_PATH="${1:-./build/export/CacheCleaner.app}"

if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}❌ .app dosyası bulunamadı: ${APP_PATH}${NC}"
    echo -e "${YELLOW}Kullanım: ./create-dmg.sh [.app yolu]${NC}"
    exit 1
fi

echo -e "${BLUE}💿 DMG oluşturuluyor...${NC}"
echo -e "${BLUE}Kaynak: ${APP_PATH}${NC}\n"

DMG_FINAL_NAME="${DMG_NAME}-v${VERSION}-${BUILD_NUMBER}.dmg"
DMG_TEMP_NAME="${DMG_NAME}-temp.dmg"
DMG_VOLUME_NAME="${DMG_NAME}"
EXPORT_PATH="./build/export"

# Geçici DMG klasörü
DMG_DIR="./build/dmg"
rm -rf "${DMG_DIR}"
mkdir -p "${DMG_DIR}"

# .app dosyasını kopyala
cp -R "${APP_PATH}" "${DMG_DIR}/"

# Applications klasörüne simlink oluştur
ln -s /Applications "${DMG_DIR}/Applications"

# DMG oluştur
hdiutil create -srcfolder "${DMG_DIR}" -volname "${DMG_VOLUME_NAME}" \
    -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW -size 200m "${EXPORT_PATH}/${DMG_TEMP_NAME}"

# DMG'yi mount et
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "${EXPORT_PATH}/${DMG_TEMP_NAME}" | \
    egrep '^/dev/' | sed 1q | awk '{print $1}')

sleep 2

# DMG görünümünü ayarla
VOLUME_PATH="/Volumes/${DMG_VOLUME_NAME}"
APP_NAME=$(basename "${APP_PATH}")

echo '
   tell application "Finder"
     tell disk "'${DMG_VOLUME_NAME}'"
           open
           set current view of container window to icon view
           set toolbar visible of container window to false
           set statusbar visible of container window to false
           set the bounds of container window to {400, 100, 920, 420}
           set viewOptions to the icon view options of container window
           set arrangement of viewOptions to not arranged
           set icon size of viewOptions to 72
           set position of item "'${APP_NAME}'" of container window to {160, 205}
           set position of item "Applications" of container window to {360, 205}
           close
           open
           update without registering applications
           delay 2
     end tell
   end tell
' | osascript

# DMG'yi unmount et
sync
hdiutil detach "${DEVICE}"

# DMG'yi sıkıştır
hdiutil convert "${EXPORT_PATH}/${DMG_TEMP_NAME}" -format UDZO -imagekey zlib-level=9 \
    -o "${EXPORT_PATH}/${DMG_FINAL_NAME}"

# Geçici dosyaları temizle
rm -f "${EXPORT_PATH}/${DMG_TEMP_NAME}"

echo -e "${GREEN}✅ DMG başarıyla oluşturuldu: ${EXPORT_PATH}/${DMG_FINAL_NAME}${NC}\n"

# Dosya boyutunu göster
DMG_SIZE=$(du -h "${EXPORT_PATH}/${DMG_FINAL_NAME}" | cut -f1)
echo -e "${BLUE}📦 DMG Boyutu: ${DMG_SIZE}${NC}"
echo -e "${BLUE}📁 Konum: ${EXPORT_PATH}/${DMG_FINAL_NAME}${NC}"

