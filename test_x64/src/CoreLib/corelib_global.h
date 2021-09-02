#pragma once

#include <QtCore/qglobal.h>

#ifndef BUILD_STATIC
# if defined(CORELIB_LIB)
#  define CORELIB_EXPORT Q_DECL_EXPORT
# else
#  define CORELIB_EXPORT Q_DECL_IMPORT
# endif
#else
# define CORELIB_EXPORT
#endif
