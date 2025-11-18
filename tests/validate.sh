#!/bin/bash
# Validation script for koverlay copy-on-select implementation

echo "=========================================="
echo "KOverlay Copy-on-Select Mode Validation"
echo "=========================================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS=0
FAIL=0
WARN=0

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    PASS=$((PASS + 1))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    FAIL=$((FAIL + 1))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    WARN=$((WARN + 1))
}

echo "1. Checking source files exist..."
if [ -f "src/overlay_view.h" ] && [ -f "src/overlay_view.cpp" ]; then
    check_pass "Source files found"
else
    check_fail "Missing source files"
    exit 1
fi

echo
echo "2. Checking DBus methods are declared..."
if grep -q "ToggleCopyMode" src/overlay_adaptor.h && \
   grep -q "ShowCopyMode" src/overlay_adaptor.h && \
   grep -q "HideCopyMode" src/overlay_adaptor.h; then
    check_pass "DBus copy mode methods declared"
else
    check_fail "Missing DBus copy mode methods"
fi

echo
echo "3. Checking copy mode state management..."
if grep -q "bool copyMode_" src/overlay_view.h; then
    check_pass "Copy mode state variable found"
else
    check_fail "Missing copy mode state variable"
fi

echo
echo "4. Checking clipboard integration..."
if grep -q "#include <QClipboard>" src/overlay_view.cpp && \
   grep -q "QClipboard" src/overlay_view.cpp; then
    check_pass "Clipboard integration present"
else
    check_fail "Missing clipboard integration"
fi

echo
echo "5. Checking focus event handling..."
if grep -q "QEvent::FocusOut" src/overlay_view.cpp && \
   grep -q "bool event(QEvent" src/overlay_view.h; then
    check_pass "Focus event handling implemented"
else
    check_fail "Missing focus event handling"
fi

echo
echo "6. Checking QML TextEdit implementation..."
if grep -q "TextEdit" src/Overlay.qml && \
   grep -q "selectByMouse" src/Overlay.qml && \
   grep -q "selectByKeyboard" src/Overlay.qml && \
   grep -q "persistentSelection" src/Overlay.qml; then
    check_pass "QML TextEdit with selection properties"
else
    check_fail "Missing QML TextEdit selection properties"
fi

echo
echo "7. Checking Ctrl+A support..."
if grep -q "Qt.Key_A" src/Overlay.qml && \
   grep -q "ControlModifier" src/Overlay.qml; then
    check_pass "Ctrl+A select all support implemented"
else
    check_warn "Ctrl+A support may be missing"
fi

echo
echo "8. Checking selection clearing..."
if grep -q "clearSelection" src/Overlay.qml && \
   grep -q "deselect" src/Overlay.qml; then
    check_pass "Selection clearing mechanism present"
else
    check_fail "Missing selection clearing"
fi

echo
echo "9. Checking input region management..."
if grep -q "applyFullInputRegion" src/overlay_view.cpp && \
   grep -q "applyEmptyInputRegion" src/overlay_view.cpp; then
    check_pass "Input region management implemented"
else
    check_fail "Missing input region management"
fi

echo
echo "10. Checking keyboard interactivity toggle..."
if grep -q "setKeyboardInteractivity" src/overlay_view.cpp; then
    check_pass "Keyboard interactivity toggle present"
else
    check_fail "Missing keyboard interactivity toggle"
fi

echo
echo "11. Verifying copy on de-focus logic..."
if grep -q "FocusOut" src/overlay_view.cpp && \
   grep -q "copySelectionToClipboard" src/overlay_view.cpp; then
    check_pass "Copy on de-focus logic implemented"
else
    check_fail "Missing copy on de-focus logic"
fi

echo
echo "12. Checking QMetaObject::invokeMethod usage..."
if grep -q "QMetaObject::invokeMethod" src/overlay_view.cpp; then
    check_pass "QMetaObject::invokeMethod used for QML interaction"
else
    check_warn "QMetaObject::invokeMethod not found (may use different approach)"
fi

echo
echo "13. Checking for proper includes..."
if grep -q "#include <QEvent>" src/overlay_view.cpp && \
   grep -q "#include <QClipboard>" src/overlay_view.cpp && \
   grep -q "#include <QGuiApplication>" src/overlay_view.cpp; then
    check_pass "All necessary includes present"
else
    check_warn "Some includes may be missing"
fi

echo
echo "14. Checking README documentation..."
if grep -q "ToggleCopyMode" README.md && \
   grep -q "copy-on-select\|Copy-on-Select" README.md; then
    check_pass "README documents copy mode feature"
else
    check_warn "README may be missing copy mode documentation"
fi

echo
echo "=========================================="
echo "Summary:"
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"
echo -e "${YELLOW}Warnings: $WARN${NC}"
echo "=========================================="

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}All critical checks passed!${NC}"
    exit 0
else
    echo -e "${RED}Some checks failed. Please review the implementation.${NC}"
    exit 1
fi
