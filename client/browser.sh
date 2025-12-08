#!/data/data/com.termux/files/usr/bin/bash

# Browser Automation Client Library
# Helper functions to control Android Browser from Termux

BASE_URL="http://localhost:8765"

# Navigate to URL
browser_goto() {
    local url="$1"
    curl -s -X POST "$BASE_URL/navigate" \
        -H "Content-Type: application/json" \
        -d "{\"url\":\"$url\"}" | jq -r '.message'
}

# Execute JavaScript (no return value)
browser_execute() {
    local script="$1"
    curl -s -X POST "$BASE_URL/execute" \
        -H "Content-Type: application/json" \
        -d "{\"script\":$(echo "$script" | jq -R .)}" | jq -r '.message'
}

# Execute JavaScript (with return value)
browser_eval() {
    local script="$1"
    curl -s -X POST "$BASE_URL/eval" \
        -H "Content-Type: application/json" \
        -d "{\"script\":$(echo "$script" | jq -R .)}" | jq -r '.result'
}

# Get current URL
browser_url() {
    curl -s "$BASE_URL/url" | jq -r '.url'
}

# Get page title
browser_title() {
    curl -s "$BASE_URL/title" | jq -r '.title'
}

# Get full HTML
browser_html() {
    curl -s "$BASE_URL/html" | jq -r '.html'
}

# Take screenshot (Base64)
browser_screenshot() {
    local output="${1:-screenshot.png}"
    curl -s "$BASE_URL/screenshot" | jq -r '.screenshot' | base64 -d > "$output"
    echo "Screenshot saved to $output"
}

# Go back
browser_back() {
    curl -s -X POST "$BASE_URL/back" | jq -r '.message'
}

# Go forward
browser_forward() {
    curl -s -X POST "$BASE_URL/forward" | jq -r '.message'
}

# Reload page
browser_refresh() {
    curl -s -X POST "$BASE_URL/refresh" | jq -r '.message'
}

# Check server connection
browser_ping() {
    curl -s "$BASE_URL/ping" | jq -r '.status'
}

# Start floating bubble
browser_bubble_start() {
    curl -s -X POST "$BASE_URL/bubble/start" | jq -r '.message'
}

# Stop floating bubble
browser_bubble_stop() {
    curl -s -X POST "$BASE_URL/bubble/stop" | jq -r '.message'
}

# Show help
browser_help() {
    cat << 'EOF'
Browser Automation Client - Usage

Navigation:
  browser_goto <url>          Navigate to URL
  browser_back                Go back
  browser_forward             Go forward
  browser_refresh             Reload page

Information:
  browser_url                 Get current URL
  browser_title               Get page title
  browser_html                Get full HTML

JavaScript:
  browser_execute <script>    Execute script (no return)
  browser_eval <script>       Execute script and get result

Other:
  browser_screenshot [file]   Save screenshot (default: screenshot.png)
  browser_ping                Check server connection
  browser_bubble_start        Show floating bubble (overlay with Termux)
  browser_bubble_stop         Close floating bubble
  browser_help                Show this help

Examples:
  browser_goto "https://example.com"
  browser_title
  browser_eval "document.querySelector('h1').textContent"
  browser_screenshot my-screenshot.png
EOF
}
