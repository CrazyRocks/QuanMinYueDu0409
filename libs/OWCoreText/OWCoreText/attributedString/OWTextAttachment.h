//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum
{
    OWTextAttachmentTypeImage,
    OWTextAttachmentTypeVideoURL,
	OWTextAttachmentTypeAnnotation,//注释
	OWTextAttachmentTypeObject,
	OWTextAttachmentTypeGeneric,
    OWTextAttachmentTypeAudioURL
    
}  OWTextAttachmentType;

typedef enum
{
	OWTextAttachmentVerticalAlignmentBaseline = 0,
	OWTextAttachmentVerticalAlignmentTop,
	OWTextAttachmentVerticalAlignmentCenter,
	OWTextAttachmentVerticalAlignmentBottom
} OWTextAttachmentVerticalAlignment;

@interface OWTextAttachment : NSObject

@property (nonatomic, assign) CGSize originalSize;
@property (nonatomic, assign) CGSize displaySize;
@property (nonatomic,assign) CGPoint positionCenter;
@property (nonatomic, strong) id contents;
@property (nonatomic, assign) OWTextAttachmentType contentType;

@property (nonatomic, strong) NSURL *contentURL;
@property (nonatomic, strong) NSURL *hyperLinkURL;
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic, assign) OWTextAttachmentVerticalAlignment verticalAlignment;
// customized ascend and descent for the run delegates
- (CGFloat)ascentForLayout;
- (CGFloat)descentForLayout;

@end
