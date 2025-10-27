#!/bin/bash

# Time Tracking App - 测试运行脚本
# 用途：快速运行各种测试配置

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROJECT="time.xcodeproj"
SCHEME="timeTests"
DESTINATION="platform=macOS"

echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}  Time Tracking App - Test Runner${NC}"
echo -e "${GREEN}==================================================${NC}"
echo ""

# 函数：运行测试
run_tests() {
    local test_target=$1
    local test_name=$2
    
    echo -e "${YELLOW}▶ Running: ${test_name}${NC}"
    echo ""
    
    if [ -z "$test_target" ]; then
        xcodebuild test \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            2>&1 | grep -E "(Test|✔|✗|passed|failed|BUILD)"
    else
        xcodebuild test \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -only-testing:"$test_target" \
            2>&1 | grep -E "(Test|✔|✗|passed|failed|BUILD)"
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✔ ${test_name} PASSED${NC}"
    else
        echo -e "${RED}✗ ${test_name} FAILED${NC}"
        exit 1
    fi
    echo ""
}

# 解析命令行参数
case "$1" in
    "all")
        echo "Running all tests..."
        run_tests "" "All Tests"
        ;;
    "integration")
        echo "Running integration tests..."
        run_tests "timeTests/IntegrationTests" "Integration Tests"
        ;;
    "unit")
        echo "Running unit tests..."
        run_tests "timeTests/ActivityDataProcessorTests" "Activity Data Processor Tests"
        run_tests "timeTests/ProjectManagerTests" "Project Manager Tests"
        run_tests "timeTests/ProjectReorderingTests" "Project Reordering Tests"
        ;;
    "quick")
        echo "Running quick test suite (essential tests only)..."
        run_tests "timeTests/IntegrationTests/testEnvironmentObjectsInjection" "Environment Objects Test"
        run_tests "timeTests/IntegrationTests/testProjectCRUDFlow" "Project CRUD Test"
        run_tests "timeTests/IntegrationTests/testActivityTrackingFlow" "Activity Tracking Test"
        ;;
    "coverage")
        echo "Running tests with code coverage..."
        xcodebuild test \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -enableCodeCoverage YES
        
        echo ""
        echo -e "${GREEN}Coverage report generated at:${NC}"
        echo "$HOME/Library/Developer/Xcode/DerivedData/time-*/Logs/Test/"
        ;;
    "build")
        echo "Building project..."
        xcodebuild build \
            -project "$PROJECT" \
            -scheme "time" \
            -configuration Debug
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✔ Build SUCCEEDED${NC}"
        else
            echo -e "${RED}✗ Build FAILED${NC}"
            exit 1
        fi
        ;;
    "clean")
        echo "Cleaning build artifacts..."
        xcodebuild clean \
            -project "$PROJECT" \
            -scheme "$SCHEME"
        echo -e "${GREEN}✔ Clean completed${NC}"
        ;;
    *)
        echo "Usage: $0 {all|integration|unit|quick|coverage|build|clean}"
        echo ""
        echo "Commands:"
        echo "  all         - Run all tests"
        echo "  integration - Run only integration tests"
        echo "  unit        - Run only unit tests"
        echo "  quick       - Run essential tests only (fast)"
        echo "  coverage    - Run tests with code coverage analysis"
        echo "  build       - Build the project"
        echo "  clean       - Clean build artifacts"
        echo ""
        echo "Examples:"
        echo "  ./run_tests.sh all"
        echo "  ./run_tests.sh integration"
        echo "  ./run_tests.sh quick"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}  Test run completed successfully!${NC}"
echo -e "${GREEN}==================================================${NC}"
