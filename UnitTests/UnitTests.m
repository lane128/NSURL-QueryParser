//
//  UnitTests.m
//  UnitTests
//
//  Created by Adam Wang on 2022/1/17.
//

#import <XCTest/XCTest.h>
#import "NSURL+QueryParser.h"

static NSString *const uq_URLReservedChars =  @"￼=,!$&'()*+;@?\r\n\"<>#\t :/";

@interface UnitTests : XCTestCase

@end

@implementation UnitTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    NSString *url = @"gm://www.sample.com/flutter/#/container?a=1=1=2=3===1&b=abc&efg";
    NSDictionary *assetDict = url.qp_queryDictionary;
    NSDictionary *predictDict = @{
        @"a": @"1=1=2=3===1",
        @"b": @"abc",
        @"efg": [NSNull null]
    };
    XCTAssertEqualObjects(predictDict, assetDict, @"Did not return corrent keys/values");
}

- (void)testRemoveDictionaryNullValues {
    NSString *url = @"gm://www.sample.com/flutter/#/container?a=1=1=2=3===1&b=abc&efg";
    NSDictionary *assertDict = url.qp_queryDictionary.qp_removeNullValues;
    NSDictionary *predictDict = @{
        @"a": @"1=1=2=3===1",
        @"b": @"abc"
    };
    XCTAssertEqualObjects(predictDict, assertDict, @"Did not return corrent keys/values");
}

- (void)testRemoveQueryString {
    NSURL *testURL = [NSURL URLWithString:@"http://sample.com/aaa?a=1=2&b=2&c=xx&d=2adfa#hash"];
    NSURL *removeQueryURL = testURL.qp_removeQuery;
    XCTAssertEqualObjects(removeQueryURL, [NSURL URLWithString:@"http://sample.com/aaa#hash"]);
}

- (void)testURLQueryDictionary {
    NSURL *testURL = [NSURL URLWithString:@"http://sample.com/#/aaa?a=1&b=2"];
    NSDictionary *assertDict = testURL.qp_queryDictionary;
    NSDictionary *predictDict = @{@"a": @"1", @"b": @"2"};
    XCTAssertEqualObjects(assertDict, predictDict);
}

- (void)testShouldExtractQueryDictionary {
    NSDictionary *dict = @{@"cat":@"cheese", @"foo":@"bar"};
    XCTAssertEqualObjects(@"http://www.foo.com/?cat=cheese&foo=bar".qp_URL.qp_queryDictionary,
                          dict,
                          @"Did not return correct keys/values");
}

- (void)testShouldExtractQueryWithEncodedValues {
    NSDictionary *dict = @{@"翻訳":@"久しぶり"};
    XCTAssertEqualObjects(@"http://www.foo.com/?%E7%BF%BB%E8%A8%B3=%E4%B9%85%E3%81%97%E3%81%B6%E3%82%8A".qp_URL.qp_queryDictionary,
                          dict,
                          @"Did not return correct keys/values");
}

- (void)testShouldIgnoreInvalidQueryComponent {
    NSDictionary *dict = @{@"cat":@"cheese", @"invalid": @"foo=bar"};
    XCTAssertEqualObjects(@"http://www.foo.com/?cat=cheese&invalid=foo=bar".qp_URL.qp_queryDictionary,
                          dict,
                          @"Did not return correct keys/values");
}

- (void)testShouldCreateSimpleQuery {
    NSDictionary *dict = @{@"cat":@"cheese", @"foo":@"bar"};
    XCTAssertEqualObjects([@"http://www.foo.com/".qp_URL qp_appendingQueryDictionary:dict].absoluteString,
                          @"http://www.foo.com/?cat=cheese&foo=bar",
                          @"Did not create correctly formatted URL");
}

- (void)testShouldAppendASimpleQuery {
    NSDictionary *dict = @{@"key":@"value"};
    XCTAssertEqualObjects([@"http://www.foo.com/path".qp_URL qp_appendingQueryDictionary:dict].absoluteString,
                          @"http://www.foo.com/path?key=value",
                          @"Did not create correctly formatted URL");
}

- (void)testShouldAppendWhenURLContainsJustQueryBegin {
    NSDictionary *dict = @{@"key":@"value"};
    XCTAssertEqualObjects([@"http://www.foo.com/path?".qp_URL qp_appendingQueryDictionary:dict].absoluteString,
                          @"http://www.foo.com/path?key=value",
                          @"Did not create correctly formatted URL");
}

- (void)testShouldAppendToExistingQueryWithFragment {
    NSDictionary *dict = @{@"cat":@"cheese", @"foo":@"bar"};
    XCTAssertEqualObjects([@"http://www.foo.com/?aKey=aValue&another=val2#fragment".qp_URL qp_appendingQueryDictionary:dict].absoluteString,
                          @"http://www.foo.com/?aKey=aValue&another=val2&cat=cheese&foo=bar#fragment",
                          @"Did not create correctly formatted URL");
}

