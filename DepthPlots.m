function DepthPlots(z, maxZ, N)
    % Depth diagnostic plots, moved here so the DepthArray function isn't
    % cluttered.  The four values below turn them on and off as needed.
    final = 0;
    animated = 0;
    particle = 0;
    histogram = 0;
 
    % Single figure of the final vs. original positions
    if final
        figure()
        scatter(z(:,1), z(:,end))
        xlabel('Original depth (m)');
        ylabel('Final depth (m)');
        title('Particle Location');
    end
    
    % Make an animated gif of the first hour.
    % Code is from MathWorks Support Team, here:
    % https://www.mathworks.com/matlabcentral/answers/94495-how-can-i-create-animated-gif-images-in-matlab
    if animated
        h = figure;
        axis tight manual % this ensures that getframe() returns a consistent size
        filename = 'testAnimated.gif';
        for n = 1:60
            % Draw plot for y = x.^n
            x = z(:, 1);
            y = z(:, n);
            scatter(x,y)
            xlabel('Original depth (m)', 'FontSize', 20);
            ylabel('Final depth (m)', 'FontSize', 20);
            drawnow
            % Capture the plot as an image
            frame = getframe(h);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            % Write to the GIF File
            if n == 1
                imwrite(imind,cm,filename,'gif', 'Loopcount',inf, 'DelayTime',5);
            else
                imwrite(imind,cm,filename,'gif','WriteMode','append', 'DelayTime',0.5);
            end
        end
    end
    
    if particle
        % Just for presentation purposes, draw the history of a single particle for
        % a few time steps.
        scrz=get(0,'ScreenSize');
        h=figure('Position', [scrz(3)/2, 1, scrz(3)/5, scrz(4)]);
        axis tight manual % this ensures that getframe() returns a consistent size
        filename = 'testOnePoint.gif';
        for n = 1:10
            % Draw plot for y = x.^n
            x = z(100, 1);
            y = z(100, n);
            scatter(x,y)
            disp(y)
            % Label points
            t = sprintf("t = %d", n);
            text(x+0.1, y+0.1, t, 'FontSize', 20)
            xlabel('Original depth (m)', 'FontSize', 20);
            ylabel('Current depth (m)', 'FontSize', 20);
            xlim([11, 13]);
            ylim([8, 14]);

            drawnow
            % Capture the plot as an image
            frame = getframe(h);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            % Write to the GIF File
            if n == 1
                imwrite(imind,cm,filename,'gif', 'Loopcount',inf, 'DelayTime',5);
            else
                imwrite(imind,cm,filename,'gif','WriteMode','append', 'DelayTime',2);
            end
        end
    end
    
    if histogram    
        % A figure to show whether particles are biased up or down.  They start
        % evenly distributed, so the final distribution should also be constant.
        figure('Position', [scrz(3)/5, 1, scrz(3)/5, scrz(4)]);
        bins = histcounts(z(:, end), maxZ);
        barh(bins, 1);
        hold on;
        plot([N/maxZ, N/maxZ], [0, maxZ]);
        set(gca,'YDir','reverse','XAxisLocation','Top')
        xlabel('Particles per meter', 'Fontsize', 20);
        ylabel('Depth(m)', 'Fontsize', 20);
    end
    
end
    