//
//  UIColor+SixLetter.m
//  keyBoards
//
//  Created by invoker on 16/3/8.
//  Copyright © 2016年 QQQ. All rights reserved.
//

#import "UIColor+SixLetter.h"

@implementation UIColor (SixLetter)

+ (UIColor *)colorWithSixLetter:(NSString *)sixLetter alpha:(CGFloat)alpha {
    if(sixLetter.length != 6) {
        return [UIColor clearColor];
    }
    NSString *red = [sixLetter substringWithRange:NSMakeRange(0, 2)];
    NSString *green = [sixLetter substringWithRange:NSMakeRange(2, 2)];
    NSString *blue = [sixLetter substringWithRange:NSMakeRange(4, 2)];
    unsigned int r,g,b;
    [[NSScanner scannerWithString:red] scanHexInt:&r];
    [[NSScanner scannerWithString:green] scanHexInt:&g];
    [[NSScanner scannerWithString:blue] scanHexInt:&b];
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:alpha];
}

+ (UIColor *)colorWithSixLetter:(NSString *)sixLetter {
    return [self colorWithSixLetter:sixLetter alpha:1.0f];
}

@end