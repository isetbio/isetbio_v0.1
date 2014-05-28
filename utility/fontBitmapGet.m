function bitmap = fontBitmapGet(font)
%% Read a bitmap from a stored file (data/fonts) or create one on the screne
%
%  bitmap = fontBitmapGet(font)
%
% This function helps get the font bitmap from the system. The basic idea
% of this function is to draw a letter on a canvas in the background and
% read back the frame
%
%  Inputs:
%   font - font data structure (fontCreate)
%
%  Outputs:
%    bitMap     - bitmap image
%
% Example:
%    font = fontCreate; bitmap = fontBitmapGet(font);
%
% (HJ) May, 2014

%% Init
if notDefined('font'), error('font required'); end

try
    % See if we have a font stored for this variable
    name = fontGet(font,'name');
    fName = sprintf('%s.mat',name);
    fName = fullfile(isetRootPath,'data','fonts',fName);
    foo = load(fName);
    bitmap = foo.bmSrc.dataIndex;
    b = zeros(size(bitmap,1),size(bitmap,2)/3,3);
    for ii=1:3
        b(:,:,ii) = bitmap(:,ii:3:end);
    end
    
    font = fontSet(font,'bitmap',b);
    return;
    
catch
    
    % No font file found.  Create an example on the screen
    character = fontGet(font,'character');
    fontSz = fontGet(font,'size');
    family = fontGet(font,'family');
    
    %% Set up canvas
    hFig = figure('Position', [50 50 150+fontSz 150+fontSz],...
        'Units', 'pixels', ...
        'Color', [1 1 1], ...
        'Visible', 'off');
    axes('Position',[0 0 1 1],'Units','Normalized');
    axis off;
    
    %% Draw character and capture the frame
    % Place each character in the middle of the figure
    texthandle = text(0.5,1,character, ...
        'Units', 'Normalized', ...
        'FontName', family, ...
        'FontUnits', 'pixels', ...
        'FontSize', fontSz, ...
        'HorizontalAlignment', 'Center', ...
        'VerticalAlignment', 'Top', ...
        'Interpreter', 'None', ...
        'Color',[0 0 0]);
    drawnow;
    
    % Take a snapshot
    try
        bitMap = hardcopy(hFig, '-dzbuffer', '-r0');
    catch
        bitMap = getframe(hFig);
        bitMap = bitMap.cdata;
    end
    
    delete(texthandle);
    
    % Crop height as appropriate
    bwBitMap = min(bitMap, [], 3);
    bitMap = bitMap(find(min(bwBitMap, [], 2) < 255, 1, 'first') : ...
        find(min(bwBitMap, [], 2) < 255, 1, 'last'), :, :);
    
    % Crop width to remove all white space
    bitMap = bitMap(:, find(min(bwBitMap, [], 1) < 255, 1, 'first') : ...
        find(min(bwBitMap, [], 1) < 255, 1, 'last'), :);
    
    % Invert and store in binary format
    bitmap = zeros(size(bitMap));
    bitmap(bitMap > 127) = 1;
    
    close(hFig);
    
end

end