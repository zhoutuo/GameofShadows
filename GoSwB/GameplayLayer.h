//
//  GameplayLayer.h
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "cocos2d.h"
#import "Box2D.h"
#import "PhysicsSprite.h"

// Physics constants.
#define PTM_RATIO 32

typedef enum {
    ROTATING,
    MOVING,
    TAP,
    NONE
} Phase;

@interface GameplayLayer : CCLayer {
    NSInteger touchedObjectTag;
    CCSprite* objectsContainer;
    CGRect* containerBox;
    
    CCSprite* rotationCircle;
    PhysicsSprite* droid1;
    CCArray* touchArray;
    Phase touchOperation;
    
    // Physics section.
    b2World* physicsWorld;
    b2Body* droid1Body;
    b2Body* physicsGroundBody;
    b2Fixture* physicsWorldTop;
    b2Fixture* physicsWorldBottom;
    b2Fixture* physicsWorldLeft;
    b2Fixture* physicsWorldRight;
    
    NSMutableArray* objectSpriteArray;
    NSMutableArray* objectBodyArray;
}


-(CGPoint) getSpriteRelativePos: (CCSprite*) object;

@end