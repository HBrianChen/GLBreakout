//
//  BCGame.m
//  GLBreakout
//
//  Created by BrianChen on 2018/7/25.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCGame.h"
#import "BCResourceManager.h"
#import <GLKit/GLKit.h>
#import "BCShader.h"
#import "BCSpriteRenderer.h"
#import "BCGameLevel.h"
#import "BCGameObject.h"
#import "BCBallObject.h"
#import "BCParticleGenerator.h"
#import "BCPostProcessor.h"
#import "BCPowerUp.h"
#import "BCGameAudioPlayer.h"
#import "BCTextRenderer.h"

@interface BCGame () {
    BCSpriteRenderer *_renderer;
    BCResourceManager *_manager;
    NSString *_resourcesPath;
    NSUInteger _width;
    NSUInteger _height;
    NSArray<BCGameLevel *> *_levels;
    NSArray<NSString *> *_levelPaths;
    BCGameObject *_paddle;
    GLKVector2 _paddleSize;
    float _paddleVelocity;
    BCBallObject *_ball;
    GLKVector2 _ballVelocity;
    float _ballRadius;
    BCParticleGenerator *_particleGenerator;
    BCPostProcessor *_effects;
    float _shakeTime;
    double _startTime;
    NSMutableArray<BCPowerUp *> *_powerUps;
    BCGameAudioPlayer *_audioPlayer;
    NSMutableDictionary<NSString *, NSString *> *_audioFiles;
    
    BCTextRenderer *_textRenderer;
    NSUInteger _lives;
}

@end

@implementation BCGame

- (instancetype)initWithWidth:(NSUInteger)width height:(NSUInteger)height {
    if (self = [super init]) {
        _resourcesPath = [[NSBundle mainBundle] resourcePath];
        _resourcesPath = [_resourcesPath stringByAppendingPathComponent:@"Resources"];
        _manager = [BCResourceManager sharedResourceManager];
        _width = width;
        _height = height;
        _paddleSize = GLKVector2Make(100, 20);
        _paddleVelocity = 500;
        _ballVelocity = GLKVector2Make(100.0f, -350.0f);
        _ballRadius = 12.5f;
        _shakeTime = 0.0f;
        _startTime = CFAbsoluteTimeGetCurrent();
        _powerUps = [NSMutableArray array];
        _audioPlayer = [BCGameAudioPlayer sharedAudioPlayer];
        _audioFiles = [NSMutableDictionary dictionary];
        _lives = 3;
        _state = BCGame_MENU;
    }
    return self;
}

- (void)setupGame {
    [self loadShaders];
    [self loadTextures];
    [self loadLevels];
    [self createObjects];
    
    NSString *breakoutFile = [_resourcesPath stringByAppendingPathComponent:@"breakout.mp3"];
    NSString *bleepFile1 = [_resourcesPath stringByAppendingPathComponent:@"bleep.mp3"];
    NSString *bleepFile2 = [_resourcesPath stringByAppendingPathComponent:@"bleep.wav"];
    NSString *powerUpFile = [_resourcesPath stringByAppendingPathComponent:@"powerup.wav"];
    NSString *solidFile = [_resourcesPath stringByAppendingPathComponent:@"solid.wav"];
    _audioFiles[@"breakout"] = breakoutFile;
    _audioFiles[@"bleep1"] = bleepFile1;
    _audioFiles[@"bleep2"] = bleepFile2;
    _audioFiles[@"powerup"] = powerUpFile;
    _audioFiles[@"solid"] = solidFile;
    
    [_audioPlayer playAudio:_audioFiles[@"breakout"] isLoop:YES];
}

