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
#define LIGHT_SPRITE_DEPTH 3
#define DYNAMIC_LIGHTNING_DEPTH 50
#define SHADOW_MONESTER_DEPTH 100
#define SHADOW_BLOCK_SIZE 20

@interface ShadowsLayer : CCLayer {
    NSMutableDictionary* objShadowTable;
    bool shadowMap[DEVICE_HEIGHT][DEVICE_WIDTH];
    CCSprite* shadowMonster;
    CCSprite* wormholeExit;
    CCSprite* WormholeTransition;
    bool touchOFF;
    bool hasTransition;
    CGPoint transitionPoint;
    
    //test object
    CCSprite* sun;
    
}
-(void) castShadowFrom:(CCArray*)objects withRatios:(CCArray*)ratios withAPs:(CCArray*)APs;
-(void) castLightFrom:(CCArray*)lights withRatios:(CCArray*)ratios withAPs:(CCArray*)APs;
-(void) updateShadowPos:(NSInteger)objectSpriteTag withRelativePos:(CGPoint) relativePos;
-(void) updateShadowRot:(NSInteger)objectSpriteTag withAngle:(float) angle;
-(void) startActionMode;
-(void) finishActionMode;

@end
