require "mkmf"

$CFLAGS << " $(optflags)"

create_makefile("field_test/ext")
