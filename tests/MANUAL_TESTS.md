# Manual Testing Guide for Copy-on-Select Mode

## Prerequisites
- KDE Plasma 6 on Wayland
- koverlay installed and running

## Test Cases

### Test 1: Copy Mode Activation
**Steps:**
1. Bind a hotkey to `qdbus org.erx.KOverlay /Overlay org.erx.KOverlay.ToggleCopyMode`
2. Press the hotkey
3. Verify overlay becomes visible and interactive

**Expected:**
- Overlay should appear
- Overlay should accept mouse clicks (not click-through)
- Keyboard focus should be on the overlay

**Status:** ⬜ Pass ⬜ Fail

---

### Test 2: Mouse Text Selection
**Steps:**
1. Activate copy mode
2. Click and drag mouse across text in overlay
3. Verify text is highlighted

**Expected:**
- Text should be visually selected/highlighted
- Selection should persist after releasing mouse button

**Status:** ⬜ Pass ⬜ Fail

---

### Test 3: Keyboard Text Selection
**Steps:**
1. Activate copy mode
2. Click to place cursor in text
3. Use Shift+Arrow keys to select text
4. Verify text is highlighted

**Expected:**
- Text should be selected as arrow keys are pressed
- Selection should update properly with Shift+Left/Right/Up/Down

**Status:** ⬜ Pass ⬜ Fail

---

### Test 4: Select All (Ctrl+A)
**Steps:**
1. Activate copy mode
2. Press Ctrl+A
3. Verify all text is selected

**Expected:**
- All text in overlay should be highlighted

**Status:** ⬜ Pass ⬜ Fail

---

### Test 5: Copy on De-focus (Click Away)
**Steps:**
1. Activate copy mode
2. Select some text with mouse or keyboard
3. Click outside the overlay window
4. Check clipboard contents (e.g., paste into another application)

**Expected:**
- Selected text should be copied to clipboard
- Selection should be cleared (no longer highlighted)

**Status:** ⬜ Pass ⬜ Fail

---

### Test 6: Copy on De-focus (Alt+Tab)
**Steps:**
1. Activate copy mode
2. Select some text
3. Press Alt+Tab to switch to another window
4. Check clipboard contents

**Expected:**
- Selected text should be copied to clipboard
- Selection should be cleared

**Status:** ⬜ Pass ⬜ Fail

---

### Test 7: Copy Mode Deactivation
**Steps:**
1. Activate copy mode
2. Select some text
3. Press copy mode hotkey again
4. Verify overlay is hidden
5. Check clipboard

**Expected:**
- Selected text should be copied to clipboard before hiding
- Overlay should become hidden
- Overlay should be click-through again when shown in normal mode

**Status:** ⬜ Pass ⬜ Fail

---

### Test 8: No Clipboard Flooding
**Steps:**
1. Activate copy mode
2. Select text
3. Change selection multiple times without de-focusing
4. Monitor clipboard (should not change yet)
5. De-focus overlay
6. Check clipboard

**Expected:**
- Clipboard should only update once when de-focusing
- Not every time selection changes

**Status:** ⬜ Pass ⬜ Fail

---

### Test 9: Standard Mode Independence
**Steps:**
1. Use standard overlay toggle (not copy mode)
2. Verify overlay is click-through
3. Activate copy mode
4. Deactivate copy mode
5. Use standard overlay toggle again
6. Verify still click-through

**Expected:**
- Copy mode should not affect standard overlay mode
- Standard mode should remain click-through

**Status:** ⬜ Pass ⬜ Fail

---

### Test 10: Multi-line Text Selection
**Steps:**
1. Configure overlay with multi-line text
2. Activate copy mode
3. Select text spanning multiple lines
4. De-focus and check clipboard

**Expected:**
- Should be able to select across multiple lines
- Newlines should be preserved in clipboard

**Status:** ⬜ Pass ⬜ Fail

---

## Notes
- Test on KDE Plasma 6 Wayland
- Test with different text configurations (font sizes, styles, etc.)
- Verify no memory leaks or crashes during extended use
