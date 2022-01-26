//
//  NSURL+QueryParser.m
//  UnitTests
//
//  Created by Adam Wang on 2022/1/17.
//  Copyright (c) 2013 Adam Wang. All rights reserved.
//

#import "NSURL+QueryParser.h"

static NSString * const kForwardSlash        = @"/";
static NSString * const kQuerySeparator      = @"&";
static NSString * const kQueryDivider        = @"=";
static NSString * const kQueryBegin          = @"?";
static NSString * const kFragmentSeparator   = @"#";

@implementation NSURL (QueryParser)

- (nullable NSDictionary *)qp_queryDictionary {
    return self.absoluteString.qp_queryDictionary;
}

- (NSURL *)qp_removeQuery {
    return [NSURL URLWithString:self.absoluteString.qp_removeQuery];
}

- (NSURL *)qp_appendingQueryDictionary:(NSDictionary *)queryDictionary {
    return [self qp_appendingQueryDictionary:queryDictionary sortedKeys:NO];
}

- (NSURL *)qp_appendingQueryDictionary:(NSDictionary *)queryDictionary sortedKeys:(BOOL)sortedKeys {
    return [NSURL URLWithString:[self.absoluteString qp_appendingQueryDictionary:queryDictionary sortedKeys:sortedKeys]];
}

- (NSURL *)qp_replaceQueryByQueryDictionary:(NSDictionary *)queryDictionary {
    return [self qp_replaceQueryByQueryDictionary:queryDictionary sortedKeys:NO];
}

- (NSURL *)qp_replaceQueryByQueryDictionary:(NSDictionary *)queryDictionary sortedKeys:(BOOL)sortedKeys {
    NSURL *noQueryURL = [self qp_removeQuery];
    return [noQueryURL qp_appendingQueryDictionary:queryDictionary sortedKeys:sortedKeys];
}

@end

@implementation NSString (QueryParser)

- (NSURL *)qp_URL {
    if (!self || [self isEqual:[NSNull null]]) {
        return nil;
    }
    return [NSURL URLWithString:self];
}

- (nullable NSString *)qp_queryString {
    // Separate with '?' remove the scheme, host, path
    NSArray<NSString *> *componets = [self componentsSeparatedByString:kQueryBegin];
    NSString *queryString = nil;
    if (componets.count <= 1) {
        return queryString;
    } else {
        NSArray<NSString *> *tempComponets = [componets subarrayWithRange:NSMakeRange(1, componets.count - 1)];
        queryString = [tempComponets componentsJoinedByString:kQueryBegin];
    }
    
    // Separate with '#' Remove the fragment part
    NSArray<NSString *> *queryComponets = [queryString componentsSeparatedByString:kFragmentSeparator];
    NSString *cleanQueryString = queryComponets.firstObject;
    return cleanQueryString;
}

- (nullable NSDictionary *)qp_queryDictionary {
    NSString *cleanQueryString = self.qp_queryString;
    
    NSArray<NSString *> *queryDataArray = [cleanQueryString componentsSeparatedByString:kQuerySeparator];
    if (queryDataArray.count == 0) {
        return nil;
    }
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
    for (NSString *queryItemString in queryDataArray) {
        NSArray<NSString *> *queryItemArray = [queryItemString componentsSeparatedByString:kQueryDivider];
        if (queryItemArray.count == 0) {
            continue;
        }
        
        NSString *key = [queryItemArray[0] stringByRemovingPercentEncoding];
        id value = nil;
        
        if (queryItemArray.count == 1) {
            value = [NSNull null];
        }
        
        if (queryItemArray.count == 2) {
            value = [queryItemArray[1] stringByRemovingPercentEncoding];
            value = [value length] ? value : [NSNull null];
        }
        
        // Divide the key - value by the first '=', consider the '=' right side as a whole part
        if (queryItemArray.count > 2) {
            NSArray<NSString *> *tempQueryItemArray = [queryItemArray subarrayWithRange:NSMakeRange(1, queryItemArray.count - 1)];
            value = [[tempQueryItemArray componentsJoinedByString:@"="] stringByRemovingPercentEncoding];
            value = [value length] ? value : [NSNull null];
        }
        
        [queryDict setValue:value forKey:key];
    }
    
    return queryDict;
}

