require "distribution/math_extension"

# formulas from
# https://www.evanmiller.org/bayesian-ab-testing.html
module FieldTest
  module Calculations
    def self.prob_b_beats_a(alpha_a, beta_a, alpha_b, beta_b)
      total = 0.0

      # for performance
      logbeta_aa_ba = Math.logbeta(alpha_a, beta_a)
      beta_ba = beta_b + beta_a

      0.upto(alpha_b - 1) do |i|
        total += Math.exp(Math.logbeta(alpha_a + i, beta_ba) -
          Math.log(beta_b + i) - Math.logbeta(1 + i, beta_b) -
          logbeta_aa_ba)
      end

      total
    end

    def self.prob_c_beats_a_and_b(alpha_a, beta_a, alpha_b, beta_b, alpha_c, beta_c)
      total = 0.0

      # for performance
      logbeta_ac_bc = Math.logbeta(alpha_c, beta_c)
      abc = beta_a + beta_b + beta_c
      log_bb_j = []
      logbeta_j_bb = []
      logbeta_ac_i_j = []
      0.upto(alpha_b - 1) do |j|
        log_bb_j[j] = Math.log(beta_b + j)
        logbeta_j_bb[j] = Math.logbeta(1 + j, beta_b)

        0.upto(alpha_a - 1) do |i|
          logbeta_ac_i_j[i + j] ||= Math.logbeta(alpha_c + i + j, abc)
        end
      end

      0.upto(alpha_a - 1) do |i|
        # for performance
        log_ba_i = Math.log(beta_a + i)
        logbeta_i_ba = Math.logbeta(1 + i, beta_a)

        0.upto(alpha_b - 1) do |j|
          total += Math.exp(logbeta_ac_i_j[i + j] -
            log_ba_i - log_bb_j[j] -
            logbeta_i_ba - logbeta_j_bb[j] -
            logbeta_ac_bc)
        end
      end

      1 - prob_b_beats_a(alpha_c, beta_c, alpha_a, beta_a) -
        prob_b_beats_a(alpha_c, beta_c, alpha_b, beta_b) + total
    end
  end
end
