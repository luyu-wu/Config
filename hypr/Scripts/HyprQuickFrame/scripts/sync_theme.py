#!/usr/bin/env python3
import json
import os
import sys
import re

# Define paths
NOCTALIA_COLORS = os.path.expanduser("~/.config/noctalia/colors.json")
THEME_TOML = os.path.expanduser("~/.config/hyprquickframe/theme.toml")

# Mapping: (Section, Key) -> Noctalia Color Key
# Section None means global
COLOR_MAPPING = {
    (None, "accent"): "mPrimary",
    (None, "accentText"): "mOnPrimary",
    
    # ("bar", "background"): ("mSurface", 1.0),
    ("bar", "border"): "mOutline",
    ("bar", "text"): "mOnSurfaceVariant",
    
    # ("toggle", "background"): "mSurfaceVariant",
    ("toggle", "edit"): "mSecondary",
    ("toggle", "temp"): "mTertiary",
    
    ("share", "connected"): "mPrimary",
    ("share", "errorBackground"): "mError",
    ("share", "errorIcon"): "mOnError",
    ("share", "pending"): "mOutline" 
}

def hex_to_rgba(hex_color, opacity):
    hex_color = hex_color.lstrip('#')
    r = int(hex_color[0:2], 16)
    g = int(hex_color[2:4], 16)
    b = int(hex_color[4:6], 16)
    return f"rgba({r}, {g}, {b}, {opacity})"

def main():
    # Read Noctalia colors
    try:
        with open(NOCTALIA_COLORS, 'r') as f:
            colors = json.load(f)
    except Exception as e:
        print(f"Error reading {NOCTALIA_COLORS}: {e}")
        sys.exit(1)

    # Read Theme TOML
    try:
        with open(THEME_TOML, 'r') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading {THEME_TOML}: {e}")
        sys.exit(1)

    # Update colors
    new_lines = []
    current_section = None
        
    for line in lines:
        stripped = line.strip()
        
        # Detect section
        if stripped.startswith("[") and stripped.endswith("]"):
            current_section = stripped[1:-1]
            new_lines.append(line)
            continue
            
        # Detect key-value pair
        if "=" in stripped and not stripped.startswith("#"):
            key = stripped.split("=")[0].strip()
            
            mapping_key = (current_section, key)
            if mapping_key in COLOR_MAPPING:
                target_val = COLOR_MAPPING[mapping_key]
                
                # Handle special tuple for opacity (color_key, opacity)
                if isinstance(target_val, tuple):
                    color_key, opacity = target_val
                    hex_color = colors.get(color_key)
                    if hex_color:
                        new_val = hex_to_rgba(hex_color, opacity)
                        new_lines.append(f'{key} = "{new_val}"\n')
                        print(f"Updated [{current_section}] {key} to {new_val}")
                        continue
                else:
                    hex_color = colors.get(target_val)
                    if hex_color:
                        new_lines.append(f'{key} = "{hex_color}"\n')
                        print(f"Updated [{current_section}] {key} to {hex_color} ({target_val})")
                        continue
        
        new_lines.append(line)

    # 4. Write back to TOML
    try:
        with open(THEME_TOML, 'w') as f:
            f.writelines(new_lines)
        print(f"Successfully updated {THEME_TOML}")
    except Exception as e:
        print(f"Error writing {THEME_TOML}: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
