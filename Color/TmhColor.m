//
//  TmhColor.m
//  Tmh
//
//  Created by TMH on 04.02.13.
//  Copyright (c) 2013 Tmh. All rights reserved.
//

#import "TmhColor.h"

@implementation TmhColor

/*
 * HEX to UIColor convertion
 * Assumes input like "#00FF00" (#RRGGBB).
 */
+ (UIColor *)hexToColor:(NSString *)hexString {
    
    unsigned rgbValue = 0;
    
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

/*
 * Apply gradient on view
 */
+ (void)verticalGradient:(UIView *)view topColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor
{
    CAGradientLayer * gradient = [CAGradientLayer layer];
    [gradient setFrame:[view bounds]];
    [gradient setColors:[NSArray arrayWithObjects:(id)[topColor CGColor], (id)[bottomColor CGColor], nil]];
    
    [view.layer addSublayer:gradient];
}

/*
 * Generate random color
 */
+ (UIColor *)random
{
    float hue = arc4random_uniform(1001) / 1000.0;
    float brightnest = 1 - arc4random_uniform(100) / 1000.0;

    return [UIColor colorWithHue:hue saturation:0.7 brightness:brightnest alpha:1];
}

@end
