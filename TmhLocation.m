//
//  TmhLocation.m
//  Twishort
//
//  Created by TMHo on 29.12.16.
//  Copyright © 2016 TMH. All rights reserved.
//

#import "TmhLocation.h"

@implementation TmhLocation
{
    CLLocationManager *lm;
    NSTimer *timeupTimer; // prevent lose power, only n seconds to find location
    NSDate *lastTimeUpdated;
}

/*
 * Check location permission
 */
- (BOOL)isLocationAllow
{
    if ([CLLocationManager locationServicesEnabled] &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        return YES;
    }
    return NO;
}

- (void)search
{
    [self locationWithAccuracy:kCLLocationAccuracyBest];
}

- (void)locationWithAccuracy:(CLLocationAccuracy)accuracy
{
    if (![self isLocationAllow]) {
        if (self.delegate) {
            [self.delegate failLocation:[NSError errorWithDomain:@"" code:TmhLocationErrorStatusUnauthorize userInfo:nil]];
        }
        return;
    }
    
    lm = [CLLocationManager new];
    lm.delegate = self;
    lm.desiredAccuracy = accuracy;
    lm.distanceFilter = kCLDistanceFilterNone;
    lm.headingFilter = kCLHeadingFilterNone;
    lm.pausesLocationUpdatesAutomatically = NO;
    lm.activityType = CLActivityTypeOtherNavigation;
    
    if (timeupTimer.isValid) {
        [timeupTimer invalidate];
    }
    timeupTimer = [NSTimer scheduledTimerWithTimeInterval:80
                                                   target:self
                                                 selector:@selector(stopTimer)
                                                 userInfo:nil
                                                  repeats:NO];
    [lm startUpdatingLocation];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
        [lm requestWhenInUseAuthorization];
    }
}

- (void)stopTimer
{
    [lm stopUpdatingLocation];

    if (self.delegate) {
        [self.delegate failLocation:[NSError errorWithDomain:@"" code:TmhLocationErrorStatusTimer userInfo:nil]];
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [lm stopUpdatingLocation];

    if (self.delegate) {
        [self.delegate failLocation:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [lm stopUpdatingLocation];
 
    CLLocation *location = [locations lastObject];

    [timeupTimer invalidate];
    
    DLog(@"Location: %0.6f:%0.6f", location.coordinate.latitude, location.coordinate.longitude);

    // prevent multiple call
    if (lastTimeUpdated
        && [lastTimeUpdated timeIntervalSinceNow] > -1.0) {
        return;
    }
    lastTimeUpdated = [NSDate new];

    if (self.delegate) {
        [self.delegate updateLocation:location];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation");
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    DLog(@"Pause location update");
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    DLog(@"Resume location update");
}

@end
