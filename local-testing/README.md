# Local Testing Setup

This folder is excluded from git and contains credentials for local testing.

## Files in this folder

- `generate_keys.sh` - Script to generate RSA key pair
- `create_service_user.sql` - SQL to create the service user in Snowflake
- `config.toml.example` - Example Snowflake CLI configuration
- `snowflake_key.p8` - Your private key (generated, DO NOT COMMIT)
- `snowflake_key.pub` - Your public key (generated)

## Quick Start

### 1. Generate Keys

```bash
chmod +x generate_keys.sh
./generate_keys.sh
```

### 2. Create Service User in Snowflake

1. Copy the public key from `snowflake_key.pub`
2. Open `create_service_user.sql` and paste the public key
3. Run the SQL in Snowflake as ACCOUNTADMIN

### 3. Configure Snowflake CLI

```bash
# Copy example config
cp config.toml.example ~/.snowflake/config.toml

# Edit with your account details
nano ~/.snowflake/config.toml
```

### 4. Test Connection

```bash
snow connection test -c telco-local
```

### 5. Run SQL

```bash
snow sql -c telco-local -q "SELECT CURRENT_USER(), CURRENT_ROLE();"
```

## Security Notes

⚠️ **NEVER commit private keys or credentials to git!**

This folder is in `.gitignore` to prevent accidental commits.

