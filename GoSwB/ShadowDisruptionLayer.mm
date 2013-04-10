//
//  ShadowDisruptionLayer.m
//  Game of Shadows
//
//  Created by Ludovic Lang on 3/8/13.
//
//

#import "GameplayLayer.h"
#import "ShadowDisruptionLayer.h"
#import "Globals.h"
#import "GameplayScene.h"
@implementation ShadowDisruptionLayer

#define LIGHT_HEIGHT_FACTOR 2.0f
#define LIGHT_WIDTH_FACTOR 2.0f

-(id)init{
    if (self = [super init]) {
        objLightTable = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) dealloc {
    [objLightTable release];
    [super dealloc];
}

-(bool) checkIfInLight:(int)ycoor :(int)xcoor {
    CGPoint point = ccp(xcoor, ycoor);
    //iterate all elements of the light sources
    for (LightSource* cur in self.children) {
        if ([cur isOn] and CGRectContainsPoint([cur getInnerBoundingBox], point)) {
            return true;
        }
    }
    return false;
}

-(void) castLightFrom:(CCArray*)objects withRatios:(CCArray *)ratios {
    
    if (objects.count != ratios.count) {
        return;
    }
    for (int i = 0; i < objects.count; ++i) {
        CCSprite* cur = (CCSprite*)[objects objectAtIndex:i];
        CCTexture2D* texture = cur.texture;
        CCSprite* light = [CCSprite spriteWithTexture:texture];
        [light setColor:ccc3(255, 255, 255)];
        [light setScaleY:LIGHT_HEIGHT_FACTOR];
        [light setScaleX:LIGHT_WIDTH_FACTOR];
        
        light.tag = [GameplayScene TagGenerater];
        
        [objLightTable
         setObject:[NSNumber numberWithInteger:light.tag]
         forKey:[NSNumber numberWithInteger:cur.tag]];
        
        [self addChild:light];
        CGPoint ratio = [[ratios objectAtIndex:i] CGPointValue];
        [self updateLightPos:cur.tag withRelativePos: ratio];
    }
}

-(void) updateLightPos:(NSInteger)objectSpriteTag withRelativePos:(CGPoint)relativePos {
    CCSprite* child = [self getLightSpriteFromTag:objectSpriteTag];
    if (child != nil) {
        child.position = [self calculateLightPos: relativePos];
    }

}

-(CCSprite*) getLightSpriteFromTag: (NSInteger) objectSpriteTag {
    NSNumber* tag = (NSNumber*)[objLightTable objectForKey:[NSNumber numberWithInteger:objectSpriteTag]];
    NSInteger tagInteger = [tag unsignedIntegerValue];
    CCSprite* child = (CCSprite*)[self getChildByTag:tagInteger];
    return child;
}

-(CGPoint) calculateLightPos:(CGPoint)objectRelativePos {
    CGSize wins = [[CCDirector sharedDirector] winSize];
    NSInteger posY = wins.height * objectRelativePos.y;
    NSInteger posX = wins.width * objectRelativePos.x;
    return ccp(posX, posY);
}


@end
