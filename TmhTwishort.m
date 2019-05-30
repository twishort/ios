//
//  TmhTwishort.m
//  Twishort
//
//  Created by TMH on 06.06.13.
//  Copyright (c) 2013 TMH. All rights reserved.
//

#import "TmhTwishort.h"

NSString * const kTmhSocialTwishortApiKey = @"";

NSString * const kTmhSocialTwishortUrlPost = @"http://api.twishort.com/1.1/post.json";
NSString * const kTmhSocialTwishortUrlUpdateId = @"http://api.twishort.com/1.1/update_ids.json";
NSString * const kTmhSocialTwishortParamTwitterVerifyCredentials = @"https://api.twitter.com/1.1/account/verify_credentials.json";
NSString * const kTmhSocialTwishortParamApiKey = @"api_key";
NSString * const kTmhSocialTwishortParamText = @"text";
NSString * const kTmhSocialTwishortParamTitle = @"title";
NSString * const kTmhSocialTwishortParamLat = @"lat";
NSString * const kTmhSocialTwishortParamLong = @"long";
NSString * const kTmhSocialTwishortParamPlace = @"place";
NSString * const kTmhSocialTwishortParamPlaceId = @"place_id";
NSString * const kTmhSocialTwishortParamId = @"id";
NSString * const kTmhSocialTwishortParamIdStr = @"id_str";
NSString * const kTmhSocialTwishortParamTweetId = @"tweet_id";
NSString * const kTmhSocialTwishortParamMedia = @"media";
NSString * const kTmhSocialTwishortParamEntities = @"entities";
NSString * const kTmhSocialTwishortParamExtendedEntities = @"extended_entities";
NSString * const kTmhSocialTwishortXAuthServiceProvider = @"X-Auth-Service-Provider";
NSString * const kTmhSocialTwishortXVerifyCredentials = @"X-Verify-Credentials-Authorization";
NSString * const kTmhSocialTwishortResponseText = @"text_to_tweet";
NSString * const kTmhSocialTwishortResponseError = @"error";
NSString * const kTmhSocialTwishortResponseCode = @"code";
NSString * const kTmhSocialTwishortStorageToken = @"token";
NSString * const kTmhSocialTwishortStorageSecretToken = @"secret token";

@implementation TmhTwishort
{
    NSString *signature;
}

/*
 * Clear stored tokens
 */
- (void)clearToken
{
    [self removeStorageObject:kTmhSocialTwishortStorageToken];
    [self removeStorageObject:kTmhSocialTwishortStorageSecretToken];
}

/*
 * Update tweet id on Twishort
 */
- (void)updateId:(NSString *)twishortId tweetId:(NSString *)tweetId onSuccess:(TmhSocialResult)onSuccess onError:(TmhSocialError)onError
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
                             kTmhSocialTwishortParamApiKey : kTmhSocialTwishortApiKey,
                             kTmhSocialTwishortParamId : twishortId,
                             kTmhSocialTwishortParamTweetId : tweetId
                             }];
    
    NSDictionary *media = self.lastResponse[kTmhSocialTwishortParamExtendedEntities][kTmhSocialTwishortParamMedia];

    if (media.count) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:media options:0 error:nil];
        params[kTmhSocialTwishortParamMedia] = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    NSDictionary *place = self.lastResponse[kTmhSocialTwishortParamPlace];
    if ([place isKindOfClass:NSDictionary.class]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:place options:0 error:nil];
        params[kTmhSocialTwishortParamPlace] = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    NSDictionary *headers = @{
                              kTmhSocialTwishortXAuthServiceProvider : kTmhSocialTwishortParamTwitterVerifyCredentials,
                              kTmhSocialTwishortXVerifyCredentials : signature
                              };
    
    TmhConnection *con = [TmhConnection new];
    [con POST:kTmhSocialTwishortUrlUpdateId
   withParams:params
   andHeaders:headers
    onSuccess:^(NSDictionary *data) {
        onSuccess();
    } onError:^(int statusCode, NSDictionary *data) {
        NSError *error = [NSError errorWithDomain:@"twishort"
                                             code:[self errorCode:data withDefault:kTmhTwishortErrorShare]
                                         userInfo:@{NSLocalizedDescriptionKey : [self errorText:data]}
                          ];
        onError(error);
    }];
}

#pragma mark - TmhSocialDelegate

/*
 * Share tweet with Twishort
 */
