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
@property (nonatomic, strong) NSMutableArray *smoothingArray;

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

- (void)initializeLatest {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i++) {
        NSMutableArray *data = [[NSMutableArray alloc] init];
        for (int j = 0; i < 3; i++) {
            [data addObject:@0];
        }
        [array addObject:data];
    }
}


- (void)startMagnetometerUpdates {
    // Initialize smoothing array
    //[self initializeLatest];
    // start the compass
    [self.locationManager startUpdatingHeading];
}

- (void)stopMagnetometerUpdates {
    [self.locationManager stopUpdatingHeading];
}

// This delegate method is invoked when the location manager has heading data.
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    // Update the labels with the raw x, y, and z values.
    
    /*
    float last_x = [_latestData[@"x"] floatValue];
    float last_y = [_latestData[@"y"] floatValue];
    float last_z = [_latestData[@"z"] floatValue];
    float rotate_treshold = 50;
    
    
    float smoothed_x, smoothed_y, smoothed_z = 0.0f;
    
    for (int i = 0; i < 10; i++) {
        smoothed_x += [_smoothingArray[i][0] floatValue];
        smoothed_y += [_smoothingArray[i][1] floatValue];
        smoothed_z += [_smoothingArray[i][2] floatValue];
        
        NSLog(@"smoothed_y_%d = %f", i, smoothed_y);
        
    }
    
    
    smoothed_x = smoothed_x / 10;
    smoothed_y = smoothed_y / 10;
    smoothed_z = smoothed_z / 10;
    
    for (int i = 0; i < 9; i++) {
        _smoothingArray[i+1][0] = _smoothingArray[i][0];
        _smoothingArray[i+1][1] = _smoothingArray[i][1];
        _smoothingArray[i+1][2] = _smoothingArray[i][2];
    }
    
    _smoothingArray[0][0] = [NSNumber numberWithFloat:heading.x];
    _smoothingArray[0][1] = [NSNumber numberWithFloat:heading.y];
    _smoothingArray[0][2] = [NSNumber numberWithFloat:heading.z];
    
    //NSLog(@"smoothed: x: %.2f, y: %.2f, z: %.2f", smoothed_x, smoothed_y, smoothed_z);
    //NSLog(@"new: x: %.2f, y: %.2f, z: %.2f", heading.x, heading.y, heading.z);

    
    
    
    if ((fabs(last_x - smoothed_x) > rotate_treshold || fabs(last_x - smoothed_y) > rotate_treshold) &&
        (smoothed_x > 20 && smoothed_y > 20))
    {
        rotating = YES;
    }
    
    //NSLog(@"Rotating: %f", rotating);
     */
    
    BOOL rotating = NO;
        
    float x, y, z;
    if (rotating) {
        //x = last_x;
        //y = last_y;
        //z = last_z;
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
