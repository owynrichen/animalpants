//
//  CCAutoScaling.m
//  FootGame
//
//  Created by Owyn Richen on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCAutoScaling.h"

static NSInteger runningDevice_ = 0;

NSInteger runningDevice()
{
    if (runningDevice_ != 0)
        return runningDevice_;

    NSInteger ret=-1;

    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if( CC_CONTENT_SCALE_FACTOR() == 2 )
            ret = kiPadRetina;
        else
            ret = kiPad;
    }
    else
    {
        if( CC_CONTENT_SCALE_FACTOR() == 2 )
            ret = kiPhoneRetina;
        else
            ret = kiPhone;
    }

    runningDevice_ = ret;

    return ret;
}

float autoScaleForDevice(DeviceResolutionType device) {
    float autoScaleFactor = 1;

    switch(device) {
        case kiPadRetina:
            autoScaleFactor = 1;  // 1536 / 1536
            break;
        case kiPad:
            autoScaleFactor = 0.5;  // 768 / 1536
            break;
        case kiPhoneRetina:
            autoScaleFactor = 0.4166666666666; // ~ 640 / 1536
            break;
        case kiPhone:
            autoScaleFactor = 0.2083333333333; // ~ 320 / 1536
            break;
    }

    return autoScaleFactor;
}

float autoScaleForCurrentDevice() {
    return autoScaleForDevice(runningDevice());
}

float positionScaleForDevice(DeviceResolutionType device, DimensionType d) {
    float autoScaleFactor = 1;
    
    switch(device) {
        case kiPadRetina:
        case kiPad:
            autoScaleFactor = 1;  // 768 / 768
            break;
        case kiPhoneRetina:
        case kiPhone:
            if (d == kDimensionX) {
                autoScaleFactor = 0.41015625; // ~ 420 / 1024
            } else {
                autoScaleFactor = 0.4166666666666; // ~ 320 / 768
            }
            break;
    }
    
    return autoScaleFactor;
}

float positionScaleForCurrentDevice(DimensionType d) {
    return positionScaleForDevice(runningDevice(), d);
}

float positionRatioForDevice(DeviceResolutionType device) {
    switch(device) {
        case kiPadRetina:
        case kiPhoneRetina:
            return 1.0f;
            break;
        case kiPad:
        case kiPhone:
            return 2.0f;
            break;
    }
}

float positionRatioForCurrentDevice() {
    return positionRatioForDevice(runningDevice());
}

float autoScaleToPositionMultiplier(DeviceResolutionType device) {
    switch(device) {
        case kiPadRetina:
        case kiPhoneRetina:
            return 1.0f;
            break;
        case kiPad:
        case kiPhone:
            return 1.0f;
            break;
    }
}

CGPoint autoScaledPointToPositionForDevice(DeviceResolutionType device, CGPoint point) {
    float multiplier = autoScaleToPositionMultiplier(device);
    
    return ccp(point.x * multiplier, point.y * multiplier);
}

CGPoint autoScaledPointToPositionForCurrentDevice(CGPoint point) {
    return autoScaledPointToPositionForDevice(runningDevice(), point);
}

CGRect autoScaledRectToPositionForDevice(DeviceResolutionType device, CGRect rect) {
    float multiplier = autoScaleToPositionMultiplier(device);
    
    return CGRectMake(rect.origin.x * multiplier, rect.origin.y * multiplier, rect.size.width * multiplier, rect.size.height * multiplier);
}

CGRect autoScaledRectToPositionForCurrentDevice(CGRect rect) {
    return autoScaledRectToPositionForDevice(runningDevice(), rect);
}