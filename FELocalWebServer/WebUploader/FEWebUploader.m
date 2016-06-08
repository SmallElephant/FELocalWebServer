/*
 Copyright (c) 2012-2015, Pierre-Olivier Latour
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * The name of Pierre-Olivier Latour may not be used to endorse
 or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL PIERRE-OLIVIER LATOUR BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#if !__has_feature(objc_arc)
#error FEWebUploader requires ARC
#endif

#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <SystemConfiguration/SystemConfiguration.h>
#endif

#import "FEWebUploader.h"
#import "GCDWebServerDataRequest.h"
#import "GCDWebServerMultiPartFormRequest.h"
#import "GCDWebServerURLEncodedFormRequest.h"
#import "GCDWebServerDataResponse.h"
#import "GCDWebServerErrorResponse.h"
#import "GCDWebServerFileResponse.h"

@interface FEWebUploader () {
@private
    NSString* _uploadDirectory;
    NSArray* _allowedExtensions;
    BOOL _allowHidden;
}
@end

@implementation FEWebUploader (Methods)

// Must match implementation in GCDWebDAVServer
- (BOOL)_checkSandboxedPath:(NSString*)path {
    return [[path stringByStandardizingPath] hasPrefix:_uploadDirectory];
}

- (BOOL)_checkFileExtension:(NSString*)fileName {
    if (_allowedExtensions && ![_allowedExtensions containsObject:[[fileName pathExtension] lowercaseString]]) {
        return NO;
    }
    return YES;
}

- (NSString*) _uniquePathForPath:(NSString*)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSString* directory = [path stringByDeletingLastPathComponent];
        NSString* file = [path lastPathComponent];
        NSString* base = [file stringByDeletingPathExtension];
        NSString* extension = [file pathExtension];
        int retries = 0;
        do {
            if (extension.length) {
                path = [directory stringByAppendingPathComponent:[[base stringByAppendingFormat:@" (%i)", ++retries] stringByAppendingPathExtension:extension]];
            } else {
                path = [directory stringByAppendingPathComponent:[base stringByAppendingFormat:@" (%i)", ++retries]];
            }
        } while ([[NSFileManager defaultManager] fileExistsAtPath:path]);
    }
    return path;
}

- (GCDWebServerResponse*)uploadFile:(GCDWebServerMultiPartFormRequest*)request {
    NSRange range = [[request.headers objectForKey:@"Accept"] rangeOfString:@"application/json" options:NSCaseInsensitiveSearch];
    NSString* contentType = (range.location != NSNotFound ? @"application/json" : @"text/plain; charset=utf-8");  // Required when using iFrame transport (see https://github.com/blueimp/jQuery-File-Upload/wiki/Setup)
    
    GCDWebServerMultiPartFile *file=request.files[0];
    
    if ((!_allowHidden && [file.fileName hasPrefix:@"."]) || ![self _checkFileExtension:file.fileName]) {
        return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_Forbidden message:@"Uploaded file name \"%@\" is not allowed", file.fileName];
    }

    NSString* absolutePath = [self _uniquePathForPath:[_uploadDirectory
                                                       stringByAppendingPathComponent:file.fileName]];


    NSError* error = nil;
//    30s 3M 1M/10s 100KB/s
    if (![[NSFileManager defaultManager] moveItemAtPath:file.temporaryPath toPath:absolutePath error:&error]) {
            return [GCDWebServerErrorResponse responseWithServerError:kGCDWebServerHTTPStatusCode_InternalServerError underlyingError:error message:@"Failed moving uploaded file to \"%@\"", absolutePath];
    }
    
    if ([self.delegate respondsToSelector:@selector(webUploader:didUploadFileAtPath:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate webUploader:self didUploadFileAtPath:absolutePath];
        });
    }
    return [GCDWebServerDataResponse responseWithJSONObject:@{} contentType:contentType];
}

//- (GCDWebServerResponse*)uploadFile:(GCDWebServerMultiPartFormRequest*)request {
//    NSRange range = [[request.headers objectForKey:@"Accept"] rangeOfString:@"application/json" options:NSCaseInsensitiveSearch];
//    NSString* contentType = (range.location != NSNotFound ? @"application/json" : @"text/plain; charset=utf-8");  // Required when using iFrame transport (see https://github.com/blueimp/jQuery-File-Upload/wiki/Setup)
//    
////    GCDWebServerMultiPartFile* file = [request firstFileForControlName:@"files[]"];
//    GCDWebServerMultiPartFile *file=request.files[0];
//    if ((!_allowHidden && [file.fileName hasPrefix:@"."]) || ![self _checkFileExtension:file.fileName]) {
//        return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_Forbidden message:@"Uploaded file name \"%@\" is not allowed", file.fileName];
//    }
//    NSString* relativePath = [[request firstArgumentForControlName:@"path"] string];
//    NSString* absolutePath = [self _uniquePathForPath:[[_uploadDirectory stringByAppendingPathComponent:relativePath] stringByAppendingPathComponent:file.fileName]];
//    if (![self _checkSandboxedPath:absolutePath]) {
//        return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_NotFound message:@"\"%@\" does not exist", relativePath];
//    }
//    
//    if (![self shouldUploadFileAtPath:absolutePath withTemporaryFile:file.temporaryPath]) {
//        return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_Forbidden message:@"Uploading file \"%@\" to \"%@\" is not permitted", file.fileName, relativePath];
//    }
//    
//    NSError* error = nil;
//    if (![[NSFileManager defaultManager] moveItemAtPath:file.temporaryPath toPath:absolutePath error:&error]) {
//        return [GCDWebServerErrorResponse responseWithServerError:kGCDWebServerHTTPStatusCode_InternalServerError underlyingError:error message:@"Failed moving uploaded file to \"%@\"", relativePath];
//    }
//    
//    if ([self.delegate respondsToSelector:@selector(webUploader:didUploadFileAtPath:)]) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.delegate webUploader:self didUploadFileAtPath:absolutePath];
//        });
//    }
//    return [GCDWebServerDataResponse responseWithJSONObject:@{} contentType:contentType];
//}



@end

@implementation FEWebUploader

@synthesize uploadDirectory=_uploadDirectory, allowedFileExtensions=_allowedExtensions, allowHiddenItems=_allowHidden,
title=_title, header=_header, prologue=_prologue, epilogue=_epilogue, footer=_footer;

@dynamic delegate;

- (instancetype)initWithUploadDirectory:(NSString*)path {
    if ((self = [super init])) {
        
        NSString *resourcesBundlePath = [[NSBundle mainBundle] pathForResource:@"FEWebUploader" ofType:@"bundle"];
//        NSBundle *resourcesBundle = [NSBundle bundleWithPath:resourcesBundlePath];
        NSBundle* siteBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[FEWebUploader class]] pathForResource:@"FEWebUploader" ofType:@"bundle"]];
        if (siteBundle == nil) {
            return nil;
        }
        _uploadDirectory = [[path stringByStandardizingPath] copy];
        
        __weak typeof(FEWebUploader *) weakSelf=self;
        // Resource files
        [self addGETHandlerForBasePath:@"/" directoryPath:[siteBundle resourcePath] indexFilename:nil cacheAge:3600 allowRangeRequests:NO];
        
        // Web page
        [self addHandlerForMethod:@"GET" path:@"/" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
            
            NSString *htmlPath = [NSString stringWithFormat:@"%@/index.html",resourcesBundlePath];
            NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath
                                                             encoding:NSUTF8StringEncoding error:nil];
            
            return [GCDWebServerDataResponse responseWithHTML:htmlString];
//            return [GCDWebServerDataResponse responseWithHTMLTemplate:[siteBundle pathForResource:@"index" ofType:@"html"]
//                                                            variables:@{}];
            
        }];
        
        // File upload
        [self addHandlerForMethod:@"POST" path:@"/upload" requestClass:[GCDWebServerMultiPartFormRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
            return [weakSelf uploadFile:(GCDWebServerMultiPartFormRequest*)request];
        }];
    }
    return self;
}

@end

@implementation FEWebUploader (Subclassing)

- (BOOL)shouldUploadFileAtPath:(NSString*)path withTemporaryFile:(NSString*)tempPath {
    return YES;
}

- (BOOL)shouldMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
    return YES;
}

- (BOOL)shouldDeleteItemAtPath:(NSString*)path {
    return YES;
}

- (BOOL)shouldCreateDirectoryAtPath:(NSString*)path {
    return YES;
}

@end
