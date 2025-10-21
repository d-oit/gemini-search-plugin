# Advanced Usage Examples

Complex workflows and advanced features.

## Multi-Step Research Workflow

### Research Project Example

**Goal**: Research and implement JWT authentication

**Step 1: Overview**

```
/search what is JWT authentication
```

Cache: MISS (15 sec)
Result: Comprehensive JWT explanation

**Step 2: Implementation**

```
/search nodejs JWT authentication implementation
```

Cache: MISS (12 sec)
Result: Code examples and libraries

**Step 3: Security**

```
/search JWT security best practices
```

Cache: MISS (10 sec)
Result: Security guidelines

**Step 4: Testing**

```
/search testing JWT authentication jest
```

Cache: MISS (11 sec)
Result: Testing strategies

**Total Time**: ~48 seconds (first run)
**Repeat Research**: ~4 seconds (all cached)

---

## Environment Configuration

### Custom Cache TTL

```bash
# 30-minute cache
export CACHE_TTL=1800
/search your query

# 24-hour cache
export CACHE_TTL=86400
/search your query
```

### Custom Retry Logic

```bash
# More aggressive retries
export MAX_RETRIES=5
export RETRY_DELAY=2
/search your query
```

### Disable Link Validation

```bash
# Faster searches
export ENABLE_LINK_VALIDATION=false
/search your query
```

---

## Batch Processing

### Script for Multiple Searches

```bash
#!/bin/bash
# research-batch.sh

queries=(
    "machine learning basics"
    "neural networks explained"
    "deep learning frameworks"
    "tensorflow vs pytorch"
)

for query in "${queries[@]}"; do
    echo "Searching: $query"
    bash scripts/search-wrapper.sh search "$query" > "results/${query// /_}.json"
    sleep 2  # Rate limiting
done
```

**Usage:**

```bash
chmod +x research-batch.sh
./research-batch.sh
```

---

## Integration with CI/CD

### Pre-commit Research

```bash
# .git/hooks/pre-commit
#!/bin/bash

# Research best practices before commit
if git diff --cached | grep -q "TODO"; then
    echo "Researching TODOs..."
    bash scripts/search-wrapper.sh search "code review best practices"
fi
```

### Documentation Generation

```bash
#!/bin/bash
# generate-docs.sh

# Search for latest documentation standards
STANDARDS=$(bash scripts/search-wrapper.sh search "API documentation best practices 2024")

# Use results to guide documentation
echo "$STANDARDS" > docs/standards.md
```

---

## Advanced Validation

### Custom Validation Script

```bash
#!/bin/bash
# custom-validate.sh

validate_all_results() {
    local query="$1"
    local results_file="$2"

    # Extract URLs from search results
    urls=$(jq -r '.results[].url' "$results_file")

    for url in $urls; do
        title=$(jq -r ".results[] | select(.url==\"$url\") | .title" "$results_file")
        snippet=$(jq -r ".results[] | select(.url==\"$url\") | .snippet" "$results_file")

        # Validate each result
        result=$(bash scripts/search-wrapper.sh validate-result "$title" "$url" "$snippet" "$query")

        if [[ "$result" == VALID* ]]; then
            echo "✓ $url"
        else
            echo "✗ $url (filtered)"
        fi
    done
}

validate_all_results "$1" "$2"
```

---

## Performance Optimization

### Parallel Searches

```bash
#!/bin/bash
# parallel-search.sh

search_parallel() {
    local queries=("$@")

    for query in "${queries[@]}"; do
        bash scripts/search-wrapper.sh search "$query" > "/tmp/${query// /_}.json" &
    done

    wait  # Wait for all searches to complete

    echo "All searches complete!"
}

search_parallel "python tutorial" "javascript guide" "rust handbook"
```

### Pre-warming Cache

```bash
#!/bin/bash
# warm-cache.sh

# Common searches to pre-cache
common_queries=(
    "git commands cheat sheet"
    "docker commands reference"
    "kubectl commands"
    "bash scripting guide"
)

for query in "${common_queries[@]}"; do
    echo "Caching: $query"
    bash scripts/search-wrapper.sh search "$query" > /dev/null
done

echo "Cache warmed with ${#common_queries[@]} queries"
```

---

## Analytics and Monitoring

### Custom Analytics Script

```bash
#!/bin/bash
# analytics-custom.sh

analyze_usage() {
    local log_file="/tmp/gemini-search.log"

    echo "=== Search Analytics ==="
    echo "Total searches: $(grep -c 'Gemini search successful' $log_file)"
    echo "Cache hits: $(grep -c 'Cache hit' $log_file)"
    echo "Cache misses: $(grep -c 'Cache miss' $log_file)"
    echo ""
    echo "Top 5 queries:"
    grep 'Gemini search successful' $log_file | \
        awk -F'query: ' '{print $2}' | \
        sort | uniq -c | sort -rn | head -5
}

analyze_usage
```

### Performance Monitoring

