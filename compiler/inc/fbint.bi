''	FreeBASIC - 32-bit BASIC Compiler.
''	Copyright (C) 2004-2005 Andre Victor T. Vicentini (av1ctor@yahoo.com.br)
''
''	This program is free software; you can redistribute it and/or modify
''	it under the terms of the GNU General Public License as published by
''	the Free Software Foundation; either version 2 of the License, or
''	(at your option) any later version.
''
''	This program is distributed in the hope that it will be useful,
''	but WITHOUT ANY WARRANTY; without even the implied warranty of
''	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
''	GNU General Public License for more details.
''
''	You should have received a copy of the GNU General Public License
''	along with this program; if not, write to the Free Software
''	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA.


''
'' internal compiler definitions
''

const FB.MAXINCRECLEVEL%	= 4
const FB.MAXINCPATHS%		= 16

const FB.MAXNANELEN%		= 128

const FB_MAXPROCARGS%		= 16

''
const FB.INITELEMENTNODES% 	= 1000

const FB.INITSYMBOLNODES%	= 3000
const FB.INITLOCSYMBOLNODES%= FB.INITSYMBOLNODES \ 10

const FB.INITARGNODES%		= 2000

const FB.INITDIMNODES%		= 400

const FB.INITLIBNODES%		= 50

''
const FB.POINTERSIZE%		= 4%
const FB.INTEGERSIZE%		= 4%
const FB.ARRAYDESCSIZE%		= FB.INTEGERSIZE*5

const FB.ARRAYDESC.DATAOFFS% = 0%

const FB.DATALABELNAME 		= "_fb_data_begin"
const FB.DATALABELPREFIX 	= "_datalbl_"


'' print modes (same as in rtlib/fb.h)
enum FBPRINTMASK
	FB.PRINTMASK.NEWLINE	= &h00000001
	FB.PRINTMASK.PAD        = &h00000002
	FB.PRINTMASK.ISLAST		= &h80000000
end enum

'' file constants (same as in rtlib/fb.h)
enum FBFILEMODE
	FB.FILE.MODE.BINARY
	FB.FILE.MODE.RANDOM
	FB.FILE.MODE.INPUT
	FB.FILE.MODE.OUTPUT
	FB.FILE.MODE.APPEND
end enum

enum FBFILEACCESS
	FB.FILE.ACCESS.READ		= 1
	FB.FILE.ACCESS.WRITE
	FB.FILE.ACCESS.READWRITE
end enum

enum FBFILELOCK
	FB.FILE.LOCK.SHARED
	FB.FILE.LOCK.READ
	FB.FILE.LOCK.WRITE
	FB.FILE.LOCK.READWRITE
end enum

''
''
''

'' some chars
const CHAR_NULL   	= 00, _
      CHAR_CR  	  	= 13, _
      CHAR_LF  	  	= 10, _
      CHAR_SPACE  	= 32, _
      CHAR_TAB    	= 09, _
      CHAR_0   		= 48, _
      CHAR_1    	= 49, _
      CHAR_7  		= 56, _
      CHAR_9   		= 57, _
      CHAR_AUPP    	= 65, _
      CHAR_ALOW  	= 97, _
      CHAR_BUPP    	= 66, _
      CHAR_BLOW    	= 98, _
      CHAR_DUPP    	= 68, _
      CHAR_DLOW  	= 100, _
      CHAR_EUPP    	= 69, _
      CHAR_ELOW    	= 101, _
      CHAR_FUPP    	= 70, _
      CHAR_FLOW    	= 102, _
      CHAR_HUPP    	= 72, _
      CHAR_HLOW    	= 104, _
      CHAR_OUPP    	= 79, _
      CHAR_OLOW    	= 111, _
      CHAR_ZUPP    	= 90, _
      CHAR_ZLOW  	= 122, _
      CHAR_LPRNT  	= 40, _
      CHAR_RPRNT  	= 41, _
      CHAR_COMMA 	= 44, _
      CHAR_DOT    	= 46, _
      CHAR_PLUS   	= 43, _
      CHAR_MINUS  	= 45, _
      CHAR_RSLASH  	= 92, _
      CHAR_CARET   	= 42, _
      CHAR_SLASH   	= 47, _
      CHAR_CART   	= 94, _
      CHAR_EQ     	= 61, _
      CHAR_LT     	= 60, _
      CHAR_GT     	= 62, _
      CHAR_AMP		= 38, _
      CHAR_UNDER	= 95, _
      CHAR_EXCL		= 33, _
      CHAR_SHARP	= 35, _
      CHAR_DOLAR	= 36, _
      CHAR_PERC		= 37, _
      CHAR_QUOTE	= 34, _
      CHAR_APOST	= 39, _
      CHAR_TIMES	= 42, _
      CHAR_STAR		= CHAR_TIMES, _
      CHAR_COLON	= 58, _
      CHAR_SEMICOLON= 59, _
      CHAR_AT		= 64, _
      CHAR_QUESTION	= 63


