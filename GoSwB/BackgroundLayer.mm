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
                
        CCMenuItem *pauseMenuItem = [CCMenuItemImage
                                    itemWithNormalImage:@"Pause.png" selectedImage:@"Pause.png"
                                    target:self selector:@selector(pauseButtonMenu:)];
        pauseMenuItem.position = ccp(984, 730);
        CCMenu *pauseMenu = [CCMenu menuWithItems:pauseMenuItem, nil];
        pauseMenu.position = CGPointZero;
        [self addChild:pauseMenu];

        isGamePause = false;
    }
    return self;
}


-(void) pauseButtonMenu : (id) sender {
    if(isGamePause){
        NSLog(@"Button pushed in isGamePause == true");
    }
    else{
        NSLog(@"Button pushed in isGamePause == false");
        isGamePause = true;
        ccColor4B c = ccc4(130,130,130,100);
        PauseLayer * p = [[[PauseLayer alloc]initWithColor:c]autorelease];
        [self.parent addChild:p z:10];
        [[CCDirector sharedDirector] pause];
    }
}

@end
