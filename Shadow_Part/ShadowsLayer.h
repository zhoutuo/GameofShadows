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
-(void) castShadowFrom:(CCArray*)objects withRatios:(CCArray*)ratios;
-(void) updateShadowPos:(NSInteger)objectSpriteTag withRelativePos:(CGPoint) relativePos;
-(void) updateShadowRot:(NSInteger) objectSpriteTag withAngle:(float) angle;


@end
