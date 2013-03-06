//
//  ShadowsLayer.h
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PathFinder.h"


#define DEVICE_WIDTH 1024
#define DEVICE_HEIGHT 768

@interface ShadowsLayer : CCLayer {
    float shadowHeightFactor;
    float shadowWidthFactor;
    NSMutableDictionary* objShadowTable;
    bool shadowMap[DEVICE_HEIGHT][DEVICE_WIDTH];
    int clearanceMap[DEVICE_HEIGHT][DEVICE_WIDTH];
    
}
-(void) castShadowFrom:(CCArray*)objects withRatios:(CCArray*)ratios;
-(void) updateShadowPos:(NSInteger)objectSpriteTag withRelativePos:(CGPoint) relativePos;
-(void) updateShadowRot:(NSInteger)objectSpriteTag withAngle:(float) angle;
-(void) startActionMode;
-(void) finishActionMode;

-(bool)pathFinder: (int)startX :(int)startY :(int)endX :(int)endY;

@end
