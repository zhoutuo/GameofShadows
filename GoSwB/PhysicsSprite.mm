//
//  PhysicsSprite.mm
//  ShadowPhysics
//
//  Created by Adib Parkar on 2/14/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import "PhysicsSprite.h"

// Needed PTM_RATIO
#import "GameplayLayer.h"
#import "GameplayScene.h"

#pragma mark - PhysicsSprite
@implementation PhysicsSprite

-(void) setPhysicsBody:(b2Body *)body
{
	body_ = body;
}

-(b2Body*) getPhysicsBody {
    return body_;
}

// this method will only get called if the sprite is batched.
// return YES if the physics values (angles, position ) changed
// If you return NO, then nodeToParentTransform won't be called.
-(BOOL) dirty
{
	return YES;
}
//
//// returns the transform matrix according the Chipmunk Body values
//-(CGAffineTransform) nodeToParentTransform
//{	
//	b2Vec2 pos  = body_->GetPosition();
//	
//	float x = pos.x * PTM_RATIO;
//	float y = pos.y * PTM_RATIO;
//	
//	if ( ignoreAnchorPointForPosition_ ) {
//		x += anchorPointInPoints_.x;
//		y += anchorPointInPoints_.y;
//	}
//	
//	// Make matrix
//	float radians = body_->GetAngle();
//	float c = cosf(radians);
//	float s = sinf(radians);
//	
//	if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ){
//		x += c*-anchorPointInPoints_.x + -s*-anchorPointInPoints_.y;
//		y += s*-anchorPointInPoints_.x + c*-anchorPointInPoints_.y;
//	}
//	
//	// Rot, Translate Matrix
//	transform_ = CGAffineTransformMake( c,  s,
//									   -s,	c,
//									   x,	y );
//    
//
//	
//	return transform_;
//}


@end
