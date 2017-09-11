//
//  JMUnidecode.m
//
//  Created by Jota Melo on 24/12/16.
//  Copyright © 2016 Jota. All rights reserved.
//

#import "JMUnidecode.h"

@interface JMUnidecode ()

@property (class, nonatomic, readonly) JMUnidecode *sharedInstance;
@property (strong, nonatomic) NSDictionary<NSString *, NSArray<NSString *> *> *table;

@end

@implementation JMUnidecode

+ (JMUnidecode *)sharedInstance
{
    static JMUnidecode *unidecode;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unidecode = [JMUnidecode new];
    });
    return unidecode;
}

+ (void)preload
{
    [self.sharedInstance characterListForSection:0];
}

+ (NSString *)stringFromUnicodeCodePoint:(NSUInteger)codePoint
{
    return [[NSString alloc] initWithBytes:&codePoint length:4 encoding:NSUTF32LittleEndianStringEncoding];
}

+ (NSString *)unidecode:(NSString *)string
{
    NSMutableString *unidecodedString = @"".mutableCopy;
    
    NSData *stringData = [string dataUsingEncoding:NSUTF32LittleEndianStringEncoding];
    const uint32_t *UTF32Bytes = stringData.bytes;
    for (int i = 0; i < stringData.length / 4; i++) {
        uint32_t currentCharacter = UTF32Bytes[i];
        
        if (currentCharacter < 0x80) { // Basic ASCII
            [unidecodedString appendString:[self stringFromUnicodeCodePoint:currentCharacter]];
            continue;
        }
        
        NSUInteger section = currentCharacter >> 8; // Remove last 2 hex digits
        NSUInteger position = currentCharacter % 256; // Last two hex digits
        
        NSArray<NSString *> *list = [self.sharedInstance characterListForSection:section];
        if (list && position < list.count) {
            [unidecodedString appendString:list[position]];
        }
    }
    
    return unidecodedString;
}

- (NSArray<NSString *> *)characterListForSection:(NSUInteger)section
{
    if (!self.table) {
        NSURL *fileURL = [NSBundle.mainBundle URLForResource:@"JMUnidecodeData" withExtension:@"json"];
        if (!fileURL) {
            NSURL *bundleURL = [[NSBundle bundleForClass:[JMUnidecode class]] URLForResource:@"JMUnidecode" withExtension:@"bundle"];
            fileURL = [[NSBundle bundleWithURL:bundleURL] URLForResource:@"JMUnidecodeData" withExtension:@"json"];
        }
        
        NSData *fileData = [[NSData alloc] initWithContentsOfURL:fileURL];
        self.table = [NSJSONSerialization JSONObjectWithData:fileData options:0 error:nil];
    }
    
    return self.table[@(section).stringValue];
}

@end
