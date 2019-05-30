//
//  TmhSocialTwitter.m
//  TmhSocial
//
//  Created by TMH on 06.03.13.
//  Copyright (c) 2013 TMH. All rights reserved.
//

#import "TmhSocialTwitter.h"
#import <CommonCrypto/CommonHMAC.h>
#import <Social/Social.h>
#import "NSData+Base64.h"
#import <TwitterKit/TWTRKit.h>

NSString * const kTmhSocialTwitterConsumerKey = @"";
NSString * const kTmhSocialTwitterConsumerSecret = @"";

static NSString *kTmhSocialTwitterParameterString = @"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=HMAC-SHA1&oauth_timestamp=%@&oauth_token=%@&oauth_version=1.0";
static NSString *kTmhSocialTwitterOAuthSignature = @"OAuth oauth_consumer_key=\"%@\", oauth_nonce=\"%@\", oauth_signature=\"%@\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"%@\", oauth_token=\"%@\", oauth_version=\"1.0\"";

NSString * const kTmhSocialTwitterStorageAccount = @"twitter_account";

NSString * const kTmhSocialTwitterUrlStatusUpdate = @"https://api.twitter.com/1.1/statuses/update.json";
NSString * const kTmhSocialTwitterUrlStatusUpdateWithMedia = @"https://api.twitter.com/1.1/statuses/update_with_media.json";
NSString * const kTmhSocialTwitterUrlRequestToken = @"https://api.twitter.com/oauth/request_token";
NSString * const kTmhSocialTwitterUrlUserInfo = @"https://api.twitter.com/1.1/account/verify_credentials.json";
NSString * const kTmhSocialTwitterUrlGeoSearch = @"https://api.twitter.com/1.1/geo/search.json";
NSString * const kTmhSocialTwitterUrlUpload = @"https://upload.twitter.com//1.1/media/upload.json";
NSString * const kTmhSocialTwitterUrlUserProfile = @"https://twitter.com/%@/status/%@";
NSString * const kTmhSocialTwitterParamStatus = @"status";
NSString * const kTmhSocialTwitterParamMedia = @"media";
NSString * const kTmhSocialTwitterParamMediaType = @"media_type";
NSString * const kTmhSocialTwitterParamMediaTypeJpeg = @"image/jpeg";
NSString * const kTmhSocialTwitterParamMediaTypeMp4 = @"video/mp4";
NSString * const kTmhSocialTwitterParamMediaFilenameImage = @"image.jpg";
NSString * const kTmhSocialTwitterParamMediaFilenameVideo = @"video.mp4";
NSString * const kTmhSocialTwitterParamTotalBytes = @"total_bytes";
NSString * const kTmhSocialTwitterParamCommand = @"command";
NSString * const kTmhSocialTwitterParamInit = @"INIT";
NSString * const kTmhSocialTwitterParamAppend = @"APPEND";
NSString * const kTmhSocialTwitterParamFinalize = @"FINALIZE";
NSString * const kTmhSocialTwitterParamMediaIds = @"media_ids";
NSString * const kTmhSocialTwitterParamMediaId = @"media_id";
NSString * const kTmhSocialTwitterParamMediaCategory = @"media_category";
NSString * const kTmhSocialTwitterParamMediaCategoryVideoAmplify = @"amplify_video";
NSString * const kTmhSocialTwitterParamMediaCategoryVideo = @"tweet_video";
NSString * const kTmhSocialTwitterParamMediaIdString = @"media_id_string";
NSString * const kTmhSocialTwitterParamSegmentIndex = @"segment_index";
NSString * const kTmhSocialTwitterParamCode = @"code";
NSString * const kTmhSocialTwitterParamErrors = @"errors";
NSString * const kTmhSocialTwitterParamError = @"error";
NSString * const kTmhSocialTwitterParamLat = @"lat";
NSString * const kTmhSocialTwitterParamLong = @"long";
NSString * const kTmhSocialTwitterParamAccuracy = @"accuracy";
NSString * const kTmhSocialTwitterParamMaxResults = @"max_results";
NSString * const kTmhSocialTwitterParamGranularity = @"granularity";
NSString * const kTmhSocialTwitterParamPoi = @"poi";
NSString * const kTmhSocialTwitterParamPlaceId = @"place_id";
NSString * const kTmhSocialTwitterParamDisplayCoordinates = @"display_coordinates";
NSString * const kTmhSocialTwitterParamUsername = @"screen_name";
NSString * const kTmhSocialTwitterParamAvatar = @"profile_image_url";
NSString * const kTmhSocialTwitterParamMessage = @"message";
NSString * const kTmhSocialTwitterParamTypeUrlEncoded = @"application/x-www-form-urlencoded";
NSString * const kTmhSocialTwitterParamTypeFormData = @"multipart/form-data";
NSString * const kTmhSocialTwitterParamResult = @"result";
NSString * const kTmhSocialTwitterParamPlaces = @"places";
NSString * const kTmhSocialTwitterParamId = @"id";
NSString * const kTmhSocialTwitterParamName = @"name";
NSString * const kTmhSocialTwitterParamContainedWithin = @"contained_within";