- (void)processInput:(CGFloat)dt {
    if (_state == BCGame_MENU) {
        if ([self processKeyOnce:BCKeyEnter]) {
            NSLog(@"player enter game. level: %lu", (unsigned long)_level);
            _state = BCGame_ACTIVE;
        }
        if ([self processKeyOnce:BCKeyW]) {
            _level = (_level + 1) % 4;
        }
        if ([self processKeyOnce:BCKeyS]) {
            if (_level > 0) {
                _level--;
            } else {
                _level = 3;
            }
        }
    }
    if (_state == BCGame_WIN) {
        if (_keys[BCKeyEnter]) {
            _keysProcessed[BCKeyEnter] = YES;
            _effects.enableChaos = NO;
            _state = BCGame_MENU;
        }
    }
    if (_state == BCGame_ACTIVE) {
        GLfloat velocity = _paddleVelocity * dt;
        if (_keys[BCKeyA]) {
            if (_paddle.position.x >= 0) {
                _paddle.position = GLKVector2Make(_paddle.position.x - velocity, _paddle.position.y);
                if (_ball.isStuck)
                    _ball.position = GLKVector2Make(_ball.position.x - velocity, _ball.position.y);
            }
        }
        if (_keys[BCKeyD]) {
            if (_paddle.position.x + _paddle.size.x <= _width) {
                _paddle.position = GLKVector2Make(_paddle.position.x + velocity, _paddle.position.y);
                if (_ball.isStuck) {
                    _ball.position = GLKVector2Make(_ball.position.x + velocity, _ball.position.y);
                }
            }
        }
        if (_keys[BCKeySpace]) {
            _ball.isStuck = NO;
        }
    }
}

- (BOOL)processKeyOnce:(BCKey)key {
    if (_keys[key] && !_keysProcessed[key]) {
        _keysProcessed[key] = YES;
        return YES;
    }
    return NO;
}

- (void)update:(CGFloat)dt {
    [_ball moveWithDT:dt windowWidth:_width];
    [self doCollisions];
    [_particleGenerator updateWithDT:dt object:_ball newParticles:2 offset:GLKVector2Make(_ball.radius / 2, _ball.radius / 2)];
    if (_ball.position.y >= _height) {
        NSLog(@"player lost one live.");
        _lives--;
        if (_lives == 0) {
            [self resetLevel];
        }
        [self resetPaddleAndBall];
    }
    if (_shakeTime > 0.0f) {
        _shakeTime -= dt;
        if (_shakeTime <= 0.0f) {
            _effects.enableShake = NO;
        }
    }
    [self updatePowerUpsWithTime:dt];
    
    if (_state == BCGame_ACTIVE && [_levels[_level] isCompleted]) {
        NSLog(@"player win the game.");
        [self resetLevel];
        [self resetPaddleAndBall];
        _effects.enableChaos = YES;
        _state = BCGame_WIN;
    }
}

- (void)render {
    [_effects beginRender];
    
    [_renderer drawSpriteWithTexture:_manager.textures[@"background"] position:GLKVector2Make(0, 0) size:GLKVector2Make(_width, _height) rotate:0 color:GLKVector3Make(1.0f, 1.0f, 1.0f)];
    [_levels[_level]  draw:_renderer];
    [_paddle draw:_renderer];
    for (BCPowerUp *powerUp in _powerUps) {
        if (!powerUp.destroyed) {
            [powerUp draw:_renderer];
        }
    }
    [_particleGenerator draw];
    [_ball draw:_renderer];
    
    [_effects endRender];
    
    double time = CFAbsoluteTimeGetCurrent() - _startTime;
    [_effects render:time];
    
    NSString *liveStr = [NSString stringWithFormat:@"Lives:%lu", _lives];
    [_textRenderer renderText:liveStr x:5.0f y:5.0f scale:1.0f];
    
    if (_state == BCGame_MENU) {
        [_textRenderer renderText:@"Press ENTER to start" x:250.0f y:_height / 2 scale:1.0f];
        [_textRenderer renderText:@"Press W or S to select level" x:245.0f y:_height / 2 + 20.0f scale:0.75f];
    }
    if (_state == BCGame_WIN) {
        [_textRenderer renderText:@"You WON!!!" x:320.0f y:_height / 2 - 20.0f scale:1.0f color:GLKVector3Make(0.0f, 1.0f, 0.0f)];
        [_textRenderer renderText:@"Press ENTER to retry or ESC to quit" x:130.0f y:_height / 2 scale:1.0f color:GLKVector3Make(1.0f, 1.0f, 0.0f)];
    }
}