'' tokens
const FB.TK.EOF%				= 32767

enum FBTK_ENUM
	FB.TK.EOL					= 256
	FB.TK.NUMLIT
	FB.TK.ID
	FB.TK.REM
	FB.TK.DIM
	FB.TK.STATIC
	FB.TK.SHARED
	FB.TK.INTEGER
	FB.TK.LONG
	FB.TK.SINGLE
	FB.TK.DOUBLE
	FB.TK.STRING
	FB.TK.USERDEFTYPE
	FB.TK.CALL
	FB.TK.CALLS
	FB.TK.BYVAL
	FB.TK.SEG
	FB.TK.STRLIT
	FB.TK.INCLUDE
	FB.TK.DYNAMIC
	FB.TK.AS
	FB.TK.DECLARE
	FB.TK.GOTO
	FB.TK.GOSUB
	FB.TK.AND
	FB.TK.OR
	FB.TK.XOR
	FB.TK.EQV
	FB.TK.IMP
	FB.TK.NOT
	FB.TK.EQ
	FB.TK.GT
	FB.TK.LT
	FB.TK.NE
	FB.TK.LE
	FB.TK.GE
	FB.TK.DEFINT
	FB.TK.DEFLNG
	FB.TK.DEFSNG
	FB.TK.DEFDBL
	FB.TK.DEFSTR
	FB.TK.CONST
	FB.TK.FOR
	FB.TK.STEP
	FB.TK.NEXT
	FB.TK.TO
	FB.TK.MOD
	FB.TK.TYPE
	FB.TK.END
	FB.TK.SUB
	FB.TK.FUNCTION
	FB.TK.CDECL
	FB.TK.STDCALL
	FB.TK.ALIAS
	FB.TK.LIB
	FB.TK.LET
	FB.TK.BYTE
	FB.TK.UBYTE
	FB.TK.SHORT
	FB.TK.USHORT
	FB.TK.UINT
	FB.TK.DEFBYTE
	FB.TK.DEFUBYTE
	FB.TK.DEFSHORT
	FB.TK.DEFUSHORT
	FB.TK.DEFUINT
	FB.TK.EXIT
	FB.TK.DO
	FB.TK.LOOP
	FB.TK.RETURN
	FB.TK.ANY
	FB.TK.PTR
	FB.TK.POINTER
	FB.TK.VARPTR
	FB.TK.FIELDDEREF
	FB.TK.SHL
	FB.TK.SHR
	FB.TK.WHILE
	FB.TK.UNTIL
	FB.TK.WEND
	FB.TK.CONTINUE
	FB.TK.CINT
	FB.TK.CLNG
	FB.TK.CSNG
	FB.TK.CDBL
	FB.TK.CBYTE
	FB.TK.CSHORT
	FB.TK.CSIGN
	FB.TK.CUNSG
	FB.TK.IF
	FB.TK.THEN
	FB.TK.ELSE
	FB.TK.ELSEIF
	FB.TK.SELECT
	FB.TK.CASE
	FB.TK.IS
	FB.TK.UNSIGNED
	FB.TK.REDIM
	FB.TK.ERASE
	FB.TK.LBOUND
	FB.TK.UBOUND
	FB.TK.UNION
	FB.TK.PUBLIC
	FB.TK.PRIVATE
	FB.TK.STR
	FB.TK.INSTR
	FB.TK.MID
	FB.TK.BYREF
	FB.TK.OPTION
	FB.TK.BASE
	FB.TK.EXPLICIT
	FB.TK.PASCAL
	FB.TK.PROCPTR
	FB.TK.SADD
	FB.TK.RESTORE
	FB.TK.READ
	FB.TK.DATA
	FB.TK.ABS
	FB.TK.SGN
	FB.TK.FIX
	FB.TK.PRINT
	FB.TK.USING
	FB.TK.LEN
	FB.TK.PEEK
	FB.TK.PEEKS
	FB.TK.PEEKI
	FB.TK.POKE
	FB.TK.POKES
	FB.TK.POKEI
	FB.TK.SWAP
	FB.TK.COMMON
	FB.TK.OPEN
	FB.TK.CLOSE
	FB.TK.SEEK
	FB.TK.PUT
	FB.TK.GET
	FB.TK.ACCESS
	FB.TK.WRITE
	FB.TK.LOCK
	FB.TK.INPUT
	FB.TK.OUTPUT
	FB.TK.BINARY
	FB.TK.RANDOM
	FB.TK.APPEND
	FB.TK.PRESERVE
	FB.TK.ON
	FB.TK.ERROR
	FB.TK.ENUM
	FB.TK.INCLIB
	FB.TK.ASM
	FB.TK.SPC
	FB.TK.TAB
	FB.TK.LINE
	FB.TK.VIEW
	FB.TK.UNLOCK
	FB.TK.FIELD
	FB.TK.LOCAL
	FB.TK.ERR
