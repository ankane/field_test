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

    def self.prob_d_beats_a_and_b_and_c(alpha_a, beta_a, alpha_b, beta_b, alpha_c, beta_c, alpha_d, beta_d)
      total = 0.0

      logbeta_ad_bd = Math.logbeta(alpha_d, beta_d)
      abcd = beta_a + beta_b + beta_c + beta_d
      logbeta_ad_i_j_k = []
      log_ba_i = []
      log_bb_j = []
      log_bc_k = []
      logbeta_i_ba = []
      logbeta_j_bb = []
      logbeta_k_bc = []

      0.upto(alpha_a - 1) do |i|
        log_ba_i[i] ||= Math.log(beta_a + i)
        logbeta_i_ba[i] ||= Math.logbeta(1 + i, beta_a)

        0.upto(alpha_b - 1) do |j|
          log_bb_j[j] ||= Math.log(beta_b + j)
          logbeta_j_bb[j] ||= Math.logbeta(1 + j, beta_b)

          0.upto(alpha_c - 1) do |k|
            log_bc_k[k] ||= Math.log(beta_c + k)
            logbeta_k_bc[k] ||= Math.logbeta(1 + k, beta_c)
            logbeta_ad_i_j_k[i + j + k] ||= Math.logbeta(alpha_d + i + j + k, abcd)

            total += Math.exp(
              logbeta_ad_i_j_k[i + j + k] -
              log_ba_i[i] - log_bb_j[j] - log_bc_k[k] -
              logbeta_i_ba[i] - logbeta_j_bb[j] - logbeta_k_bc[k] -
              logbeta_ad_bd
            )
          end
        end
      end

      1 -
        prob_b_beats_a(alpha_a, beta_a, alpha_d, beta_d) -
        prob_b_beats_a(alpha_b, beta_b, alpha_d, beta_d) -
        prob_b_beats_a(alpha_c, beta_c, alpha_d, beta_d) +
        prob_c_beats_a_and_b(alpha_a, beta_a, alpha_b, beta_b, alpha_d, beta_d) +
        prob_c_beats_a_and_b(alpha_a, beta_a, alpha_c, beta_c, alpha_d, beta_d) +
        prob_c_beats_a_and_b(alpha_b, beta_b, alpha_c, beta_c, alpha_d, beta_d) -
        total
    end

    def self.prob_e_beats_a_and_b_and_c_and_d(alpha_a, beta_a, alpha_b, beta_b, alpha_c, beta_c, alpha_d, beta_d, alpha_e, beta_e)
      total = 0.0

      logbeta_ae_be = Math.logbeta(alpha_e, beta_e)
      abcde = beta_a + beta_b + beta_c + beta_d + beta_e
      logbeta_ae_i_j_k_l = []
      log_ba_i = []
      log_bb_j = []
      log_bc_k = []
      log_bd_l = []
      logbeta_i_ba = []
      logbeta_j_bb = []
      logbeta_k_bc = []
      logbeta_l_bd = []

      0.upto(alpha_a - 1) do |i|
        log_ba_i[i] ||= Math.log(beta_a + i)
        logbeta_i_ba[i] ||= Math.logbeta(1 + i, beta_a)

        0.upto(alpha_b - 1) do |j|
          log_bb_j[j] ||= Math.log(beta_b + j)
          logbeta_j_bb[j] ||= Math.logbeta(1 + j, beta_b)

          0.upto(alpha_c - 1) do |k|
            log_bc_k[k] ||= Math.log(beta_c + k)
            logbeta_k_bc[k] ||= Math.logbeta(1 + k, beta_c)

            0.upto(alpha_d - 1) do |l|
            logbeta_ae_i_j_k_l[i + j + k + l] ||= Math.logbeta(alpha_e + i + j + k + l, abcde)

            total += Math.exp(
              logbeta_ae_i_j_k_l[i + j + k + l] -
              log_ba_i[i] - log_bb_j[j] - log_bc_k[k] - log_bd_l[l] -
              logbeta_i_ba[i] - logbeta_j_bb[j] - logbeta_k_bc[k] - logbeta_l_bd[l] -
              logbeta_ae_be
            )
          end
        end
      end

      total
      # TODO Calculate Probability
    end
  end
end