/**
 release all GL resources
 Note: must be invoked at GL context
 */
- (void)destroyGame {
    [_renderer destroyRenderer];
    [_manager destroyResourceManager];
    [_particleGenerator destroyParticleGenerator];
    [_effects destroyPostProcessor];
    [_textRenderer destroyTextRenderer];
}

#pragma mark -
#pragma mark Collision

- (void)doCollisions {
    for (BCGameObject *box in _levels[_level].bricks) {
        if (!box.destroyed) {
            BCCollision collsion = [self checkCollisionBall:_ball withBox:box];
            if (collsion.isCollision){
                if (!box.isSolid) {
                    box.destroyed = GL_TRUE;
                    [self spawnPowerUpsWithBlock:box];
                    [_audioPlayer playAudio:_audioFiles[@"bleep1"] isLoop:NO];
                } else {
                    _shakeTime = 0.05f;
                    _effects.enableShake = YES;
                    [_audioPlayer playAudio:_audioFiles[@"solid"] isLoop:NO];
                }
                if (!(_ball.passThrough && !box.isSolid)) {
                    if (collsion.dir == BCDirectionLeft || collsion.dir == BCDirectionRight) {
                        _ball.velocity = GLKVector2Make(-_ball.velocity.x, _ball.velocity.y);
                        float penetration = _ball.radius - fabsf(collsion.diffVector.x);
                        if (collsion.dir == BCDirectionLeft) {
                            _ball.position = GLKVector2Make(_ball.position.x + penetration, _ball.position.y);
                        } else {
                            _ball.position = GLKVector2Make(_ball.position.x - penetration, _ball.position.y);
                        }
                    } else {
                        _ball.velocity = GLKVector2Make(_ball.velocity.x, -_ball.velocity.y);
                        float penetration = _ball.radius - fabsf(collsion.diffVector.y);
                        if (collsion.dir == BCDirectionUp) {
                            _ball.position = GLKVector2Make(_ball.position.x, _ball.position.y - penetration);
                        } else {
                            _ball.position = GLKVector2Make(_ball.position.x, _ball.position.y + penetration);
                        }
                    }
                }
            }
        }
    }
    
    BCCollision collsionPaddle = [self checkCollisionBall:_ball withBox:_paddle];
    if (!_ball.isStuck && collsionPaddle.isCollision) {
        float centerPaddle = _paddle.position.x + _paddle.size.x / 2;
        float distance = _ball.position.x + _ball.radius - centerPaddle;
        float percentage = distance / (_paddle.size.x / 2);  // -1.0 ~ 1.0
        float strength = 2.0f;
        GLKVector2 oldVelocity = _ball.velocity;
        _ball.velocity = GLKVector2Make(_ballVelocity.x * percentage * strength, _ball.velocity.y);
        _ball.velocity = GLKVector2MultiplyScalar(GLKVector2Normalize(_ball.velocity), GLKVector2Length(oldVelocity));
        _ball.velocity = GLKVector2Make(_ball.velocity.x, -fabsf(_ball.velocity.y));
        _ball.isStuck = _ball.sticky;
        [_audioPlayer playAudio:_audioFiles[@"bleep2"] isLoop:NO];
    }
    
    for (BCPowerUp *powerUp in _powerUps) {
        if (!powerUp.destroyed) {
            if (powerUp.position.y >= _height) {
                powerUp.destroyed = YES;
            }
            if ([self checkCollisionObject1:_paddle WithObject2:powerUp]) {
                [self activatePowerUp:powerUp];
                powerUp.destroyed = YES;
                powerUp.isActivated = YES;
                [_audioPlayer playAudio:_audioFiles[@"powerup"] isLoop:NO];
            }
        }
    }
}

