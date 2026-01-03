# Spec 5: Internal Anchor Navigation

## Overview
Enable internal anchor links (e.g., `[Section](#section-name)`) to scroll smoothly to their targets within the rendered markdown, with visual highlighting to help users locate the target.

## Current State
- markdown-it-anchor plugin is already integrated and generates IDs on headings
- Anchor links work but use browser default behavior (instant jump, no visual feedback)
- Navigation delegate allows fragment-only URLs

## Requirements

### 1. Smooth Scrolling to Anchors
- Intercept anchor link clicks via JavaScript
- Scroll to target element smoothly
- Smart scroll behavior:
  - **Instant scroll** for long distances (> 2 viewport heights)
  - **Smooth scroll** for short distances (<= 2 viewport heights)

### 2. Animated Highlight Effect
- When scrolling to an anchor target, briefly highlight the element
- Highlight animation:
  - Yellow/gold background flash that fades out over ~1.5 seconds
  - Works in both light and dark themes
  - Applied to the target heading element

### 3. Offset Handling
- Scroll target should have slight offset from top (e.g., 16px) so heading isn't flush against window edge

## Technical Approach

### JavaScript Implementation (in wrapInHTML)
1. Add click event listener for anchor links (`a[href^="#"]`)
2. On click:
   - Prevent default navigation
   - Find target element by ID
   - Calculate distance to determine scroll behavior
   - Scroll to target with appropriate behavior
   - Apply highlight animation class
3. Add CSS for highlight animation using `@keyframes`

### CSS Additions
```css
/* Anchor target highlight animation */
@keyframes anchor-highlight {
    0% { background-color: rgba(255, 208, 0, 0.5); }
    100% { background-color: transparent; }
}

.anchor-highlight {
    animation: anchor-highlight 1.5s ease-out;
}

/* Dark theme variant */
@keyframes anchor-highlight-dark {
    0% { background-color: rgba(255, 208, 0, 0.3); }
    100% { background-color: transparent; }
}

html.theme-dark .anchor-highlight,
@media (prefers-color-scheme: dark) {
    html:not(.theme-light) .anchor-highlight {
        animation: anchor-highlight-dark 1.5s ease-out;
    }
}
```

### JavaScript Additions
```javascript
// Anchor navigation handler
document.addEventListener('click', function(e) {
    var link = e.target.closest('a[href^="#"]');
    if (!link) return;

    var targetId = link.getAttribute('href').slice(1);
    var target = document.getElementById(targetId);
    if (!target) return;

    e.preventDefault();

    // Calculate distance for smart scroll
    var targetRect = target.getBoundingClientRect();
    var distance = Math.abs(targetRect.top);
    var viewportHeight = window.innerHeight;
    var behavior = distance > viewportHeight * 2 ? 'instant' : 'smooth';

    // Scroll with offset
    var offset = 16;
    var scrollTop = window.scrollY + targetRect.top - offset;
    window.scrollTo({ top: scrollTop, behavior: behavior });

    // Apply highlight
    target.classList.remove('anchor-highlight');
    void target.offsetWidth; // Force reflow to restart animation
    target.classList.add('anchor-highlight');
});
```

## Files to Modify
- `Markdown Viewer/WebView.swift` - Add CSS and JavaScript for anchor navigation

## Acceptance Criteria
- [ ] Clicking an anchor link scrolls to the target heading
- [ ] Short distances use smooth scrolling
- [ ] Long distances (> 2 viewport heights) use instant scrolling
- [ ] Target element is highlighted with a fading yellow background
- [ ] Highlight animation works in both light and dark themes
- [ ] Scroll target has ~16px offset from top of viewport
- [ ] Existing tests continue to pass
