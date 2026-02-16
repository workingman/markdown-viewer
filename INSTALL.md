# Markdown Viewer — Install

macOS app for viewing `.md` files with live reload.

## Install

1. Unzip `Markdown Viewer.zip`
2. Move `Markdown Viewer.app` to `/Applications/`
3. Clear the quarantine flag (required — the app is ad-hoc signed, not notarized):
   ```
   xattr -cr /Applications/Markdown\ Viewer.app
   ```
4. Open from `/Applications/` or double-click any `.md` file

## Uninstall

```
rm -rf /Applications/Markdown\ Viewer.app
```
