' TEST_MODE : COMPILE_ONLY_OK

sub f( byval l as any const ptr )
end sub

dim r as any ptr = 0
f( r )
