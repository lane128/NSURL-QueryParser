# NSURL-QueryParser
NSURL-QueryParser is a NSURL, NSString, Dictionary class category to deal with query of URL. Easy to extract, remove, append query component. It's compatible for web router hash mark (e.g. Vue) which NSURL recognizes as fragment part.

# Installation
Supports multiple methods for installing the library in a project.

# Installation with CocoaPods
To integrate NSURL-QueryParser into your Xcode project using CocoaPods, specify it in your Podfile:
```ruby
pod 'NSURL-QueryParser'
```

# Installation with source file
To integrate NSURL-QueryParser into your Xcode project using source file. 
Just add `NSURL-QueryParser` .h and .m file in to your project.

# Usage
```objective-c
    NSString *url = @"demo://www.sample.com/flutter/#/container?a=1&b=2&c";
    NSDictionary *queryDict = url.qp_queryDictionary;
    // queryDict = @{@"a": @"1", @"b": @"2", @"c": [NSNull null]}
    queryDict = queryDict.qp_removeNullValues;
    // queryDict = @{@"a": @"1", @"b": @"2"}
    NSString *noQueryUrl = url.qp_removeQuery;
    // noQueryUrl = @"demo://www.sample.com/flutter/#/container"
    NSString *queryString = url.qp_queryString;
    // queryString = @"a=1&b=2&c"
    NSURL *URL = url.qp_URL;
    // convert url string to NSURL object if it is valid url string
    URL = [URL qp_appendingQueryDictionary:@{@"d": @"4"}];
    // demo://www.sample.com/flutter/#/container?a=1&b=2&c&d=4
```

# Unit Tests
NSURL-QueryParser includes a suite of unit tests within the UnitTests subdirectory. These tests can be run simply be executed the test action you would like to test.

# Fix
## 1.0.1
* Fix url contains web router hash '#', query append in wrong location issue.

# License
AFNetworking is released under the MIT license. See [LICENSE](https://github.com/lane128/NSURL-QueryParser/blob/develop/LICENSE) for details.
