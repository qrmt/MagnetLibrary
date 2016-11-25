//
//  BLMagnetometer.m
//  BLMagnetometer
//
//  Created by Oskar Vuola on 25/11/16.
//  Copyright © 2016 blastly. All rights reserved.
//

#import "BLMagnetometer.h"

@interface BLMagnetometer ()

@property (nonatomic, strong) NSDictionary *latestData;

@property (nonatomic, retain) CLLocationManager *locationManager;

@end


@implementation BLMagnetometer

- (instancetype)init {
    self = [super init];
    
    // setup the location manager
    _locationManager = [[CLLocationManager alloc] init];
    _latestData = @{
                    @"x": @0,
                    @"y": @0,
                    @"z": @0,
                    @"total": @0
                    };
    
    // check if the hardware has a compass
    if ([CLLocationManager headingAvailable] == NO) {
        // No compass is available. This application cannot function without a compass,
        // so a dialog will be displayed and no magnetic data will be measured.
        return nil;
    } else {
        // heading service configuration
        self.locationManager.headingFilter = kCLHeadingFilterNone;
        
        // setup delegate callbacks
        self.locationManager.delegate = self;
    }
    
    
    return self;
}

- (void)startMagnetometerUpdates {
    // start the compass
    [self.locationManager startUpdatingHeading];
}

- (void)stopMagnetometerUpdates {
    [self.locationManager stopUpdatingHeading];
}

// This delegate method is invoked when the location manager has heading data.
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    // Update the labels with the raw x, y, and z values.
    
    float last_x = [_latestData[@"x"] floatValue];
    float last_y = [_latestData[@"y"] floatValue];
    float last_z = [_latestData[@"z"] floatValue];
    float rotate_treshold = 50;
    
    BOOL rotating = NO;
    
    if (fabs(last_x - heading.x) > rotate_treshold || fabs(last_x - heading.y) > rotate_treshold) {
        rotating = YES;
    }
        
    float x, y, z;
    if (rotating) {
        x = last_x;
        y = last_y;
        z = last_z;
    } else {
        x = heading.x;
        y = heading.y;
        z = heading.z;
    }
    
    double total = pow(heading.x, 2) + pow(heading.y, 2);
    total = sqrt(total);
    
    _latestData = @{
                    @"x": @(x),
                    @"y": @(y),
                    @"z": @(z),
                    @"total": @(total),
                    @"rotating": @(rotating)
                    };
    
}

// This delegate method is invoked when the location managed encounters an error condition.
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] == kCLErrorDenied) {
        // This error indicates that the user has denied the application's request to use location services.
        [manager stopUpdatingHeading];
    } else if ([error code] == kCLErrorHeadingFailure) {
        // This error indicates that the heading could not be determined, most likely because of strong magnetic interference.
    }
}

- (NSDictionary *)latestMagnetometerData {
    return _latestData;
}

@end
