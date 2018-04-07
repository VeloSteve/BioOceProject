function [z] = DepthArray(n, dt, nt, Kz, maxZ)
%DepthArray This function is used to reduce the memory load on the
%Nicks_DTDD script.  It takes in the number of time steps and the n value
%(10^n) which determines how many cells we will be dealing with and returns
%a completed depth matrix.  It dstributes the 10^n cells over the top 100m
%and performs a random walk simulation for each cell over each time step
%   INPUTS
%       n - number of cells (10^n)
%       dt - change in time with each step (in seconds)
%       nt - number of time steps
%       Kz - vertical mixing coefficient
%   OUTPUTS
%       z - a 10^n x nt matrix of the depth experienced by each cell for each
%       step in time

    z = zeros(10^n, nt); % holding vector for our depth values. 

    z(:, 1) = linspace(0, maxZ, 10^n);
    Kz_vec = Kz_distribution(Kz, 10^n);
    naive = false;
    if naive
        walk = sqrt(2*dt*Kz_vec); % this is the distance that will be walked,
                          % either up or down based on our timestep and
                          % vertical eddy diffusivity
        fprintf('First, 10th, last walk values %d, %d, %d\n', walk(1), walk(10), walk(end));
    else
        % Use a random walk model from Visser(1997), equation 6.
        % We will use a random number inside the loop, but first generate
        % anything which is constant.
        % The first derivative  of Kz, using a central difference, except at the
        % ends.  XXX - check whether a forward difference would be better, since
        % the equation it is used in isn't centered.
        K_prime = derivative(Kz_vec, z(:, 1), 'central');
        % Visser states that the standard deviation of a R, a uniform distribution
        % -1 and 1 is 1/3, but it's sqrt(1/3).  Maybe I misunderstood something
        % but I'm using sqrt(1/3) until proven otherwise.
        r = sqrt(1/3);
        walkA = K_prime * dt;  % constant part of the step magnitude
        % The next term relies on K evaluated at an offset location!
        z_offset = z(:, 1) + K_prime*dt/2.0;
        K_offset = interp1(z(:, 1), Kz_vec, z_offset, 'linear', 'extrap');
        walkB = sqrt(2/r * K_offset * dt);
        fprintf('First, 10th, last walkA values %d, %d, %d, min = %d, max = %d\n', walkA(1), walkA(10), walkA(end), min(walkA), max(walkA));
        fprintf('First, 10th, last walkB values %d, %d, %d\n', walkB(1), walkB(10), walkB(end));

    end
% Now that we have our starting depths, we perform our random walk
    for i = 2:nt % time step loop
        if naive
            pm = sign(0.50-rand(10^n,1)); % a matrix of randomly generated positive
                                       % or negative ones that will the random
                                       % part of our simulated walk.
            pm = pm .* walk;
        else
            % walk A and walkB are arrays spaced at the initial depths, but at
            % each time step the particles move, so their K values must be found by
            % another interpolation!
            % Note: interp1 can do both at once, but code that later.
            wA = interp1(z(:,1), walkA, z(i-1));
            wB = interp1(z(:,1), walkB, z(i-1));
            pm = wA + wB .* (2*rand(10^n, 1)-1.0);
        end
        if ~mod(i, 100)
            fprintf('at i = %d pm(10) = %d, max = %d\n', i, pm(10), max(pm));
        end
        z(:,i)=z(:,i-1)+pm;
        % Calculate boundaries in vector form.  1.147 seconds for n=4 becomes
        % 0.16 seconds for the whole function.  
        ltz = find(z(:, i) < 0);
        z(ltz, i) = -z(ltz, i);
        gtmax = find(z(:, i) > maxZ);
        z(gtmax, i) = 2*maxZ - z(gtmax, i);
                   
      clear pm;
    end
clear i; clear j; clear walk, clear pm;

    

end

