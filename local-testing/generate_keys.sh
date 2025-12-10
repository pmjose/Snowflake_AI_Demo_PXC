#!/bin/bash
# Generate RSA key pair for Snowflake service user authentication

echo "Generating RSA key pair for Snowflake..."

# Generate private key (PKCS8 format, no encryption for automation)
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out snowflake_key.p8 -nocrypt

# Generate public key
openssl rsa -in snowflake_key.p8 -pubout -out snowflake_key.pub

echo ""
echo "✅ Keys generated successfully!"
echo ""
echo "Files created:"
echo "  - snowflake_key.p8  (private key - KEEP SECRET!)"
echo "  - snowflake_key.pub (public key)"
echo ""
echo "📋 Public key for Snowflake (copy everything between the BEGIN/END lines):"
echo ""
cat snowflake_key.pub
echo ""
echo "Next steps:"
echo "1. Copy the public key content (without BEGIN/END lines)"
echo "2. Edit create_service_user.sql and paste the key"
echo "3. Run the SQL in Snowflake as ACCOUNTADMIN"

