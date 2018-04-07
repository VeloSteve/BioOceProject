function dist = Kz_distribution(Kbase, n)
% Create a diffusivity distribution base on inputs.  FOR NOW this is
% just a fixed test distribution.
    dist = ones(n, 1)* Kbase;
    dist(n/2:end) = Kbase/10;


end
