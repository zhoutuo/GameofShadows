//
//  GameplayScene.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "GameplayScene.h"


@implementation GameplayScene

static NSInteger tagSeed = 10000;

-(id) init {
    if (self = [super init]) {
        
                
        backgroundLayer = [BackgroundLayer node];
        [self addChild:backgroundLayer z:0];
        
        shadowLayer = [ShadowsLayer node];
        [self addChild:shadowLayer z:1];
        
        gameplayLayer = [GameplayLayer node];
        [self addChild:gameplayLayer z:2];
        
        
    }
    return self;
    
}

-(void) onEnter {
    [super onEnter];
    //[shadowLayer castShadowFrom:gameplayLayer];
}

-(void) updateShadowPos:(CCSprite *)object {
    [shadowLayer updateShadowPos:object.tag withRelativePos:[gameplayLayer getSpriteRelativePos:object]];
}


+(NSInteger) TagGenerater {
    return tagSeed++;
}
@end
