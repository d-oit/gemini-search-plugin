#!/bin/bash
# Pre-edit hook for Gemini Search - Claude Code compatible
# Provides search suggestions when Claude uses search-related tools

# Configuration
SUGGESTIONS_LIMIT="${SUGGESTIONS_LIMIT:-5}"
CONTEXT_WINDOW="${CONTEXT_WINDOW:-10}"  # Number of previous messages to consider
MIN_KEYWORD_LENGTH="${MIN_KEYWORD_LENGTH:-3}"  # Minimum length for keywords
SUGGESTION_VALIDATION_THRESHOLD="${SUGGESTION_VALIDATION_THRESHOLD:-30}"  # Minimum relevance score

# Function to analyze conversation context with more sophisticated analysis
analyze_context() {
    # For Claude Code hooks, we'll look for relevant context in the environment
    # In a real implementation, this would analyze the current conversation context
    if [[ -n "${CLAUDE_CONTEXT:-}" ]]; then
        # Extract keywords from Claude's context if available
        echo "${CLAUDE_CONTEXT}" | tr ' ' '\n' | grep -E "^[a-zA-Z]{${MIN_KEYWORD_LENGTH},}$" | sort | uniq | head -10
    else
        # Fallback to analyzing any available context
        local keywords
        keywords=$(echo "${1:-}" | tr ' ' '\n' | grep -E "^[a-zA-Z]{${MIN_KEYWORD_LENGTH},}$" | sort | uniq | head -10)
        echo "$keywords"
    fi
}

