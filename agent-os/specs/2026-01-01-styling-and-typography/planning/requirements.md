# Spec Requirements: Styling and Typography

## Initial Description

Implement GitHub-style CSS, apply default typography settings (18px font, line height, max content width), ensure responsive layout.

## Requirements Discussion

### First Round Questions

**Q1:** What should the base body font size be?
**Answer:** 18px body font (larger than current 14px for readability)

**Q2:** What line height should be used?
**Answer:** 1.6 (already set in current implementation)

**Q3:** What max content width should be applied?
**Answer:** 980px (already set in .markdown-body)

**Q4:** What font family should be used?
**Answer:** Keep system fonts (-apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif)

**Q5:** How should the layout handle smaller window widths?
**Answer:** Content should reflow at smaller window widths (responsive behavior)

**Q6:** How should dark mode be handled?
**Answer:** Already implemented via media query, keep existing dark mode support

**Q7:** What is the scope of this spec?
**Answer:** Refining existing CSS, not adding new features. Focus on typography improvements.

### Existing Code to Reference

**Similar Features Identified:**
- Feature: Current CSS styling - Path: `/Users/gwr/Documents/dev/mdv/Markdown Viewer/WebView.swift`
- The CSS is embedded inline in the `wrapInHTML` method (lines 146-279)
- Current implementation includes: body styling, dark mode, code blocks, blockquotes, tables, headers, lists, links, images, task lists, horizontal rules

**Current CSS Analysis:**
- Body font-size: 14px (to be changed to 18px)
- Line-height: 1.6 (keep as-is)
- Max-width: 980px on .markdown-body (keep as-is)
- Font family: System fonts (keep as-is)
- Dark mode: Via prefers-color-scheme media query (keep as-is)
- Headers: Proper scaling with em units (adjust for new base size)

### Follow-up Questions

No follow-up questions needed. User provided comprehensive pre-answered requirements.

## Visual Assets

### Files Provided:
No visual assets provided.

### Visual Insights:
N/A - No visual files to analyze.

## Requirements Summary

### Functional Requirements
- Increase base body font from 14px to 18px for improved readability
- Maintain existing line-height of 1.6
- Maintain existing max-width of 980px for content container
- Keep system font stack for cross-platform compatibility
- Ensure content reflows properly at smaller window widths
- Preserve existing dark mode support via media query

### Reusability Opportunities
- All existing CSS structure in WebView.swift can be modified in place
- Dark mode color values already established and working
- Header scaling with em units will automatically adjust with new base font size
- Code block and table styling can remain largely unchanged

### Scope Boundaries

**In Scope:**
- Changing body font-size from 14px to 18px
- Ensuring proper spacing and margins match GitHub style
- Verifying responsive behavior works at smaller window sizes
- Maintaining all existing styling (headers, code, tables, blockquotes, etc.)

**Out of Scope:**
- Adding new CSS features or components
- Modifying the dark mode implementation
- Adding syntax highlighting for code blocks
- Typography settings UI (covered in future Settings specs)
- Print-specific styles (covered in Print Support spec)

### Technical Considerations
- CSS is embedded inline in Swift string within WebView.swift
- Changes are isolated to the `<style>` block in the `wrapInHTML` method
- Header sizes use em units relative to body font-size, so they will scale automatically
- Code block font-size (13px) may need review relative to new 18px body size
- No external CSS files; all styling is inline
- WKWebView handles CSS rendering with standard browser behavior
