# SEO-Optimized Media File Naming Strategy

## Overview

This document outlines the implementation strategy for SEO-optimized file naming in Ghost CFML editor cards. The approach combines SEO benefits with user-friendly original filenames to improve content discoverability while maintaining file recognition.

## File Naming Convention

### Primary Format
```
{post-slug}_{YYYYMMDD}_{original-filename}
```

### Components Breakdown
- **`{post-slug}`**: SEO-friendly post identifier
- **`{YYYYMMDD}`**: Upload date for chronological organization
- **`{original-filename}`**: Sanitized original filename for user recognition

## Examples

### Image Cards
**Original Upload**: `sunset-beach.jpg`
**SEO Optimized**: `my-travel-blog_20250128_sunset-beach.jpg`

**Original Upload**: `camera-comparison.png`  
**SEO Optimized**: `photography-guide_20250128_camera-comparison.png`

### Video Cards
**Original Upload**: `tutorial-intro.mp4`
**SEO Optimized**: `coding-bootcamp_20250128_tutorial-intro.mp4`

**Original Upload**: `product-demo.webm`
**SEO Optimized**: `software-review_20250128_product-demo.webm`

### Audio Cards
**Original Upload**: `podcast-episode-1.mp3`
**SEO Optimized**: `weekly-tech-show_20250128_podcast-episode-1.mp3`

**Original Upload**: `interview-audio.wav`
**SEO Optimized**: `founder-stories_20250128_interview-audio.wav`

## Conflict Resolution

### Duplicate Filenames
When identical filenames exist, append incremental numbers:

```
my-travel-blog_20250128_sunset-beach.jpg     (first upload)
my-travel-blog_20250128_sunset-beach_1.jpg   (second upload)
my-travel-blog_20250128_sunset-beach_2.jpg   (third upload)
```

### Algorithm
1. Generate base SEO filename
2. Check if file exists in target directory
3. If exists, append `_1`, then `_2`, etc.
4. Continue until unique filename found

## Directory Structure

Following Ghost CMS patterns, organize files by date:

```
/ghost/content/
├── images/
│   ├── 2025/
│   │   ├── 01/
│   │   │   ├── blog-post-1_20250115_hero-image.jpg
│   │   │   └── tutorial-guide_20250120_screenshot.png
│   │   └── 02/
│   │       └── news-update_20250205_featured-photo.jpg
├── videos/
│   ├── coding-tutorial_20250110_intro-video.mp4
│   └── product-demo_20250115_walkthrough.webm
└── audio/
    ├── podcast-ep1_20250108_full-episode.mp3
    └── interview_20250112_ceo-talk.wav
```

## Implementation Details

### Required Data for Upload Handlers

Each upload handler needs access to:
- **Post Slug**: From the current post being edited
- **Upload Date**: Current date (YYYYMMDD format)
- **Original Filename**: User's uploaded filename (sanitized)

### Post Context Passing

JavaScript card implementations must pass post data:

```javascript
// Example for image card upload
const formData = new FormData();
formData.append('file', file);
formData.append('type', 'content');
formData.append('postSlug', currentPostSlug);  // New parameter
formData.append('uploadDate', getCurrentDate()); // New parameter
```

### CFML Upload Handler Modifications

Update upload handlers to generate SEO filenames:

```cfml
<!--- Get post context --->
<cfparam name="form.postSlug" default="">
<cfparam name="form.uploadDate" default="#dateFormat(now(), 'yyyymmdd')#">

<!--- Build SEO filename --->
<cfif len(trim(form.postSlug)) gt 0>
    <cfset seoPrefix = form.postSlug & "_" & form.uploadDate>
    <cfset originalName = uploadResult.serverFile>
    <cfset sanitizedOriginal = reReplace(originalName, "[^a-zA-Z0-9._-]", "_", "all")>
    <cfset sanitizedOriginal = reReplace(sanitizedOriginal, "_+", "_", "all")>
    <cfset seoFileName = seoPrefix & "_" & sanitizedOriginal>
    
    <!--- Handle conflicts --->
    <cfset finalFileName = seoFileName>
    <cfset counter = 1>
    <cfloop condition="fileExists(uploadDir & finalFileName)">
        <cfset fileExtension = listLast(seoFileName, ".")>
        <cfset baseFileName = listDeleteAt(seoFileName, listLen(seoFileName, "."), ".")>
        <cfset finalFileName = baseFileName & "_" & counter & "." & fileExtension>
        <cfset counter = counter + 1>
    </cfloop>
    
    <!--- Rename uploaded file --->
    <cffile action="rename" 
            source="#uploadDir##uploadResult.serverFile#" 
            destination="#uploadDir##finalFileName#">
    <cfset uploadResult.serverFile = finalFileName>
</cfif>
```

## File Sanitization Rules

### Original Filename Cleaning
- Replace spaces with underscores: `my file.jpg` → `my_file.jpg`
- Remove special characters: `file@#$.jpg` → `file___.jpg`
- Collapse multiple underscores: `file___name.jpg` → `file_name.jpg`
- Preserve hyphens and dots: `file-name.v2.jpg` → `file-name.v2.jpg`