end enum

'' single char tokens
const FB.TK.TWOPOINTSCHAR%		= CHAR_COLON	'' :
const FB.TK.STATSEPCHAR			= CHAR_COLON	'' :
const FB.TK.COMMENTCHAR%		= CHAR_APOST	'' '
const FB.TK.DIRECTIVECHAR%		= CHAR_DOLAR	'' $
const FB.TK.DECLSEPCHAR%		= CHAR_COMMA	'' ,
const FB.TK.ASSIGN%				= FB.TK.EQ		'' special case, due the way lex processes comparators
const FB.TK.IDXOPENCHAR%		= CHAR_LPRNT	'' (
const FB.TK.IDXCLOSECHAR%		= CHAR_RPRNT	'' )
const FB.TK.DEREFCHAR%			= CHAR_CARET	'' *
const FB.TK.ADDROFCHAR			= CHAR_AT		'' @

const FB.TK.INTTYPECHAR%		= CHAR_PERC
const FB.TK.LNGTYPECHAR%		= CHAR_AMP
const FB.TK.SGNTYPECHAR%		= CHAR_EXCL
const FB.TK.DBLTYPECHAR%		= CHAR_SHARP
const FB.TK.STRTYPECHAR%		= CHAR_DOLAR


'' token classes
enum FBTKCLASS_ENUM
	FB.TKCLASS.UNKNOWN
	FB.TKCLASS.KEYWORD
	FB.TKCLASS.IDENTIFIER
	FB.TKCLASS.NUMLITERAL
	FB.TKCLASS.STRLITERAL
	FB.TKCLASS.OPERATOR
	FB.TKCLASS.DELIMITER
end enum


'' argument modes
enum FBARGMODE_ENUM
	FB.ARGMODE.BYDESC			= 1
	FB.ARGMODE.BYVAL
	FB.ARGMODE.BYREF
end enum

'' call conventions
enum FBFUNCMODE_ENUM
	FB.FUNCMODE.PASCAL			= 1
	FB.FUNCMODE.CDECL
	FB.FUNCMODE.STDCALL
end enum

const FB.DEFAULT.FUNCMODE%		= FB.FUNCMODE.STDCALL

'' symbol types (same order as IR.DATATYPES!)
enum FBSYMBTYPE_ENUM
	FB.SYMBTYPE.VOID
	FB.SYMBTYPE.BYTE
	FB.SYMBTYPE.UBYTE
	FB.SYMBTYPE.SHORT
	FB.SYMBTYPE.USHORT
	FB.SYMBTYPE.INTEGER
	FB.SYMBTYPE.LONG			= FB.SYMBTYPE.INTEGER
	FB.SYMBTYPE.UINT
	FB.SYMBTYPE.SINGLE
	FB.SYMBTYPE.DOUBLE
	FB.SYMBTYPE.STRING
	FB.SYMBTYPE.FIXSTR
	FB.SYMBTYPE.USERDEF
	FB.SYMBTYPE.FUNCTION
	FB.SYMBTYPE.POINTER            				'' must be the last
end enum

const FB.SYMBOLTYPES%			= 14-1			'' pointer not taken into account

const FB.SYMBTYPE.DATALABEL%	= FB.SYMBOLTYPES*2	'' internal only, used with DATA's


'' allocation types mask
enum FBALLOCTYPE_ENUM
	FB.ALLOCTYPE.SHARED			= 1
	FB.ALLOCTYPE.STATIC			= 2
	FB.ALLOCTYPE.DYNAMIC		= 4
	FB.ALLOCTYPE.COMMON			= 8
	FB.ALLOCTYPE.TEMP			= 16
	FB.ALLOCTYPE.ARGUMENTBYDESC	= 32
	FB.ALLOCTYPE.ARGUMENTBYVAL	= 64
	FB.ALLOCTYPE.ARGUMENTBYREF 	= 128
end enum


type FBCMPSTMT
	cmplabel		as integer					'' or inilabel
    endlabel		as integer
end type

