//
//  ShadowsLayer.h
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "cocos2d.h"


@interface ShadowsLayer : CCLayer {
    float shadowHeightFactor;
    float shadowWidthFactor;
    NSMutableDictionary* objShadowTable;
    
}
-(void) castShadowFrom:(CCLayer*)objectsLayer;

-(void) updateShadowPos:(NSInteger)objectSpriteTag withRelativePos:(CGPoint) relativePos;

@end
