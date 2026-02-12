#!/bin/bash

# Developer ID Application Sertifikası Oluşturma Script'i
# Bu script sertifikayı kontrol eder ve oluşturma adımlarını gösterir

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔐 Developer ID Application Sertifikası Kontrolü${NC}\n"

# Mevcut sertifikaları kontrol et
echo -e "${YELLOW}1. Mevcut sertifikalar kontrol ediliyor...${NC}"

CERTIFICATES=$(security find-identity -v -p codesigning 2>/dev/null | grep "Developer ID Application" || true)

if [ -z "$CERTIFICATES" ]; then
    echo -e "${RED}❌ Developer ID Application sertifikası bulunamadı${NC}\n"
    
    echo -e "${YELLOW}Developer ID Application sertifikası oluşturmak için iki yöntem var:${NC}\n"
    
    echo -e "${BLUE}Yöntem 1: Xcode'dan (Önerilen - En Kolay)${NC}"
    echo -e "1. Xcode'u açın"
    echo -e "2. Preferences (⌘,) > Accounts"
    echo -e "3. Apple ID'nizi seçin"
    echo -e "4. 'Manage Certificates...' butonuna tıklayın"
    echo -e "5. '+' butonuna tıklayın"
    echo -e "6. 'Developer ID Application' seçin"
    echo -e "7. 'Done' butonuna tıklayın\n"
    
    echo -e "${BLUE}Yöntem 2: Terminal'den CSR ile (Gelişmiş)${NC}"
    echo -e "Bu yöntem için Apple Developer hesabınıza giriş yapmanız gerekecek.\n"
    
    read -p "CSR ile oluşturmak ister misiniz? (y/n): " CREATE_CSR
    
    if [ "$CREATE_CSR" == "y" ] || [ "$CREATE_CSR" == "Y" ]; then
        echo -e "\n${YELLOW}CSR oluşturuluyor...${NC}"
        
        # Keychain'de private key oluştur
        KEY_NAME="Developer ID Application"
        KEYCHAIN="login.keychain"
        
        # Private key oluştur
        echo -e "${BLUE}Private key oluşturuluyor...${NC}"
        openssl genrsa -out /tmp/private_key.pem 2048 2>/dev/null || {
            echo -e "${RED}❌ Private key oluşturulamadı${NC}"
            exit 1
        }
        
        # CSR oluştur
        echo -e "${BLUE}CSR (Certificate Signing Request) oluşturuluyor...${NC}"
        
        read -p "E-posta adresiniz: " EMAIL
        read -p "Adınız: " NAME
        
        openssl req -new -key /tmp/private_key.pem -out /tmp/certificate_request.csr \
            -subj "/CN=Developer ID Application: ${NAME}/emailAddress=${EMAIL}" 2>/dev/null || {
            echo -e "${RED}❌ CSR oluşturulamadı${NC}"
            rm -f /tmp/private_key.pem /tmp/certificate_request.csr
            exit 1
        }
        
        echo -e "${GREEN}✅ CSR oluşturuldu: /tmp/certificate_request.csr${NC}\n"
        echo -e "${YELLOW}Şimdi yapmanız gerekenler:${NC}"
        echo -e "1. https://developer.apple.com/account/resources/certificates/list adresine gidin"
        echo -e "2. '+' butonuna tıklayın"
        echo -e "3. 'Developer ID Application' seçin"
        echo -e "4. Oluşturulan CSR dosyasını yükleyin: /tmp/certificate_request.csr"
        echo -e "5. Sertifikayı indirin ve çift tıklayarak Keychain'e ekleyin\n"
        
        echo -e "${BLUE}CSR dosyası: /tmp/certificate_request.csr${NC}"
        echo -e "${BLUE}Private key: /tmp/private_key.pem (GÜVENLİ TUTUN!)${NC}\n"
        
        read -p "Sertifikayı indirdiniz ve Keychain'e eklediniz mi? (y/n): " CERT_ADDED
        
        if [ "$CERT_ADDED" == "y" ] || [ "$CERT_ADDED" == "Y" ]; then
            # Sertifikayı kontrol et
            sleep 2
            CERTIFICATES=$(security find-identity -v -p codesigning 2>/dev/null | grep "Developer ID Application" || true)
            
            if [ -z "$CERTIFICATES" ]; then
                echo -e "${RED}❌ Sertifika hala bulunamadı. Keychain'e doğru eklendiğinden emin olun.${NC}"
                exit 1
            else
                echo -e "${GREEN}✅ Sertifika başarıyla eklendi!${NC}"
                echo -e "${BLUE}${CERTIFICATES}${NC}\n"
                
                # Private key'i temizle (güvenlik için)
                read -p "Private key dosyasını silmek ister misiniz? (y/n): " CLEANUP
                if [ "$CLEANUP" == "y" ] || [ "$CLEANUP" == "Y" ]; then
                    rm -f /tmp/private_key.pem
                    echo -e "${GREEN}✅ Private key temizlendi${NC}"
                fi
            fi
        else
            echo -e "${YELLOW}Sertifikayı ekledikten sonra bu script'i tekrar çalıştırın.${NC}"
        fi
    else
        echo -e "${YELLOW}Xcode'dan oluşturmayı tercih ediyorsunuz.${NC}"
        echo -e "${BLUE}Yukarıdaki adımları takip edin ve script'i tekrar çalıştırın.${NC}"
    fi
else
    echo -e "${GREEN}✅ Developer ID Application sertifikası bulundu!${NC}"
    echo -e "${BLUE}${CERTIFICATES}${NC}\n"
    echo -e "${GREEN}🎉 Sertifika hazır! Artık build-and-create-dmg.sh script'ini çalıştırabilirsiniz.${NC}"
fi

