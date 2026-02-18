#include <algorithm>

#include <ruby.h>

#include "bayestest.hpp"

using bayestest::BinaryTest;

static VALUE
probabilities(VALUE self, VALUE results) {
  Check_Type(results, T_ARRAY);

  int participants[4];
  int conversions[4];
  double probabilities[4];

  long count = RARRAY_LEN(results);
  VALUE *results_ptr = RARRAY_PTR(results);
  for (long i = 0; i < count; i++) {
    VALUE v = results_ptr[i];
    participants[i] = NUM2INT(rb_hash_aref(v, ID2SYM(rb_intern("participated"))));
    conversions[i] = NUM2INT(rb_hash_aref(v, ID2SYM(rb_intern("converted"))));
  }

  // no exceptions
  {
    bayestest::BinaryTest test;
    for (long i = 0; i < count; i++) {
      test.add(participants[i], conversions[i]);
    }
    auto prob = test.probabilities();
    std::copy(prob.begin(), prob.end(), probabilities);
  }

  VALUE rb_probabilities = rb_ary_new_capa(count);
  for (long i = 0; i < count; i++) {
    rb_ary_push(rb_probabilities, DBL2NUM(probabilities[i]));
  }
  return rb_probabilities;
}

extern "C"
void Init_ext() {
  VALUE rb_mFieldTest = rb_define_module("FieldTest");
  VALUE rb_mBinaryTest = rb_define_module_under(rb_mFieldTest, "BinaryTest");
  rb_define_singleton_method(rb_mBinaryTest, "probabilities", probabilities, 1);
}
