//
//  Sundown.m
//  Sundown
//
//  Created by Jakub Hampl on 15.10.12.
//  Copyright (c) 2012 Jakub Hampl. All rights reserved.
//

#import "Sundown.h"
#include "markdown.h"
#include "html.h"
#include "buffer.h"
#include "houdini.h"

static void
my_rndr_blockcode(struct buf *ob, const struct buf *text, const struct buf *lang, void *opaque)
{
	if (ob->size) bufputc(ob, '\n');
  
	if (lang && lang->size) {
    
    
    NSString *theCode = [[NSString alloc] initWithBytes:text->data length:text->size encoding:NSUTF8StringEncoding];
    NSString *highlighted;
    
    NSMutableArray *opts = [NSMutableArray arrayWithObjects:@"-f", @"html", nil];
    
    highlighted = [Sundown cacheForKey:theCode];
    if (highlighted == nil) {
      size_t i, cls;
      //BUFPUTSL(ob, "<pre><code class=\"");
      
      
      
//      for (i = 0, cls = 0; i < lang->size; ++i, ++cls) {
//        while (i < lang->size && isspace(lang->data[i]))
//          i++;
//        
//        if (i < lang->size) {
//          size_t org = i;
//          while (i < lang->size && !isspace(lang->data[i]))
//            i++;
//          
//          if (lang->data[org] == '.')
//            org++;
//          
//          if (cls) bufputc(ob, ' ');
//          escape_html(ob, lang->data + org, i - org);
//        }
//      }
      
      
      NSString *language = [[NSString alloc] initWithBytes:lang->data length:lang->size encoding:NSUTF8StringEncoding];
      NSString *lexer =[language stringByReplacingOccurrencesOfString:@"." withString:@""];
      [opts addObject:@"-l"];
      [opts addObject:lexer];
      NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"pygments/pygmentize"];
      NSLog(@"Path = %@", path);
      
      NSPipe *inPipe = [NSPipe pipe];
      NSPipe *outPipe = [NSPipe pipe];
      NSFileHandle *inFile = [inPipe fileHandleForWriting];
      
      NSTask *pygmentize = [[NSTask alloc] init];
      [pygmentize setLaunchPath:path];
      [pygmentize setArguments: opts];
      [pygmentize setStandardInput: inPipe];
      [pygmentize setStandardOutput: outPipe];
      
      [pygmentize launch];
      
      [inFile writeData: [theCode dataUsingEncoding:NSUTF8StringEncoding]];
      [inFile closeFile];
      NSLog(@"After launch");
      NSData *data = [[outPipe fileHandleForReading] readDataToEndOfFile];
      [pygmentize waitUntilExit];
      NSLog(@"After exit");
      
      NSLog(@"After data");
      highlighted = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
      NSLog(@"HIGHLIGHT: %@", highlighted);
      //*output = bufnew([highlighted length]);
      [Sundown cacheString:highlighted forKey:theCode];
      
        
    }

    
    bufputs(ob, [highlighted cStringUsingEncoding:NSUTF8StringEncoding]);
    
    
		    
	} else {
		BUFPUTSL(ob, "<pre><code>");
  
    if (text)
      houdini_escape_html0(ob, text->data, text->size, 0);
  
    BUFPUTSL(ob, "</code></pre>\n");
  }
}



#define MAX_CACHE 20

static NSMutableDictionary *_mycache = nil;


@implementation Sundown


+(void) initialize
{
  if (! _mycache) {
    _mycache = [[NSMutableDictionary alloc] initWithCapacity:MAX_CACHE];
    //[_mycache retain];
  }
}
+ (NSString *)cacheForKey:(NSString *)key {
  return [_mycache valueForKey:key];
}
+ (void)cacheString: (NSString *)obj forKey:(NSString *)key {
  if([_mycache count] >= MAX_CACHE) {
    //[_mycache release];
    _mycache = [[NSMutableDictionary alloc] initWithCapacity:MAX_CACHE];
    
  }
  _mycache[key] = obj;
}





+ (NSString *)convertMD: (NSString *)str withOptions: (int)opts
{
  if(!str.length) {
    fprintf(stderr,"Empty string passed into conversion method.");
    return nil;
  }
  
  NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
  
	struct buf *ob;
  
	struct sd_callbacks callbacks;
	struct html_renderopt options;
	struct sd_markdown *markdown;
  
	/* performing markdown parsing */
	ob = bufnew(data.length);
  
	sdhtml_renderer(&callbacks, &options, 0);
  callbacks.blockcode = my_rndr_blockcode;
	markdown = sd_markdown_new(opts, 16, &callbacks, &options);
	sd_markdown_render(ob, data.bytes, data.length, markdown);
	sd_markdown_free(markdown);
  
  NSString *string = nil;
  if (!ob->size) {
    fprintf(stderr,"Conversion of input string resulted in no html");
	}
  else {
    /* writing the result to string*/
    string = [[NSString alloc] initWithBytes:ob->data length:ob->size encoding:NSUTF8StringEncoding];
  }
  
	/* cleanup */
	bufrelease(ob);
  
	return string;
}


+ (void)asyncConvertMD: (NSString *)str withOptions: (int)opts whenDone:(void(^)(NSString*))callback
{
  dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(aQueue, ^{    
    NSString *string = [Sundown convertMD: str withOptions: opts];
    dispatch_queue_t mainQ = dispatch_get_main_queue();
    dispatch_async(mainQ, ^{
      callback(string);
    });
    
  });

}

@end
