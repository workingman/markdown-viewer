# Spec 8: Vi-Style Search

## Overview
Implement vim-style search functionality with `/` to open search, real-time highlighting, and n/N for navigating matches.

## Requirements

### Key Bindings
| Key | Action |
|-----|--------|
| `/` | Open search box |
| `Esc` | Close search box, clear highlights |
| `n` | Jump to next match |
| `N` | Jump to previous match |
| `Enter` | Jump to next match and close search box |
| `Shift+Enter` | Jump to previous match and close search box |

### Search Box UI
- Fixed position at top of viewport
- Shows current match index and total count (e.g., "3/12")
- Semi-transparent background
- Auto-focuses input when opened
- Styled consistently with light/dark themes

### Match Highlighting
- Real-time highlighting as user types
- Distinct highlight color for all matches (yellow background)
- Current match has different highlight (orange background)
- Highlights clear when search closes

### Behavior
- Search is case-insensitive
- Empty search clears all highlights
- First match is automatically selected when search starts
- Wraps around when reaching end/beginning of matches

## Technical Approach

### CSS Additions
```css
/* Search box */
.search-box {
    position: fixed;
    top: 10px;
    right: 10px;
    background: rgba(255, 255, 255, 0.95);
    border: 1px solid #d0d7de;
    border-radius: 6px;
    padding: 8px 12px;
    display: none;
    align-items: center;
    gap: 8px;
    z-index: 1000;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}
.search-box.visible { display: flex; }
.search-box input {
    border: 1px solid #d0d7de;
    border-radius: 4px;
    padding: 4px 8px;
    font-size: 14px;
    width: 200px;
    outline: none;
}
.search-box input:focus { border-color: #0969da; }
.search-box .count {
    font-size: 12px;
    color: #656d76;
    min-width: 40px;
}

/* Match highlights */
.search-match { background-color: rgba(255, 230, 0, 0.5); }
.search-match-current { background-color: rgba(255, 150, 0, 0.7); }

/* Dark theme variants */
@media (prefers-color-scheme: dark) {
    .search-box {
        background: rgba(30, 30, 30, 0.95);
        border-color: #444;
    }
    .search-box input {
        background: #2d2d2d;
        border-color: #444;
        color: #d4d4d4;
    }
    .search-box input:focus { border-color: #58a6ff; }
    .search-box .count { color: #999; }
}
```

### HTML Addition
```html
<div class="search-box" id="searchBox">
    <input type="text" id="searchInput" placeholder="Search...">
    <span class="count" id="searchCount"></span>
</div>
```

### JavaScript Implementation
```javascript
(function() {
    var searchBox = document.getElementById('searchBox');
    var searchInput = document.getElementById('searchInput');
    var searchCount = document.getElementById('searchCount');
    var matches = [];
    var currentMatchIndex = -1;

    function clearHighlights() {
        document.querySelectorAll('.search-match, .search-match-current').forEach(function(el) {
            var parent = el.parentNode;
            parent.replaceChild(document.createTextNode(el.textContent), el);
            parent.normalize();
        });
        matches = [];
        currentMatchIndex = -1;
    }

    function highlightMatches(query) {
        clearHighlights();
        if (!query) {
            searchCount.textContent = '';
            return;
        }

        var content = document.getElementById('content');
        var walker = document.createTreeWalker(content, NodeFilter.SHOW_TEXT, null, false);
        var textNodes = [];
        while (walker.nextNode()) textNodes.push(walker.currentNode);

        var regex = new RegExp('(' + query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'gi');

        textNodes.forEach(function(node) {
            if (node.nodeValue.match(regex)) {
                var span = document.createElement('span');
                span.innerHTML = node.nodeValue.replace(regex, '<mark class="search-match">$1</mark>');
                node.parentNode.replaceChild(span, node);
            }
        });

        matches = Array.from(document.querySelectorAll('.search-match'));
        if (matches.length > 0) {
            currentMatchIndex = 0;
            updateCurrentMatch();
        }
        updateCount();
    }

    function updateCurrentMatch() {
        document.querySelectorAll('.search-match-current').forEach(function(el) {
            el.classList.remove('search-match-current');
        });
        if (matches.length > 0 && currentMatchIndex >= 0) {
            matches[currentMatchIndex].classList.add('search-match-current');
            matches[currentMatchIndex].scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    }

    function updateCount() {
        if (matches.length > 0) {
            searchCount.textContent = (currentMatchIndex + 1) + '/' + matches.length;
        } else if (searchInput.value) {
            searchCount.textContent = '0/0';
        } else {
            searchCount.textContent = '';
        }
    }

    function nextMatch() {
        if (matches.length === 0) return;
        currentMatchIndex = (currentMatchIndex + 1) % matches.length;
        updateCurrentMatch();
        updateCount();
    }

    function prevMatch() {
        if (matches.length === 0) return;
        currentMatchIndex = (currentMatchIndex - 1 + matches.length) % matches.length;
        updateCurrentMatch();
        updateCount();
    }

    function openSearch() {
        searchBox.classList.add('visible');
        searchInput.focus();
        searchInput.select();
    }

    function closeSearch() {
        searchBox.classList.remove('visible');
        clearHighlights();
        searchCount.textContent = '';
        searchInput.value = '';
    }

    // Global key handler for opening search and n/N navigation
    document.addEventListener('keydown', function(e) {
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
            // Handle Escape in search input
            if (e.target === searchInput && e.key === 'Escape') {
                closeSearch();
                e.preventDefault();
            }
            // Handle Enter in search input
            if (e.target === searchInput && e.key === 'Enter') {
                if (e.shiftKey) {
                    prevMatch();
                } else {
                    nextMatch();
                }
                closeSearch();
                e.preventDefault();
            }
            return;
        }

        if (e.key === '/') {
            e.preventDefault();
            openSearch();
        } else if (e.key === 'n' && !e.ctrlKey && !e.metaKey) {
            if (matches.length > 0) nextMatch();
        } else if (e.key === 'N' && !e.ctrlKey && !e.metaKey) {
            if (matches.length > 0) prevMatch();
        }
    });

    // Real-time search as user types
    searchInput.addEventListener('input', function() {
        highlightMatches(searchInput.value);
    });
})();
```

## Files to Modify
- `Markdown Viewer/WebView.swift` - Add search CSS, HTML, and JavaScript

## Acceptance Criteria
- [ ] `/` opens search box at top right
- [ ] Search box shows input field and match count
- [ ] Typing highlights all matches in real-time
- [ ] Current match has distinct highlight color
- [ ] `n` jumps to next match
- [ ] `N` jumps to previous match
- [ ] `Enter` jumps to next and closes search
- [ ] `Shift+Enter` jumps to previous and closes search
- [ ] `Esc` closes search and clears highlights
- [ ] Match count shows "X/Y" format
- [ ] Search wraps around at document boundaries
- [ ] Works correctly in both light and dark themes
- [ ] Existing tests continue to pass
