# SSL Certificates

## For Local Development

Create self-signed certificates using OpenSSL:

### On Linux/Mac:
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout key.pem -out cert.pem -subj "/C=RU/ST=State/L=City/O=Bar/CN=localhost"
```

### On Windows (with OpenSSL installed):
```powershell
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout key.pem -out cert.pem -subj "/C=RU/ST=State/L=City/O=Bar/CN=localhost"
```

### On Windows (without OpenSSL):
You can use Git Bash (comes with Git for Windows) or install OpenSSL from:
- https://slproweb.com/products/Win32OpenSSL.html
- Or use Chocolatey: `choco install openssl`

Alternatively, you can generate certificates online or use mkcert:
```powershell
# Install mkcert (requires Chocolatey)
choco install mkcert

# Generate certificates
mkcert -install
mkcert localhost 127.0.0.1 ::1
```

## For Production (KeenDNS)

When deploying to production with KeenDNS:
1. KeenDNS will automatically provide SSL certificates
2. Place the certificates in this directory:
   - `cert.pem` - SSL certificate
   - `key.pem` - Private key
3. Restart nginx container

## Files Required

- `cert.pem` - SSL certificate
- `key.pem` - Private key

**Note**: These files are gitignored for security. Never commit real certificates to version control.
