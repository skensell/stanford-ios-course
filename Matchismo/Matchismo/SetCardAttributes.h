//
//  SetCardAttributes.h
//  SuperCard
//
//  Created by Scott Kensell on 12/12/13.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#ifndef SuperCard_SetCardAttributes_h
#define SuperCard_SetCardAttributes_h

typedef enum {
    SC_OVAL = 1,
    SC_SQUIGGLE,
    SC_DIAMOND
} set_shape_t;

typedef enum {
    SC_OPAQUE = 1,
    SC_SHADED,
    SC_HOLLOW
} set_shading_t;

typedef enum {
    SC_ONE = 1,
    SC_TWO,
    SC_THREE
} set_number_t;

typedef enum {
    SC_GREEN = 1,
    SC_RED,
    SC_PURPLE
} set_color_t;

#endif