NSInteger const kTmhSocialTwitterChunkBytes = 2097152; // 2Mb

@interface TmhSocialTwitter()
{
    ACAccountStore *accountStore;
    NSArray *accounts;
    ACAccount *account;
}
@end

@implementation TmhSocialTwitter

@synthesize account, arrayOfAccounts, onResultSuccess, onResultError, lastResponse;

- (id)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        self.viewController = viewController;
        accountStore = [ACAccountStore new];
    }
    return self;
}

- (BOOL)socialFrameworkAvailable
{
	return NSClassFromString(@"SLComposeViewController")?YES:NO;
}

- (BOOL)twitterFrameworkAvailable
{
	return NSClassFromString(@"TWTweetComposeViewController")?YES:NO;
}

/*
 * Get an error code from response
 */
- (int)errorCode:(NSDictionary *)response withDefault:(int)defaultError
{
    NSArray *errors = [response objectForKey:kTmhSocialTwitterParamErrors];
    
    if (errors) {
        return [[errors[0] objectForKey:kTmhSocialTwitterParamCode] intValue];
    }
    return defaultError;
}

/*
 * Get an error text from response
 */
- (NSString *)errorText:(NSDictionary *)response
{
    NSArray *errors = [response objectForKey:kTmhSocialTwitterParamErrors];
    
    if (errors) {
        return [errors[0] objectForKey:kTmhSocialTwitterParamMessage];
    }
    return @"";
}

/*
 * Create error object from response
 */
- (NSError *)error:(NSError *)error response:(NSDictionary *)response
{
    if (error) {
        return error;
    }
    if (response[kTmhSocialTwitterParamError]) {
        return [NSError errorWithDomain:kTmhSocialTwitterParamError
                                   code:-1
                               userInfo:@{NSLocalizedDescriptionKey: response[kTmhSocialTwitterParamError]}];
    }
    return nil;
}

#pragma mark - TmhSocialDelegate methods

/*
 * Check is user authorized
 */
- (BOOL)authorized
{
    return IOS11 ? [[Twitter sharedInstance].sessionStore hasLoggedInUsers] : [self storageObject:kTmhSocialTwitterStorageAccount]?YES:NO;
}

/*
 * Authorize application
 */
- (void)auth:(TmhSocialResult)onSuccess onError:(TmhSocialError)onError
{
    if (IOS11) {
        if (self.isAuthorized
            && !self.reselectAccount) {
            if (onSuccess) {
                onSuccess();
            }
        } else {
            if (self.isHud) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.viewController.view hideWait];
                });
            }
            [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession * _Nullable session, NSError * _Nullable error) {
            if (session != nil) {
                self.reselectAccount = NO;
                if (self.isHud) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.viewController.view showWait];
                    });
                }
                if (onSuccess) {
                    onSuccess();
                }
            } else if (onError) {
                onError(error);
            }
            }];
        }
    } else {
        ACAccountType *twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
            if (granted) {
                accounts = [accountStore accountsWithAccountType:twitterType];
                
                if ([accounts count] > 1) {
                    self.onResultSuccess = onSuccess;
                    self.onResultError = onError;
                    NSMutableArray *titles = [NSMutableArray new];
                    NSString *username = [self storageObject:kTmhSocialTwitterStorageAccount];

                    for (ACAccount *acc in accounts) {
                        if (! self.reselectAccount
                            && [acc.username isEqualToString:username]) {
                            account = acc;
                            if (self.isHud) { // bug with hud
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.viewController.view hideWait];
                                    [self.viewController.view showWait];
                                });
                            }
                            if (onSuccess) {
                                onSuccess();
                            }
                            return;
                        }
                        [titles addObject:acc.username];
                    }
                    [self selectAccount:titles];
                } else if ([accounts count] == 1) {
                    account = [accounts lastObject];
                    [self addStorageObject:account.username forKey:kTmhSocialTwitterStorageAccount];
                    if (self.isHud) { // bug with hud
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.viewController.view hideWait];
                            [self.viewController.view showWait];
                        });
                    }
                    if (onSuccess) {
                        onSuccess();
                    }
                } else {
                    if (onError) {
                        NSError *twitterError = [NSError errorWithDomain:@"twitter" code:kTmhSocialErrorAccount userInfo:@{NSLocalizedDescriptionKey : @"No twitter account"}];
                        onError(twitterError);
                    }
                }
            } else {
                if (onError) {
                    NSError *twitterError = [NSError errorWithDomain:@"twitter" code:kTmhSocialErrorAccount userInfo:@{NSLocalizedDescriptionKey : ((error != nil) && (error.localizedDescription != nil)) ? error.localizedDescription : @"Permission not granted"}];
                    onError(twitterError);
                }
            }
        };
        
        [accountStore requestAccessToAccountsWithType:twitterType options:nil completion:handler];
    }
}

