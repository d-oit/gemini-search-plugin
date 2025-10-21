# Basic Search Examples

Simple search queries demonstrating core functionality.

## Example 1: General Information Search

**Query:**

```
/search what is artificial intelligence
```

**Expected Output:**

```
CACHE_MISS
{
  "response": "Artificial intelligence (AI) refers to the simulation of human intelligence processes by machines, especially computer systems. These processes include learning, reasoning, problem-solving, perception, and language understanding...",
  "stats": {
    "models": {
      "gemini-2.5-flash": {
        "api": {
          "totalRequests": 3,
          "totalLatencyMs": 8031
        },
        "tokens": {
          "prompt": 19888,
          "candidates": 467,
          "total": 20714
        }
      }
    }
  }
}
```

**Cache Behavior:**

- First search: `CACHE_MISS` (~8-15 seconds)
- Repeat within 1 hour: `CACHE_HIT` (<1 second)

---

## Example 2: Current Events

**Query:**

```
/search latest developments in renewable energy
```

**Use Case:**

- Get up-to-date information
- Research current topics
- News and trends

**Performance:**

- Response time: 5-12 seconds
- Token usage: ~15,000-25,000 tokens
- Results: Comprehensive summary with sources

---

## Example 3: Product Information

**Query:**

```
/search best programming languages for beginners
```

**Expected Response Features:**

- Multiple language recommendations
- Comparison points
- Learning resources
- Source references

---

## Example 4: Definition Lookup

**Query:**

```
/search define machine learning
```

**Response Includes:**

- Clear definition
- Key concepts
- Practical applications
- Related terms

---

## Example 5: How-To Query

**Query:**

```
/search how to install docker on ubuntu
```

**Expected Output Type:**

- Step-by-step instructions
- Prerequisites
- Common issues
- Alternative methods

---

## Cache Statistics

View search statistics:

```
/search-stats
```

**Output:**

```
=== Cache Statistics ===
Total searches: 5
Cache hits: 0
Cache misses: 5
Cache hit rate: 0%
Log file size: 2847 bytes
```

## Clear Cache

Clear cached results:

```
/clear-cache
```

**Output:**

```
Cache cleared. Previous size: 12.5K
```

---

## Performance Comparison

| Search Type | First Search | Cached Search | Improvement |
|-------------|--------------|---------------|-------------|
| General Info | 8-15 sec | <1 sec | 95% faster |
| Technical | 10-18 sec | <1 sec | 96% faster |
| Current Events | 12-20 sec | <1 sec | 97% faster |

## Notes

- Cache expires after 1 hour (configurable via `CACHE_TTL`)
- Each unique query is cached separately
- Cache is MD5-hashed for efficiency
- Results include full JSON with statistics
