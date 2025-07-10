#!/bin/bash

# Test Runner - Comprehensive testing for multiple languages
# Tests files before and after changes to ensure fixes don't break functionality

set -euo pipefail

# Configuration
CODEBASE_DIR="../codebase"
TEST_RESULTS_DIR="../postbox/test_results"
LOG_FILE="../postbox/test_runner.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

# Initialize test environment
init_test_env() {
    mkdir -p "$TEST_RESULTS_DIR"
    touch "$LOG_FILE"
    
    # Create test summary file
    cat > "$TEST_RESULTS_DIR/test_summary.json" << 'EOF'
{
  "test_runs": [],
  "total_tests": 0,
  "passed_tests": 0,
  "failed_tests": 0,
  "last_updated": ""
}
EOF
}

# Test Python files
test_python_file() {
    local file_path="$1"
    local test_id="$2"
    local result_file="$TEST_RESULTS_DIR/python_${test_id}.json"
    
    info "🐍 Testing Python file: $(basename "$file_path")"
    
    local test_results='{
        "file": "'$file_path'",
        "language": "python",
        "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
        "tests": []
    }'
    
    # Test 1: Syntax Check
    local syntax_test='{
        "name": "syntax_check",
        "description": "Python syntax validation",
        "status": "unknown",
        "output": "",
        "duration": 0
    }'
    
    local start_time=$(date +%s)
    if python3 -m py_compile "$file_path" 2>/dev/null; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        syntax_test=$(echo "$syntax_test" | jq --arg status "passed" --arg output "Syntax check passed" --argjson duration "$duration" '.status = $status | .output = $output | .duration = $duration')
        success "  ✅ Syntax check passed"
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local error_output=$(python3 -m py_compile "$file_path" 2>&1 || echo "Syntax error")
        syntax_test=$(echo "$syntax_test" | jq --arg status "failed" --arg output "$error_output" --argjson duration "$duration" '.status = $status | .output = $output | .duration = $duration')
        error "  ❌ Syntax check failed"
    fi
    
    # Test 2: Import Check
    local import_test='{
        "name": "import_check",
        "description": "Module import validation",
        "status": "unknown",
        "output": "",
        "duration": 0
    }'
    
    start_time=$(date +%s)
    local module_name=$(basename "$file_path" .py)
    local temp_test_file="/tmp/test_import_$$_$(date +%s).py"
    
    cat > "$temp_test_file" << EOF
import sys
import os
sys.path.insert(0, os.path.dirname('$file_path'))
try:
    import $module_name
    print("Import successful")
except Exception as e:
    print(f"Import failed: {e}")
    sys.exit(1)