/*
 * Get places
 */
- (void)placesWithCoordinate:(CLLocationCoordinate2D)coordinate success:(TmhSocialList)success error:(TmhSocialError)error
{
    [self auth:^{
        
        void (^handler)(NSData *, NSHTTPURLResponse * _Nullable, NSError *) = ^(NSData *responseData, NSHTTPURLResponse * _Nullable urlResponse, NSError *e) {
            if (responseData == nil) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        error(e);
                    });
                }
                return;
            }
            id response = responseData != nil ? [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil] : nil;
            lastResponse = response;
            
            DLog(@"Response : %@", response);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (e) {
                    error(e);
                } else {
                    if (success) {
                        NSArray *places = response[kTmhSocialTwitterParamResult] ? response[kTmhSocialTwitterParamResult][kTmhSocialTwitterParamPlaces] : @[];
                        success(places);
                    }
                }
            });
        };
        
        if (IOS11) {
            TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:[Twitter sharedInstance].sessionStore.session.userID];
            NSURLRequest *request = [client URLRequestWithMethod:@"GET"
                                                       URLString:kTmhSocialTwitterUrlGeoSearch
                                                      parameters:@{
                                                                   kTmhSocialTwitterParamLat : [NSString stringWithFormat:@"%f", coordinate.latitude],
                                                                   kTmhSocialTwitterParamLong : [NSString stringWithFormat:@"%f", coordinate.longitude],
                                                                   kTmhSocialTwitterParamMaxResults : [NSString stringWithFormat:@"%i", 20],
                                                                   kTmhSocialTwitterParamAccuracy : [NSString stringWithFormat:@"%i", 1000],
                                                                   kTmhSocialTwitterParamGranularity : kTmhSocialTwitterParamPoi
                                                                   }
                                                           error:nil];
            [client sendTwitterRequest:request completion:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                handler(data, (NSHTTPURLResponse *)response, connectionError);
            }];
        } else {
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodGET
                                                              URL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
                                                                                        kTmhSocialTwitterUrlGeoSearch,
                                                                                        kTmhSocialTwitterParamLat, @(coordinate.latitude),
                                                                                        kTmhSocialTwitterParamLong, @(coordinate.longitude),
                                                                                        kTmhSocialTwitterParamMaxResults, @(20),
                                                                                        kTmhSocialTwitterParamAccuracy, @(1000),
                                                                                        kTmhSocialTwitterParamGranularity, kTmhSocialTwitterParamPoi]]
                                                       parameters:nil];
            request.account = self.account;
            [request performRequestWithHandler:handler];
        }
        
    } onError:error];
}

/*
 * Share tweet
 */
- (void)share:(NSString *)text images:(NSArray *)images video:(NSData *)video coordinate:(CLLocationCoordinate2D)coordinate placeId:(NSString *)placeId onSuccess:(TmhSocialResult)onSuccess onError:(TmhSocialError)onError
{
    [self share:text images:images video:video mediaIds:@[] coordinate:coordinate placeId:placeId onSuccess:onSuccess onError:onError];
}

