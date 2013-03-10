//
//  ShadowDisruptionLayer.m
//  Game of Shadows
//
//  Created by Ludovic Lang on 3/8/13.
//
//

#import "GameplayLayer.h"
#import "ShadowDisruptionLayer.h"

@implementation ShadowDisruptionLayer

-(id)init{
    if (self = [super init]) {
        [self initializeMap];
    }
    
    CCSprite* lightSourceSprite = [CCSprite spriteWithFile:@"lightSource.png"];
    [lightSourceSprite setAnchorPoint:ccp(0, 0)];
    [lightSourceSprite setPosition:ccp(500, 300)];
    [self addLightSource:lightSourceSprite];
    return self;
}

-(void) addLightSource:(CCSprite *)lightSource{
    CGPoint origin = [lightSource boundingBox].origin;
    CGSize size = [lightSource boundingBox].size;
    
    //adding light source to map using bounding box
    for(int i = 0 ; i < size.height; i++){
        for(int j = 0 ; j < size.width; j++){
            lightSourceMap[(int)origin.y + i][(int)origin.x + j] = true;
        }
    }
    
    //adding light source sprite to layer
    [self addChild:lightSource z:5];
}

-(bool) checkIfInLight:(int)ycoor :(int)xcoor{
    return lightSourceMap[ycoor][xcoor];
}

-(void) initializeMap{
    for(int i = 0 ; i < DEVICE_HEIGHT; i++){
        for(int j = 0; j < DEVICE_WIDTH; j++){
            lightSourceMap[i][j] = false;
        }
    }
}

@end
