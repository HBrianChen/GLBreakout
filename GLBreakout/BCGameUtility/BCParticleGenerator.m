//
//  BCParticleGenerator.m
//  GLBreakout
//
//  Created by BrianChen on 2018/8/4.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCParticleGenerator.h"
#import "BCShader.h"
#import "BCTexture2D.h"
#import "BCGameObject.h"

@interface BCParticleGenerator () {
    NSMutableArray<BCParticle *> *_particles;
    NSUInteger _amount;
    BCShader *_shader;
    BCTexture2D *_texture;
    GLuint _VAO;
    GLuint _VBO;
    NSUInteger _lastUsedParticle;
}

@end

@implementation BCParticleGenerator

- (instancetype)initWithShader:(BCShader *)shader texture:(BCTexture2D *)texture amount:(NSUInteger)amount {
    if (self = [super init]) {
        _shader = shader;
        _texture = texture;
        _amount = amount;
        _particles = [NSMutableArray arrayWithCapacity:_amount];
        _lastUsedParticle = 0;
        [self setup];
    }
    return self;
}

- (void)setup {
    GLfloat particle_quad[] = {
        0.0f, 1.0f, 0.0f, 1.0f,
        1.0f, 0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 0.0f,
        
        0.0f, 1.0f, 0.0f, 1.0f,
        1.0f, 1.0f, 1.0f, 1.0f,
        1.0f, 0.0f, 1.0f, 0.0f
    };
    glGenVertexArrays(1, &_VAO);
    glGenBuffers(1, &_VBO);
    glBindVertexArray(_VAO);
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(particle_quad), particle_quad, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), (GLvoid *)0);
    glBindVertexArray(0);
    
    @autoreleasepool {
        for (NSUInteger i = 0; i < _amount; i++) {
            BCParticle *particle = [[BCParticle alloc] init];
            [_particles addObject:particle];
        }
    }
}

- (void)updateWithDT:(float)dt object:(BCGameObject *)object newParticles:(NSUInteger)newParticles offset:(GLKVector2)offset {
    // Add new particles
    for (NSUInteger i = 0; i < newParticles; i++) {
        NSUInteger unusedParticle = [self firstUnusedParticleIndex];
        [self respawnParticle:_particles[unusedParticle] object:object offset:offset];
    }
    // Update all particles
    for (BCParticle *particle in _particles) {
        particle.life -= dt;
        if (particle.life > 0.0f) {
            particle.position = GLKVector2Subtract(particle.position, GLKVector2MultiplyScalar(particle.velocity, dt));
            particle.color = GLKVector4Make(particle.color.r, particle.color.g, particle.color.b, particle.color.a - dt * 2.5);
        }
    }
}

- (void)draw {
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    [_shader use];
    for (BCParticle *particle in _particles) {
        if (particle.life > 0.0) {
            [_shader setVector2f:@"offset" vec2f:particle.position];
            [_shader setVector4f:@"color" vec4f:particle.color];
            [_texture bind];
            glBindVertexArray(_VAO);
            glDrawArrays(GL_TRIANGLES, 0, 6);
            glBindVertexArray(0);
        }
    }
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (NSUInteger)firstUnusedParticleIndex {
    for (NSUInteger i = _lastUsedParticle; i < _amount; i++) {
        if (_particles[i].life <= 0.0f) {
            _lastUsedParticle = i;
            return i;
        }
    }
    
    for (NSUInteger i = 0; i < _lastUsedParticle; i++) {
        if (_particles[i].life <= 0.0f) {
            _lastUsedParticle = i;
            return i;
        }
    }
    
    _lastUsedParticle = 0;
    return 0;
}

- (void)respawnParticle:(BCParticle *)particle object:(BCGameObject *)object offset:(GLKVector2)offset {
    float random = (rand() % 100 - 50) / 10.0f;
    float rColor = 0.5 + (rand() % 100) / 100.0f;
    particle.position = GLKVector2Add(GLKVector2AddScalar(object.position, random), offset);
    particle.color = GLKVector4Make(rColor, rColor, rColor, 1.0f);
    particle.life = 1.0f;
    particle.velocity = GLKVector2MultiplyScalar(object.velocity, 0.1f);
}

- (void)destroyParticleGenerator {
    glDeleteBuffers(1, &_VBO);
    glDeleteVertexArrays(1, &_VAO);
}

@end