- (void)share:(NSString *)text images:(NSArray *)images video:(NSData *)video title:(NSString *)title coordinate:(CLLocationCoordinate2D)coordinate place:(NSString *)place placeId:(NSString *)placeId onSuccess:(TmhSocialResult)onSuccess onError:(TmhSocialError)onError
{
    if (self.status != kTmhTwishortStatusTwitterToken) {
        
        self.status = kTmhTwishortStatusBegin;
    
        @try {
            
            [self auth:^{
                
                self.status = kTmhTwishortStatusTwitterAuth;
                
                TmhOAuthReverse *oauthReverse = [TmhOAuthReverse new];
                
                [oauthReverse signature:self.account onSuccess:^(NSString *token, NSString *secretToken) {
                    
                    self.status = kTmhTwishortStatusTwitterToken;
                    
                    [self addStorageObject:token forKey:kTmhSocialTwishortStorageToken];
                    [self addStorageObject:secretToken forKey:kTmhSocialTwishortStorageSecretToken];
                    
                    [self share:text images:images video:video title:title coordinate:coordinate place:place placeId:placeId onSuccess:onSuccess onError:onError];
                    
                } onError:^{
                    NSError *error = [NSError errorWithDomain:@"twitter"
                                                         code:kTmhTwishortErrorSignature
                                                     userInfo:@{NSLocalizedDescriptionKey : @"Can't get token for signature"}];
                    onError(error);
                }];
            } onError:^(NSError *error) {
                onError(error);
            }];
        } @catch (NSException *e) {
            NSError *error = [NSError errorWithDomain:@"twishort" code:kTmhTwishortErrorShare userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Exception : %@", e.description]}];
            onError(error);
        }
        return;
    }
    
    NSString *token = [self storageObject:kTmhSocialTwishortStorageToken];
    NSString *secretToken = [self storageObject:kTmhSocialTwishortStorageSecretToken];
    self.lastTweetId = nil;
    
    signature = [self signature:@"GET" url:kTmhSocialTwishortParamTwitterVerifyCredentials token:token secretToken:secretToken];
    BOOL isMedia = images.count > 0 || video != nil;
    
    
    // 1 Twishort
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                  kTmhSocialTwishortParamApiKey : kTmhSocialTwishortApiKey,
                                                                                  kTmhSocialTwishortParamText : text,
                                                                                  kTmhSocialTwishortParamMedia : [NSNumber numberWithInt:isMedia?1:0]
                                                                                  }];
    if (title) {
        [params setObject:title forKey:kTmhSocialTwishortParamTitle];
    }
    
    NSDictionary *headers = @{
                              kTmhSocialTwishortXAuthServiceProvider : kTmhSocialTwishortParamTwitterVerifyCredentials,
                              kTmhSocialTwishortXVerifyCredentials : signature
                              };
    
    TmhConnection *con = [TmhConnection new];
    [con POST:kTmhSocialTwishortUrlPost
   withParams:params
   andHeaders:headers
    onSuccess:^(NSDictionary *data) {
        NSString *textTwishort = data[kTmhSocialTwishortResponseText];
        NSString *twishortId = data[kTmhSocialTwishortParamId];
        
        DLog(@"Text from Twishort : %@", textTwishort);
        
        self.status = kTmhTwishortStatusTwishortText;
        
        // 2 Twitter
        [super share:textTwishort
              images:images
               video:video
          coordinate:coordinate
             placeId:placeId
           onSuccess:^{
               
               self.status = kTmhTwishortStatusTwitterText;
               
               NSString *tweetId = [self.lastResponse objectForKey:kTmhSocialTwishortParamIdStr];
               self.lastTweetId = tweetId;
               
               // 3 Twishort
               dispatch_async(dispatch_get_main_queue(), ^{
                   
                   self.status = kTmhTwishortStatusTwishortUpdate;
                   
                   [self updateId:twishortId
                          tweetId:tweetId
                        onSuccess:onSuccess
                          onError:^(NSError *error) {
                               // Success anyway
                               if (onSuccess) {
                                   onSuccess();
                               }
                   }];
               });
           }
            onError:onError];

    } onError:^(int statusCode, NSDictionary *data) {
        NSError *error = [NSError errorWithDomain:@"twishort"
                                             code:[self errorCode:data withDefault:kTmhTwishortErrorShare]
                                         userInfo:@{NSLocalizedDescriptionKey : [self errorText:data]}
                          ];
        onError(error);
    }];
}

/*
 * Logout from social network
 */
- (void)logout
{
    [super logout];
    
    [self clearToken];
}

@end
