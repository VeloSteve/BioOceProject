function[Iz]= NickEq3( Io,z,varargin )
%NickEq3 This function caculates light attentuation with depth.  It is
%assumed that at least one of the dimensions of Io and z will match.
%   INPUTS:
%       Io - light intensity at the surface
%       k - attenuation coefficient
%       z - depth
%   OUTPUTS:
%       Iz - light intensity at given depth
    if nargin == 3
        t = varargin{1}; % checking if we have an i iteration value for this function
    end
    k = 1.8/30; % light attenuation coefficient
    [m,n]=size(z); % getting the size of our depth matrix
    [r,c]=size(Io); % determining if the surface irradiance is a matrix or vector
    if m > r
        % JSR - this does the same thing regardless of the if test!!!
        if n > 0
            Io=repmat(Io,m,1); % generating an equal sized matrix of Io.  This is needed
        else
            Io=repmat(Io,m,1);
        end
   elseif n > c           % for the formula below
        if n>0
            Io=repmat(Io(t),1,n);
        else
            Io=repmat(Io,1,n); % if it's not different in one dimension, maybe it's
        end
    end                    % the other.
    Iz = Io.*exp(-k.*z); % dot notation used to ensure elementwise mulitplication of matrices
    


end

