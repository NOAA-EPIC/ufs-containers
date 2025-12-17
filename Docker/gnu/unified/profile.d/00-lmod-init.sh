# Initialize Lmod profile (login shells)
if [ -f /usr/share/lmod/lmod/init/profile ]; then
    source /usr/share/lmod/lmod/init/profile
fi

# Initialize Lmod for Bash non-login shells
if [ -n "$BASH_VERSION" ] && [ -f /usr/share/lmod/lmod/init/bash ]; then
    source /usr/share/lmod/lmod/init/bash
fi

