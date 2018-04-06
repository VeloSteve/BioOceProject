function [z] = DepthArray(n,dt,nt,Kz,maxZ)
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

    z = zeros(10^n,nt); % holding vector for our depth values. 

    for i = 2:10^n
        z(i) = z(i-1) + (maxZ/10^n); % evenly spacing our initial depth from 0 to ~100m
    end
    
    walk = sqrt(2*dt*Kz); % this is the distance that will be walked,
                          % either up or down based on our timestep and
                          % verctical eddy difusivity
% Now that we have our starting depths, we perform our random walk
    for i = 2:nt % time step loop
        pm = sign(0.51-rand(10^n,1)); % a matrix of randomly generated positve
                                   % or negative ones that will the random
                                   % part of our simulated walk.
        pm=pm.*walk;
        z(:,i)=z(:,i-1)+pm;
        for j = 1:10^n
            %z(j,i) = NickEq4(z(j,i-1),walk,pm(j,i));
             %z(j,i) = z(j,i-1) + (pm(j)*walk);
             % We need to code in our boundary conditions.  This is a relfective
            % boundary to prevent cell accumulation at the edges.
                if z(j,i) < 0 % phytoplankton don't generally take to the air
                    z(j,i) = z(j,i)*-1;
                elseif z(j,i) > maxZ % we aren't going to consider depths greater than 100m
                    z(j,i) = maxZ -(z(j,i)-maxZ);
                else % but if everything is okay, we proceed as planned.

                end
        end
      clear pm;
    end
clear i; clear j; clear walk, clear pm;

    

end