- (BCDirection)directionOfVector:(GLKVector2)vector {
    GLKVector2 compass[] = {
        GLKVector2Make(0.0, 1.0),  // Up
        GLKVector2Make(0.0, -1.0), // Down
        GLKVector2Make(-1.0, 0.0), // Left
        GLKVector2Make(1.0, 0.0),  // Right
    };
    float max = 0.0f;
    int best_match = -1;
    for (int i = 0; i < 4; i++) {
        float dot_product = GLKVector2DotProduct(GLKVector2Normalize(vector), compass[i]);
        if (dot_product > max) {
            max = dot_product;
            best_match = i;
        }
    }
    return (BCDirection)best_match;
}

- (BCCollision)checkCollisionBall:(BCBallObject *)ball withBox:(BCGameObject *)box {
    GLKVector2 ballCenter = GLKVector2AddScalar(ball.position, ball.radius);
    GLKVector2 boxHalfExtents = GLKVector2DivideScalar(box.size, 2);
    GLKVector2 boxCenter = GLKVector2Add(box.position, boxHalfExtents);
    GLKVector2 difference = GLKVector2Subtract(ballCenter, boxCenter);
    GLKVector2 clamped = GLKVector2Maximum(GLKVector2Minimum(difference, boxHalfExtents), GLKVector2Negate(boxHalfExtents));
    GLKVector2 closest = GLKVector2Add(boxCenter, clamped);
    GLKVector2 diff = GLKVector2Subtract(closest, ballCenter);
    BCCollision collision;
    if (GLKVector2Length(diff) < ball.radius) {
        collision.isCollision = YES;
        collision.dir = [self directionOfVector:diff];
        collision.diffVector = diff;
    } else {
        collision.isCollision = NO;
    }
    return collision;
}

- (BOOL)checkCollisionObject1:(BCGameObject *)object1 WithObject2:(BCGameObject *)object2 {
    BOOL collisionX = (object1.position.x + object1.size.x >= object2.position.x) && (object2.position.x + object2.size.x >= object1.position.x);
    BOOL collisionY = (object1.position.y + object1.size.y >= object2.position.y) && (object2.position.y + object2.size.y >= object1.position.y);
    return collisionX && collisionY;
}

#pragma mark -
#pragma mark reset

- (void)resetLevel {
    [_levels[_level] loadFromFile:_levelPaths[_level] levelWidth:_width levelHeight:_height * 0.5];
    _lives = 3;
}

- (void)resetPaddleAndBall {
    _paddle.size = _paddleSize;
    _paddle.position = GLKVector2Make(_width / 2 - _paddleSize.x / 2, _height - _paddleSize.y);
    GLKVector2 ballPos = GLKVector2Add(_paddle.position, GLKVector2Make(_paddleSize.x / 2 - _ballRadius, -_ballRadius * 2));
    [_ball resetWithPosition:ballPos velocity:_ballVelocity];
}

#pragma mark -
#pragma mark load resources