/*
 * Share tweet
 */
- (void)share:(NSString *)text images:(NSArray *)images video:(NSData *)video mediaIds:(NSArray *)ids coordinate:(CLLocationCoordinate2D)coordinate placeId:(NSString *)placeId onSuccess:(TmhSocialResult)onSuccess onError:(TmhSocialError)onError
{
    [self auth:^{
        
        NSString *textToShare = [text copy];
        
        // upload images/video first
        
        if (images.count) {
            [self uploadImage:images[0]
                      success:^(NSString *id) {
                          NSArray *newIds = id.length ? [ids arrayByAddingObject:id] : ids;
                          NSMutableArray *newImages = [NSMutableArray arrayWithArray:images];
                          [newImages removeObjectAtIndex:0];
                          [self share:text images:[newImages copy] video:nil mediaIds:newIds coordinate:coordinate placeId:placeId onSuccess:onSuccess onError:onError];
                      } error:onError];
            return;
        } else if (video) {
            [self uploadVideo:video
                      success:^(NSString *id) {
                          [self share:text images:nil video:nil mediaIds:@[id] coordinate:coordinate placeId:placeId onSuccess:onSuccess onError:onError];
                      } error:onError];
            return;
        }
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{kTmhSocialTwitterParamStatus : textToShare}];
        
        if (ids.count) {
            params[kTmhSocialTwitterParamMediaIds] = [ids componentsJoinedByString:@","];
        }
        if (CLLocationCoordinate2DIsValid(coordinate)) {
            params[kTmhSocialTwitterParamLat] = [NSString stringWithFormat:@"%f", coordinate.latitude];
            params[kTmhSocialTwitterParamLong] = [NSString stringWithFormat:@"%f", coordinate.longitude];
            params[kTmhSocialTwitterParamDisplayCoordinates] = @"true";
        }
        if (placeId) {
            params[kTmhSocialTwitterParamPlaceId] = placeId;
        }
        
        
        void (^handler)(NSData *, NSHTTPURLResponse * _Nullable, NSError *) = ^(NSData *responseData, NSHTTPURLResponse * _Nullable urlResponse, NSError *error) {
            if (responseData == nil) {
                if (onError) {
                    NSError *twitterError = [NSError errorWithDomain:@"twitter"
                                                                code:[self errorCode:0 withDefault:kTmhSocialErrorShare]
                                                            userInfo:@{NSLocalizedDescriptionKey : @"Empty response"}];
                    onError(twitterError);
                }
                return;
            }
            id response = [NSJSONSerialization JSONObjectWithData:responseData
                                                          options:0
                                                            error:nil];
            lastResponse = response;
            
            DLog(@"Response : %@", response);
            
            if (error
                || [urlResponse statusCode] != 200) {
                if (onError) {
                    NSError *twitterError = [NSError errorWithDomain:@"twitter"
                                                                code:[self errorCode:response withDefault:kTmhSocialErrorShare]
                                                            userInfo:@{NSLocalizedDescriptionKey : [self errorText:response]}];
                    onError(twitterError);
                }
            } else {
                if (onSuccess) {
                    onSuccess();
                }
            }
        };
        
        if (IOS11) {
            TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:[Twitter sharedInstance].sessionStore.session.userID];
            NSURLRequest *request = [client URLRequestWithMethod:@"POST"
                                                       URLString:kTmhSocialTwitterUrlStatusUpdate
                                                      parameters:params
                                                           error:nil];
            [client sendTwitterRequest:request completion:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                handler(data, (NSHTTPURLResponse *)response, connectionError);
            }];
        } else {
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                         requestMethod:SLRequestMethodPOST
                                                   URL:[NSURL URLWithString:kTmhSocialTwitterUrlStatusUpdate]
                                            parameters:params];
            
            request.account = self.account;
            [request performRequestWithHandler:handler];
        }
    } onError:onError];

}


/*
 * Upload image
 */
