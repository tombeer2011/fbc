/*
 *  libfb - FreeBASIC's runtime library
 *	Copyright (C) 2004-2005 Andre Victor T. Vicentini (av1ctor@yahoo.com.br)
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 * file_inputstr - input$ function
 *
 * chng: nov/2004 written [v1ctor]
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include "fb.h"


/*:::::*/
FBCALL FBSTRING *fb_FileStrInput( int bytes, int fnum )
{
	FILE 		*f;
	FBSTRING 	*dst;
	int			len;

	if( fnum < 0 || fnum > FB_MAX_FILES )
		return &fb_strNullDesc;

	FB_LOCK();

	if( fnum == 0 )
		f = stdin;
	else
		f = fb_fileTB[fnum-1].f;

	if( f == NULL ) {
		FB_UNLOCK();
		return &fb_strNullDesc;
	}

	FB_STRLOCK();

	dst = (FBSTRING *)fb_hStrAllocTmpDesc( );
	if( dst == NULL ) {
		FB_STRUNLOCK();
		FB_UNLOCK();
		return &fb_strNullDesc;
	}

	fb_hStrAllocTemp( dst, bytes );
	if( dst->data == NULL )
	{
		fb_hStrDelTempDesc( dst );
		FB_STRUNLOCK();
		FB_UNLOCK();
		return &fb_strNullDesc;
	}

	if( fnum == 0 )
	{
		if( fb_ReadString( dst->data, bytes, f ) != NULL )
			len = strlen( dst->data );
		else
			len = 0;
	}
	else
		len = fread( dst->data, 1, bytes, f );

	if( len != bytes )
	{
		dst->data[len] = '\0';
		dst->len = len | FB_TEMPSTRBIT;				/* mark as temp */
	}

	FB_STRUNLOCK();
	FB_UNLOCK();

	return dst;
}

