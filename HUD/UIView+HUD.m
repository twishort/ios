//
//  UIView+HUD.m
//  NAVIXY Viewer
//
//  Created by TMH on 16.05.14.
//  Copyright (c) 2014 Tmh. All rights reserved.
//

#import "UIView+HUD.h"
#import "SVProgressHUD.h"

@implementation UIView(HUD)

static UIColor *tintColor;
static UIColor *errorColor;

#pragma mark - Message and Wait

+ (void)setHUDTintColor:(UIColor *)color
{
    tintColor = color;
}

+ (void)setHUDErrorColor:(UIColor *)color
{
    errorColor = color;
}

+ (void)setHUDFont:(UIFont *)font
{
    [SVProgressHUD setFont:font];
}

- (BOOL)isWaiting
{
    return [SVProgressHUD isVisible];
}

- (void)showWait
{
    [SVProgressHUD setRingThickness:3];
    [SVProgressHUD setRingNoTextRadius:28];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.9]];
    [SVProgressHUD setForegroundColor:tintColor];
    [SVProgressHUD show];
}

- (void)hideWait
{
    [SVProgressHUD dismiss];
}

- (void)showError:(NSString *)localizedString
{
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.9]];
    [SVProgressHUD setForegroundColor:errorColor];
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(localizedString, nil)];
}

- (void)showToast:(NSString *)localizedString
{
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.9]];
    [SVProgressHUD setForegroundColor:tintColor];
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(localizedString, nil)];
}

@end