- (void)loadShaders {
    NSString *spriteVSFile = [_resourcesPath stringByAppendingPathComponent:@"SpriteVS.glsl"];
    NSString *spriteFSFile = [_resourcesPath stringByAppendingPathComponent:@"SpriteFS.glsl"];
    BCShader *spriteShader = [_manager loadShaderWithVShaderFile:spriteVSFile fShaderFile:spriteFSFile shaderName:@"sprite"];
    
    NSString *particleVSFile = [_resourcesPath stringByAppendingPathComponent:@"ParticleVS.glsl"];
    NSString *particleFSFile = [_resourcesPath stringByAppendingPathComponent:@"ParticleFS.glsl"];
    BCShader *particleShader = [_manager loadShaderWithVShaderFile:particleVSFile fShaderFile:particleFSFile shaderName:@"particle"];
    
    NSString *effectVSFile = [_resourcesPath stringByAppendingPathComponent:@"PostProcessVS.glsl"];
    NSString *effectFSFile = [_resourcesPath stringByAppendingPathComponent:@"PostProcessFS.glsl"];
    [_manager loadShaderWithVShaderFile:effectVSFile fShaderFile:effectFSFile shaderName:@"effects"];
    
    NSString *textVSFile = [_resourcesPath stringByAppendingPathComponent:@"TextVS.glsl"];
    NSString *textFSFile = [_resourcesPath stringByAppendingPathComponent:@"TextFS.glsl"];
    BCShader *textShader = [_manager loadShaderWithVShaderFile:textVSFile fShaderFile:textFSFile shaderName:@"text"];
    
    GLKMatrix4 projection = GLKMatrix4MakeOrtho(0.0f, _width, _height, 0.0f, -1.0f, 1.0f);
    [spriteShader use];
    [spriteShader setInteger:@"image" value:0];
    [spriteShader setMatrix4:@"projection" matrix4:projection];
    _renderer = [[BCSpriteRenderer alloc] initWithShader:spriteShader];
    
    [particleShader use];
    [particleShader setInteger:@"image" value:0];
    [particleShader setMatrix4:@"projection" matrix4:projection];
    
    [textShader use];
    [textShader setInteger:@"text" value:0];
    [textShader setMatrix4:@"projection" matrix4:projection];
   
}

- (void)loadTextures {
    NSString *textureFile = [_resourcesPath stringByAppendingPathComponent:@"awesomeface.png"];
    [_manager loadTextureWithFile:textureFile useAlpha:YES textureName:@"face"];
    
    NSString *backgroundFile = [_resourcesPath stringByAppendingPathComponent:@"background.jpg"];
    [_manager loadTextureWithFile:backgroundFile useAlpha:NO textureName:@"background"];
    
    NSString *blockFile = [_resourcesPath stringByAppendingPathComponent:@"block.png"];
    [_manager loadTextureWithFile:blockFile useAlpha:NO textureName:@"block"];
    
    NSString *blockSolidFile = [_resourcesPath stringByAppendingPathComponent:@"block_solid.png"];
    [_manager loadTextureWithFile:blockSolidFile useAlpha:NO textureName:@"block_solid"];
    
    NSString *paddleFile = [_resourcesPath stringByAppendingPathComponent:@"paddle.png"];
    [_manager loadTextureWithFile:paddleFile useAlpha:YES textureName:@"paddle"];
    
    NSString *particleFile = [_resourcesPath stringByAppendingPathComponent:@"particle.png"];
    [_manager loadTextureWithFile:particleFile useAlpha:YES textureName:@"particle"];
    
    NSString *chaosFile = [_resourcesPath stringByAppendingPathComponent:@"powerup_chaos.png"];
    [_manager loadTextureWithFile:chaosFile useAlpha:YES textureName:@"tex_chaos"];
    
    NSString *confuseFile = [_resourcesPath stringByAppendingPathComponent:@"powerup_confuse.png"];
    [_manager loadTextureWithFile:confuseFile useAlpha:YES textureName:@"tex_confuse"];
    
    NSString *increaseFile = [_resourcesPath stringByAppendingPathComponent:@"powerup_increase.png"];
    [_manager loadTextureWithFile:increaseFile useAlpha:YES textureName:@"tex_size"];
    
    NSString *passThroughFile = [_resourcesPath stringByAppendingPathComponent:@"powerup_passthrough.png"];
    [_manager loadTextureWithFile:passThroughFile useAlpha:YES textureName:@"tex_pass"];
    
    NSString *speedFile = [_resourcesPath stringByAppendingPathComponent:@"powerup_speed.png"];
    [_manager loadTextureWithFile:speedFile useAlpha:YES textureName:@"tex_speed"];
    
    NSString *stickyFile = [_resourcesPath stringByAppendingPathComponent:@"powerup_sticky.png"];
    [_manager loadTextureWithFile:stickyFile useAlpha:YES textureName:@"tex_sticky"];
}

