import UniformTypeIdentifiers

extension UTType {
    /// UTType for markdown documents
    /// Supports both `.md` and `.markdown` file extensions
    /// Conforms to `public.text` hierarchy
    static var markdown: UTType {
        UTType(importedAs: "net.daringfireball.markdown")
    }
}
