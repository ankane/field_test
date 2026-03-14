#include <ruby.h>

#include "bayestest.h"

static VALUE probabilities(VALUE self, VALUE results)
{
    Check_Type(results, T_ARRAY);

    long count = RARRAY_LEN(results);
    if (count > 4) {
        rb_raise(rb_eArgError, "too many variants");
    }

    int participants[4];
    int conversions[4];
    double probabilities[4];

    VALUE *results_ptr = RARRAY_PTR(results);
    for (long i = 0; i < count; i++) {
        VALUE v = results_ptr[i];
        participants[i] = NUM2INT(rb_hash_aref(v, ID2SYM(rb_intern("participated"))));
        conversions[i] = NUM2INT(rb_hash_aref(v, ID2SYM(rb_intern("converted"))));
    }

    int status = bayestest_binary((int) count, participants, conversions, probabilities);
    if (status != 0) {
        rb_raise(rb_eRuntimeError, "bad status");
    }

    VALUE rb_probabilities = rb_ary_new_capa(count);
    for (long i = 0; i < count; i++) {
        rb_ary_push(rb_probabilities, DBL2NUM(probabilities[i]));
    }
    return rb_probabilities;
}

void Init_ext(void)
{
    VALUE rb_mFieldTest = rb_define_module("FieldTest");
    VALUE rb_mBinaryTest = rb_define_module_under(rb_mFieldTest, "BinaryTest");
    rb_define_singleton_method(rb_mBinaryTest, "probabilities", probabilities, 1);
}
