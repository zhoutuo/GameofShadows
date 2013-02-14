//
//  GameplayLayer.h
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "cocos2d.h"

typedef enum {
    ROTATING,
    MOVING,
    TAP,
    NONE
} Phase;

@interface GameplayLayer : CCLayer {
    NSInteger touchedObjectTag;
    CCSprite* objectsContainer;
    CCSprite* rotationCircle;
    CCSprite* droid1;
    CCArray* touchArray;
    Phase touchOperation;
}


-(CGPoint) getSpriteRelativePos: (CCSprite*) object;

@end