- (void)loadLevels {
    BCGameLevel *one = [[BCGameLevel alloc] init];
    BCGameLevel *two = [[BCGameLevel alloc] init];
    BCGameLevel *three = [[BCGameLevel alloc] init];
    BCGameLevel *four = [[BCGameLevel alloc] init];
    _levels = @[one, two, three, four];
    
    NSString *oneLevelFile = [_resourcesPath stringByAppendingPathComponent:@"one.lvl"];
    NSString *twoLevelFile = [_resourcesPath stringByAppendingPathComponent:@"two.lvl"];
    NSString *threeLevelFile = [_resourcesPath stringByAppendingPathComponent:@"three.lvl"];
    NSString *fourLevelFile = [_resourcesPath stringByAppendingPathComponent:@"four.lvl"];
    _levelPaths = @[oneLevelFile, twoLevelFile, threeLevelFile, fourLevelFile];
    
    _level = 0;
    for (NSUInteger i = 0; i<4; i++) {
        [_levels[i] loadFromFile:_levelPaths[i] levelWidth:_width levelHeight:_height * 0.5];
    }
}

- (void)createObjects {
    GLKVector2 paddlePos = GLKVector2Make(_width / 2 - _paddleSize.x / 2, _height - _paddleSize.y);
    _paddle = [[BCGameObject alloc] initWithPosition:paddlePos size:_paddleSize texture:_manager.textures[@"paddle"]];
    
    GLKVector2 ballPos = GLKVector2Make(paddlePos.x + _paddleSize.x / 2 - _ballRadius, paddlePos.y - _ballRadius * 2);
    _ball = [[BCBallObject alloc] initWithPosition:ballPos texture:_manager.textures[@"face"] radius:_ballRadius velocity:_ballVelocity];
    
    _particleGenerator = [[BCParticleGenerator alloc] initWithShader:_manager.shaders[@"particle"] texture:_manager.textures[@"particle"] amount:500];
    
    _effects = [[BCPostProcessor alloc] initWithShader:_manager.shaders[@"effects"] size:CGSizeMake(_width, _height)];
    //_effects.enableChaos = YES;
    //_effects.enableConfuse = YES;
    
    _textRenderer = [[BCTextRenderer alloc] initWithShader:_manager.shaders[@"text"]];
    NSString *fontFile = [_resourcesPath stringByAppendingPathComponent:@"OCRAEXT.TTF"];
    [_textRenderer loadFont:fontFile fontSize:24];
}

#pragma mark -
#pragma mark Power Up

- (BOOL)shouldSpawnWithChance:(NSUInteger)chance {
    NSUInteger random = rand() % chance;
    return random == 0;
}

- (void)spawnPowerUpsWithBlock:(BCGameObject *)block {
    if ([self shouldSpawnWithChance:10]) {
        BCPowerUp *powerUp = [[BCPowerUp alloc] initWithType:BCPowerUpSpeed color:GLKVector3Make(0.5f, 0.5f, 1.0f) duration:0.0f position:block.position texture:_manager.textures[@"tex_speed"]];
        [_powerUps addObject:powerUp];
    }
    if ([self shouldSpawnWithChance:10]) {
        BCPowerUp *powerUp = [[BCPowerUp alloc] initWithType:BCPowerUpSticky color:GLKVector3Make(1.0f, 0.5f, 1.0f) duration:20.0f position:block.position texture:_manager.textures[@"tex_sticky"]];
        [_powerUps addObject:powerUp];
    }
    if ([self shouldSpawnWithChance:10]) {
        BCPowerUp *powerUp = [[BCPowerUp alloc] initWithType:BCPowerUpPassThrough color:GLKVector3Make(0.5f, 1.0f, 0.5f) duration:10.0f position:block.position texture:_manager.textures[@"tex_pass"]];
        [_powerUps addObject:powerUp];
    }
    if ([self shouldSpawnWithChance:10]) {
        BCPowerUp *powerUp = [[BCPowerUp alloc] initWithType:BCPowerUpPadSizeInc color:GLKVector3Make(1.0f, 0.6f, 0.4f) duration:0.0f position:block.position texture:_manager.textures[@"tex_size"]];
        [_powerUps addObject:powerUp];
    }
    if ([self shouldSpawnWithChance:15]) {
        BCPowerUp *powerUp = [[BCPowerUp alloc] initWithType:BCPowerUpConfuse color:GLKVector3Make(1.0f, 0.3f, 0.3f) duration:15.0f position:block.position texture:_manager.textures[@"tex_confuse"]];
        [_powerUps addObject:powerUp];
    }
    if ([self shouldSpawnWithChance:15]) {
        BCPowerUp *powerUp = [[BCPowerUp alloc] initWithType:BCPowerUpChaos color:GLKVector3Make(0.9f, 0.25f, 0.25f) duration:15.0f position:block.position texture:_manager.textures[@"tex_chaos"]];
        [_powerUps addObject:powerUp];
    }
}

