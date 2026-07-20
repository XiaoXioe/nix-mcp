#!/usr/bin/env python3
import urllib.request
import json
import re
import subprocess
import sys
import os

PACKAGES = {
    "ssh-mcp": {
        "type": "npm",
        "file": "pkgs/ssh-mcp/default.nix",
        "npm_name": "ssh-mcp"
    },
    "codebase-memory-mcp": {
        "type": "github",
        "file": "pkgs/codebase-memory-mcp/default.nix",
        "repo": "DeusData/codebase-memory-mcp"
    },
    "google-colab-mcp": {
        "type": "pypi",
        "file": "pkgs/google-colab-mcp/default.nix",
        "pypi_name": "google-colab-mcp"
    },
    "telegram-mcp": {
        "type": "pypi",
        "file": "pkgs/telegram-mcp/default.nix",
        "pypi_name": "telegram-mcp-jgalea"
    },
    "github-mcp-server": {
        "type": "github",
        "file": "pkgs/github-mcp-server/default.nix",
        "repo": "github/github-mcp-server"
    },
    "tavily-mcp": {
        "file": "pkgs/tavily-mcp/default.nix",
        "npm_name": "tavily-mcp",
        "type": "npm"
    },
    "server-memory": {
        "file": "pkgs/server-memory/default.nix",
        "npm_name": "@modelcontextprotocol/server-memory",
        "type": "npm"
    }
}

DUMMY_HASH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

def get_latest_version(pkg_name, info):
    try:
        if info["type"] == "pypi":
            url = f"https://pypi.org/pypi/{info['pypi_name']}/json"
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req) as response:
                data = json.loads(response.read().decode())
                return data["info"]["version"]
        elif info["type"] == "npm":
            url = f"https://registry.npmjs.org/{info['npm_name']}/latest"
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req) as response:
                data = json.loads(response.read().decode())
                return data["version"]
        elif info["type"] == "github":
            url = f"https://api.github.com/repos/{info['repo']}/releases/latest"
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req) as response:
                data = json.loads(response.read().decode())
                tag = data["tag_name"]
                return tag.lstrip("v")
    except Exception as e:
        print(f"Error fetching version for {pkg_name}: {e}")
        return None

def update_package(name, info, latest_version):
    filepath = info["file"]
    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        return False

    with open(filepath, "r") as f:
        content = f.read()

    # Parse current version
    version_match = re.search(r'version\s*=\s*"([^"]+)";', content)
    if not version_match:
        print(f"Could not parse current version in {filepath}")
        return False
    current_version = version_match.group(1)

    if current_version == latest_version:
        print(f"[-] {name} is already up to date ({current_version}).")
        return False

    print(f"[+] Updating {name} from {current_version} to {latest_version}...")

    # Parse current hash
    hash_match = re.search(r'(sha256|outputHash)\s*=\s*"([^"]+)";', content)
    if not hash_match:
        print(f"Could not parse current hash in {filepath}")
        return False
    hash_key = hash_match.group(1)
    current_hash = hash_match.group(2)

    # 1. Update version and set hash to dummy
    new_content = content.replace(f'version = "{current_version}";', f'version = "{latest_version}";')
    new_content = new_content.replace(f'{hash_key} = "{current_hash}";', f'{hash_key} = "{DUMMY_HASH}";')

    with open(filepath, "w") as f:
        f.write(new_content)

    # Add to git so Nix sees the change
    subprocess.run(["git", "add", filepath], check=True)

    # 2. Run nix build to get correct hash
    print(f"    Running nix build to trigger hash mismatch...")
    build_cmd = ["nix", "build", f".#packages.x86_64-linux.{name}", "--no-link", "--extra-experimental-features", "nix-command flakes"]
    res = subprocess.run(build_cmd, capture_output=True, text=True)

    stderr = res.stderr
    # Search for the "got: sha256-..." pattern in Nix error
    got_match = re.search(r'got:\s+(sha256-\S+)', stderr)
    if not got_match:
        # Also check for older output format if any
        got_match = re.search(r'specified:\s+sha256-A+.*\n\s+got:\s+(sha256-\S+)', stderr)
        
    if not got_match:
        print(f"    Error: Could not retrieve new hash from build error. Stderr output:")
        print(stderr)
        # Revert changes
        with open(filepath, "w") as f:
            f.write(content)
        subprocess.run(["git", "add", filepath], check=True)
        return False

    new_hash = got_match.group(1).rstrip()
    print(f"    Found new hash: {new_hash}")

    # 3. Replace dummy hash with the correct new hash
    new_content = new_content.replace(f'{hash_key} = "{DUMMY_HASH}";', f'{hash_key} = "{new_hash}";')
    with open(filepath, "w") as f:
        f.write(new_content)

    # Staging final version
    subprocess.run(["git", "add", filepath], check=True)

    # 4. Confirm build succeeds
    print(f"    Verifying build with new hash...")
    verify_res = subprocess.run(build_cmd, capture_output=True, text=True)
    if verify_res.returncode != 0:
        print(f"    Verification build failed:")
        print(verify_res.stderr)
        # Revert
        with open(filepath, "w") as f:
            f.write(content)
        subprocess.run(["git", "add", filepath], check=True)
        return False

    print(f"[✓] Successfully updated {name} to version {latest_version}!")
    
    # 5. Commit the update if there are staged changes
    diff_res = subprocess.run(["git", "diff", "--cached", "--quiet"])
    if diff_res.returncode != 0:
        commit_msg = f"chore(deps): bump {name} from {current_version} to {latest_version}"
        subprocess.run(["git", "commit", "-m", commit_msg], check=True)
        print(f"    Committed update: {commit_msg}")
    else:
        print(f"    No changes to commit (final state matches HEAD).")
    return True

def main():
    # Make sure we're in the repository root directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    print("Checking for updates of Nix MCP packages...")
    updated_any = False
    for name, info in PACKAGES.items():
        print(f"\nChecking {name}...")
        latest = get_latest_version(name, info)
        if latest:
            if update_package(name, info, latest):
                updated_any = True
        else:
            print(f"Skipping {name} due to fetch error.")

    if updated_any:
        print("\n[✓] Updates completed and committed successfully!")
    else:
        print("\n[-] All packages are up to date.")

if __name__ == "__main__":
    main()
