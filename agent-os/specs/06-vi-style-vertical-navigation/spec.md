# Spec 6: Vi-Style Vertical Navigation

## Overview
Implement vim-style keyboard navigation for vertical scrolling, allowing power users to navigate documents efficiently without using the mouse or trackpad.

## Requirements

### Key Bindings
| Key | Action | Scroll Amount |
|-----|--------|---------------|
| `j` | Scroll down | ~40px (one line) |
| `k` | Scroll up | ~40px (one line) |
| `gg` | Go to top | Instant jump to top |
| `G` | Go to bottom | Instant jump to bottom |
| `Ctrl+d` | Half-page down | 50% of viewport height |
| `Ctrl+u` | Half-page up | 50% of viewport height |
| `Ctrl+f` | Full-page down | 100% of viewport height |
| `Ctrl+b` | Full-page up | 100% of viewport height |

### Scroll Behavior
- **Line scroll (j/k)**: Smooth, small increments (~40px matches line height)
- **Half/full page (Ctrl+d/u/f/b)**: Smooth scroll for better orientation
- **Top/bottom (gg/G)**: Instant jump

### Implementation Notes
- `gg` requires tracking key sequence (two consecutive 'g' presses within ~500ms)
- Keys should only work when not in a text input or search field
- Scroll should respect document boundaries (no overscroll)

## Technical Approach

### JavaScript Implementation
Add keyboard event listener in the WebView HTML that:
1. Tracks last key press for `gg` sequence detection
2. Handles all vi-style key bindings
3. Uses `window.scrollBy()` for relative scrolling
4. Uses `window.scrollTo()` for absolute positioning (gg/G)

```javascript
(function() {
    var lastKey = '';
    var lastKeyTime = 0;
    var LINE_HEIGHT = 40;

    document.addEventListener('keydown', function(e) {
        // Ignore if in input field
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;

        var key = e.key;
        var now = Date.now();
        var viewportHeight = window.innerHeight;

        // Handle gg sequence
        if (key === 'g' && !e.ctrlKey && !e.metaKey) {
            if (lastKey === 'g' && (now - lastKeyTime) < 500) {
                window.scrollTo({ top: 0, behavior: 'instant' });
                lastKey = '';
                return;
            }
            lastKey = 'g';
            lastKeyTime = now;
            return;
        }

        // Reset sequence tracking for non-g keys
        lastKey = '';

        // Single key bindings
        switch(key) {
            case 'j':
                window.scrollBy({ top: LINE_HEIGHT, behavior: 'smooth' });
                break;
            case 'k':
                window.scrollBy({ top: -LINE_HEIGHT, behavior: 'smooth' });
                break;
            case 'G':
                if (!e.ctrlKey && !e.metaKey) {
                    window.scrollTo({ top: document.body.scrollHeight, behavior: 'instant' });
                }
                break;
            case 'd':
                if (e.ctrlKey) {
                    e.preventDefault();
                    window.scrollBy({ top: viewportHeight / 2, behavior: 'smooth' });
                }
                break;
            case 'u':
                if (e.ctrlKey) {
                    e.preventDefault();
                    window.scrollBy({ top: -viewportHeight / 2, behavior: 'smooth' });
                }
                break;
            case 'f':
                if (e.ctrlKey) {
                    e.preventDefault();
                    window.scrollBy({ top: viewportHeight, behavior: 'smooth' });
                }
                break;
            case 'b':
                if (e.ctrlKey) {
                    e.preventDefault();
                    window.scrollBy({ top: -viewportHeight, behavior: 'smooth' });
                }
                break;
        }
    });
})();
```

## Files to Modify
- `Markdown Viewer/WebView.swift` - Add vi navigation JavaScript

## Acceptance Criteria
- [ ] `j` scrolls down one line (~40px)
- [ ] `k` scrolls up one line (~40px)
- [ ] `gg` (double-tap g) jumps to top of document
- [ ] `G` jumps to bottom of document
- [ ] `Ctrl+d` scrolls down half a page
- [ ] `Ctrl+u` scrolls up half a page
- [ ] `Ctrl+f` scrolls down a full page
- [ ] `Ctrl+b` scrolls up a full page
- [ ] Keys don't interfere with text input fields
- [ ] Existing tests continue to pass