- (void)activatePowerUp:(BCPowerUp *)powerUp {
    switch (powerUp.type) {
        case BCPowerUpSpeed:
            _ball.velocity = GLKVector2MultiplyScalar(_ball.velocity, 1.2);
            break;
        case BCPowerUpSticky:
            _ball.sticky = YES;
            _paddle.color = GLKVector3Make(1.0f, 0.5f, 1.0f);
            break;
        case BCPowerUpPassThrough:
            _ball.passThrough = YES;
            _ball.color = GLKVector3Make(1.0f, 0.5f, 0.5f);
            break;
        case BCPowerUpPadSizeInc:
            _paddle.size = GLKVector2Make(_paddle.size.x + 50, _paddle.size.y);
            break;
        case BCPowerUpConfuse:
            _effects.enableConfuse = YES;
            break;
        case BCPowerUpChaos:
            _effects.enableChaos = YES;
            break;
        default:
            break;
    }
}

- (BOOL)isOtherPowerUpActiveWithType:(BCPowerUpType)type {
    for (BCPowerUp *powerUp in _powerUps) {
        if (powerUp.isActivated && powerUp.type == type) {
            return YES;
        }
    }
    return NO;
}

- (void)updatePowerUpsWithTime:(CGFloat)dt {
    NSMutableArray<BCPowerUp *> *newPowerUps = [NSMutableArray array];
    for (BCPowerUp *powerUp in _powerUps) {
        powerUp.position = GLKVector2Add(powerUp.position, GLKVector2MultiplyScalar(powerUp.velocity, dt));
        if (powerUp.isActivated) {
            powerUp.duration -= dt;
            
            if (powerUp.duration <= 0.0f) {
                powerUp.isActivated = NO;
                BOOL isOtherPowerUpActive = [self isOtherPowerUpActiveWithType:powerUp.type];
                if (isOtherPowerUpActive) {
                    if (!powerUp.destroyed) {
                        [newPowerUps addObject:powerUp];
                    }
                    continue;
                }
                switch (powerUp.type) {
                    case BCPowerUpSticky:
                        _ball.sticky = NO;
                        _paddle.color = GLKVector3Make(1.0f, 1.0f, 1.0f);
                        break;
                    case BCPowerUpPassThrough:
                        _ball.passThrough = NO;
                        _ball.color = GLKVector3Make(1.0f, 1.0f, 1.0f);
                        break;
                    case BCPowerUpConfuse:
                        _effects.enableConfuse = NO;
                        break;
                    case BCPowerUpChaos:
                        _effects.enableChaos = NO;
                        break;
                    default:
                        break;
                }
            }
        }
        if (powerUp.isActivated || !powerUp.destroyed) {
            [newPowerUps addObject:powerUp];
        }
    }
    _powerUps = newPowerUps;
}

@end
