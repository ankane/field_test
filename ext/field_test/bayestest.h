/*
 * BayesTest C v0.1.1
 * https://github.com/ankane/bayestest-c
 * MIT License
 */

#pragma once

#include <limits.h>
#include <math.h>
#include <stdlib.h>

/// @private
static inline double bayestest_logbeta(double a, double b) {
    // TODO use lgamma_r when available
    return lgamma(a) + lgamma(b) - lgamma(a + b);
}

/// @private
static inline double bayestest_prob_b_beats_a(int alpha_a, int beta_a, int alpha_b, int beta_b) {
    double total = 0.0;
    double logbeta_aa_ba = bayestest_logbeta(alpha_a, beta_a);
    double beta_ba = beta_b + beta_a;

    for (int i = 0; i < alpha_b; i++) {
        total += exp(
            bayestest_logbeta(alpha_a + i, beta_ba) - log(beta_b + i)
            - bayestest_logbeta(1 + i, beta_b) - logbeta_aa_ba
        );
    }

    return total;
}

/// @private
static inline double bayestest_prob_c_beats_ab(
    int alpha_a,
    int beta_a,
    int alpha_b,
    int beta_b,
    int alpha_c,
    int beta_c
) {
    double* log_bb_j_logbeta_j_bb = malloc(sizeof(double) * (unsigned int) alpha_b);
    double* logbeta_ac_i_j = malloc(sizeof(double) * (unsigned int) (alpha_a + alpha_b));

    if (log_bb_j_logbeta_j_bb == NULL || logbeta_ac_i_j == NULL) {
        free(log_bb_j_logbeta_j_bb);
        free(logbeta_ac_i_j);
        return NAN;
    }

    double total = 0.0;
    double logbeta_ac_bc = bayestest_logbeta(alpha_c, beta_c);

    for (int j = 0; j < alpha_b; j++) {
        log_bb_j_logbeta_j_bb[j] = log(beta_b + j) + bayestest_logbeta(1 + j, beta_b);
    }

    double abc = beta_a + beta_b + beta_c;
    for (int i = 0; i < alpha_a + alpha_b; i++) {
        logbeta_ac_i_j[i] = bayestest_logbeta(alpha_c + i, abc);
    }

    for (int i = 0; i < alpha_a; i++) {
        double sum_i = -log(beta_a + i) - bayestest_logbeta(1 + i, beta_a) - logbeta_ac_bc;

        for (int j = 0; j < alpha_b; j++) {
            total += exp(sum_i + logbeta_ac_i_j[i + j] - log_bb_j_logbeta_j_bb[j]);
        }
    }

    free(log_bb_j_logbeta_j_bb);
    free(logbeta_ac_i_j);

    return 1 - bayestest_prob_b_beats_a(alpha_c, beta_c, alpha_a, beta_a)
        - bayestest_prob_b_beats_a(alpha_c, beta_c, alpha_b, beta_b) + total;
}

