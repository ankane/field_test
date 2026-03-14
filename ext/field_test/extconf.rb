require "mkmf"

$CFLAGS << " $(optflags)"

$CFLAGS += " -Wall -Wextra -Wconversion"

create_makefile("field_test/ext")
