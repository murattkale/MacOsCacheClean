#!/bin/bash

# Developer ID Application Sertifikası - Terminal Komutları

echo "=== 1. Mevcut Sertifikaları Kontrol Et ==="
security find-identity -v -p codesigning | grep "Developer ID Application"

echo ""
echo "=== 2. Eğer sertifika yoksa, CSR oluştur: ==="
echo ""
echo "Aşağıdaki komutları sırayla çalıştırın:"
echo ""
echo "# Private key oluştur:"
echo "openssl genrsa -out ~/Desktop/private_key.pem 2048"
echo ""
echo "# CSR oluştur (EMAIL ve NAME değerlerini değiştirin):"
echo "openssl req -new -key ~/Desktop/private_key.pem -out ~/Desktop/certificate_request.csr \\"
echo "  -subj \"/CN=Developer ID Application: YOUR_NAME/emailAddress=YOUR_EMAIL@example.com\""
echo ""
echo "# CSR içeriğini göster:"
echo "cat ~/Desktop/certificate_request.csr"
echo ""
echo "=== 3. Sonraki Adımlar ==="
echo "1. https://developer.apple.com/account/resources/certificates/list adresine gidin"
echo "2. '+' butonuna tıklayın"
echo "3. 'Developer ID Application' seçin"
echo "4. Oluşturulan CSR dosyasını (~/Desktop/certificate_request.csr) yükleyin"
echo "5. Sertifikayı indirin ve çift tıklayarak Keychain'e ekleyin"
echo ""
echo "=== 4. Sertifikayı ekledikten sonra kontrol et: ==="
echo "security find-identity -v -p codesigning | grep 'Developer ID Application'"

