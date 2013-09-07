//
//  Game.h
//  Game
//
#import "ParallaxSprite.h"

@interface Game : SPSprite
{
    BOOL isJump;
    int frameCount;
    int score;
}

@property (nonatomic, retain) ParallaxSprite* layer_1;
@property (nonatomic, retain) ParallaxSprite* layer_2;
@property (nonatomic, retain) ParallaxSprite* layer_3;
@property (nonatomic, retain) ParallaxSprite* layer_4;
@property (nonatomic, retain) SPMovieClip *player;
@property (nonatomic, retain) SPTextField* scoreText;

@property (nonatomic, retain) NSMutableArray *stars;

@end
