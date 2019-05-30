//
//  TmhSocialTwitter.h
//  TmhSocial
//
//  Created by TMH on 06.03.13.
//  Copyright (c) 2013 TMH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import "TmhSocial.h"
#import <CoreLocation/CoreLocation.h>

extern NSString * const kTmhSocialTwitterConsumerKey;
extern NSString * const kTmhSocialTwitterConsumerSecret;
extern NSString * const kTmhSocialTwitterStorageAccount;
extern NSString * const kTmhSocialTwitterUrlStatusUpdate;
extern NSString * const kTmhSocialTwitterUrlStatusUpdateWithMedia;
extern NSString * const kTmhSocialTwitterUrlUserInfo;
extern NSString * const kTmhSocialTwitterUrlRequestToken;
extern NSString * const kTmhSocialTwitterUrlUserProfile;
extern NSString * const kTmhSocialTwitterParamStatus;
extern NSString * const kTmhSocialTwitterParamMedia;
extern NSString * const kTmhSocialTwitterParamUsername;
extern NSString * const kTmhSocialTwitterParamAvatar;
extern NSString * const kTmhSocialTwitterParamErrors;

typedef enum {
    kTmhSocialTwitterErrorRateLimit = 152,
    kTmhSocialTwitterErrorDuplicate = 187
} kTmhSocilTwitterError;

typedef void (^TmhSocialTwitterId)(NSString *id);

@interface TmhSocialTwitter : TmhSocial <TmhSocialDelegate>
{
    TmhSocialResult onResultSuccess;
    TmhSocialResult onResultError;
}

@property (atomic, readwrite, copy) TmhSocialResult onResultSuccess;
@property (atomic, readwrite, copy) TmhSocialError onResultError;
@property (atomic, retain) ACAccount *account;
@property (atomic, retain) NSArray *arrayOfAccounts;
@property (atomic, retain) NSDictionary *lastResponse;
@property (atomic) BOOL reselectAccount;

/*
 * Get signature for the request
 */
- (NSString *)signature:(NSString *)method url:(NSString *)url token:(NSString *)token secretToken:(NSString *)secretToken;

/*
 * Get an error code from response
 */
- (int)errorCode:(NSDictionary *)response withDefault:(int)defaultError;


/*
 * Get an error text from response
 */
- (NSString *)errorText:(NSDictionary *)response;

/*
 * Share tweet
 */
- (void)share:(NSString *)text images:(NSArray *)images video:(NSData *)video coordinate:(CLLocationCoordinate2D)coordinate placeId:(NSString *)placeId onSuccess:(TmhSocialResult)onSuccess onError:(TmhSocialError)onError;

/*
 * Get places
 */
- (void)placesWithCoordinate:(CLLocationCoordinate2D)coordinate success:(TmhSocialList)success error:(TmhSocialError)error;

@end
