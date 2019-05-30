//
//  TmhSocial.h
//  Twishort
//
//  Created by TMH on 18.05.13.
//  Copyright (c) 2013 TMH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TmhConnection.h"
#import "UIView+HUD.h"

typedef enum {
    kTmhSocialErrorAccount,
    kTmhSocialErrorShare,
    kTmhSocialErrorInfo,
    kTmhSocialErrorCancel,
} kTmhSocilError;

typedef void (^TmhSocialResult)();
typedef void (^TmhSocialInfo)(NSDictionary *info);
typedef void (^TmhSocialList)(NSArray *list);
typedef void (^TmhSocialError)(NSError *error);

@protocol TmhSocialDelegate <NSObject>

@required

/*
 * Check is user authorized
 */
- (BOOL)authorized;

/*
 * Authorize application
 */
- (void)auth:(TmhSocialResult)onSuccess onError:(TmhSocialError)onError;

/*
 * Share specified text, url, image
 */
- (void)share:(NSString *)text url:(NSString *)urlString image:(UIImage *)image onSuccess:(TmhSocialResult)onSuccess onError:(TmhSocialError)onError;

/*
 * Get user's profile info
 */
- (void)userInfo:(TmhSocialInfo)onSuccess onError:(TmhSocialError)onError;

/*
 * Logout from social network
 */
- (void)logout;

@end


@interface TmhSocial : NSObject

@property (atomic,readonly) BOOL isAuthorized;
@property (atomic, retain) NSString *selectAccountText;
@property (atomic, retain) NSString *noAccountText;
@property (atomic, retain) NSString *cancelText;
@property (atomic,retain) UIViewController *viewController;
@property (nonatomic, retain) UIImage *avatar;
@property (nonatomic, retain) NSString *username;
@property (atomic) BOOL isHud;

- (id)initWithViewController:(UIViewController *)viewController;

/*
 * Add object to storage
 */
- (void)addStorageObject:(id)object forKey:(NSString *)key;

/*
 * Remove object from storage
 */
- (void)removeStorageObject:(NSString *)key;

/*
 * Get object from storage
 */
- (id)storageObject:(NSString *)key;

/*
 * Get data by url
 */
- (void)dataWithUrl:(NSString *)urlString onSuccess:(TmhSocialResult)onSuccess onError:(TmhSocialResult)onError;

/*
 * Show "select account" menu
 */
- (void)selectAccount:(NSArray *)titles;

/*
 * Show "no account" message
 */
- (void)messageNoAccount;

@end
