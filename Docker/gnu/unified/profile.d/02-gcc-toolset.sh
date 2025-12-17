# Avoid re-sourcing
[ -n "$GCC_TOOLSET_SOURCED" ] && return
export GCC_TOOLSET_SOURCED=1

# Enable gcc-toolset-13 safely
if [ -f /opt/rh/gcc-toolset-13/enable ]; then
    # Equivalent to: scl enable gcc-toolset-13 bash
    source /opt/rh/gcc-toolset-13/enable
fi

