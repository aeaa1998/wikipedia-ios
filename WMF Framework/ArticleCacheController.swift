
import Foundation

public final class ArticleCacheController: CacheController {
    
    override public func toggleCache(url: URL) {
        guard let key = url.wmf_databaseKey else {
            return
        }
        
        if isCached(url: url) {
            dbWriter.remove(groupKey: key, itemKey: key)
        } else {
            dbWriter.add(url: url, groupKey: key, itemKey: key)
        }
    }
    
    public func cacheFromMigration(desktopArticleURL: URL, itemKey: String? = nil, content: String, mimeType: String) { //articleURL should be desktopURL
        
        guard let articleDBWriter = dbWriter as? ArticleCacheDBWriter,
        let articleFileWriter = fileWriter as? ArticleCacheFileWriter else {
            return
        }
        
        articleDBWriter.cacheMobileHtmlFromMigration(desktopArticleURL: desktopArticleURL) { (item) in
            articleFileWriter.migrateCachedContent(content: content, cacheItem: item, mimeType: mimeType) {
                articleDBWriter.migratedCacheItemFile(cacheItem: item) {
                    print("success")
                }
            }
        }
    }
}
