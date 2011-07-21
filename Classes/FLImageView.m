//
//  FLImageView.m
//  FullyLoaded
//
//  Created by Anoop Ranganath on 1/1/11.
//  Copyright 2011 Anoop Ranganath. All rights reserved.
//
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "FLImageView.h"
#import "FullyLoaded.h"

@interface FLImageView()

@property (nonatomic, readwrite, retain) NSString *imageURLString;

- (void)populateImage:(UIImage *)anImage;
- (UIImage*)scaledImageJustifiedLeft:(UIImage*)image;

@end

@implementation FLImageView

@synthesize autoresizeEnabled = _autoresizeEnabled,
            imageURLString = _imageURLString;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizeEnabled = NO;
        self.contentMode = UIViewContentModeScaleAspectFit;
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(imageLoaded:)
                                                     name:FLImageLoadedNotification 
                                                   object:nil];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFit;
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(imageLoaded:)
                                                     name:FLImageLoadedNotification 
                                                   object:nil];
    }
    return self;
}

- (void)loadImageAtURLString:(NSString *)aString placeholderImage:(UIImage *)placeholderImage {
    
    self.imageURLString = aString;
    self.image = nil;
    
    UIImage *anImage = [[FullyLoaded sharedFullyLoaded] imageForURL:self.imageURLString];
    if (anImage != nil) {
        [self populateImage:anImage];
    } else {
        [self populateImage:placeholderImage];
    }
}

- (void)imageLoaded:(NSNotification *)aNote {
    UIImage *anImage = [[FullyLoaded sharedFullyLoaded] imageForURL:self.imageURLString];
    if (anImage) {
        [self populateImage:anImage];
    }
}

- (void)populateImage:(UIImage *)anImage {
    if (self.autoresizeEnabled) {
        CGRect newBounds = self.frame;
        newBounds.size.width = anImage.size.width / [UIScreen mainScreen].scale;
        newBounds.size.height = anImage.size.height / [UIScreen mainScreen].scale;
        self.frame = newBounds;
        self.image = anImage;
//        self.image = [self scaledImageJustifiedLeft:anImage];
    }
    else {
        self.image = anImage;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FLImageLoadedNotification
                                                  object:nil];
    self.imageURLString = nil;
    [super dealloc];
}



// create an image the size of the current bounds, with content left-justified
// in the future this could be refactored with a justification enum of (left|center|right)
// justifyImage:(UIImage*) x:(justification) y:(justification)
- (UIImage*)scaledImageJustifiedLeft:(UIImage*)image {
    
    CGSize is = image.size;         // image size
    CGSize bs = self.bounds.size;   // bounds size
    
    // don't bother with strange sizes
    if (is.width < 1 || is.height < 1 || bs.width < 1 || bs.height < 1) return nil;
    
    // aspect ratios
    CGFloat i_ar = is.width / is.height;
    CGFloat b_ar = bs.width / bs.height;

    CGFloat scale;
    if (i_ar < b_ar) { // image is thinner than bounds; fit height
        scale = bs.height / is.height;
    }
    else { // image is fatter than bounds; fit width
        scale = bs.width / is.width;
    }
    
    CGRect r; // draw rect, relative to bounds size; draw the entire image into this rect
    r.size = CGSizeMake(is.width * scale, is.height * scale);
    
    // justification is hard-coded to x:left y:center; to generalize add justification cases for x and y 
    r.origin = CGPointMake(0, (bs.height - r.size.height) * 0.5);
    
    UIGraphicsBeginImageContextWithOptions(bs, NO, [UIScreen mainScreen].scale);
    [image drawInRect:r];
    UIImage *res = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    LOG_SIZE(is);
    LOG_SIZE(bs);
    LOG_SIZE(res.size);
    
    return res;
}



@end
