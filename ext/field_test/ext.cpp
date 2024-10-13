#include <ruby.h>

#include "bayestest.hpp"

using bayestest::BinaryTest;

void binary_test_free(void* data)
{
  free(data);
}

size_t binary_test_size(const void* data)
{
  // does not currently include size of variants
  return sizeof(BinaryTest);
}

static const rb_data_type_t binary_test_type = {
  .wrap_struct_name = "binary_test",
  .function = {
    .dmark = NULL,
    .dfree = binary_test_free,
    .dsize = binary_test_size,
  },
  .data = NULL,
  .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

VALUE binary_test_alloc(VALUE self)
{
  BinaryTest* data = new BinaryTest();

  return TypedData_Wrap_Struct(self, &binary_test_type, data);
}

VALUE binary_test_add(VALUE self, VALUE participants, VALUE conversions)
{
  BinaryTest* data;
  TypedData_Get_Struct(self, BinaryTest, &binary_test_type, data);

  data->add(NUM2INT(participants), NUM2INT(conversions));

  return Qnil;
}

VALUE binary_test_probabilities(VALUE self)
{
  BinaryTest* data;
  TypedData_Get_Struct(self, BinaryTest, &binary_test_type, data);

  VALUE arr = rb_ary_new();
  for (auto &v : data->probabilities()) {
    rb_ary_push(arr, DBL2NUM(v));
  }
  return arr;
}

extern "C"
void Init_ext() {
  auto mFieldTest = rb_define_module("FieldTest");

  auto cBinaryTest = rb_define_class_under(mFieldTest, "BinaryTest", rb_cObject);
  rb_define_alloc_func(cBinaryTest, binary_test_alloc);
  rb_define_method(cBinaryTest, "add", binary_test_add, 2);
  rb_define_method(cBinaryTest, "probabilities", binary_test_probabilities, 0);
}
