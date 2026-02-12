#!/bin/bash

# CacheCleaner Signing Setup Script
# Bu script Team ID'nizi bulur ve ExportOptions.plist'i günceller

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'

NC='\033[0m'

echo -e "${BLUE}🔍 Team ID ve Sertifika Kontrolü${NC}\n"

# Xcode'dan Team ID'yi bulmaya çalış
echo -e "${YELLOW}1. Xcode'dan Team ID aranıyor...${NC}"

# Xcode preferences'ten Team ID'yi bul
TEAM_ID=$(defaults read ~/Library/Preferences/com.apple.dt.Xcode.plist IDEProvisioningTeamIDs 2>/dev/null | grep -o '[A-Z0-9]\{10\}' | head -1)

if [ -z "$TEAM_ID" ]; then
    echo -e "${YELLOW}   Xcode preferences'ten Team ID bulunamadı.${NC}"
    echo -e "${YELLOW}   Alternatif yöntem deneniyor...${NC}"
    
    # Xcode projesinden Team ID'yi bulmaya çalış
    TEAM_ID=$(grep -r "DEVELOPMENT_TEAM" CacheCleaner.xcodeproj/project.pbxproj 2>/dev/null | head -1 | grep -o '[A-Z0-9]\{10\}' | head -1)
fi

if [ -z "$TEAM_ID" ]; then
    echo -e "${RED}❌ Team ID otomatik bulunamadı.${NC}\n"
    echo -e "${YELLOW}Manuel olarak Team ID'nizi bulmak için:${NC}"
    echo -e "${BLUE}1. Xcode'u açın${NC}"
    echo -e "${BLUE}2. Preferences > Accounts > Apple ID'nizi seçin${NC}"
    echo -e "${BLUE}3. Team ID'yi kopyalayın (10 karakterlik harf/rakam kombinasyonu)${NC}"
    echo -e "${BLUE}4. Veya: https://developer.apple.com/account > Membership${NC}\n"
    
    read -p "Team ID'nizi girin (10 karakter): " TEAM_ID
    
    if [ -z "$TEAM_ID" ] || [ ${#TEAM_ID} -ne 10 ]; then
        echo -e "${RED}❌ Geçersiz Team ID!${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Team ID bulundu: ${TEAM_ID}${NC}\n"
fi

# ExportOptions.plist'i güncelle
echo -e "${YELLOW}2. ExportOptions.plist güncelleniyor...${NC}"

if [ -f "ExportOptions.plist" ]; then
    /usr/libexec/PlistBuddy -c "Set :teamID ${TEAM_ID}" ExportOptions.plist
    echo -e "${GREEN}✅ ExportOptions.plist güncellendi${NC}\n"
else
    echo -e "${RED}❌ ExportOptions.plist bulunamadı!${NC}"
    exit 1
fi

# Developer ID Application sertifikasını kontrol et
echo -e "${YELLOW}3. Developer ID Application sertifikası kontrol ediliyor...${NC}"

CERTIFICATE=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1)

if [ -z "$CERTIFICATE" ]; then
    echo -e "${RED}❌ Developer ID Application sertifikası bulunamadı!${NC}\n"
    echo -e "${YELLOW}Sertifika oluşturmak için:${NC}"
    echo -e "${BLUE}1. Xcode'u açın${NC}"
    echo -e "${BLUE}2. Preferences > Accounts > Apple ID'nizi seçin${NC}"
    echo -e "${BLUE}3. 'Manage Certificates...' butonuna tıklayın${NC}"
    echo -e "${BLUE}4. '+' butonuna tıklayın${NC}"
    echo -e "${BLUE}5. 'Developer ID Application' seçin${NC}"
    echo -e "${BLUE}6. 'Done' butonuna tıklayın${NC}\n"
    echo -e "${YELLOW}Sertifika oluşturduktan sonra bu script'i tekrar çalıştırın.${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Developer ID Application sertifikası bulundu${NC}"
    echo -e "${BLUE}   ${CERTIFICATE}${NC}\n"
fi

echo -e "${GREEN}🎉 Signing setup tamamlandı!${NC}\n"
echo -e "${BLUE}Artık build-and-create-dmg.sh script'ini çalıştırabilirsiniz.${NC}"

