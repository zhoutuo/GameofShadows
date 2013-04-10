//
//  ShadowDisruptionLayer.h
//  Game of Shadows
//
//  Created by Ludovic Lang on 3/8/13.
//
//

#import <Foundation/Foundation.h>
#import "LightSource.h"

@interface ShadowDisruptionLayer : CCLayer {
    NSMutableDictionary* objLightTable;
}
-(bool) checkIfInLight: (int)xcoor :(int) ycoor;
-(void) castLightFrom:(CCArray*)objects withRatios:(CCArray *)ratios;
-(void) updateLightPos:(NSInteger)objectSpriteTag withRelativePos:(CGPoint) relativePos;
@end