/// @private
static inline double bayestest_prob_d_beats_abc(
    int alpha_a,
    int beta_a,
    int alpha_b,
    int beta_b,
    int alpha_c,
    int beta_c,
    int alpha_d,
    int beta_d
) {
    double* log_bb_j_logbeta_j_bb = malloc(sizeof(double) * (unsigned int) alpha_b);
    double* log_bc_k_logbeta_k_bc = malloc(sizeof(double) * (unsigned int) alpha_c);
    double* logbeta_bd_i_j_k = malloc(
        sizeof(double) * (unsigned int) (alpha_a + alpha_b + alpha_c)
    );

    if (log_bb_j_logbeta_j_bb == NULL || log_bc_k_logbeta_k_bc == NULL
        || logbeta_bd_i_j_k == NULL) {
        free(log_bb_j_logbeta_j_bb);
        free(log_bc_k_logbeta_k_bc);
        free(logbeta_bd_i_j_k);
        return NAN;
    }

    double total = 0.0;
    double logbeta_ad_bd = bayestest_logbeta(alpha_d, beta_d);

    for (int j = 0; j < alpha_b; j++) {
        log_bb_j_logbeta_j_bb[j] = log(beta_b + j) + bayestest_logbeta(1 + j, beta_b);
    }

    for (int k = 0; k < alpha_c; k++) {
        log_bc_k_logbeta_k_bc[k] = log(beta_c + k) + bayestest_logbeta(1 + k, beta_c);
    }

    double abcd = beta_a + beta_b + beta_c + beta_d;
    for (int i = 0; i < alpha_a + alpha_b + alpha_c; i++) {
        logbeta_bd_i_j_k[i] = bayestest_logbeta(alpha_d + i, abcd);
    }

    for (int i = 0; i < alpha_a; i++) {
        double sum_i = -log(beta_a + i) - bayestest_logbeta(1 + i, beta_a) - logbeta_ad_bd;

        for (int j = 0; j < alpha_b; j++) {
            double sum_j = sum_i - log_bb_j_logbeta_j_bb[j];

            for (int k = 0; k < alpha_c; k++) {
                total += exp(sum_j + logbeta_bd_i_j_k[i + j + k] - log_bc_k_logbeta_k_bc[k]);
            }
        }
    }

    free(log_bb_j_logbeta_j_bb);
    free(log_bc_k_logbeta_k_bc);
    free(logbeta_bd_i_j_k);

    return 1 - bayestest_prob_b_beats_a(alpha_a, beta_a, alpha_d, beta_d)
        - bayestest_prob_b_beats_a(alpha_b, beta_b, alpha_d, beta_d)
        - bayestest_prob_b_beats_a(alpha_c, beta_c, alpha_d, beta_d)
        + bayestest_prob_c_beats_ab(alpha_a, beta_a, alpha_b, beta_b, alpha_d, beta_d)
        + bayestest_prob_c_beats_ab(alpha_a, beta_a, alpha_c, beta_c, alpha_d, beta_d)
        + bayestest_prob_c_beats_ab(alpha_b, beta_b, alpha_c, beta_c, alpha_d, beta_d) - total;
}

/// Returns the winning probability of each variant for binary outcomes.
static inline int bayestest_binary(
    int variants,
    const int* participants,
    const int* conversions,
    double* probabilities
) {
    if (variants < 0 || variants > 4) {
        return -1;
    }

    for (int i = 0; i < variants; i++) {
        if (participants[i] < 0) {
            return -1;
        }

        if (participants[i] > INT_MAX / (int) sizeof(double) / 4) {
            return -1;
        }

        if (conversions[i] < 0) {
            return -1;
        }

        if (conversions[i] > INT_MAX / (int) sizeof(double) / 4) {
            return -1;
        }

        if (conversions[i] > participants[i]) {
            return -1;
        }
    }

    switch (variants) {
        case 0: {
            break;
        }
        case 1: {
            probabilities[0] = 1;
            break;
        }
        case 2: {
            int a = 1;
            int b = 0;
            double prob = bayestest_prob_b_beats_a(
                1 + conversions[a],
                1 + participants[a] - conversions[a],
                1 + conversions[b],
                1 + participants[b] - conversions[b]
            );

            if (isnan(prob)) {
                return -1;
            }
            probabilities[0] = prob;
            probabilities[1] = 1 - prob;
            break;
        }
        case 3: {
            double total = 0.0;
            for (int i = 0; i < 2; i++) {
                int c = i;
                int b = (i + 1) % 3;
                int a = (i + 2) % 3;

                double prob = bayestest_prob_c_beats_ab(
                    1 + conversions[a],
                    1 + participants[a] - conversions[a],
                    1 + conversions[b],
                    1 + participants[b] - conversions[b],
                    1 + conversions[c],
                    1 + participants[c] - conversions[c]
                );

                if (isnan(prob)) {
                    return -1;
                }
                probabilities[i] = prob;
                total += prob;
            }
            probabilities[2] = 1 - total;
            break;
        }
        case 4: {
            double total = 0.0;
            for (int i = 0; i < 3; i++) {
                int d = i;
                int c = (i + 1) % 4;
                int b = (i + 2) % 4;
                int a = (i + 3) % 4;

                double prob = bayestest_prob_d_beats_abc(
                    1 + conversions[a],
                    1 + participants[a] - conversions[a],
                    1 + conversions[b],
                    1 + participants[b] - conversions[b],
                    1 + conversions[c],
                    1 + participants[c] - conversions[c],
                    1 + conversions[d],
                    1 + participants[d] - conversions[d]
                );

                if (isnan(prob)) {
                    return -1;
                }
                probabilities[i] = prob;
                total += prob;
            }
            probabilities[3] = 1 - total;
            break;
        }
        default: {
            return -1;
        }
    }

    return 0;
}

