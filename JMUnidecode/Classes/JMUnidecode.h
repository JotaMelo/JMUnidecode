//
//  JMUnidecode.y
//
//  Created by Jota Melo on 24/12/16.
//  Copyright © 2016 Jota. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMUnidecode : NSObject

+ (void)preload;
+ (NSString *)stringFromUnicodeCodePoint:(NSUInteger)codePoint;
+ (NSString *)unidecode:(NSString *)unidecode;

@end