- (void)uploadImage:(NSData *)imageData success:(TmhSocialTwitterId)success error:(TmhSocialError)error
{
    // upload image
    
    void (^handler)(NSData *, NSHTTPURLResponse * _Nullable, NSError *) = ^(NSData *responseData, NSHTTPURLResponse * _Nullable urlResponse, NSError *e) {
        if (responseData == nil) {
            if (error) {
                error(e);
            }
            return;
        }
        id response = [NSJSONSerialization JSONObjectWithData:responseData
                                                      options:0
                                                        error:nil];
        DLog(@"Upload response: %@", response);
        
        if (e) {
            if (error) {
                error(e);
            }
        } else {
            if (success) {
                success(response[kTmhSocialTwitterParamMediaIdString]);
            }
        }
    };
    
    if (IOS11) {
        TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:[Twitter sharedInstance].sessionStore.session.userID];
        NSURLRequest *request = [client URLRequestWithMethod:@"POST"
                                                   URLString:kTmhSocialTwitterUrlUpload
                                                  parameters:@{
                                                               kTmhSocialTwitterParamMedia : [imageData base64EncodedStringWithOptions:0]
                                                               }
                                                       error:nil];
        [client sendTwitterRequest:request completion:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            handler(data, (NSHTTPURLResponse *)response, connectionError);
        }];
    } else {
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodPOST
                                                          URL:[NSURL URLWithString:kTmhSocialTwitterUrlUpload]
                                                   parameters:nil];
        
        [request addMultipartData:imageData
                         withName:kTmhSocialTwitterParamMedia
                             type:kTmhSocialTwitterParamMediaTypeJpeg
                         filename:kTmhSocialTwitterParamMediaFilenameImage];
        
        request.account = self.account;
        [request performRequestWithHandler:handler];
    }
}

/*
 * Upload video
 */
- (void)uploadVideo:(NSData *)video success:(TmhSocialTwitterId)success error:(TmhSocialError)error
{
    void (^handler)(NSData *, NSHTTPURLResponse * _Nullable, NSError *) = ^(NSData *responseData, NSHTTPURLResponse * _Nullable urlResponse, NSError *e) {
        if (responseData == nil) {
            if (error) {
                error(e);
            }
            return;
        }
        id response = [NSJSONSerialization JSONObjectWithData:responseData
                                                      options:0
                                                        error:nil];
        DLog(@"Init video response: %@", response);
        
        if (response[kTmhSocialTwitterParamErrors]) {
            e = [NSError errorWithDomain:kTmhSocialTwitterParamMedia
                                    code:[response[kTmhSocialTwitterParamErrors][0][kTmhSocialTwitterParamCode] intValue]
                                userInfo:@{NSLocalizedDescriptionKey: response[kTmhSocialTwitterParamErrors][0][kTmhSocialTwitterParamMessage]}];
        }
        if (e) {
            if (error) {
                error(e);
            }
        } else {
            NSString *mediaId = response[kTmhSocialTwitterParamMediaIdString];
            [self appendVideoChunk:video mediaId:mediaId segment:0 success:success error:error];
        }
    };
    
    if (IOS11) {
        TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:[Twitter sharedInstance].sessionStore.session.userID];
        NSURLRequest *request = [client URLRequestWithMethod:@"POST"
                                                   URLString:kTmhSocialTwitterUrlUpload
                                                  parameters:@{
                                                               kTmhSocialTwitterParamCommand : kTmhSocialTwitterParamInit,
                                                               kTmhSocialTwitterParamMediaType : kTmhSocialTwitterParamMediaTypeMp4,
                                                               kTmhSocialTwitterParamMediaCategoryVideo : kTmhSocialTwitterParamMediaCategory,
                                                               kTmhSocialTwitterParamTotalBytes : [NSString stringWithFormat:@"%lu", (unsigned long)video.length]
                                                               }
                                                       error:nil];
        
        [client sendTwitterRequest:request completion:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            handler(data, (NSHTTPURLResponse *)response, connectionError);
        }];
    } else {
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodPOST
                                                          URL:[NSURL URLWithString:kTmhSocialTwitterUrlUpload]
                                                   parameters:nil];
        
        [request addMultipartData:[kTmhSocialTwitterParamInit dataUsingEncoding:NSUTF8StringEncoding]
                         withName:kTmhSocialTwitterParamCommand
                             type:kTmhSocialTwitterParamTypeUrlEncoded
                         filename:nil];
        [request addMultipartData:[kTmhSocialTwitterParamMediaTypeMp4 dataUsingEncoding:NSUTF8StringEncoding]
                         withName:kTmhSocialTwitterParamMediaType
                             type:kTmhSocialTwitterParamTypeUrlEncoded
                         filename:nil];
        [request addMultipartData:[kTmhSocialTwitterParamMediaCategory dataUsingEncoding:NSUTF8StringEncoding]
                         withName:kTmhSocialTwitterParamMediaCategoryVideo
                             type:kTmhSocialTwitterParamTypeUrlEncoded
                         filename:nil];
        [request addMultipartData:[[NSString stringWithFormat:@"%lu", (unsigned long)video.length] dataUsingEncoding:NSUTF8StringEncoding]
                         withName:kTmhSocialTwitterParamTotalBytes
                             type:kTmhSocialTwitterParamTypeUrlEncoded
                         filename:nil];
        
        request.account = self.account;
        [request performRequestWithHandler:handler];
    }
}

