//
//  ShadowsLayer.h
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"


#define DEVICE_WIDTH 1024
#define DEVICE_HEIGHT 768
#define SHADOW_SPRITE_DEPTH 1
#define WORMHOLE_DEPTH 2
#define DYNAMIC_LIGHTNING_DEPTH 50
#define SHADOW_MONESTER_DEPTH 100

@interface ShadowsLayer : CCLayer {
    float shadowHeightFactor;
    float shadowWidthFactor;
    NSMutableDictionary* objShadowTable;
    bool shadowMap[DEVICE_HEIGHT][DEVICE_WIDTH];
    int clearanceMap[DEVICE_HEIGHT][DEVICE_WIDTH];
    CCSprite* shadowMonster;
    CCSprite* wormholeEntrance;
    CCSprite* wormholeExit;
    CCSprite* WormholeTransition;
    bool goHere;
    
    //test object
    CCSprite* sun;
    
}
-(void) castShadowFrom:(CCArray*)objects withRatios:(CCArray*)ratios;
-(void) updateShadowPos:(NSInteger)objectSpriteTag withRelativePos:(CGPoint) relativePos;
-(void) updateShadowRot:(NSInteger)objectSpriteTag withAngle:(float) angle;
-(void) startActionMode;
-(void) finishActionMode;

@end
