//
//  ShadowsLayer.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//
#import "ShadowsLayer.h"
#import "GameplayScene.h"
#define PTM_RATIO 32.0


@implementation ShadowsLayer

-(id) init {
    if (self = [super init]) {
        shadowHeightFactor = 2.0f;
        shadowWidthFactor = 2.0f;
        objShadowTable = [[NSMutableDictionary alloc] init];
        
        
    }
    return self;
}


-(void) dealloc {
    [objShadowTable release];
    [super dealloc];
}

-(CGPoint) calculateShadowPos:(CGPoint)objectRelativePos {
    CGSize wins = [[CCDirector sharedDirector] winSize];
    NSInteger posY = wins.height * objectRelativePos.y;
    NSInteger posX = wins.width * objectRelativePos.x;
    return ccp(posX, posY);
}


-(void) castShadowFrom:(GameplayLayer*)objectsLayer {
    
    CCArray* children = objectsLayer.children;
    for (NSInteger i = 0; i < children.count; ++i) {
        CCSprite* cur = [children objectAtIndex:i];
        CCTexture2D* texture = cur.texture;
        
        CCSprite* shadow = [CCSprite spriteWithTexture:texture];
        [shadow setColor:ccc3(0, 0, 0)];
        [shadow setScaleY:shadowHeightFactor];
        [shadow setScaleX:shadowWidthFactor];
        
        shadow.tag = [GameplayScene TagGenerater];
        
        [objShadowTable
         setObject:[NSNumber numberWithInteger:shadow.tag]
         forKey:[NSNumber numberWithInteger:cur.tag]];
        
        [self addChild:shadow];
        
        [self updateShadowPos:cur.tag withRelativePos:[objectsLayer getSpriteRelativePos:cur]];
    }
}

-(void) updateShadowPos:(NSInteger)objectSpriteTag withRelativePos:(CGPoint)relativePos {

    NSNumber* tag = (NSNumber*)[objShadowTable objectForKey:[NSNumber numberWithInteger:objectSpriteTag]];
    NSInteger tagInteger = [tag unsignedIntegerValue];
    
    CCSprite* child = (CCSprite*)[self getChildByTag:tagInteger];
    if (child != nil) {
        child.position = [self calculateShadowPos: relativePos];
    }
}

@end
