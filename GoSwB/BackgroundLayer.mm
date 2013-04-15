//
//  BackgroundLayer.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "BackgroundLayer.h"
#import "Globals.h"


@implementation BackgroundLayer

-(id) init {
    if (self = [super init]) {
      //  CGSize wins = [[CCDirector sharedDirector] winSize];
        background = [CCSprite spriteWithFile:@"Room layout texture.png"];
        background.anchorPoint= ccp(0,0);
        
        
     //   background.position = ccp(wins.width / 2, wins.height / 2);
        background.position = ccp(0,0);
        
        if(currentLevel == 5){
            background = [CCSprite spriteWithFile:@"hugeBackground.png"];
            background.anchorPoint= ccp(0,0);
            background.anchorPoint= ccp(0,0);
        }
        [self addChild:background];
        //UIView* glView = (UIView*) [[CCDirector sharedDirector] view];
        
    }
    return self;
}


-(void) shift:(CGPoint) centerPoint{
    // get the layer's CCCamera values
	float centerX, centerY, centerZ;
	[self.camera centerX:&centerX centerY:&centerY centerZ:&centerZ];
    
    float eyeX, eyeY, eyeZ;
	[self.camera eyeX:&eyeX eyeY:&eyeY eyeZ:&eyeZ];
    
    centerX = centerPoint.x;
    centerY = centerPoint.y;
    
    // update the camera values
    [self.camera setCenterX:centerX centerY:centerY centerZ:centerZ];
    [self.camera setEyeX:centerX eyeY:centerY eyeZ:eyeZ];
}



@end
