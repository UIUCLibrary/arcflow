# Local ArcLight Solr Setup Complete!

Thank you for your patience. I've created a complete Docker-based setup for running ArcLight Solr locally for testing.

## What Was Created

### 1. Docker Configuration (`docker-compose.yml`)
- Runs Solr 8.11.2 (compatible with ArcLight)
- Exposes Solr on port 8983
- Persists data in a Docker volume
- Supports custom Solr configuration via the `solr-config/` directory

### 2. Documentation
- **`docs/LOCAL_SOLR_SETUP.md`** - Complete setup guide with:
  - Three options for getting ArcLight Solr configuration
  - Instructions for cloning data from your remote dev Solr
  - Using the local Solr with arcflow
  - Troubleshooting tips

- **`docs/SOLR_QUICK_REFERENCE.md`** - Quick command reference for:
  - Daily operations (start/stop/logs)
  - Data management
  - Common troubleshooting steps

### 3. Automation Script (`scripts/setup-local-solr.sh`)
- Interactive setup script that:
  - Checks prerequisites
  - Helps you get ArcLight Solr configuration
  - Starts the local Solr instance
  - Waits for Solr to be ready
  - Supports both Docker Compose v1 and v2

### 4. Configuration Template (`.env.example`)
- Template for managing configuration
- Documents all available options

## How to Use It

### Quick Start

```bash
# 1. Get the Solr configuration (choose one option):

# Option A: From your local Arcuit installation
cd /path/to/arcuit
ARCLIGHT_PATH=$(bundle show arclight)
cp -r "${ARCLIGHT_PATH}/solr/config" /path/to/arcflow/solr-config

# Option B: Clone from ArcLight repository
cd /tmp
git clone --depth 1 https://github.com/projectblacklight/arclight.git
cp -r arclight/solr/config /path/to/arcflow/solr-config
rm -rf arclight

# Option C: Use the automated setup script (recommended)
./scripts/setup-local-solr.sh

# 2. Start Solr
docker compose up -d

# 3. Verify it's working
curl http://localhost:8983/solr/admin/cores?action=STATUS

# 4. Use with arcflow
python arcflow/main.py \
  --arclight-dir /path/to/arcuit \
  --aspace-dir /path/to/archivesspace \
  --solr-url http://localhost:8983/solr/arclight
```

### Cloning Data from Remote Dev Environment

See the full guide in `docs/LOCAL_SOLR_SETUP.md`, but the basic steps are:

```bash
# 1. SSH tunnel to remote (use different port to avoid conflict with local)
ssh -NTL 8984:localhost:8983 archivesspace-dev.library.illinois.edu

# 2. Export from remote
curl "http://localhost:8984/solr/arclight/select?q=*:*&rows=10000&wt=json" > /tmp/remote-docs.json

# 3. Import to local (see full script in docs)
```

## Testing Workflow

Your typical development workflow will now be:

1. **Start local Solr**: `docker compose up -d`
2. **Make changes** to arcflow indexing code (on your `index_creators` branch)
3. **Run arcflow** pointing to local Solr: 
   ```bash
   python arcflow/main.py --solr-url http://localhost:8983/solr/arclight ...
   ```
4. **Check results** in Solr admin UI: http://localhost:8983/solr/
5. **If something breaks**, clear and try again:
   ```bash
   curl "http://localhost:8983/solr/arclight/update?commit=true" \
     -H "Content-Type: text/xml" \
     --data-binary '<delete><query>*:*</query></delete>'
   ```
6. **When done**, stop Solr: `docker compose down`

## Benefits of This Setup

✅ **Isolated from shared dev** - No risk of breaking the team's development environment  
✅ **Easy reset** - Can clear data or completely recreate with one command  
✅ **Reproducible** - Same Docker image every time  
✅ **Fast** - Local, no network latency  
✅ **Flexible** - Can clone production/dev data or start fresh  

## Files Modified

- ✅ `docker-compose.yml` - Docker Compose configuration
- ✅ `docs/LOCAL_SOLR_SETUP.md` - Complete setup documentation
- ✅ `docs/SOLR_QUICK_REFERENCE.md` - Quick reference guide
- ✅ `scripts/setup-local-solr.sh` - Automated setup script
- ✅ `scripts/README.md` - Scripts documentation
- ✅ `.env.example` - Environment configuration template
- ✅ `.gitignore` - Updated to exclude `solr-config/` and `.env`
- ✅ `README.md` - Updated with local development instructions

## What's NOT Committed

The `solr-config/` directory is in `.gitignore` because the Solr configuration can vary by environment and version of ArcLight. Each developer will get their own copy from their Arcuit installation or from the ArcLight repository.

## Next Steps

1. **Get the Solr configuration** using one of the methods above
2. **Start Docker**: `docker compose up -d`
3. **Test it works**: Visit http://localhost:8983/solr/
4. **Continue your work** on the `index_creators` branch
5. **(Optional) Clone remote data** if you want to test with real data

## Need Help?

- See `docs/LOCAL_SOLR_SETUP.md` for detailed documentation
- See `docs/SOLR_QUICK_REFERENCE.md` for quick command reference
- Run `./scripts/setup-local-solr.sh` for guided setup

Happy testing! 🎉
