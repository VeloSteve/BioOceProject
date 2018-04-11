function dist = Kz_distribution(Kbase, maxZ, n)
% Create a diffusivity distribution based on inputs.  FOR NOW this is
% just a fixed test distribution.
    dist = ones(n, 1)* Kbase;
    % Decrease Kz linearly over a distance of 3 meters, starting at 50 meters.
    % This is arbitrary, but by using a fixed distance the slope (and 2nd
    % derivative) shouldn't be affected by the total number of points used.
    tPoints = 3.0/(maxZ/n);
    transition = linspace(Kbase, Kbase/10, tPoints);
    pos = n*50/maxZ;
    dist(pos:pos+tPoints-1) = transition;
    dist(pos+tPoints:end) = Kbase/10;
end