''
type FBENV
	'' paths
	libpathidx		as integer

	incpaths		as integer

	'' source file
	inf				as integer
	infile			as string * 260

	'' destine file
	outfile			as string * 260

	'' stmt recursion
	forstmt			as FBCMPSTMT
	dostmt			as FBCMPSTMT
	whilestmt		as FBCMPSTMT
	procstmt		as FBCMPSTMT

	'' globals
	scope			as integer					'' current scope (0=main module)
	reclevel		as integer					'' >0 if parsing an include file
	currproc 		as integer					'' current proc (def= INVALID)

	'' cmm-line options
	clopt			as FBCMMLINEOPT

	'' debug states
	dbglname 		as string * 32
	dbglnum 		as integer
	dbgpos 			as long

	'' options
	optbase			as integer					'' default=0
	optargmode		as integer					'' def    =byref
	optexplicit		as integer					'' def    =false
	optprocpublic	as integer					'' def    =true

	compoundcnt		as integer					'' checked when parsing EXIT
	lastcompound	as integer					'' last compound stmt (token), def= INVALID
	cputype 		as integer                  '' used by the emit module
	isdynamic		as integer					'' TRUE with $dynamic, FALSE with $static
	isprocstatic	as integer					'' TRUE with SUB/FUNCTION (...) STATIC
	procerrorhnd	as integer					'' var holding the old error handler inside a proc
end type


''
type FBARRAYDIM
	lower			as long
	upper			as long
end type

''
type FBTYPELEMENT
	free			as integer

	typ				as integer
	subtype			as integer					'' only if another UDT
	ofs				as integer
	parent			as integer
	nameidx			as integer

	lgt				as integer
	dims			as integer
	dimhead			as integer
	dimtail			as integer
	dif				as integer

	l				as integer					'' left
	r				as integer					'' right

	prv				as integer					'' linked-list nodes
	nxt				as integer					'' /
end type


''
type FBLIBRARY
	nameidx			as integer

	prv				as integer					'' linked-list nodes
	nxt				as integer					'' /
end type


''
enum SYMBCLASS_ENUM
	FB.SYMBCLASS.VAR			= 1
	FB.SYMBCLASS.CONST
	FB.SYMBCLASS.UDT
	FB.SYMBCLASS.PROC
	FB.SYMBCLASS.LABEL
	FB.SYMBCLASS.ENUM
end enum

''
type FBLABEL
	declared		as integer
end type

''
type FBVARDIM
	lower			as long
	upper			as long

	r				as integer					'' right

	prv				as integer					'' linked-list nodes
	nxt				as integer					'' /
end type

type FBSVAR
	dims			as integer
	dimhead 		as integer
	dimtail			as integer
	dif				as long
	desc			as integer
end type

type FBSCONST
	textidx			as integer
end type

''
type FBSUDT
	isunion			as integer
	elements		as integer
	head			as integer					'' first element
	tail			as integer					'' last  /
	ofs				as integer
	align			as integer
	innerlgt		as integer					'' used with inner nameless unions
end type

''
type FBPROCARG
	nameidx			as integer
	typ				as integer
	subtype			as integer					'' UDT's only
	lgt				as integer
	mode			as integer
	suffix			as integer					'' QB quirk..

	optional		as integer					'' true or false
	defvalue		as double					'' default value

	l				as integer					'' left
	r				as integer					'' right

	prv				as integer					'' linked-list nodes
	nxt				as integer					'' /
end type

type FBSPROC
	mode			as integer					'' calling convention (STDCALL, PASCAL, C)
	lib				as integer
	args			as integer
	arghead 		as integer
	argtail			as integer
	isdeclared		as integer					'' FALSE = just the prototype
end type


''
type FBLOCSYMBOL
    s				as integer

	prv				as integer					'' linked-list nodes
	nxt				as integer					'' /
end type

type FBSYMBOL
	class			as integer					'' var, const, proc, ..
	typ				as integer					'' integer, float, string, pointer, ..
	subtype			as integer					'' used by UDT's
	alloctype		as integer					'' STATIC, DYNAMIC, SHARED, ARG, ..

	nameidx			as integer
	aliasidx		as integer

	scope			as integer
	lgt				as long

	initialized		as integer
	inittextidx		as integer

	union
		v			as FBSVAR
		c			as FBSCONST
		u			as FBSUDT
		p			as FBSPROC
		l			as FBLABEL
	end union

	prv				as integer					'' linked-list nodes
	nxt				as integer					'' /
end type

''
type FBKEYWORD
	nameidx			as integer
	id				as integer
	class			as integer
end type

''
type FBSTRING
	id				as long
	lgt				as long
end type

const FB.STRSTRUCTSIZE%		= 4+4

'' "fake" descriptors as UDT's
const FB.DESCTYPE.ARRAY% 	= -2
const FB.DESCTYPE.STR% 		= -3


'$include:'inc\symb.bi'

'$include:'inc\strpool.bi'

'$include:'inc\hlp.bi'


''
'' super globals
''
common shared env as FBENV
