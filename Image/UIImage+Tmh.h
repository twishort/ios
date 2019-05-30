//
//  TmhImage.h
//  NAVIXY Viewer
//
//  Created by TMH on 08.05.14.
//  Copyright (c) 2014 Tmh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Tmh)


/*
 * Tint image with color
 */
- (UIImage *)imageWithColor:(UIColor *)color;

/*
 * Tint image with color
 */
- (UIImage *)tinedImageWithColor:(UIColor *)color;

/*
 * Resize image
 */
- (UIImage *)convertToSize:(CGSize)size;

/*
 * Merge two images
 */
- (UIImage *)mergeWithImage:(UIImage*)second;

/*
 * Radial gradient image
 */
+ (UIImage *)radialGradientImage:(CGSize)size start:(UIColor *)start end:(UIColor *)end radius:(float)radius;


@end
