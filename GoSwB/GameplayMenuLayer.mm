//
//  GameplayMenuLayer.m
//  Game of Shadows
//
//  Created by Ryan Schubert on 4/14/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameplayMenuLayer.h"
#import "BackgroundLayer.h"
#import "PauseLayer.h"
#import "Globals.h"


@implementation GameplayMenuLayer


-(id) init {
    if (self = [super init]) {
        
         pauseMenuItem = [CCMenuItemImage
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