### Post Slug Sanitization
- Convert to lowercase
- Replace spaces with hyphens: `My Blog Post` → `my-blog-post`
- Remove special characters except hyphens
- Limit length to 50 characters for filename compatibility

## SEO Benefits

### Search Engine Optimization
- **Descriptive URLs**: Filenames contain relevant keywords
- **Content Context**: Post slug provides topical relevance
- **Date Organization**: Chronological structure aids indexing
- **User Recognition**: Original names maintain usability

### Example SEO Impact
**Before**: `/ghost/content/images/IMG_1234.jpg`
**After**: `/ghost/content/images/2025/01/travel-photography-tips_20250128_mountain-sunrise.jpg`

The optimized filename provides:
- Topic context (`travel-photography-tips`)
- Date relevance (`20250128`)
- Content description (`mountain-sunrise`)

## Implementation Phases

### Phase 1: Image Cards ✨ Priority
- [ ] Update `/ghost/admin/ajax/upload-image.cfm`
- [ ] Modify image card JavaScript to pass post context
- [ ] Test with various image formats and sizes
- [ ] Validate filename sanitization

### Phase 2: Video Cards
- [ ] Update `/ghost/admin/ajax/upload-video.cfm`
- [ ] Modify video card JavaScript
- [ ] Handle video-specific metadata
- [ ] Test with different video formats

### Phase 3: Audio Cards
- [ ] Update `/ghost/admin/ajax/upload-audio.cfm`
- [ ] Modify audio card JavaScript
- [ ] Handle audio metadata
- [ ] Test with various audio formats

### Phase 4: File Cards (Optional)
- [ ] Update `/ghost/admin/ajax/upload-file.cfm`
- [ ] Handle document/file uploads
- [ ] Consider file type restrictions

## Testing Strategy

### Test Cases
1. **Normal Upload**: Standard filename with post context
2. **Special Characters**: Filenames with spaces, symbols
3. **Long Filenames**: Test filename length limits
4. **Duplicate Names**: Multiple files with same original name
5. **Missing Context**: Uploads without post slug (fallback)
6. **Unicode Characters**: International filename support

### Validation Checklist
- [ ] SEO filename generation works correctly
- [ ] Conflict resolution prevents overwrites
- [ ] File permissions set properly (644)
- [ ] Web URLs generate correctly
- [ ] Database updates reflect new filenames
- [ ] Backward compatibility maintained

## Edge Cases

### Missing Post Context
If post slug unavailable, fallback to date-only prefix:
```
20250128_original-filename.jpg
```

### Very Long Filenames
Truncate components to prevent filesystem limits:
- Post slug: Max 50 characters
- Original filename: Max 100 characters
- Total filename: Max 255 characters

### Special Characters in Post Slugs
Handle international and special characters:
```javascript
// JavaScript slug generation
function generateSlug(title) {
    return title
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '') // Remove diacritics
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-+|-+$/g, '');
}
```

## Database Considerations

### Storage Impact
- Longer filenames require adequate database column lengths
- Consider indexing on filename patterns for search
- Track original vs. SEO filenames for migration

### Migration Strategy
- Existing files remain unchanged
- New uploads use SEO naming
- Optional migration script for existing files
- Maintain URL redirects if needed

## Performance Considerations

### File System Impact
- Longer filenames use more inode space
- Directory organization improves file access
- Consider filesystem limits (ext4: 255 characters)

### Web Performance
- Descriptive URLs may be longer but more cacheable
- CDN considerations for path-based caching
- Gzip compression for filename repetition

## Monitoring and Analytics

### Success Metrics
- SEO ranking improvements for image searches
- File organization efficiency
- User satisfaction with file recognition
- System performance impact

### Logging Strategy
```cfml
<!--- Log SEO filename generation --->
<cflog file="ghost-seo-naming" 
       text="Generated SEO filename: #originalName# → #seoFileName# for post: #postSlug#">
```

## Best Practices

### Do's ✅
- Keep post slugs descriptive and concise
- Preserve original filename structure
- Use consistent date formatting
- Handle conflicts gracefully
- Maintain backward compatibility

### Don'ts ❌
- Don't modify existing file URLs without redirects
- Don't exceed filesystem filename limits
- Don't remove file extensions
- Don't ignore special character sanitization
- Don't forget to update database references

## Future Enhancements

### Potential Improvements
- **Alt text integration**: Include image alt text in filename
- **Category prefixes**: Add post category to filename
- **Language codes**: Support multi-language sites
- **Version tracking**: Handle file revisions
- **Bulk migration**: Tool for existing file renaming

### Integration Opportunities
- **CDN optimization**: Path-based cache strategies
- **Search integration**: Filename-based content discovery
- **Analytics tracking**: File access patterns
- **SEO reporting**: Filename effectiveness metrics

---

## Implementation Notes

This strategy balances SEO optimization with practical file management needs. The approach maintains user-friendly original filenames while adding contextual SEO value through post association and date organization.

The implementation should be done incrementally, starting with image cards as the highest priority, followed by video and audio cards. Each phase should include thorough testing to ensure compatibility with existing functionality.

**Last Updated**: January 28, 2025
**Status**: Implementation Ready
**Priority**: High