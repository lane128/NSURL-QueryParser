//
//  NSURL+QueryParser.h
//  UnitTests
//
//  Created by Adam Wang on 2022/1/17.
//  Copyright (c) 2013 Adam Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (QueryParser)

- (nullable NSDictionary *)qp_queryDictionary;

- (NSURL *)qp_removeQuery;

- (NSURL *)qp_appendingQueryDictionary:(NSDictionary *)queryDictionary;

- (NSURL *)qp_appendingQueryDictionary:(NSDictionary *)queryDictionary sortedKeys:(BOOL)sortedKeys;

- (NSURL *)qp_replaceQueryByQueryDictionary:(NSDictionary *)queryDictionary;

- (NSURL *)qp_replaceQueryByQueryDictionary:(NSDictionary *)queryDictionary sortedKeys:(BOOL)sortedKeys;

@end

@interface NSString (QueryParser)

- (nullable NSURL *)qp_URL;

- (nullable NSString *)qp_queryString;

- (nullable NSDictionary *)qp_queryDictionary;

- (NSString *)qp_removeQuery;

- (NSString *)qp_appendingQueryDictionary:(NSDictionary *)queryDictionary;

- (NSString *)qp_appendingQueryDictionary:(NSDictionary *)queryDictionary sortedKeys:(BOOL)sortedKeys;

- (NSString *)qp_replaceQueryByQueryDictionary:(NSDictionary *)queryDictionary;

- (NSString *)qp_replaceQueryByQueryDictionary:(NSDictionary *)queryDictionary sortedKeys:(BOOL)sortedKeys;

@end

@interface NSDictionary (QueryParser)

- (nullable NSString *)qp_queryString;

- (nullable NSString *)qp_queryStringBySortedKeys:(BOOL)sortedKeys;

- (nullable NSDictionary *)qp_removeNullValues;

@end

NS_ASSUME_NONNULL_END
