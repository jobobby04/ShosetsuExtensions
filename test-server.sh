#!/bin/bash -x
set -euo pipefail

# This file simply runs an http server locally and watches for changes in extensions to update the index.
# Requires java to be installed.
# Defaults to hosting on: http://localhost:8000

# How to use:
# 1. Run this script
# 2. Ensure the <your-ip>:8000 is in your Shosetsu installation's repository list
# 3. Make your changes to the extensions
# 4. Reload the repository list in Shosetsu
# 5. Test your changes
# 6. Repeat steps 3-5 as needed

# Ensure that jwebserver is available and the extension-tester.jar is downloaded
if ! command -v jwebserver &> /dev/null; then
  echo "jwebserver not found. Please ensure you have an up-to-date version of java installed and in your PATH."
  exit 1
fi
if [ ! -f bin/extension-tester.jar ]; then
  echo "extension-tester.jar not found. Running dev-setup.sh to download it."
  ./dev-setup.sh --tester
fi

# Function to handle termination signals
cleanup() {
  set +u # if pids are not set, that's fine
  kill -SIGINT "$jwebserver_pid" "$java_pid" 2>/dev/null || true
}

# Trap termination signals and call cleanup
trap cleanup SIGINT SIGTERM

# Start index generation process and save its PID
(java -jar bin/extension-tester.jar --generate-index --watch || cleanup) &
java_pid=$!

# Start jwebserver and save its PID
(jwebserver -b :: || cleanup) &
jwebserver_pid=$!

# Wait for both processes to finish
wait "$jwebserver_pid"
wait "$java_pid"