//
//  TmhSocial.m
//  Twishort
//
//  Created by TMH on 18.05.13.
//  Copyright (c) 2013 TMH. All rights reserved.
//

#import "TmhSocial.h"

@implementation TmhSocial

@synthesize selectAccountText, noAccountText, viewController = viewController_, cancelText;

- (id)initWithViewController:(UIViewController *)viewController
{
    self = [self init];
    if (self) {
        viewController_ = viewController;
    }
    return self;
}

/*
 * Getter for isAuthorized property
 */
- (BOOL)isAuthorized
{
    return [(id<TmhSocialDelegate>)self authorized];
}

/*
 * Add object to storage
 */
- (void)addStorageObject:(id)object forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 * Remove object from storage
 */
- (void)removeStorageObject:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 * Get object from storage
 */
- (id)storageObject:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

/*
 * Get user's avatar
 */
- (UIImage *)avatar
{
    NSData *data = [self storageObject:@"avatar"];
    return data ? [UIImage imageWithData:data] : nil;
}

/*
 * Set user's avatar
 */
- (void)setAvatar:(UIImage *)avatar
{
    [self addStorageObject:UIImagePNGRepresentation(avatar) forKey:@"avatar"];
}

/*
 * Get user's name
 */
- (NSString *)getUsername
{
    return [self storageObject:@"username"];
}

/*
 * Set user's name
 */
- (void)setUsername:(NSString *)username
{
    [self addStorageObject:username forKey:@"username"];
}

/*
 * Get data by url
 */
- (void)dataWithUrl:(NSString *)urlString onSuccess:(TmhSocialResult)onSuccess onError:(TmhSocialResult)onError
{
    TmhConnection *connection = [TmhConnection new];
    connection.cache = YES;
    
    [connection GET:urlString
          onSuccess:^(id data) {
                  onSuccess(data);
              }
            onError:onError];
}

/*
 * Show select account menu
 */
- (void)selectAccount:(NSArray *)titles
{
    if (! self.viewController) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:selectAccountText
                                                            delegate:(id<UIActionSheetDelegate>)self
                                                   cancelButtonTitle:nil
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:nil];
        for (NSString *title in titles) {
            [action addButtonWithTitle:title];
        }
        if (!IPAD) {
            action.cancelButtonIndex = [action addButtonWithTitle:cancelText];
        }
        [action showInView:self.viewController.view];
        if (self.isHud) {
            [self.viewController.view hideWait];   
        }
    });
}

/*
 * Show "no account" message
 */
- (void)messageNoAccount
{
    if (! noAccountText) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:noAccountText
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    });
}

@end
