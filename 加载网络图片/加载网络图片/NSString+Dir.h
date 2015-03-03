//
//  NSString+Dir.h
//  02-沙盒复习
//
//  Created by apple on 15/1/11.
//

#import <Foundation/Foundation.h>

@interface NSString (Dir)

/**
 *  返回缓存路径的完整路径名
 */
- (NSString *)cacheDir;
/**
 *  返回文档路径的完整路径名
 */
- (NSString *)documentDir;
/**
 *  返回临时路径的完整路径名
 */
- (NSString *)tmpDir;

@end
