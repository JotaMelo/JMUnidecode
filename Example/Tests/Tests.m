//
//  JMUnidecodeTests.m
//  JMUnidecodeTests
//
//  Created by Jota Melo on 09/11/2017.
//  Copyright (c) 2017 Jota Melo. All rights reserved.
//

#import "JMUnidecode.h"
@import XCTest;

@interface Tests : XCTestCase

@end

@implementation Tests

- (NSString *)stringFromUnicodeCodePoint:(NSUInteger)codePoint
{
    return [[NSString alloc] initWithBytes:&codePoint length:4 encoding:NSUTF32LittleEndianStringEncoding];
}

- (void)testASCII
{
    for (int i = 0; i < 128; i++) {
        NSString *character = [self stringFromUnicodeCodePoint:i];
        NSString *unidecodedCharacter = [JMUnidecode unidecode:character];
        
        XCTAssertEqualObjects(character, unidecodedCharacter);
    }
}

- (void)testBmp
{
    for (int i = 0; i < 0x10000; i++) {
        // Just check that it doesn't throw an exception
        
        NSString *character = [self stringFromUnicodeCodePoint:i];
        [JMUnidecode unidecode:character];
    }
}

- (void)testCirclesLatin
{
    for (int i = 0; i < 26; i++) {
        NSString *a = [self stringFromUnicodeCodePoint:'a' + i];
        NSString *b = [JMUnidecode unidecode:[self stringFromUnicodeCodePoint:0x24d0 + i]];
        
        XCTAssertEqualObjects(a, b);
    }
}

- (void)testMathematicalLatin
{
    // 13 consecutive sequences of A-Z, a-z with some codepoints
    // undefined. We just count the undefined ones and don't check
    // positions.
    
    NSUInteger empty = 0;
    for (int i = 0x1d400; i < 0x1d6a4; i++) {
        NSString *a;
        if (i % 52 < 26) {
            a = [self stringFromUnicodeCodePoint:'A' + i % 26];
        } else {
            a = [self stringFromUnicodeCodePoint:'a' + i % 26];
        }
        
        NSString *b = [JMUnidecode unidecode:[self stringFromUnicodeCodePoint:i]];
        if (b.length == 0) {
            empty++;
        } else {
            XCTAssertEqualObjects(a, b);
        }
    }
    
    XCTAssertEqual(empty, 24);
}

- (void)testMatematicalDigits
{
    for (int i = 0x1d7ce; i < 0x1d800; i++) {
        NSString *a = [NSString stringWithFormat:@"%c", '0' + (i - 0x1d7ce) % 10];
        NSString *b = [JMUnidecode unidecode:a];
        
        XCTAssertEqualObjects(a, b);
    }
}

- (void)testSpecific
{
    // force table load
    [JMUnidecode unidecode:@"á"];
    
    NSArray *tests = @[@[@"Hello, World!", @"Hello, World!"],
                       @[@"'\"\r\n", @"'\"\r\n"],
                       @[@"ČŽŠčžš", @"CZSczs"],
                       @[@"ア", @"a"],
                       @[@"α", @"a"],
                       @[@"château", @"chateau"],
                       @[@"viñedos", @"vinedos"],
                       @[@"北亰", @"Bei Jing "],
                       @[@"Efﬁcient", @"Efficient"],
                       
                       // https://github.com/iki/unidecode/commit/4a1d4e0a7b5a11796dc701099556876e7a520065
                       @[@"příliš žluťoučký kůň pěl ďábelské ódy", @"prilis zlutoucky kun pel dabelske ody"],
                       @[@"PŘÍLIŠ ŽLUŤOUČKÝ KŮŇ PĚL ĎÁBELSKÉ ÓDY", @"PRILIS ZLUTOUCKY KUN PEL DABELSKE ODY"],
                       
                       // Table that doesn't exist
                       @[@"\ua500", @""],
                       
                       // Table that has less than 256 entries
                       @[@"\u1eff", @""]
                       ];
    
    for (NSArray<NSString *> *test in tests) {
        XCTAssertEqualObjects([JMUnidecode unidecode:test.firstObject], test.lastObject);
    }
}
@end

