#!/bin/bash

# Function to update the status of tasks dynamically
update_status() {
    tput cuu1 # Move cursor up one line
    tput el   # Clear the line
    echo "$1"
}

# Step 1: Clear system cache
echo "⏳ Clearing system cache..."
CACHES=(
    "$HOME/Library/Caches" 
    "/Library/Caches"
)

for CACHE_DIR in "${CACHES[@]}"
do
    if [ -d "$CACHE_DIR" ]; then
        update_status "✅ Clearing cache in: $CACHE_DIR"
        find "$CACHE_DIR" -mindepth 1 ! -name "CloudKit" -exec sudo rm -rf {} + 2>/dev/null || \
        update_status "⚠️ Some items could not be deleted in: $CACHE_DIR"
    else
        update_status "❌ Cache directory not found: $CACHE_DIR"
    fi
done

# Step 2: Clear Quick Look cache
echo "⏳ Clearing Quick Look cache..."
sudo qlmanage -r cache
update_status "✅ Quick Look cache cleared"

# Step 3: Remove temporary files
echo "⏳ Removing temporary files..."
sudo rm -rf /private/tmp/* 2>/dev/null || \
update_status "⚠️ Some items in /private/tmp could not be removed"
update_status "✅ Temporary files removed"

# Step 4: Clear DNS cache
echo "⏳ Clearing DNS cache..."
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
update_status "✅ DNS cache cleared"

# Step 5: Clear system logs
echo "⏳ Clearing system logs..."
sudo rm -rf /private/var/log/* 2>/dev/null || \
update_status "⚠️ Some system logs could not be cleared"
update_status "✅ System logs cleared"

# Step 6: Clean Homebrew cache
echo "⏳ Cleaning Homebrew cache..."
brew cleanup
if [ $? -eq 0 ]; then
    update_status "✅ Homebrew cache cleaned"
else
    update_status "❌ Homebrew cleanup failed"
fi

# Step 7: Remove old Time Machine snapshots
echo "⏳ Removing old Time Machine snapshots..."
sudo tmutil deletelocalsnapshots /
update_status "✅ Old Time Machine snapshots removed"

# Step 8: Clean node_modules older than 120 days
echo "⏳ Cleaning node_modules older than 120 days..."
sudo find . -name "node_modules" -type d -mtime +120 | xargs sudo rm -rf
update_status "✅ Old node_modules cleaned"

# Step 9: Clean CocoaPods cache
echo "⏳ Cleaning CocoaPods cache..."
sudo rm -rf "${HOME}/Library/Caches/CocoaPods"
update_status "✅ CocoaPods cache cleaned"

# Step 10: Delete old simulators
echo "⏳ Deleting old simulators..."
sudo xcrun simctl delete unavailable
update_status "✅ Old simulators deleted"

# Step 11: Clean Xcode derived data and other data
echo "⏳ Cleaning Xcode derived data and logs..."
sudo rm -rf ~/Library/Developer/Xcode/Archives
sudo rm -rf ~/Library/Developer/Xcode/DerivedData
sudo rm -rf ~/Library/Developer/Xcode/iOS\ Device\ Logs/
update_status "✅ Xcode data and logs cleaned"

# Step 12: Clean Docker volumes
echo "⏳ Cleaning up Docker volumes..."
if docker info >/dev/null 2>&1; then
    sudo docker volume prune -f
    update_status "✅ Docker volumes cleaned"
else
    update_status "❌ Docker daemon is not running or not accessible"
fi

# Step 13: Empty Trash
echo "⏳ Emptying Trash..."
TRASH_DIR="$HOME/.Trash"
if [ -d "$TRASH_DIR" ]; then
    sudo rm -rf "$TRASH_DIR"/* 2>/dev/null || \
    update_status "⚠️ Some items in the Trash could not be removed"
    update_status "✅ Trash emptied"
else
    update_status "❌ Trash directory not found"
fi

# Final message
echo "🎉 All cleaning tasks completed successfully!"
