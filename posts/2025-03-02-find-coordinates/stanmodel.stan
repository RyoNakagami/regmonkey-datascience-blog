data {
    int<lower=1> N;  // Number of data points
    array[N] real y; // outcomes
    array[N] real x; // outcomes
}

parameters {
    real<lower=0> r_0; // probability of success
    real x_0;             // Center x-coordinate
    real y_0;             // Center y-coordinate
}

model {
    // priors
    r_0 ~ uniform(2, 30);
    real sigma = 1;

    // objective loss
    array[N] real circle_equation;
    for (i in 1:N) {
        circle_equation[i] = sqrt((x[i] - x_0)^2 + (y[i] - y_0)^2) - r_0;
    }

    circle_equation ~ normal(0, sigma);
}
