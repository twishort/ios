//
//  TmhLocation.h
//  Twishort
//
//  Created by TMH on 29.12.16.
//  Copyright © 2016 TMH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM (NSInteger, TmhLocationErrorStatus) {
    TmhLocationErrorStatusUnauthorize = 100,
    TmhLocationErrorStatusTimer
};

@protocol TmhLocationDelegate <NSObject>

- (void)updateLocation:(CLLocation *)location;
- (void)failLocation:(NSError *)error;

@end

@interface TmhLocation : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id<TmhLocationDelegate> delegate;

- (void)search;
- (void)locationWithAccuracy:(CLLocationAccuracy)accuracy;

@end