/// @private
static inline double bayestest_prob_1_beats_2(int alpha_1, int beta_1, int alpha_2, int beta_2) {
    double total = 0.0;
    double log_b1 = log(beta_1);
    double a2_log_b2 = alpha_2 * log(beta_2);
    double log_b1_b2 = log(beta_1 + beta_2);

    for (int k = 0; k < alpha_1; k++) {
        total += exp(
            k * log_b1 + a2_log_b2 - (k + alpha_2) * log_b1_b2 - log(k + alpha_2)
            - bayestest_logbeta(k + 1, alpha_2)
        );
    }

    return total;
}

/// @private
static inline double bayestest_prob_1_beats_23(
    int alpha_1,
    int beta_1,
    int alpha_2,
    int beta_2,
    int alpha_3,
    int beta_3
) {
    double total = 0.0;
    double log_b1_b2_b3 = log(beta_1 + beta_2 + beta_3);
    double a1_log_b1 = alpha_1 * log(beta_1);
    double log_b2 = log(beta_2);
    double log_b3 = log(beta_3);
    double loggamma_a1 = lgamma(alpha_1);

    for (int k = 0; k < alpha_2; k++) {
        double sum_k = a1_log_b1 + k * log_b2 - lgamma(k + 1);

        for (int l = 0; l < alpha_3; l++) {
            total += exp(
                sum_k + l * log_b3 - (k + l + alpha_1) * log_b1_b2_b3 + lgamma(k + l + alpha_1)
                - lgamma(l + 1) - loggamma_a1
            );
        }
    }

    return 1 - bayestest_prob_1_beats_2(alpha_2, beta_2, alpha_1, beta_1)
        - bayestest_prob_1_beats_2(alpha_3, beta_3, alpha_1, beta_1) + total;
}

/// Returns the winning probability of each variant for count data.
static inline int bayestest_count(
    int variants,
    const int* events,
    const int* exposure,
    double* probabilities
) {
    if (variants < 0 || variants > 3) {
        return -1;
    }

    for (int i = 0; i < variants; i++) {
        if (events[i] < 0) {
            return -1;
        }

        if (events[i] > INT_MAX / 4) {
            return -1;
        }

        if (exposure[i] < 0) {
            return -1;
        }

        if (exposure[i] > INT_MAX / 4) {
            return -1;
        }
    }

    switch (variants) {
        case 0: {
            break;
        }
        case 1: {
            probabilities[0] = 1;
            break;
        }
        case 2: {
            int a = 0;
            int b = 1;
            double prob = bayestest_prob_1_beats_2(events[a], exposure[a], events[b], exposure[b]);

            probabilities[0] = prob;
            probabilities[1] = 1 - prob;
            break;
        }
        case 3: {
            double total = 0.0;
            for (int i = 0; i < 2; i++) {
                int a = i;
                int b = (i + 1) % 3;
                int c = (i + 2) % 3;

                double prob = bayestest_prob_1_beats_23(
                    events[a], exposure[a], events[b], exposure[b], events[c], exposure[c]
                );

                probabilities[i] = prob;
                total += prob;
            }
            probabilities[2] = 1 - total;
            break;
        }
        default: {
            return -1;
        }
    }

    return 0;
}
