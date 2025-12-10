#!/bin/bash
# Test Snowflake connection using the service user

echo "Testing Snowflake connection..."
echo ""

# Test connection
snow connection test -c telco-local

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Connection successful!"
    echo ""
    echo "Running verification queries..."
    echo ""
    
    # Verify user and role
    snow sql -c telco-local -q "SELECT CURRENT_USER() AS user, CURRENT_ROLE() AS role, CURRENT_WAREHOUSE() AS warehouse;"
    
    # List databases
    echo ""
    echo "Available databases:"
    snow sql -c telco-local -q "SHOW DATABASES LIKE 'TELCO%';"
else
    echo ""
    echo "❌ Connection failed!"
    echo ""
    echo "Troubleshooting:"
    echo "1. Check your account locator in ~/.snowflake/config.toml"
    echo "2. Verify the service user was created in Snowflake"
    echo "3. Confirm the public key was set correctly"
    echo "4. Check the private key path is correct"
fi

