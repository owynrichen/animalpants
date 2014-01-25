//
//  ParentGatePopup.h
//  FootGame
//
//  Created by Richen, Owyn on 12/31/13.
//
//

#import "Popup.h"
#import "CCLabelTTFWithExtrude.h"
#import "CCLabelTTFWithStroke.h"
#import "LongPressButton.h"
#import "CCAutoScalingSprite.h"

typedef void (^ParentClickBlock)(void);

static const int PARENT_GATE_TAG = 1874;

@interface ParentGatePopup : Popup {
    CCLabelTTFWithExtrude *title;
    CCLabelTTFWithStroke *summary;
    CCAutoScalingSprite *girls;
    LongPressButton *button;
}

@property (nonatomic) ParentClickBlock clickBlock;

+(ParentGatePopup *) popupWithSummaryKey: (NSString *) key clickBlock: (ParentClickBlock) pcBlock;

-(id) initWithSummaryKey: (NSString *) key clickBlock: (ParentClickBlock) pcBlock;

@end