- (NSString *)qp_removeQuery {
    NSArray<NSString *> *queryComponents = [self componentsSeparatedByString:kQueryBegin];
    if (queryComponents.count <= 1) {
        return queryComponents.firstObject;
    } else {
        NSString * beforeQueryString = queryComponents.firstObject;
        NSArray<NSString *> *tempQueryComponents = [queryComponents subarrayWithRange:NSMakeRange(1, queryComponents.count - 1)];
        NSString *afterQuery = [tempQueryComponents componentsJoinedByString:kQueryBegin];
        NSArray<NSString *> *fragmentComponents = [afterQuery componentsSeparatedByString:kFragmentSeparator];
        if (fragmentComponents.count <= 1) {
            return beforeQueryString;
        } else {
            NSArray<NSString *> *tempFragmentComponents = [fragmentComponents subarrayWithRange:NSMakeRange(1, fragmentComponents.count - 1)];
            NSString *remainderFragemntString = [tempFragmentComponents componentsJoinedByString:kFragmentSeparator];
            NSString *fragmentString = [NSString stringWithFormat:@"%@%@%@", beforeQueryString, kFragmentSeparator, remainderFragemntString];
            return fragmentString;
        }
    }
}

- (NSString *)qp_appendingQueryDictionary:(NSDictionary *)queryDictionary {
    return [self qp_appendingQueryDictionary:queryDictionary sortedKeys:NO];
}

- (NSString *)qp_appendingQueryDictionary:(NSDictionary *)queryDictionary sortedKeys:(BOOL)sortedKeys {
    NSString *oldQueryString = [self qp_queryString];
    NSMutableArray<NSString *> *combineArray = oldQueryString.length ? @[oldQueryString].mutableCopy : [NSMutableArray array];
    
    NSString *dictionaryQuery = [queryDictionary qp_queryStringBySortedKeys:sortedKeys];
    if (dictionaryQuery.length) {
        [combineArray addObject:dictionaryQuery];
    }
    
    NSString *queryString = [combineArray componentsJoinedByString:kQuerySeparator];
    queryString = [queryString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSString *noQueryString = [self qp_removeQuery];
    
    NSArray<NSString *> *fragmentArray = [noQueryString componentsSeparatedByString:kFragmentSeparator];
    
    if (fragmentArray.count == 0) {
        return queryString;
    } else if (fragmentArray.count == 1) {
        return [NSString stringWithFormat:@"%@%@%@", fragmentArray[0], kQueryBegin, queryString];
    } else if (fragmentArray.count == 2) {
        if ([fragmentArray[1] hasPrefix:kForwardSlash]) {
            return [NSString stringWithFormat:@"%@%@%@%@%@", fragmentArray.firstObject, kFragmentSeparator, fragmentArray.lastObject, kQueryBegin, queryString];
        }
        return [NSString stringWithFormat:@"%@%@%@%@%@", fragmentArray.firstObject, kQueryBegin, queryString, kFragmentSeparator, fragmentArray.lastObject];
    } else {
        NSArray<NSString *> *tempFragmentsArray = [fragmentArray subarrayWithRange:NSMakeRange(0, fragmentArray.count - 1)];
        NSString *beforeFragmentString = [tempFragmentsArray componentsJoinedByString:kFragmentSeparator];
        return [NSString stringWithFormat:@"%@%@%@%@%@", beforeFragmentString, kQueryBegin, queryString, kFragmentSeparator, fragmentArray.lastObject];
    }
}

- (NSString *)qp_replaceQueryByQueryDictionary:(NSDictionary *)queryDictionary {
    return [self qp_replaceQueryByQueryDictionary:queryDictionary sortedKeys:NO];
}

- (NSString *)qp_replaceQueryByQueryDictionary:(NSDictionary *)queryDictionary sortedKeys:(BOOL)sortedKeys {
    NSString *noQueryString = [self qp_removeQuery];
    return [noQueryString qp_appendingQueryDictionary:queryDictionary sortedKeys:sortedKeys];
}

@end

@implementation NSDictionary (QueryParser)

- (nullable NSString *)qp_queryString {
    return [self qp_queryStringBySortedKeys:NO];
}

- (nullable NSString *)qp_queryStringBySortedKeys:(BOOL)sortedKeys {
    NSMutableString *queryString = @"".mutableCopy;
    NSArray *keys = sortedKeys ? [self.allKeys sortedArrayUsingSelector:@selector(compare:)] : self.allKeys;
    for (NSString *key in keys) {
        id rawValue = self[key];
        NSString *value = nil;
        // beware of empty or null
        if (!(rawValue == [NSNull null] || ![rawValue description].length)) {
            value = [self[key] description];
        }
        [queryString appendFormat:@"%@%@%@%@",
         queryString.length ? kQuerySeparator : @"",
         key,
         value ? kQueryDivider : @"",
         value ? value : @""];
    }
    return queryString.length ? queryString : nil;
}

- (NSDictionary *)qp_removeNullValues {
    if (!self || [self isEqual:[NSNull null]]) {
        return nil;
    }
    
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    for (id <NSCopying> key in [self allKeys]) {
        id value = self[key];
        if (!value || [value isEqual:[NSNull null]]) {
            [mutableDictionary removeObjectForKey:key];
        }
    }
    return mutableDictionary;
}

@end