```bash
#!/bin/bash
# monitor-performance.sh

monitor_search() {
    local query="$1"
    local start=$(date +%s%N)

    bash scripts/search-wrapper.sh search "$query" > /dev/null

    local end=$(date +%s%N)
    local duration=$(( (end - start) / 1000000 ))  # Convert to ms

    echo "Query: $query"
    echo "Duration: ${duration}ms"

    if [ $duration -lt 1000 ]; then
        echo "Status: ✓ FAST (cached)"
    elif [ $duration -lt 15000 ]; then
        echo "Status: ✓ NORMAL"
    else
        echo "Status: ⚠ SLOW"
    fi
}

monitor_search "$1"
```

---

## API Integration

### REST API Wrapper

```bash
#!/bin/bash
# api-wrapper.sh

# Simple REST API for search plugin
while true; do
    read -p "Query: " query

    if [ "$query" == "exit" ]; then
        break
    fi

    result=$(bash scripts/search-wrapper.sh search "$query")

    # Format as JSON API response
    echo "{
        \"query\": \"$query\",
        \"timestamp\": \"$(date -Iseconds)\",
        \"result\": $result
    }" | jq .
done
```

### Web Hook Integration

```bash
#!/bin/bash
# webhook.sh

search_and_notify() {
    local query="$1"
    local webhook_url="$2"

    # Perform search
    result=$(bash scripts/search-wrapper.sh search "$query")

    # Send to webhook
    curl -X POST "$webhook_url" \
        -H "Content-Type: application/json" \
        -d "{
            \"query\": \"$query\",
            \"result\": $result
        }"
}

search_and_notify "latest AI news" "https://your-webhook.com/endpoint"
```

---

## Error Handling

### Robust Search Wrapper

```bash
#!/bin/bash
# robust-search.sh

set -euo pipefail

safe_search() {
    local query="$1"
    local max_attempts=3
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        echo "Attempt $attempt of $max_attempts..."

        if result=$(bash scripts/search-wrapper.sh search "$query" 2>&1); then
            echo "$result"
            return 0
        else
            echo "Failed, retrying..." >&2
            sleep $((attempt * 2))
            ((attempt++))
        fi
    done

    echo "Error: All attempts failed" >&2
    return 1
}

safe_search "$1"
```

---

## Testing and Development

### Unit Test Helper

```bash
#!/bin/bash
# test-helper.sh

run_test() {
    local test_name="$1"
    local query="$2"
    local expected="$3"

    echo "Running: $test_name"

    result=$(bash scripts/search-wrapper.sh search "$query" 2>&1 | grep "$expected")

    if [ $? -eq 0 ]; then
        echo "✓ PASS: $test_name"
        return 0
    else
        echo "✗ FAIL: $test_name"
        return 1
    fi
}

# Test suite
run_test "Cache Miss Test" "unique-query-$(date +%s)" "CACHE_MISS"
run_test "Cache Hit Test" "static-query" "CACHE_HIT"
```

### Mock Search for Testing

```bash
#!/bin/bash
# mock-search.sh

mock_search() {
    local query="$1"

    # Return mock data for testing
    echo '{
        "response": "Mock search result for: '"$query"'",
        "stats": {
            "models": {
                "mock": {
                    "tokens": {
                        "total": 100
                    }
                }
            }
        }
    }'
}

mock_search "$1"
```

---

## Production Deployment

### Systemd Service

```ini
# /etc/systemd/system/gemini-search.service
[Unit]
Description=Gemini Search Service
After=network.target

[Service]
Type=simple
User=search-user
WorkingDirectory=/opt/gemini-search
ExecStart=/opt/gemini-search/api-wrapper.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Docker Container

```dockerfile
FROM alpine:latest

RUN apk add --no-cache bash curl jq nodejs npm

WORKDIR /app
COPY . /app

RUN npm install -g @google/genai-cli

CMD ["bash", "scripts/search-wrapper.sh", "stats"]
```

### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gemini-search
spec:
  replicas: 3
  selector:
    matchLabels:
      app: gemini-search
  template:
    metadata:
      labels:
        app: gemini-search
    spec:
      containers:
      - name: search
        image: gemini-search:latest
        env:
        - name: CACHE_TTL
          value: "3600"
        - name: MAX_RETRIES
          value: "3"
```

---

## Performance Tuning

### Optimal Configuration

```bash
# For high-volume searches
export CACHE_TTL=7200         # 2-hour cache
export MAX_RETRIES=2          # Fewer retries
export ENABLE_LINK_VALIDATION=false  # Skip validation

# For accuracy-critical searches
export CACHE_TTL=600          # 10-minute cache
export MAX_RETRIES=5          # More retries
export ENABLE_LINK_VALIDATION=true   # Full validation
```

### Cache Management

```bash
# Monitor cache size
du -sh /tmp/gemini-search-cache

# Clear old entries
find /tmp/gemini-search-cache -mtime +1 -delete

# Backup cache
tar -czf cache-backup.tar.gz /tmp/gemini-search-cache
```

---

## Tips for Advanced Usage

1. **Batch Operations**: Process multiple queries in parallel
2. **Cache Strategy**: Pre-warm common queries
3. **Error Handling**: Implement retry logic
4. **Monitoring**: Track performance and usage
5. **Integration**: Connect with existing tools
6. **Optimization**: Tune for your use case
7. **Testing**: Create comprehensive test suites
8. **Documentation**: Keep examples up-to-date
