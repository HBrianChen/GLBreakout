//
//  BCTextRenderer.m
//  GLBreakout
//
//  Created by BrianChen on 2018/8/13.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCTextRenderer.h"
#import "BCShader.h"
#import "BCCharacter.h"
#import "BCResourceManager.h"
#include <ft2build.h>
#include FT_FREETYPE_H

@implementation BCTextRenderer {
    BCShader *_shader;
    GLuint _VAO;
    GLuint _VBO;
}

- (instancetype)initWithShader:(BCShader *)shader {
    if (self = [super init]) {
        _shader = shader;
        glGenVertexArrays(1, &_VAO);
        glGenBuffers(1, &_VBO);
        
        glBindVertexArray(_VAO);
        glBindBuffer(GL_ARRAY_BUFFER, _VBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 6 * 4, NULL, GL_DYNAMIC_DRAW);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), 0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArray(0);
        
        
        _characters = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)loadFont:(NSString *)fontFile fontSize:(NSUInteger)fontSize {
    [_characters removeAllObjects];
    FT_Library ft;
    if (FT_Init_FreeType(&ft)) {
        NSLog(@"Could not init free type library.");
        return;
    }
    FT_Face face;
    if (FT_New_Face(ft, fontFile.UTF8String, 0, &face)) {
        NSLog(@"Failed to load font.");
        return;
    }
    
    FT_Set_Pixel_Sizes(face, 0, (FT_UInt)fontSize);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    for (GLubyte c = 0; c < 128; c++) {
        if (FT_Load_Char(face, c, FT_LOAD_RENDER)) {
            NSLog(@"Failed to load %c Glyph.", c);
            continue;
        }
        
        GLuint texture;
        glGenTextures(1, &texture);
        glBindTexture(GL_TEXTURE_2D, texture);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, face->glyph->bitmap.width, face->glyph->bitmap.rows, 0, GL_RED, GL_UNSIGNED_BYTE, face->glyph->bitmap.buffer);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        BCCharacter *character = [[BCCharacter alloc] init];
        character.textureID = texture;
        character.size = CGSizeMake(face->glyph->bitmap.width, face->glyph->bitmap.rows);
        character.bearing = CGSizeMake(face->glyph->bitmap_left, face->glyph->bitmap_top);
        character.advance = (unsigned int)face->glyph->advance.x;
        
        NSString *key = [NSString stringWithFormat:@"%c", c];
        _characters[key] = character;
    }
    glBindTexture(GL_TEXTURE_2D, 0);
    FT_Done_Face(face);
    FT_Done_FreeType(ft);
}

- (void)renderText:(NSString *)text x:(float)x y:(float)y scale:(float)scale {
    [self renderText:text x:x y:y scale:scale color:GLKVector3Make(1.0f, 1.0f, 1.0f)];
}

- (void)renderText:(NSString *)text x:(float)x y:(float)y scale:(float)scale color:(GLKVector3)color {
    [_shader use];
    [_shader setVector3f:@"textColor" vec3f:color];
    glActiveTexture(GL_TEXTURE0);
    glBindVertexArray(_VAO);
    
    NSUInteger len = [text length];
    unichar buffer[len+1];
    
    [text getCharacters:buffer range:NSMakeRange(0, len)];
    
    for(int i = 0; i < len; i++) {
        NSString *key = [NSString stringWithFormat:@"%C", buffer[i]];
        BCCharacter *ch = _characters[key];
        GLfloat xpos = x + ch.bearing.width * scale;
        GLfloat ypos = y + (_characters[@"H"].bearing.height - ch.bearing.height) * scale;
        GLfloat w = ch.size.width * scale;
        GLfloat h = ch.size.height * scale;
        GLfloat vertices[6][4] = {
            {xpos, ypos + h, 0.0, 1.0},
            {xpos + w, ypos, 1.0, 0.0},
            {xpos, ypos, 0.0, 0.0},
            
            {xpos, ypos + h, 0.0, 1.0},
            {xpos + w, ypos + h, 1.0, 1.0},
            {xpos + w, ypos, 1.0, 0.0}
        };
        glBindTexture(GL_TEXTURE_2D, ch.textureID);
        glBindBuffer(GL_ARRAY_BUFFER, _VBO);
        glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertices), vertices);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        glDrawArrays(GL_TRIANGLES, 0, 6);

        x += (ch.advance >> 6) * scale;
    }
    glBindVertexArray(0);
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)destroyTextRenderer {
    glDeleteBuffers(1, &_VBO);
    glDeleteVertexArrays(1, &_VAO);
    [_characters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, BCCharacter * _Nonnull obj, BOOL * _Nonnull stop) {
        GLuint textureID = obj.textureID;
        glDeleteTextures(1, &textureID);
    }];
    [_characters removeAllObjects];
}

@end
