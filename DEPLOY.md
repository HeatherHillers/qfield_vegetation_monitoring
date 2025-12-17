# Deployment Guide for QField Projects

This guide covers deploying QField plugin projects to QFieldCloud, both through the GUI and command-line interface.

## Deployment Methods

### Method 1: QFieldSync Plugin (GUI)

1. Open your demo project in QGIS
2. Open QFieldSync plugin
3. Configure the components directory as an attachment directory
4. Synchronize to QFieldCloud
5. On qfield.cloud project page, enable "On demand attachment files download"

### Method 2: QFieldCloud CLI (Automated)

For automated workflows and rapid iteration during development.

#### Installation

```bash
pip install qfieldcloud-sdk
```

#### Authentication

**Option A: Login (stores token for subsequent commands)**
```bash
qfieldcloud-cli login your_username your_password
```

**Option B: Environment variables**
```bash
export QFIELDCLOUD_TOKEN="your_token_here"
export QFIELDCLOUD_URL="https://app.qfield.cloud/api/v1/"
```

#### Finding Your Project ID

The CLI requires the project ID (UUID), not the project name.

**From QField Cloud URL (easiest):**
```
https://app.qfield.cloud/projects/abc-123-def-456-789/
                                 ^^^^^^^^^^^^^^^^^^^^
                                  This is your project ID
```

**Using the CLI:**
```bash
# List all your projects with their IDs
qfieldcloud-cli list-projects

# Output shows:
# - "id": "abc-123-def-456-789"  <- Project ID (UUID)
# - "name": "demo1_hello"        <- Human-readable name
```

**Using Python SDK:**
```python
from qfieldcloud_sdk import sdk

client = sdk.Client()
client.login("username", "password")

# Find project by name
projects = client.list_projects()
for project in projects:
    if project["name"] == "demo1_hello":
        print(f"Project ID: {project['id']}")
        break
```

#### Common CLI Commands

**Upload project files:**
```bash
qfieldcloud-cli upload-files PROJECT_ID ./demo1_hello --force
```

**Upload with file filter:**
```bash
# Only upload QML files
qfieldcloud-cli upload-files PROJECT_ID ./demo1_hello --filter "*.qml" --force
```

**Download project files:**
```bash
qfieldcloud-cli download-files PROJECT_ID ./local_dir --force-download
```

**Trigger packaging job:**
```bash
# Prepares project for QField mobile app download
qfieldcloud-cli job-trigger PROJECT_ID package
```

**Check packaging status:**
```bash
qfieldcloud-cli package-latest PROJECT_ID
```

**List project files:**
```bash
qfieldcloud-cli list-files PROJECT_ID
```

#### Example Workflow: Update Demo Plugin

```bash
# 1. Upload modified plugin files
qfieldcloud-cli upload-files abc-123-project-id ./demo4_header_form --force

# 2. Trigger packaging
qfieldcloud-cli job-trigger abc-123-project-id package

# 3. Wait for packaging to complete (check status)
qfieldcloud-cli package-latest abc-123-project-id

# 4. On QField mobile: Delete and re-download the project
```

## Important Notes

### Plugin Updates Require Full Restart

**Synchronization alone is NOT sufficient** for plugin updates:

1. **Completely restart QField** on mobile device
2. **Delete the project** from QField
3. **Re-download the project** from QFieldCloud
4. In stubborn cases, delete the project from QFieldCloud and re-upload

### Testing & Debugging

1. **Start QField from command line** to see QML errors
   - Program errors are NOT printed in the client log
   - Command-line output shows QML compilation errors

2. **Test component loading independently** before adding functionality

3. **Component name uniqueness**: Use unique component names across all projects to prevent loading conflicts

### File Structure Requirements

- Main QML file must match project name (e.g., `demo1_hello.qml` for `demo1_hello.qgs`)
- All component QML files must be in a subdirectory (conventionally `components/`)
- Components directory must be configured as an attachment directory in QFieldSync
- Enable "On demand attachment files download" in project settings on qfield.cloud

## Resources

- **QFieldCloud SDK Documentation**: https://opengisch.github.io/qfieldcloud-sdk-python/
- **CLI Reference**: https://opengisch.github.io/qfieldcloud-sdk-python/cli/
- **API Documentation**: https://docs.qfield.org/reference/qfieldcloud/api/
- **PyPI Package**: https://pypi.org/project/qfieldcloud-sdk/
