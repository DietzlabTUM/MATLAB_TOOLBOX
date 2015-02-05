function [ p_fit, A_sub, B_sub] = calculate_ration_of_areas( A, B_in, varargin )
% Calculates the ration of subimage A to subimage B based on a scattered
% plot and a linear fit. 
%  - This method should be more robust to errors in bakcground corretion.
%  - It also overlays the two images to reduce shift-errores
% 
% Input:    A = channel 1 of image (or subimage)
%           B_in = channel 2 of image (or subimage)
%           display_plot (optional) 
% Example:  calculateRation(A, B)
%           calculateRation(A, B, 'display', 'on')

    % parse input variables
    p = inputParser;
    default_display = 'off';
    expected_display = {'on', 'off'};
    
    addRequired(p,'A',@isnumeric);
    addRequired(p,'B_in',@isnumeric);
    addParameter(p,'display', default_display,  @(x) any(validatestring(x,expected_display))); % check display is 'on' or 'off'

    parse(p, A, B_in, varargin{:});
    display_bool = strcmp(p.Results.display, 'on');

    % Find best overlay of images
    [cc, shift, B] = xcorr2_bounded(A, B_in, 5, 0); % find the best overlay of images with +- 5 pixel
    
    % only use subimage for further analysis (because it might have been
    % shifted)
    dy = shift(2);
    dx = shift(1);
    
    B_sub = B( max(1,1+dy):min(size(B,1), size(B,1)+dy), max(1,1+dx):min(size(B,2), size(B,2)+dx) );
    A_sub = A( max(1,1+dy):min(size(B,1), size(B,1)+dy), max(1,1+dx):min(size(B,2), size(B,2)+dx) );

       
    % Fit a line to the scattered points ot obtain slope and offset
    p_fit = polyfit(B_sub(:), A_sub(:), 1);
    
    % scatter plot of data (if desired
   if display_bool
       figure();
        x = [min([B_sub(:); B_in(:)]) max([B_sub(:); B_in(:)])];
        p_raw = polyfit(B_in(:), A(:), 1);
        plot(B_in(:), A(:), 'b.', x, p_raw(1)*x+p_raw(2), 'b', B_sub(:), A_sub(:), 'r.', x, p_fit(1)*x+p_fit(2), 'r')   
        legend({'Data raw', 'Fit to raw data', 'Shifted data', 'Fit to shifted data'})
        xlabel('Channel B'), ylabel('Channel A')
   end
end

