# include "fbcu.bi"

namespace fbc_tests.structs.obj_property_alias

type UDT
	as integer p_v

	declare sub      setv alias "setv"( byval new_v as integer )
	declare property v    alias "setv"( byval new_v as integer )

	declare function getv alias "getv"( ) as integer
	declare property v    alias "getv"( ) as integer
end type

function UDT.getv( ) as integer
	function = p_v
end function

sub UDT.setv( byval new_v as integer)
	p_v = new_v
end sub

private sub test cdecl( )
	dim as UDT x

	CU_ASSERT( x.p_v = 0 )

	x.v = 1
	CU_ASSERT( x.p_v = 1 )
	CU_ASSERT( x.v = 1 )
end sub

private sub ctor( ) constructor
	fbcu.add_suite( "fbc_tests.structs.obj_property_alias" )
	fbcu.add_test( "test", @test )
end sub

end namespace