EOF
    
    if python3 "$temp_test_file" 2>/dev/null; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        import_test=$(echo "$import_test" | jq --arg status "passed" --arg output "Import check passed" --argjson duration "$duration" '.status = $status | .output = $output | .duration = $duration')
        success "  ✅ Import check passed"
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local error_output=$(python3 "$temp_test_file" 2>&1 || echo "Import error")
        import_test=$(echo "$import_test" | jq --arg status "failed" --arg output "$error_output" --argjson duration "$duration" '.status = $status | .output = $output | .duration = $duration')
        warn "  ⚠️  Import check failed"
    fi
    
    rm -f "$temp_test_file"
    
    # Test 3: Linting (if pylint available)
    local lint_test='{
        "name": "lint_check",
        "description": "Code quality analysis",
        "status": "skipped",
        "output": "pylint not available",
        "duration": 0
    }'
    
    if command -v pylint &> /dev/null; then
        start_time=$(date +%s)
        local lint_output=$(pylint "$file_path" --output-format=text --score=yes 2>&1 || true)
        local lint_score=$(echo "$lint_output" | grep "Your code has been rated" | sed -n 's/.*rated at \([0-9.]*\).*/\1/p')
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        if [ -n "$lint_score" ] && (( $(echo "$lint_score >= 7.0" | bc -l) )); then
            lint_test=$(echo "$lint_test" | jq --arg status "passed" --arg output "Lint score: $lint_score/10" --argjson duration "$duration" '.status = $status | .output = $output | .duration = $duration')
            success "  ✅ Lint check passed (score: $lint_score)"
        else
            lint_test=$(echo "$lint_test" | jq --arg status "failed" --arg output "Lint score: $lint_score/10" --argjson duration "$duration" '.status = $status | .output = $output | .duration = $duration')
            warn "  ⚠️  Lint check failed (score: $lint_score)"
        fi
    fi
    
    # Combine all tests
    test_results=$(echo "$test_results" | jq --argjson syntax "$syntax_test" --argjson import "$import_test" --argjson lint "$lint_test" '.tests = [$syntax, $import, $lint]')
    
    # Save results
    echo "$test_results" > "$result_file"
    
    # Return overall status
    local failed_tests=$(echo "$test_results" | jq '[.tests[] | select(.status == "failed")] | length')
    if [ "$failed_tests" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Test JavaScript/Node.js files
test_javascript_file() {
    local file_path="$1"
    local test_id="$2"
    local result_file="$TEST_RESULTS_DIR/javascript_${test_id}.json"
    
    info "🟨 Testing JavaScript file: $(basename "$file_path")"
    
    local test_results='{
        "file": "'$file_path'",
        "language": "javascript",
        "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
        "tests": []
    }'
    
    # Test 1: Syntax Check
    local syntax_test='{
        "name": "syntax_check",
        "description": "JavaScript syntax validation",
        "status": "unknown",
        "output": "",
        "duration": 0
    }'
    
    local start_time=$(date +%s)
    if node -c "$file_path" 2>/dev/null; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        syntax_test=$(echo "$syntax_test" | jq --arg status "passed" --arg output "Syntax check passed" --argjson duration "$duration" '.status = $status | .output = $output | .duration = $duration')
        success "  ✅ Syntax check passed"
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local error_output=$(node -c "$file_path" 2>&1 || echo "Syntax error")
        syntax_test=$(echo "$syntax_test" | jq --arg status "failed" --arg output "$error_output" --argjson duration "$duration" '.status = $status | .output = $output | .duration = $duration')
        error "  ❌ Syntax check failed"
    fi
    
    # Test 2: ESLint (if available)
    local lint_test='{
        "name": "eslint_check",
        "description": "JavaScript linting",
        "status": "skipped",
        "output": "eslint not available",
        "duration": 0
    }'
    
    if command -v eslint &> /dev/null; then
        start_time=$(date +%s)
        local lint_output=$(eslint "$file_path" 2>&1 || true)
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        if [ -z "$lint_output" ]; then
            lint_test=$(echo "$lint_test" | jq --arg status "passed" --arg output "No linting errors" --argjson duration "$duration" '.status = $status | .output = $output | .duration = $duration')
            success "  ✅ ESLint check passed"
        else
            lint_test=$(echo "$lint_test" | jq --arg status "failed" --arg output "$lint_output" --argjson duration "$duration" '.status = $status | .output = $output | .duration = $duration')
            warn "  ⚠️  ESLint check failed"
        fi
    fi
    
    # Test 3: Basic execution test (if it's a runnable script)
    local execution_test='{
        "name": "execution_test",
        "description": "Basic execution test",
        "status": "skipped",
        "output": "File is a module, not executable",
        "duration": 0
    }'
    
    # Check if file has main execution pattern
    if grep -q "if.*__filename.*require.main" "$file_path" || grep -q "module.exports" "$file_path"; then
        start_time=$(date +%s)
        local temp_test_file="/tmp/test_exec_$$_$(date +%s).js"
        
        cat > "$temp_test_file" << EOF
try {
    require('$file_path');
    console.log('Module loaded successfully');
} catch (error) {
    console.error('Module load failed:', error.message);
    process.exit(1);
}
EOF
        
        if timeout 5 node "$temp_test_file" 2>/dev/null; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            execution_test=$(echo "$execution_test" | jq --arg status "passed" --arg output "Module loaded successfully" --argjson duration "$duration" '.status = $status | .output = $output | .duration = $duration')
            success "  ✅ Execution test passed"
        else
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            local error_output=$(timeout 5 node "$temp_test_file" 2>&1 || echo "Execution failed")
            execution_test=$(echo "$execution_test" | jq --arg status "failed" --arg output "$error_output" --argjson duration "$duration" '.status = $status | .output = $output | .duration = $duration')
            warn "  ⚠️  Execution test failed"
        fi
        
        rm -f "$temp_test_file"
    fi
    
    # Combine all tests
    test_results=$(echo "$test_results" | jq --argjson syntax "$syntax_test" --argjson lint "$lint_test" --argjson execution "$execution_test" '.tests = [$syntax, $lint, $execution]')
    
    # Save results
    echo "$test_results" > "$result_file"
    
    # Return overall status
    local failed_tests=$(echo "$test_results" | jq '[.tests[] | select(.status == "failed")] | length')
    if [ "$failed_tests" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Test TypeScript files
test_typescript_file() {
    local file_path="$1"
    local test_id="$2"
    local result_file="$TEST_RESULTS_DIR/typescript_${test_id}.json"
    
    info "🔷 Testing TypeScript file: $(basename "$file_path")"
    
    local test_results='{
        "file": "'$file_path'",
        "language": "typescript",
        "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
        "tests": []
    }'
    
    # Test 1: TypeScript Compilation
    local compile_test='{
        "name": "typescript_compile",
        "description": "TypeScript compilation check",
        "status": "unknown",
        "output": "",
        "duration": 0
    }'
    
    if command -v tsc &> /dev/null; then
        local start_time=$(date +%s)
        if tsc --noEmit "$file_path" 2>/dev/null; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            compile_test=$(echo "$compile_test" | jq --arg status "passed" --arg output "TypeScript compilation passed" --argjson duration "$duration" '.status = $status | .output = $output | .duration = $duration')
            success "  ✅ TypeScript compilation passed"
        else
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            local error_output=$(tsc --noEmit "$file_path" 2>&1 || echo "Compilation error")
            compile_test=$(echo "$compile_test" | jq --arg status "failed" --arg output "$error_output" --argjson duration "$duration" '.status = $status | .output = $output | .duration = $duration')
            error "  ❌ TypeScript compilation failed"
        fi
    else
        compile_test=$(echo "$compile_test" | jq --arg status "skipped" --arg output "TypeScript compiler not available" '.status = $status | .output = $output')
        warn "  ⚠️  TypeScript compiler not available"
    fi
    
    # Combine all tests
    test_results=$(echo "$test_results" | jq --argjson compile "$compile_test" '.tests = [$compile]')
    
    # Save results
    echo "$test_results" > "$result_file"
    
    # Return overall status
    local failed_tests=$(echo "$test_results" | jq '[.tests[] | select(.status == "failed")] | length')
    if [ "$failed_tests" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Test a single file based on its extension
test_file() {
    local file_path="$1"
    local test_id="${2:-$(date +%s)_$$}"
    
    if [ ! -f "$file_path" ]; then
        error "File not found: $file_path"
        return 1
    fi
    
    local file_ext="${file_path##*.}"
    local test_passed=false
    
    case "$file_ext" in
        py)
            if test_python_file "$file_path" "$test_id"; then
                test_passed=true
            fi
            ;;
        js)
            if test_javascript_file "$file_path" "$test_id"; then
                test_passed=true
            fi
            ;;
        ts|tsx)
            if test_typescript_file "$file_path" "$test_id"; then
                test_passed=true
            fi
            ;;
        jsx)
            # Treat JSX as JavaScript
            if test_javascript_file "$file_path" "$test_id"; then
                test_passed=true
            fi
            ;;
        *)
            warn "Unsupported file type: $file_ext for file $file_path"
            return 0  # Don't fail for unsupported types
            ;;
    esac
    
    if [ "$test_passed" = true ]; then
        success "🎉 All tests passed for $(basename "$file_path")"
        return 0
    else
        error "💥 Some tests failed for $(basename "$file_path")"
        return 1
    fi
}