/*
 * Upload video, append chunk
 */
- (void)appendVideoChunk:(NSData *)video mediaId:(NSString *)mediaId segment:(NSInteger)segment success:(TmhSocialTwitterId)success error:(TmhSocialError)error
{
    // append
    
    void (^handler)(NSData *, NSHTTPURLResponse * _Nullable, NSError *) = ^(NSData *responseData, NSHTTPURLResponse * _Nullable urlResponse, NSError *e) {
        if (responseData == nil) {
            if (error) {
                error(e);
            }
            return;
        }
        id response = [NSJSONSerialization JSONObjectWithData:responseData
                                                      options:0
                                                        error:nil];
        DLog(@"Append video response: %@", response);
        
        e = [self error:e response:response];
        
        if (e) {
            if (error) {
                error(e);
            }
        } else {
            if (video.length > (segment + 1) * kTmhSocialTwitterChunkBytes) {
                // append
                [self appendVideoChunk:video mediaId:mediaId segment:(segment + 1) success:success error:error];
            } else {
                // finalize
                [self finalizeVideo:mediaId success:success error:error];
            }
        }
    };
    int length = (int)MIN(kTmhSocialTwitterChunkBytes, video.length - (segment * kTmhSocialTwitterChunkBytes));
    NSData *videoData = [video subdataWithRange:NSMakeRange(segment * kTmhSocialTwitterChunkBytes, length)];

    if (IOS11) {
        TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:[Twitter sharedInstance].sessionStore.session.userID];
        NSURLRequest *request = [client URLRequestWithMethod:@"POST"
                                                   URLString:kTmhSocialTwitterUrlUpload
                                                  parameters:@{
                                                               kTmhSocialTwitterParamCommand : kTmhSocialTwitterParamAppend,
                                                               kTmhSocialTwitterParamMediaId : mediaId,
                                                               kTmhSocialTwitterParamMediaCategoryVideo : kTmhSocialTwitterParamMediaCategory,
                                                               kTmhSocialTwitterParamSegmentIndex : [NSString stringWithFormat:@"%i", (int)segment],
                                                               kTmhSocialTwitterParamMedia : [videoData base64EncodedStringWithOptions:0]
                                                               }
                                                       error:nil];
        
        [client sendTwitterRequest:request completion:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            handler(data, (NSHTTPURLResponse *)response, connectionError);
        }];
    } else {
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodPOST
                                                          URL:[NSURL URLWithString:kTmhSocialTwitterUrlUpload]
                                                   parameters:nil];
        
        [request addMultipartData:[kTmhSocialTwitterParamAppend dataUsingEncoding:NSUTF8StringEncoding]
                         withName:kTmhSocialTwitterParamCommand
                             type:kTmhSocialTwitterParamTypeFormData
                         filename:nil];
        [request addMultipartData:[mediaId dataUsingEncoding:NSUTF8StringEncoding]
                         withName:kTmhSocialTwitterParamMediaId
                             type:kTmhSocialTwitterParamTypeFormData
                         filename:nil];
        [request addMultipartData:[kTmhSocialTwitterParamMediaCategory dataUsingEncoding:NSUTF8StringEncoding]
                         withName:kTmhSocialTwitterParamMediaCategoryVideo
                             type:kTmhSocialTwitterParamTypeUrlEncoded
                         filename:nil];
        [request addMultipartData:[[NSString stringWithFormat:@"%i", (int)segment] dataUsingEncoding:NSUTF8StringEncoding]
                         withName:kTmhSocialTwitterParamSegmentIndex
                             type:kTmhSocialTwitterParamTypeFormData
                         filename:nil];
        [request addMultipartData:videoData
                         withName:kTmhSocialTwitterParamMedia
                             type:kTmhSocialTwitterParamTypeFormData
                         filename:kTmhSocialTwitterParamMediaFilenameVideo];

        request.account = self.account;
        [request performRequestWithHandler:handler];
    }
}


