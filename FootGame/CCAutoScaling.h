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

NSInteger runningDevice();
float autoScaleForCurrentDevice();
float autoScaleForDevice(DeviceResolutionType device);
float positionScaleForDevice(DeviceResolutionType device, DimensionType d);
float positionScaleForCurrentDevice(DimensionType d);

#define fontScaleForCurrentDevice() positionScaleForCurrentDevice(kDimensionX)

#define ccpToRatio(__X__,__Y__) CGPointMake(__X__ * positionScaleForCurrentDevice(kDimensionY),__Y__ * positionScaleForCurrentDevice(kDimensionY))