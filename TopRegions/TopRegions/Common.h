//
//  Header.h
//  flickr_places
//
//  Created by Scott Kensell on 1/3/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#ifndef flickr_places_common_h
#define flickr_places_common_h

#ifdef DEBUG
#undef DEBUG
#endif

#define THIS_METHOD NSStringFromSelector(_cmd)
#define THIS_CLASS [self class]

#define DEBUG(A, ...) NSLog(@"DEBUG %@", [NSString stringWithFormat:A, ##__VA_ARGS__])
#define INFO(A, ...) NSLog(@"INFO %@--%@ %@", THIS_CLASS, THIS_METHOD, [NSString stringWithFormat:A, ##__VA_ARGS__])
#define WARNING(A, ...) NSLog(@"WARNING %@--%@ %@", THIS_CLASS, THIS_METHOD, [NSString stringWithFormat:A, ##__VA_ARGS__])
#define ERROR(A, ...) NSLog(@"ERROR %@--%@ %@", THIS_CLASS, THIS_METHOD, [NSString stringWithFormat:A, ##__VA_ARGS__])

//#define DEBUG(A, ...) NSLog(@"DEBUG %@--%@ %@", THIS_CLASS, THIS_METHOD, [NSString stringWithFormat:A, ##__VA_ARGS__])
//#define INFO(A, ...) NSLog(@"INFO %@--%@ %@", THIS_CLASS, THIS_METHOD, [NSString stringWithFormat:A, ##__VA_ARGS__])
//#define WARNING(A, ...) NSLog(@"WARNING %@--%@ %@", THIS_CLASS, THIS_METHOD, [NSString stringWithFormat:A, ##__VA_ARGS__])
//#define ERROR(A, ...) NSLog(@"ERROR %@--%@ %@", THIS_CLASS, THIS_METHOD, [NSString stringWithFormat:A, ##__VA_ARGS__])

#endif
