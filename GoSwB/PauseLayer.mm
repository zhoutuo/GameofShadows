//
//  PauseLayer.m
//  Game of Shadows
//
//  Created by Ryan Ball on 3/4/13.
//
//

#import "PauseLayer.h"
#import "Globals.h"
#import "CCBReader.h"

@implementation PauseLayer
- (id) initWithColor:(ccColor4B)color
{
    if ((self = [super initWithColor:color]))
    {
        
        self.isTouchEnabled=YES;
        
        //Add menu items
        CCMenuItem *menuItem1 = [CCMenuItemImage
                                 itemWithNormalImage:@"Resume_Text.png" selectedImage:@"Resume_Text.png" target:self selector:@selector(resume:)];
        CCMenuItem *menuItem2 = [CCMenuItemImage
                                 itemWithNormalImage:@"Home_Text.png" selectedImage:@"Home_Text.png" target:self selector:@selector(goHome:)];
        
        CCMenu *menu = [CCMenu menuWithItems:menuItem1, menuItem2, nil];
        [menu alignItemsVertically];
        [self addChild:menu];
        
    }
    return self;
}


- (void)resume:(id)sender
{
    NSLog(@"resume");
    [[CCDirector sharedDirector] stopAnimation]; // call this to make sure you don't start a second display link!
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] startAnimation];
    isGamePause = false;
    [self.parent removeChild:self cleanup:YES];
}

-(void)goHome:(id)sender
{
    NSLog(@"goHome");
    [[CCDirector sharedDirector] stopAnimation]; // call this to make sure you don't start a second display link!
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] startAnimation];
    isGamePause = false;
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[CCBReader sceneWithNodeGraphFromFile:@"MainMenuScene.ccbi"]]];
}

- (void) dealloc
{
    [super dealloc];
}



@end
