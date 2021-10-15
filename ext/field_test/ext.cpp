#include <rice/rice.hpp>
#include "bayestest.hpp"

extern "C"
void Init_ext() {
  auto rb_mFieldTest = Rice::define_module("FieldTest");

  Rice::define_class_under(rb_mFieldTest, "Calculations")
    .define_singleton_function("prob_b_beats_a", &bayestest::prob_b_beats_a)
    .define_singleton_function("prob_c_beats_a_and_b", &bayestest::prob_c_beats_ab)
    .define_singleton_function("prob_d_beats_a_and_b_and_c", &bayestest::prob_d_beats_abc);
}
