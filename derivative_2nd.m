function d2 = derivative_2nd(y, x)
% Accepts vectors of x and y values, and computes the second derivative d2y/dx2
% by finite difference.  Only central difference is supported.
    d2 = zeros(length(x), 1);
    % Skip the end points which don't have a defined central difference.
    d2(2:end-1) = (y(3:end) -2*y(2:end-1) + y(1:end-2)) ./ ((x(3:end) - x(1:end-2))/2).^2;
    % End points by forward or backward difference:
    d2(1) = (y(3) - 2*y(2) + y(1)) ./ ((x(3) - x(1))/2).^2;
    d2(end) = (y(end) - 2*y(end-1) + y(end-1)) ./ ((x(end) - x(end-2))/2).^2;
    
end
