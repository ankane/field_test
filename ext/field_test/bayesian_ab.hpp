#pragma once

#include <cmath>
#include <vector>

namespace bayesian_ab {

double logbeta(double a, double b) {
  return std::lgamma(a) + std::lgamma(b) - std::lgamma(a + b);
}

double prob_b_beats_a(int alpha_a, int beta_a, int alpha_b, int beta_b) {
  double total = 0.0;
  double logbeta_aa_ba = logbeta(alpha_a, beta_a);
  double beta_ba = beta_b + beta_a;

  for (auto i = 0; i < alpha_b; i++) {
    total += exp(logbeta(alpha_a + i, beta_ba) - log(beta_b + i) - logbeta(1 + i, beta_b) - logbeta_aa_ba);
  }

  return total;
}

double prob_c_beats_a_and_b(int alpha_a, int beta_a, int alpha_b, int beta_b, int alpha_c, int beta_c) {
  double total = 0.0;

  // for performance
  double logbeta_ac_bc = logbeta(alpha_c, beta_c);
  double abc = beta_a + beta_b + beta_c;
  std::vector<double> log_bb_j;
  log_bb_j.reserve(alpha_b);
  std::vector<double> logbeta_j_bb;
  logbeta_j_bb.reserve(alpha_b);
  std::vector<double> logbeta_ac_i_j;
  logbeta_ac_i_j.reserve(alpha_a + alpha_b);

  for (auto j = 0; j < alpha_b; j++) {
    log_bb_j.push_back(log(beta_b + j));
    logbeta_j_bb.push_back(logbeta(1 + j, beta_b));

    for (auto i = 0; i < alpha_a; i++) {
      if (logbeta_ac_i_j.size() == i + j) {
        logbeta_ac_i_j.push_back(logbeta(alpha_c + i + j, abc));
      }
    }
  }

  for (auto i = 0; i < alpha_a; i++) {
    // for performance
    double log_ba_i = log(beta_a + i);
    double logbeta_i_ba = logbeta(1 + i, beta_a);

    for (auto j = 0; j < alpha_b; j++) {
      total += exp(logbeta_ac_i_j[i + j] -
        log_ba_i - log_bb_j[j] -
        logbeta_i_ba - logbeta_j_bb[j] -
        logbeta_ac_bc);
    }
  }

  return 1 - prob_b_beats_a(alpha_c, beta_c, alpha_a, beta_a) -
    prob_b_beats_a(alpha_c, beta_c, alpha_b, beta_b) + total;
}

double prob_d_beats_a_and_b_and_c(int alpha_a, int beta_a, int alpha_b, int beta_b, int alpha_c, int beta_c, int alpha_d, int beta_d) {
  double total = 0.0;

  double logbeta_ad_bd = logbeta(alpha_d, beta_d);
  double abcd = beta_a + beta_b + beta_c + beta_d;

  std::vector<double> log_bb_j;
  log_bb_j.reserve(alpha_b);
  std::vector<double> logbeta_j_bb;
  logbeta_j_bb.reserve(alpha_b);

  for (auto j = 0; j < alpha_b; j++) {
    log_bb_j.push_back(log(beta_b + j));
    logbeta_j_bb.push_back(logbeta(1 + j, beta_b));
  }

  std::vector<double> log_bc_k;
  log_bc_k.reserve(alpha_c);
  std::vector<double> logbeta_k_bc;
  logbeta_k_bc.reserve(alpha_c);

  for (auto k = 0; k < alpha_c; k++) {
    log_bc_k.push_back(log(beta_c + k));
    logbeta_k_bc.push_back(logbeta(1 + k, beta_c));
  }

  std::vector<double> logbeta_bd_i_j_k;
  logbeta_bd_i_j_k.reserve(alpha_a + alpha_b + alpha_c);

  for (auto i = 0; i < alpha_a + alpha_b + alpha_c; i++) {
    logbeta_bd_i_j_k.push_back(logbeta(alpha_d + i, abcd));
  }

  for (auto i = 0; i < alpha_a; i++) {
    double log_ba_i = log(beta_a + i);
    double logbeta_i_ba = logbeta(1 + i, beta_a);

    for (auto j = 0; j < alpha_b; j++) {
      for (auto k = 0; k < alpha_c; k++) {
        total += exp(logbeta_bd_i_j_k[i + j + k] -
          log_ba_i - log_bb_j[j] - log_bc_k[k] - logbeta_i_ba -
          logbeta_j_bb[j] - logbeta_k_bc[k] - logbeta_ad_bd);
      }
    }
  }

  return 1 - prob_b_beats_a(alpha_a, beta_a, alpha_d, beta_d) -
    prob_b_beats_a(alpha_b, beta_b, alpha_d, beta_d) -
    prob_b_beats_a(alpha_c, beta_c, alpha_d, beta_d) +
    prob_c_beats_a_and_b(alpha_a, beta_a, alpha_b, beta_b, alpha_d, beta_d) +
    prob_c_beats_a_and_b(alpha_a, beta_a, alpha_c, beta_c, alpha_d, beta_d) +
    prob_c_beats_a_and_b(alpha_b, beta_b, alpha_c, beta_c, alpha_d, beta_d) - total;
}

}
