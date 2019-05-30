//
//  TmhColor.h
//  Tmh
//
//  Created by TMH on 04.02.13.
//  Copyright (c) 2013 Tmh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface TmhColor : NSObject

/*
 * HEX to UIColor convertion
 * Assumes input like "#00FF00" (#RRGGBB).
 */
+ (UIColor *)hexToColor:(NSString *)hexString;

/*
 * Apply gradient on view
 */
+ (void)verticalGradient:(UIView *)view topColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor;

/*
 * Generate random color
 */
+ (UIColor *)random;

@end
