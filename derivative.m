function dydx = derivative(y, x, method)
% Accepts vectors of x and y values, and computes the derivative dy/dx by finite
% difference.  "method" is central, forward, or backward, though not all may be
% supported at first.
    dydx = zeros(length(x), 1);
    if strcmp(method, 'central')
        % Skip the end points which don't have a defined central difference.
        dydx(2:end-1) = (y(3:end) - y(1:end-2)) ./ (x(3:end) - x(1:end-2));
        % End points by forward or backward difference:
        dydx(1) = (y(2) - y(1)) ./ (x(2) - x(1));
        dydx(end) = (y(end) - y(end-1)) ./ (x(end) - x(end-1));
    elseif strcmp(method, 'forward')
        % Skip the last point which doesn't have a defined forward difference.
        dydx(1:end-1) = (y(2:end) - y(1:end-1)) ./ (x(2:end) - x(1:end-1));
        % Last point by backward difference, but it's the same as the previous
        % point by forward difference, so just copy it.
        dydx(end) = dydx(end-1);
    else
        error("Sorry, only central and forward difference is supported at this time.");
    end
end
