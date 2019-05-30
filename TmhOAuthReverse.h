//
//  TmhOAuthReverse.h
//  Twishort
//
//  Created by TMH on 12.06.13.
//  Copyright (c) 2013 TMH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWAPIManager.h"

typedef void (^TmhOAuthReverseSuccess)(NSString *token, NSString *secretToken);
typedef void (^TmhOAuthReverseError)(void);

@interface TmhOAuthReverse : TWAPIManager

/*
 * Get OAuth signature
 */
- (void)signature:(ACAccount *)account onSuccess:(TmhOAuthReverseSuccess)onSuccess onError:(TmhOAuthReverseError)onError;

@end
