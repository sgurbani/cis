function Bvn = bern(v, n, u)
%returns the v-th term (0<=v<=n) of the n-th degree Bernstein polynomial
%of u (0<=u<=1)
binom_coeff = gamma(n+1) / gamma(v+1) / gamma(n-v+1);

Bvn = binom_coeff * u^v * (1-u)^(n-v);

end