function dist = Kz_distribution(Kz, z, doPlot)
% Create a diffusivity distribution based on inputs.

    if isequal(size(Kz), [1,1])
        dist = ones(length(z), 1)* Kz;
    else
        % it's an array of depths and values
        %dist_linear = interp1(Kz(:, 1), Kz(:, 2), z, 'linear', 'extrap');
        dist_makima = interp1(Kz(:, 1), Kz(:, 2), z, 'makima', 'extrap');
        if doPlot
            scrz=get(0,'ScreenSize');
            figure('Position', [scrz(3)*.8, 1, scrz(3)/5 - 10, scrz(4)]);
            semilogx(Kz(:, 2), Kz(:, 1), 'ko', 'DisplayName', 'inputs');
            hold on;
            %semilogx(dist_linear, z, '-k', 'DisplayName', 'linear');
            semilogx(dist_makima, z, '-b', 'DisplayName', 'Makima interpolation');

            set(gca,'YDir','reverse','XAxisLocation','Top')
            xlabel('Kz [m^2/s]', 'FontSize', 20);
            ylabel('Depth [m]', 'FontSize', 20);
            legend({}, 'Location', 'best', 'FontSize', 20)
            drawnow()
        end
        dist = dist_makima;
    end

end