/*
 * Upload video, finalize
 */
- (void)finalizeVideo:(NSString *)mediaId success:(TmhSocialTwitterId)success error:(TmhSocialError)error
{
    void (^handler)(NSData *, NSHTTPURLResponse * _Nullable, NSError *) = ^(NSData *responseData, NSHTTPURLResponse * _Nullable urlResponse, NSError *e) {
        if (responseData == nil) {
            if (error) {
                error(e);
            }
            return;
        }
        id response = [NSJSONSerialization JSONObjectWithData:responseData
                                                      options:0
                                                        error:nil];
        DLog(@"Finalize video response: %@", response);
        
        e = [self error:e response:response];
        
        if (e) {
            if (error) {
                error(e);
            }
        } else {
            if (success) {
                success(mediaId);
            }
        }
    };
    
    if (IOS11) {
        TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:[Twitter sharedInstance].sessionStore.session.userID];
        NSURLRequest *request = [client URLRequestWithMethod:@"POST"
                                                   URLString:kTmhSocialTwitterUrlUpload
                                                  parameters:@{
                                                               kTmhSocialTwitterParamCommand : kTmhSocialTwitterParamFinalize,
                                                               kTmhSocialTwitterParamMediaId : mediaId,
                                                               kTmhSocialTwitterParamMediaCategoryVideo : kTmhSocialTwitterParamMediaCategory
                                                               }
                                                       error:nil];
        
        [client sendTwitterRequest:request completion:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            handler(data, (NSHTTPURLResponse *)response, connectionError);
        }];
    } else {
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodPOST
                                                          URL:[NSURL URLWithString:kTmhSocialTwitterUrlUpload]
                                                   parameters:nil];
        
        [request addMultipartData:[kTmhSocialTwitterParamFinalize dataUsingEncoding:NSUTF8StringEncoding]
                         withName:kTmhSocialTwitterParamCommand
                             type:kTmhSocialTwitterParamTypeUrlEncoded
                         filename:nil];
        [request addMultipartData:[kTmhSocialTwitterParamMediaCategory dataUsingEncoding:NSUTF8StringEncoding]
                         withName:kTmhSocialTwitterParamMediaCategoryVideo
                             type:kTmhSocialTwitterParamTypeUrlEncoded
                         filename:nil];
        [request addMultipartData:[mediaId dataUsingEncoding:NSUTF8StringEncoding]
                         withName:kTmhSocialTwitterParamMediaId
                             type:kTmhSocialTwitterParamTypeUrlEncoded
                         filename:nil];
        
        request.account = self.account;
        [request performRequestWithHandler:handler];
    }
}


/*
 * Share specified text, url and image
 */
- (void)share:(NSString *)text url:(NSString *)urlString image:(UIImage *)image onSuccess:(TmhSocialResult)onSuccess onError:(TmhSocialError)onError
{
    [self share:text images:nil video:nil coordinate:kCLLocationCoordinate2DInvalid placeId:nil onSuccess:onSuccess onError:onError];
}

/*
 * Get users profile info
 */
- (void)userInfo:(TmhSocialInfo)onSuccess onError:(TmhSocialError)onError
{
    [self auth:^{
        NSString *url = kTmhSocialTwitterUrlUserInfo;
        
        DLog(@"Url : %@", url);
        
        NSURL *requestURL = [NSURL URLWithString:url];
        
        void (^handler)(NSData *responseData,
          NSHTTPURLResponse *urlResponse,
          NSError *error) = ^(NSData *responseData,
                                       NSHTTPURLResponse *urlResponse,
                                       NSError *error) {

            id response = responseData ? [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil] : nil;
            lastResponse = response;
            
            DLog(@"Response user info : %@", response);
            
            if (error
                || [urlResponse statusCode] != 200) {
                if (onSuccess) {
                    onSuccess(@{
                                kTmhSocialTwitterParamUsername: IOS11 ? [Twitter sharedInstance].sessionStore.session.userID : account.username
                              });
                }
            } else {
                if (onSuccess) {
                    onSuccess(response);
                }
            }
        };
        
        if (IOS11) {
            TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:[Twitter sharedInstance].sessionStore.session.userID];
            NSURLRequest *request = [client URLRequestWithMethod:@"GET"
                                                       URLString:url
                                                      parameters:nil
                                                           error:nil];
            [client sendTwitterRequest:request completion:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                handler(data, (NSHTTPURLResponse *)response, connectionError);
            }];
        } else {
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                        requestMethod:SLRequestMethodGET
                                                                  URL:requestURL
                                                           parameters:nil];
            request.account =  self.account;
            [request performRequestWithHandler:handler];
        }
    } onError:onError];
}

