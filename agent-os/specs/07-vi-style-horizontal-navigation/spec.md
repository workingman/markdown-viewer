# Spec 7: Vi-Style Horizontal Navigation

## Overview
Implement vim-style keyboard navigation for horizontal scrolling, complementing the vertical navigation from Spec 6.

## Requirements

### Key Bindings
| Key | Action | Scroll Amount |
|-----|--------|---------------|
| `h` | Scroll left | ~40px |
| `l` | Scroll right | ~40px |
| `0` | Go to far left | Instant jump to x=0 |
| `$` | Go to far right | Instant jump to max scroll |

### Scroll Behavior
- **Character scroll (h/l)**: Smooth, small increments (~40px)
- **Far left/right (0/$)**: Instant jump

### Implementation Notes
- Add to existing vi navigation keydown handler
- Keys should only work when not in a text input or search field
- `$` requires Shift key detection (Shift+4 on US keyboards)

## Technical Approach

Add cases to existing switch statement in vi navigation handler:

```javascript
case 'h':
    window.scrollBy({ left: -LINE_HEIGHT, behavior: 'smooth' });
    break;
case 'l':
    window.scrollBy({ left: LINE_HEIGHT, behavior: 'smooth' });
    break;
case '0':
    window.scrollTo({ left: 0, behavior: 'instant' });
    break;
case '$':
    window.scrollTo({ left: document.body.scrollWidth, behavior: 'instant' });
    break;
```

## Files to Modify
- `Markdown Viewer/WebView.swift` - Add h/l/0/$ cases to vi navigation

## Acceptance Criteria
- [ ] `h` scrolls left ~40px
- [ ] `l` scrolls right ~40px
- [ ] `0` jumps to far left
- [ ] `$` jumps to far right
- [ ] Keys don't interfere with text input fields
- [ ] Existing tests continue to pass
