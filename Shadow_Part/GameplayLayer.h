//
//  GameplayLayer.h
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "cocos2d.h"

@interface GameplayLayer : CCLayer {
    NSInteger touchedObjectTag;
    CCSprite* objectsContainer;
    CCSprite* droid1;
    CCArray* touchArray;
    
    NSInteger _backgroundDepth;
    NSInteger _itemsDepth;
}

@property (readonly) NSInteger backgroundDepth;
@property (readonly) NSInteger itemsDepth;
@property (readonly) CCArray* objects;

-(CGPoint) getSpriteRelativePos: (CCSprite*) object;

@end
