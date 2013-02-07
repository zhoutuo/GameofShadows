//
//  GameplayLayer.h
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "cocos2d.h"

@interface GameplayLayer : CCLayer {
    CGRect touchRect;
    NSInteger touchedObjectTag;
    CCNode* objectsContainer;

}

-(CGPoint) getSpriteRelativePos: (CCSprite*) object;

@end
