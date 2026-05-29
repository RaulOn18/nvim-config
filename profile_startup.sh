#!/bin/bash
# Profile Neovim startup time
# Usage: bash profile_startup.sh

echo "Profiling Neovim startup time..."
echo "================================"

# Profile with --startuptime
nvim --startuptime startup.log -c "quit"

# Show summary
echo ""
echo "Startup Time Summary:"
echo "---------------------"
tail -20 startup.log

echo ""
echo "Full log saved to: startup.log"
echo ""
echo "Top 10 slowest plugins:"
grep "require" startup.log | sort -t: -k2 -n | tail -10
