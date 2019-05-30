//
//  TmhImage.m
//  NAVIXY Viewer
//
//  Created by TMH on 08.05.14.
//  Copyright (c) 2014 Tmh. All rights reserved.
//

#import "UIImage+Tmh.h"

@implementation UIImage (Tmh)

/*
 * Tint image with color
 */
- (UIImage *)imageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

/*
 * Tint image with color
 */
- (UIImage *)tinedImageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

/*
 * Resize image
 */
- (UIImage *)convertToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return destImage;
}

/*
 * Merge two images
 */
- (UIImage *)mergeWithImage:(UIImage *)second
{
    // get size of the first image
    CGFloat firstWidth = self.size.width;
    CGFloat firstHeight = self.size.height;
    
    // get size of the second image
    CGFloat secondWidth = second.size.width;
    CGFloat secondHeight = second.size.height;
    
    // build merged size
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    
    // capture image context ref
    UIGraphicsBeginImageContextWithOptions(mergedSize, NO, self.scale);
    
    //Draw images onto the context
    [self drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [second drawInRect:CGRectMake((firstWidth - secondWidth) / 2.0, (firstHeight - secondHeight) / 2.0, secondWidth, secondHeight)];
    
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
}

/*
 * Radial gradient image
 */
+ (UIImage *)radialGradientImage:(CGSize)size start:(UIColor *)start end:(UIColor *)end radius:(float)radius
{
    // Render a radial background
    // http://developer.apple.com/library/ios/#documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_shadings/dq_shadings.html
    
    CGFloat startRed = 0.0, startGreen = 0.0, startBlue = 0.0, startAlpha = 0.0;
    CGFloat endRed = 0.0, endGreen = 0.0, endBlue = 0.0, endAlpha = 0.0;
    [start getRed:&startRed green:&startGreen blue:&startBlue alpha:&startAlpha];
    [end getRed:&endRed green:&endGreen blue:&endBlue alpha:&endAlpha];
    
    // Initialise
    UIGraphicsBeginImageContextWithOptions(size, YES, 1);
    
    // Create the gradient's colours
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { startRed, startGreen, startBlue, startAlpha,
        endRed, endGreen, endBlue, endAlpha };
    
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
    
    // Normalise the 0-1 ranged inputs to the width of the image
    CGPoint myCentrePoint = CGPointMake(size.width / 2.0, size.height / 2.0);
    
    // Draw it!
    CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, myCentrePoint,
                                 0, myCentrePoint, radius,
                                 kCGGradientDrawsAfterEndLocation);
    
    // Grab it as an autoreleased image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Clean up
    CGColorSpaceRelease(myColorspace); // Necessary?
    CGGradientRelease(myGradient); // Necessary?
    UIGraphicsEndImageContext(); // Clean up
    return image;
}

@end
