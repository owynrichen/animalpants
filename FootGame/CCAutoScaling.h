//
//  CCAutoScaling.h
//  FootGame
//
//  Created by Owyn Richen on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    kiPhone = 1,
    kiPhoneRetina = 2,
    kiPad = 3,
    kiPadRetina = 4,
} DeviceResolutionType;

typedef enum {
    kDimensionX,
    kDimensionY
} DimensionType;

// returns the DeviceResolutionType of the device
NSInteger runningDevice();

// Gets the pixel scale ratio miltiplier for a given device based
// on the assumption the the source image is ipad retina resolution
// this is used to help more easily scale ipad ratio work to the iphone
float autoScaleForCurrentDevice();
float autoScaleForDevice(DeviceResolutionType device);

// Gets the position scale multiplier with the assumption that the
// source number is based on the ipad/ipad retina coordinate system
float positionScaleForDevice(DeviceResolutionType device, DimensionType d);
float positionScaleForCurrentDevice(DimensionType d);

// TODO: this could be done with reverse transformation, no?
// This currently returns 2x for non-retina devices to help calculate
// positions for nodes added as children to previously scaled nodes.
// This is to help compensate for previous scaling done impacting coordinate transforms
float positionRatioForDevice(DeviceResolutionType device);
float positionRatioForCurrentDevice();

// THESE AREN'T USED AT THE MOMENT
CGPoint autoScaledPointToPositionForDevice(DeviceResolutionType device, CGPoint point);
CGPoint autoScaledPointToPositionForCurrentDevice(CGPoint point);
CGRect autoScaledRectToPositionForDevice(DeviceResolutionType device, CGRect point);
CGRect autoScaledRectToPositionForCurrentDevice(CGRect point);

// A macro to simplify the scaling of font sizes
#define fontScaleForCurrentDevice() positionScaleForCurrentDevice(kDimensionX)

// A macro to simplify creating of CGPoints based including the multiplier for easy scaling
// between ipad aspect ratios and iphone
#define ccpToRatio(__X__,__Y__) CGPointMake(__X__ * positionScaleForCurrentDevice(kDimensionY),__Y__ * positionScaleForCurrentDevice(kDimensionY))