# Test all files in codebase
test_all_files() {
    info "🧪 Running comprehensive tests on all codebase files"
    
    local total_files=0
    local passed_files=0
    local failed_files=0
    
    # Find all supported files
    local files=$(find "$CODEBASE_DIR" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \))
    
    for file in $files; do
        ((total_files++))
        
        if test_file "$file" "batch_$(date +%s)_$total_files"; then
            ((passed_files++))
        else
            ((failed_files++))
        fi
    done
    
    # Update summary
    local summary='{
        "test_runs": [],
        "total_tests": '$total_files',
        "passed_tests": '$passed_files',
        "failed_tests": '$failed_files',
        "last_updated": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
    }'
    
    echo "$summary" > "$TEST_RESULTS_DIR/test_summary.json"
    
    # Final report
    info "📊 Test Summary:"
    info "   Total files tested: $total_files"
    success "   Passed: $passed_files"
    if [ $failed_files -gt 0 ]; then
        error "   Failed: $failed_files"
    else
        info "   Failed: $failed_files"
    fi
    
    return $failed_files
}

# Generate test report
generate_report() {
    info "📋 Generating test report..."
    
    local report_file="$TEST_RESULTS_DIR/test_report.html"
    
    cat > "$report_file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Collaborative Agents - Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #f0f0f0; padding: 20px; border-radius: 5px; }
        .test-file { margin: 20px 0; border: 1px solid #ddd; border-radius: 5px; }
        .test-header { background: #e8f4f8; padding: 10px; font-weight: bold; }
        .test-content { padding: 15px; }
        .passed { color: green; }
        .failed { color: red; }
        .skipped { color: orange; }
        .test-item { margin: 10px 0; padding: 10px; background: #f9f9f9; border-radius: 3px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🧪 Collaborative Agents Test Report</h1>
        <p>Generated on: <span id="timestamp"></span></p>
    </div>
    <div id="test-results"></div>
    <script>
        document.getElementById('timestamp').textContent = new Date().toISOString();
        // Test results will be populated by the script
    </script>
</body>
</html>
EOF
    
    success "Test report generated: $report_file"
}

# Main function
main() {
    case "${1:-test-all}" in
        test-file)
            if [ -z "${2:-}" ]; then
                error "Usage: $0 test-file <file_path>"
                exit 1
            fi
            init_test_env
            test_file "$2"
            ;;
        test-all)
            init_test_env
            test_all_files
            generate_report
            ;;
        report)
            generate_report
            ;;
        clean)
            rm -rf "$TEST_RESULTS_DIR"
            success "Test results cleaned"
            ;;
        --help|-h)
            echo "Usage: $0 [command] [options]"
            echo ""
            echo "Commands:"
            echo "  test-file <file>  Test a specific file"
            echo "  test-all          Test all files in codebase (default)"
            echo "  report            Generate HTML test report"
            echo "  clean             Clean test results"
            echo "  --help            Show this help"
            ;;
        *)
            error "Unknown command: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"