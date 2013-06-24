//
//  CCMenuItemImageTouchDown.h
//  FootGame
//
//  Created by Owyn Richen on 2/4/13.
//
//

#import "CCMenuItem.h"

@interface CCMenuItemImageTouchDown : CCMenuItemImage {
    void (^downBlock)(id sender);
}

-(void) addDownEvent: (void (^)(id sender)) block;

@end
