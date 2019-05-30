//
//  TmhTwishort.h
//  Twishort
//
//  Created by TMH on 06.06.13.
//  Copyright (c) 2013 TMH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TmhSocialTwitter.h"
#import "TmhOAuthReverse.h"

typedef enum {
    kTmhTwishortErrorAuth = 1000,
    kTmhTwishortErrorShare,
    kTmhTwishortErrorSignature
} kTmhTwishortError;

typedef enum {
    kTmhTwishortStatusBegin,
    kTmhTwishortStatusTwitterAuth,
    kTmhTwishortStatusTwitterToken,
    kTmhTwishortStatusTwishortText,
    kTmhTwishortStatusTwitterText,
    kTmhTwishortStatusTwishortUpdate
} kTmhTwishortStatus;

typedef void (^TmhTwishortShare)(NSString *text, NSString *twishortId);

@interface TmhTwishort : TmhSocialTwitter

@property kTmhTwishortStatus status;
@property (nonatomic, retain) NSString *lastTweetId;

- (void)share:(NSString *)text images:(NSArray *)images video:(NSData *)video title:(NSString *)title coordinate:(CLLocationCoordinate2D)coordinate place:(NSString *)place placeId:(NSString *)placeId onSuccess:(TmhSocialResult)onSuccess onError:(TmhSocialError)onError;


@end
