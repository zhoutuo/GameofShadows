//
//  BackgroundLayer.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "BackgroundLayer.h"

@implementation BackgroundLayer
-(id) init {
    if (self = [super init]) {
        CGSize wins = [[CCDirector sharedDirector] winSize];
        CCSprite* background = [CCSprite spriteWithFile:@"Background.png"];
        background.position = ccp(wins.height / 2, wins.width / 2);
        [self addChild:background];
        
    }
    return self;
}
@end
