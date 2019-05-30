//
//  TmhOAuthReverse.m
//  Twishort
//
//  Created by TMH on 12.06.13.
//  Copyright (c) 2013 TMH. All rights reserved.
//

#import "TmhOAuthReverse.h"
#import <TwitterKit/TWTRKit.h>

@implementation TmhOAuthReverse

/*
 * Get OAuth signature
 */
- (void)signature:(ACAccount *)account onSuccess:(TmhOAuthReverseSuccess)onSuccess onError:(TmhOAuthReverseError)onError
{
    if (IOS11) {
        id<TWTRAuthSession> session = [Twitter sharedInstance].sessionStore.session;
        onSuccess(session.authToken, session.authTokenSecret);
    } else {
        [self performReverseAuthForAccount:account withHandler:^(NSData *responseData, NSError *error) {
            
            if (error
                || ! responseData) {
                onError();
                return;
            }
            
            NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            
            NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
            NSArray *result = @[];
            for (NSString *part in parts) {
                result = [result arrayByAddingObject:[part componentsSeparatedByString:@"="]];
            }
            
            if ([result count] < 2) {
                onError();
                return;
            }
            
            NSString *token = [[result objectAtIndex:0] objectAtIndex:1];
            NSString *secretToken = [[result objectAtIndex:1] objectAtIndex:1];
            
            if (! token
                || ! secretToken) {
                onError();
                return;
            }
            
            DLog(@"Token: %@", token);
            DLog(@"Token secret: %@", secretToken);
            
            onSuccess(token, secretToken);
        }];
    }
}


@end