- (void)testShouldSortKeysWithOptionProvided {
    NSDictionary *dict = @{@"xyz":@"bazzle",@"cat":@"cheese", @"foo":@"bar"};
    XCTAssertEqualObjects([@"http://www.foo.com/".qp_URL qp_appendingQueryDictionary:dict sortedKeys:YES].absoluteString,
                          @"http://www.foo.com/?cat=cheese&foo=bar&xyz=bazzle",
                          @"Did not create correctly formatted URL");
}

- (void)testShouldEncodeKeysAndValues {
    NSDictionary *dict = @{@"翻訳":@"久しぶり"};
    XCTAssertEqualObjects([@"http://www.foo.com/".qp_URL qp_appendingQueryDictionary:dict].absoluteString,
                          @"http://www.foo.com/?%E7%BF%BB%E8%A8%B3=%E4%B9%85%E3%81%97%E3%81%B6%E3%82%8A",
                          @"Did not return correct keys/values");
}

- (void)testShouldEncodeValuesContainingReservedCharacters {
    NSDictionary *dict = @{@"q": @"gin & tonic", @"other": uq_URLReservedChars};
    
    XCTAssertEqualObjects([@"http://www.foo.com/".qp_URL qp_appendingQueryDictionary:dict].absoluteString,
                          @"http://www.foo.com/?q=gin%20&%20tonic&other=%EF%BF%BC=,!$&'()*+;@?%0D%0A%22%3C%3E%23%09%20:/",
                          @"Did not return correct keys/values");
}

- (void)testShouldEncodeKeysContainingReservedCharacters {
    NSDictionary *dict = @{ uq_URLReservedChars: @YES};
    
    XCTAssertEqualObjects([@"http://www.foo.com/".qp_URL qp_appendingQueryDictionary:dict].absoluteString,
                          @"http://www.foo.com/?%EF%BF%BC=,!$&'()*+;@?%0D%0A%22%3C%3E%23%09%20:/=1",
                          @"Did not return correct keys/values");
}

- (void)testShouldDealWithEmptyDictionary {
    NSString *urlString = @"http://www.foo.com/?aKey=aValue&another=val2#fragment";
    XCTAssertEqualObjects([urlString.qp_URL qp_appendingQueryDictionary:@{}].absoluteString,
                          urlString,
                          @"Did not create correctly formatted URL");
}

- (void)testShouldHandleDictionaryValuesOtherThanStrings {
    NSDictionary *dict = @{@"number":@47, @"date":[NSDate dateWithTimeIntervalSince1970:0]};
    XCTAssertEqualObjects([@"http://www.foo.com/path".qp_URL qp_appendingQueryDictionary:dict].absoluteString,
                          @"http://www.foo.com/path?number=47&date=1970-01-01%2000:00:00%20+0000",
                          @"Did not create correctly formatted URL");
}

- (void)testShouldHandleDictionaryWithEmptyPropertiesCorrectly {
    NSDictionary *dict = @{ @"key" : @"" };
    XCTAssertEqualObjects([@"http://www.foo.com/".qp_URL qp_appendingQueryDictionary:dict].absoluteString,
                          @"http://www.foo.com/?key",
                          @"Did not create correctly formatted URL");
}

- (void)testShouldHandleDictionaryWithNullPropertyCorrectly {
    NSDictionary *dict = @{ @"key1" : [NSNull null], @"key2" : @"value" };
    XCTAssertEqualObjects([@"http://www.foo.com/".qp_URL qp_appendingQueryDictionary:dict].absoluteString,
                          @"http://www.foo.com/?key1&key2=value",
                          @"Did not create correctly formatted URL");
}

- (void)testShouldConvertURLWithEmptyQueryValueToNSNull {
    NSDictionary *dict = @{ @"key" : [NSNull null] };
    XCTAssertEqualObjects(@"http://www.foo.com/?key".qp_URL.qp_queryDictionary,
                          dict,
                          @"Did not return correct keys/values");
}

- (void)testShouldHandlePossiblyInvalidURLWithSeparatorButNoValue {
    NSDictionary *dict = @{ @"key1" : [NSNull null], @"key2" : @"value" };
    XCTAssertEqualObjects(@"http://www.foo.com/?key1=&key2=value".qp_URL.qp_queryDictionary,
                          dict,
                          @"Did not return correct keys/values");
}

- (void)testShouldConvertURLWithEmptyQueryValueToNSNullWithMultipleKeys {
    NSDictionary *dict = @{ @"key1" : [NSNull null], @"key2" : @"value" };
    XCTAssertEqualObjects(@"http://www.foo.com/?key1&key2=value".qp_URL.qp_queryDictionary,
                          dict,
                          @"Did not return correct keys/values");
}

- (void)testShouldCreateURLByRemovingQuery {
    XCTAssertEqualObjects([@"http://www.foo.com/path/?cat=cheese&foo=bar".qp_URL qp_removeQuery],
                          @"http://www.foo.com/path/".qp_URL);
}

- (void)testShouldCreateURLByReplacingQueryDictionary {
    NSURL *url = @"http://www.foo.com/?cat=cheese&foo=bar".qp_URL;
    NSURL *url2 = [url qp_replaceQueryByQueryDictionary:@{ @"tree" : @1}];
    XCTAssertEqualObjects(url2, @"http://www.foo.com/?tree=1".qp_URL);
}

@end