# Function to validate a search suggestion against the context
validate_suggestion() {
    local suggestion="$1"
    local context_keywords="$2"
    local query_context="${3:-}"
    
    # Convert to lowercase for comparison
    local lower_suggestion
    lower_suggestion=$(echo "$suggestion" | tr '[:upper:]' '[:lower:]')
    local lower_context
    lower_context=$(echo "$query_context" | tr '[:upper:]' '[:lower:]')
    
    # Calculate relevance score
    local relevance_score=0
    local total_checks=0
    
    # Check if context keywords appear in the suggestion
    for keyword in $context_keywords; do
        if [[ "$lower_suggestion" == *"$keyword"* ]]; then
            ((relevance_score++))
        fi
        ((total_checks++))
    done
    
    # Check if query context appears in the suggestion
    if [[ -n "$lower_context" && "$lower_suggestion" == *"$lower_context"* ]]; then
        ((relevance_score++))
        ((total_checks++))
    fi
    
    # Calculate percentage relevance
    local relevance_percentage=0
    if [[ $total_checks -gt 0 ]]; then
        relevance_percentage=$((relevance_score * 100 / total_checks))
    fi
    
    # Additional validity checks
    local is_valid=true
    
    # Check for common invalid patterns
    if [[ "$lower_suggestion" =~ (error|failed|invalid|none|empty|unknown|n/a|na) ]]; then
        is_valid=false
    fi
    
    # Check for minimum content quality
    local suggestion_length=${#suggestion}
    if [[ $suggestion_length -lt 3 ]]; then
        is_valid=false
    fi
    
    # Return validation result
    if [[ $relevance_percentage -ge $SUGGESTION_VALIDATION_THRESHOLD ]] && [[ "$is_valid" == "true" ]]; then
        echo "VALID|$relevance_percentage|$suggestion"
        return 0
    else
        echo "INVALID|$relevance_percentage|$suggestion"
        return 1
    fi
}

# Function to generate search suggestions with validation
generate_suggestions() {
    local context_keywords="$1"
    local query_context="${2:-}"
    
    # Array to store all potential suggestions
    local suggestions=()
    
    # Generate suggestions based on context keywords
    for keyword in $context_keywords; do
        case "$keyword" in
            "ai"|"artificial"|"intelligence"|"machine"|"learning"|"neural"|"deep")
                suggestions+=("AI developments 2025" "artificial intelligence trends" "machine learning algorithms" "neural network applications" "deep learning frameworks")
                ;;
            "climate"|"change"|"environment"|"global"|"warming"|"sustainability")
                suggestions+=("climate change solutions" "renewable energy progress" "environmental sustainability initiatives" "global warming effects" "carbon footprint reduction")
                ;;
            "health"|"medical"|"medicine"|"treatment"|"therapy"|"cure")
                suggestions+=("latest medical breakthroughs" "health technology innovations" "new treatment options" "medical research findings" "therapy advances")
                ;;
            "technology"|"tech"|"software"|"programming"|"code"|"development")
                suggestions+=("latest technology trends" "software development best practices" "programming language comparisons" "coding frameworks 2025" "development tools review")
                ;;
            "business"|"economy"|"finance"|"market"|"investment")
                suggestions+=("current market trends" "business strategy innovations" "investment opportunities 2025" "economic forecast" "financial planning tips")
                ;;
            "science"|"research"|"discovery"|"study"|"experiment")
                suggestions+=("recent scientific discoveries" "research methodology improvements" "study results summary" "experiment best practices" "science breakthrough news")
                ;;
            *)
                suggestions+=("information about $keyword" "research on $keyword" "trends related to $keyword" "analysis of $keyword" "overview of $keyword")
                ;;
        esac
    done
    
    # If we have a specific query context, add related suggestions
    if [[ -n "$query_context" && "$query_context" != "unknown" ]]; then
        suggestions+=("related to: $query_context" "about: $query_context" "information on: $query_context")
    fi
    
    # Validate and filter suggestions
    local valid_suggestions=()
    for suggestion in "${suggestions[@]}"; do
        local validation_result
        validation_result=$(validate_suggestion "$suggestion" "$context_keywords" "$query_context")
        local validation_status
        validation_status=$(echo "$validation_result" | cut -d'|' -f1)
        local relevance_score
        relevance_score=$(echo "$validation_result" | cut -d'|' -f2)
        local validated_suggestion
        validated_suggestion=$(echo "$validation_result" | cut -d'|' -f3-)
        
        if [[ "$validation_status" == "VALID" ]]; then
            valid_suggestions+=("$validated_suggestion (relevance: $relevance_score%)")
        fi
    done
    
    # Output the best valid suggestions (up to the limit)
    local count=0
    for suggestion in "${valid_suggestions[@]}"; do
        if [[ $count -lt $SUGGESTIONS_LIMIT ]]; then
            echo "$suggestion"
            ((count++))
        fi
    done
    
    # If we don't have enough valid suggestions, add some fallbacks
    if [[ $count -eq 0 ]]; then
        echo "AI developments 2025"
        echo "current technology trends" 
        echo "recent research findings"
        echo "best practices guide"
        echo "comprehensive overview"
    fi
}

# Main hook execution - this is called by Claude Code when the hook is triggered
main() {
    # Get the current context from stdin or environment
    local context_input
    if [[ -t 0 ]]; then
        # No input from stdin, use environment or default
        context_input="${CLAUDE_CONTEXT:-${1:-}}"
    else
        # Read from stdin
        context_input=$(cat)
    fi
    
    # Analyze the context
    local keywords
    keywords=$(analyze_context "$context_input")

    # If we have Claude's current query/command, extract keywords from it too
    local current_query="${2:-}"
    if [[ -z "$keywords" && -n "$current_query" ]]; then
        keywords=$(echo "$current_query" | tr ' ' '\n' | grep -E "^[a-zA-Z]{${MIN_KEYWORD_LENGTH},}$" | sort | head -10)
    fi
    
    if [[ -n "$keywords" ]]; then
        echo "# Gemini Search Suggestions:"
        generate_suggestions "$keywords" "$current_query"
    else
        echo "# Gemini Search: No specific suggestions available"
        echo "# You can try: /search [your query]"
        echo "# Or: /search-stats to view usage statistics"
        echo "# Or: /clear-cache to clear cached results"
    fi
}

# Execute the main function with any available arguments
main "$@"