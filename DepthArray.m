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
    Kz_vec = Kz_distribution(Kz, maxZ, 10^n);
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

        
        %% As a check of Visser's condition at the end of page 277, calculate
        % the second derivative and compare to the timestep.
        K_2nd = derivative_2nd(Kz_vec, z(:, 1));
        % Visser (in text not code) specifies min(1/K''), but this gives
        % infinite values in regions where slope is constant.  This can't be
        % right, so look only at values which are not too small.
        %K_2_reduced = K_2nd(abs(K_2nd) > 0.001);
        %compare_to = min(1./K_2_reduced);
        % V2 - use absolute values
        compare_to = min(1./abs(K_2nd));
        fprintf("dt is %d and min(1/K'') is %d\n", dt, compare_to);
        
        %%
        % The first derivative  of Kz, using a central difference, except at the
        % ends.  XXX - check whether a forward difference would be better, since
        % the equation it is used in isn't centered.
        K_prime = derivative(Kz_vec, z(:, 1), 'central');
                
        % Visser states that the standard deviation of a R, a uniform
        % distribution between -1 and 1 is 1/3, but it's sqrt(1/3).  Maybe I
        % misunderstood something but I'm using sqrt(1/3) until proven
        % otherwise.
        r = sqrt(1/3);
        walkA = K_prime * dt;  % constant part of the step magnitude
        % The next term relies on K evaluated at an offset location!
        % NOTE that z_offset is no longer monotonic.  Changes are bigger than
        % the initial increments between particles.
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
            wA = interp1(z(:,1), walkA, z(:, i-1));
            wB = interp1(z(:,1), walkB, z(:, i-1));
            waf = 0.6; % 1.0 is the Visser algorithm.
            % For dt = 60:
            % 1.0 pumps left, max 1300 min 480
            % 0.0 right, 2400, 600
            % 0.5 right, 1200, 970
            % 0.6 GOOD - looks level
            % Now for dt = 6:
            % 0.6 GOOD
            % 0.5 right, 1150, 900
            % 1.0 left, 1280, 450
            % 0.7 left, 1100, 750
            % with naive, waf is irrelevant, right 1280, 780, wider range
            % affected
            % One more check with dt = 3 (algorithm suggests < 3.33)
            pm = waf*wA + wB .* (2*rand(10^n, 1)-1.0);
        end
        if ~mod(i, 1000)
            fprintf('at time i = %d pm(10) = %d, max = %d\n', i, pm(10), max(pm));
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
    clear i; clear j; clear walk, clear pm, clear ltz, clear gtmax;

end
