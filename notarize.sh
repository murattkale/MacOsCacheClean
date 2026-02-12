#!/bin/bash

# CacheCleaner Notarization Script
# Bu script DMG dosyasını Apple'a notarize ettirir

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
DMG_PATH="${1:-./build/export/${DMG_NAME}-v${VERSION}-${BUILD_NUMBER}.dmg}"

if [ ! -f "$DMG_PATH" ]; then
    echo -e "${RED}❌ DMG dosyası bulunamadı: ${DMG_PATH}${NC}"
    echo -e "${YELLOW}Kullanım: ./notarize.sh [DMG yolu]${NC}"
    exit 1
fi

echo -e "${BLUE}🔐 Notarization başlatılıyor...${NC}"
echo -e "${BLUE}DMG: ${DMG_PATH}${NC}\n"

# Apple ID ve app-specific password kontrolü
if [ -z "$APPLE_ID" ]; then
    echo -e "${YELLOW}⚠️  APPLE_ID environment variable bulunamadı${NC}"
    echo -e "${YELLOW}Lütfen şu komutu çalıştırın:${NC}"
    echo -e "${BLUE}export APPLE_ID=\"your-apple-id@example.com\"${NC}"
    echo -e "${BLUE}export APPLE_APP_PASSWORD=\"your-app-specific-password\"${NC}"
    exit 1
fi

if [ -z "$APPLE_APP_PASSWORD" ]; then
    echo -e "${YELLOW}⚠️  APPLE_APP_PASSWORD environment variable bulunamadı${NC}"
    echo -e "${YELLOW}App-specific password oluşturmak için:${NC}"
    echo -e "${BLUE}https://appleid.apple.com -> Sign-In and Security -> App-Specific Passwords${NC}"
    exit 1
fi

# Team ID kontrolü (ExportOptions.plist'ten al)
TEAM_ID=$(/usr/libexec/PlistBuddy -c "Print teamID" ExportOptions.plist 2>/dev/null || echo "")

if [ -z "$TEAM_ID" ] || [ "$TEAM_ID" == "YOUR_TEAM_ID" ]; then
    echo -e "${YELLOW}⚠️  Team ID bulunamadı. ExportOptions.plist dosyasını kontrol edin.${NC}"
    exit 1
fi

echo -e "${YELLOW}📤 DMG Apple'a gönderiliyor...${NC}"

# Notarization gönder
NOTARIZE_OUTPUT=$(xcrun notarytool submit "$DMG_PATH" \
    --apple-id "$APPLE_ID" \
    --password "$APPLE_APP_PASSWORD" \
    --team-id "$TEAM_ID" \
    --wait \
    --timeout 30m 2>&1)

SUBMISSION_ID=$(echo "$NOTARIZE_OUTPUT" | grep -i "id:" | head -1 | awk '{print $NF}')

if [ -z "$SUBMISSION_ID" ]; then
    echo -e "${RED}❌ Notarization başlatılamadı!${NC}"
    echo "$NOTARIZE_OUTPUT"
    exit 1
fi

echo -e "${GREEN}✅ Notarization başlatıldı. Submission ID: ${SUBMISSION_ID}${NC}\n"

# Durum kontrolü
echo -e "${YELLOW}⏳ Notarization durumu kontrol ediliyor...${NC}"

xcrun notarytool log "$SUBMISSION_ID" \
    --apple-id "$APPLE_ID" \
    --password "$APPLE_APP_PASSWORD" \
    --team-id "$TEAM_ID"

# Notarization durumunu kontrol et
STATUS=$(xcrun notarytool info "$SUBMISSION_ID" \
    --apple-id "$APPLE_ID" \
    --password "$APPLE_APP_PASSWORD" \
    --team-id "$TEAM_ID" 2>&1 | grep -i "status:" | awk '{print $NF}')

if [ "$STATUS" == "Accepted" ]; then
    echo -e "${GREEN}✅ Notarization başarıyla tamamlandı!${NC}"
    
    # DMG'yi staple et (opsiyonel, sadece .app için gerekli)
    echo -e "${YELLOW}📎 DMG'ye notarization bilgisi ekleniyor...${NC}"
    xcrun stapler staple "$DMG_PATH" 2>/dev/null || echo -e "${YELLOW}⚠️  Stapler çalıştırılamadı (DMG için normal)${NC}"
    
    echo -e "${GREEN}🎉 DMG notarize edildi ve dağıtıma hazır!${NC}"
    echo -e "${BLUE}📁 DMG: ${DMG_PATH}${NC}"
else
    echo -e "${RED}❌ Notarization başarısız! Durum: ${STATUS}${NC}"
    exit 1
fi

