//
//  BackgroundLayer.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "BackgroundLayer.h"
#import "PauseLayer.h"
#import "Globals.h"


@implementation BackgroundLayer

-(id) init {
    if (self = [super init]) {
        CGSize wins = [[CCDirector sharedDirector] winSize];
        CCSprite* background = [CCSprite spriteWithFile:@"Room layout texture.png"];
        
        
        
        
        
        background.position = ccp(wins.width / 2, wins.height / 2);
        [self addChild:background];
        
        //UIView* glView = (UIView*) [[CCDirector sharedDirector] view];
        
        CCMenuItem *pauseMenuItem = [CCMenuItemImage
                                    itemWithNormalImage:@"pause.png" selectedImage:@"pause.png"
                                    target:self selector:@selector(pauseButtonMenu:)];
        pauseMenuItem.position = ccp(984, 730);
        CCMenu *pauseMenu = [CCMenu menuWithItems:pauseMenuItem, nil];
        pauseMenu.position = CGPointZero;
        [self addChild:pauseMenu];

        isGamePause = false;
    }
    return self;
}



@end