/*
 * Logout from Twitter
 */
- (void)logout
{
    lastResponse = nil;
    self.avatar = nil;
    self.username = nil;
    
    if (IOS11) {
        TWTRSessionStore *session = [Twitter sharedInstance].sessionStore;
        if (session.hasLoggedInUsers) {
            [session logOutUserID:session.session.userID];
        }
    } else {
        arrayOfAccounts = @[];
        account = nil;
        [self removeStorageObject:kTmhSocialTwitterStorageAccount];
    }
}


#pragma mark - UIActionSheetDelegate method

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.reselectAccount = NO;
    
    if (buttonIndex < 0
        || buttonIndex >= accounts.count) {
        if (onResultError) {
            onResultError(nil);
        }
        return;
    }
    
    account = [accounts objectAtIndex:buttonIndex];

    [self addStorageObject:account.username forKey:kTmhSocialTwitterStorageAccount];
    
    if (onResultSuccess) {
        if (self.isHud) {
            [self.viewController.view showWait];
        }
        onResultSuccess();
    }
}

#pragma mark - Sign request

/*
 * Get unique string
 */
- (NSString *)uniqueString
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidStr;
}

/*
 * HMAC_SHA1 encoder
 */
- (NSString *)generateHMACSHA1Signature:(NSString *)key baseString:(NSString *)baseString
{
    const char *keyBytes = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *baseStringBytes = [baseString cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char digestBytes[20];
    
	CCHmacContext ctx;
    CCHmacInit(&ctx, kCCHmacAlgSHA1, keyBytes, strlen(keyBytes));
	CCHmacUpdate(&ctx, baseStringBytes, strlen(baseStringBytes));
	CCHmacFinal(&ctx, digestBytes);
    
	NSData *digestData = [NSData dataWithBytes:digestBytes length:20];
    return [digestData base64EncodedString];
}

/*
 * Get signature for the request
 */
- (NSString *)signature:(NSString *)method url:(NSString *)url token:(NSString *)token secretToken:(NSString *)secretToken;
{
    NSString *timestamp = [NSString stringWithFormat:@"%li", time(nil)];
    NSString *nonce = [self uniqueString];
    
    
    NSString *parameterString = [NSString stringWithFormat:kTmhSocialTwitterParameterString,
                                 [TmhConnection encodeParam:kTmhSocialTwitterConsumerKey],
                                 [TmhConnection encodeParam:nonce],
                                 [TmhConnection encodeParam:timestamp],
                                 [TmhConnection encodeParam:token]];
    DLog(@"1 : %@", parameterString);
    NSString *signatureBaseString = [NSString stringWithFormat:@"%@&%@&%@",
                                     method,
                                     [TmhConnection encodeParam:url],
                                     [TmhConnection encodeParam:parameterString]];
     
    
    DLog(@"2 : %@", signatureBaseString);
    NSString *signingKey = [NSString stringWithFormat:@"%@&%@",
                            [TmhConnection encodeParam:kTmhSocialTwitterConsumerSecret],
                            [TmhConnection encodeParam:secretToken]];
    
    DLog(@"3 : %@", signingKey);
    NSString *signature = [self generateHMACSHA1Signature:signingKey baseString:signatureBaseString];
    DLog(@"4 : %@", signature);
    
    NSString *oauthSignature = [NSString stringWithFormat:kTmhSocialTwitterOAuthSignature,
                                [TmhConnection encodeParam:kTmhSocialTwitterConsumerKey ],
                                [TmhConnection encodeParam:nonce],
                                [TmhConnection encodeParam:signature],
                                [TmhConnection encodeParam:timestamp],
                                [TmhConnection encodeParam:token]];
    DLog(@"5 : %@", oauthSignature);
    
    return oauthSignature;
}


@end
