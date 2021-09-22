#include <rice/rice.hpp>
#include "bayesian_ab.hpp"

extern "C"
void Init_ext() {
  auto rb_mFieldTest = Rice::define_module("FieldTest");

  Rice::define_class_under(rb_mFieldTest, "Calculations")
    .define_singleton_function("prob_b_beats_a", &bayesian_ab::prob_b_beats_a)
    .define_singleton_function("prob_c_beats_a_and_b", &bayesian_ab::prob_c_beats_a_and_b)
    .define_singleton_function("prob_d_beats_a_and_b_and_c", &bayesian_ab::prob_d_beats_a_and_b_and_c);
}
