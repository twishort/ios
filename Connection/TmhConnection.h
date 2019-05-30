//
//  TmhConnection.h
//  Tmh
//
//  Created by TMH on 12.02.13.
//  Copyright (c) 2013 Tmh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, TmhConnectionStatus) {
    TmhConnectionStatusInternet = -1
};

typedef NS_ENUM(NSUInteger, TmhConnectionType) {
    TmhConnectionTypeJSON,
    TmhConnectionTypeText,
    TmhConnectionTypeData
};

typedef void (^TmhConnectionSuccessEmpty)(void);
typedef void (^TmhConnectionSuccess)(id data);
typedef void (^TmhConnectionError)(int statusCode, id data);

extern NSString *const kTmhConnectionData;
extern NSString *const kTmhConnectionName;
extern NSString *const kTmhConnectionFilename;

@interface TmhConnection : NSObject <NSURLConnectionDelegate>

@property (readonly) BOOL isConnected;
@property TmhConnectionType type;
@property BOOL cache;
@property (readonly, getter = cache) BOOL isCache;
@property BOOL encodeUrl;
@property (readonly, getter = encodeUrl) BOOL isEncodeUrl;
@property BOOL requestJSON;
@property (readonly, getter = requestJSON) BOOL isRequestJSON;

/*
 * Get IP address
 */
+ (NSString *)ip;

/*
 * Check device connection to Internet
 */
+ (BOOL)connected;

- (void)GET:(NSString *)url onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError;

- (void)GET:(NSString *)url withParams:(NSDictionary *)params andHeaders:(NSDictionary *)headers onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError;

- (void)DELETE:(NSString *)url onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError;

- (void)DELETE:(NSString *)url withParams:(NSDictionary *)params andHeaders:(NSDictionary *)headers onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError;

- (void)POST:(NSString *)url withParams:(NSDictionary *)params andHeaders:(NSDictionary *)headers onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError;

- (void)POST:(NSString *)url withParams:(NSDictionary *)params andHeaders:(NSDictionary *)headers andFiles:(NSArray *)files onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError;

- (void)PUT:(NSString *)url withParams:(NSDictionary *)params andHeaders:(NSDictionary *)headers onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError;

/*
 * Request with params and headers
 */
- (void)request:(NSString *)method url:(NSString *)url withParams:(NSDictionary *)params andHeaders:(NSDictionary *)headers andFiles:(NSArray *)files onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError;

/*
 * Add info to cache
 */
- (void)addCache:(NSDictionary *)info url:(NSString *)url;

/*
 * Get cached data
 */
- (NSArray *)cachedData;

/*
 * Clear cached info
 */
+ (void)clearCache;

/*
 * Get cache result by url
 */
+ (id)cacheWithUrl:(NSString *)url;

/*
 * Encode param for using in url
 */
+ (NSString *)encodeParam:(NSString *)param;

@end
