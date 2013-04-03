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
}
-(bool) checkIfInLight: (int)xcoor :(int) ycoor;
@end