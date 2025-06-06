/*
 * File: svdb_typedef.h
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: Type definitions for SVDB Gateway
 */

#ifndef SVDB_TYPEDEF_H
#define SVDB_TYPEDEF_H

//Title: Common defines

/*
Define: INLINE
Inline function definition for C++ compatibility
*/

#ifdef __cplusplus
#define INLINE inline
#else
#define INLINE
#endif

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <time.h>
#include <stdarg.h>
#include <stdint.h>
#include <fcntl.h>
#include <signal.h>
#include <time.h>
#include <sys/time.h>

/* Use the custom SQLite path if defined, otherwise try standard path */
#ifdef SQLITE_CUSTOM_PATH
#include SQLITE_CUSTOM_PATH
#else
#include <sqlite3.h>
#endif

#ifdef SVDB_SVDPI
#include "svdpi.h"
#else
#ifndef INCLUDED_SVDPI

/*
Variable: svScalar
Basic scalar type for SystemVerilog DPI
*/

typedef uint8_t svScalar;

/*
Variable: svLogic
SystemVerilog logic type, alias for svScalar
*/

typedef svScalar svLogic; /* scalar */

/*
Variable: svBit
SystemVerilog bit type, alias for svScalar
*/

typedef svScalar svBit; /* scalar */

/*
Variable: svBitVecVal
SystemVerilog bit vector value type
*/

typedef uint32_t svBitVecVal;

/*
Variable: svOpenArrayHandle
Handle for SystemVerilog open arrays
*/

typedef void* svOpenArrayHandle;

/*
Struct: t_vpi_vecval
Structure for VPI vector values containing aval and bval fields
*/

typedef struct t_vpi_vecval {
  uint32_t aval;  /* Vector value A */
  uint32_t bval;  /* Vector value B */
} s_vpi_vecval, *p_vpi_vecval;

/*
Variable: svLogicVecVal
SystemVerilog logic vector value type, alias for s_vpi_vecval
*/

typedef s_vpi_vecval svLogicVecVal;
#endif
#endif

/*
Variable: svdb_long_t
64-bit integer type for SVDB Gateway, defaults to "long long"
*/

#ifndef  svdb_long_t
typedef long long svdb_long_t;
#endif

#endif //define SVDB_TYPEDEF_H


