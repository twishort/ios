//
//  UIView+HUD.h
//  NAVIXY Viewer
//
//  Created by TMH on 16.05.14.
//  Copyright (c) 2014 Tmh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView(HUD)

@property (nonatomic, readonly) BOOL isWaiting;

- (void)showWait;
- (void)hideWait;
- (void)showError:(NSString *)localizedString;
- (void)showToast:(NSString *)localizedString;


+ (void)setHUDTintColor:(UIColor *)color;
+ (void)setHUDErrorColor:(UIColor *)color;
+ (void)setHUDFont:(UIFont *)font;

@end
