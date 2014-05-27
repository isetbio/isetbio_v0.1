function [bitmaps, fontInfo] = fontBitmapGet(fontName, fontSz, character)
%% function fontBitmapGet([fontName], [size], [character], [padding])
%
%    This function helps get the font bitmap from the system. The basic
%    idea of this function is to draw a letter on a canvas in the
%    background and read back the frame
%
%  Inputs:
%    fontName   - string, name of the font, could use 'listfont' to see all
%                 font typs supported by the system
%    fontSz     - font size, default is 16 points
%    characters - string of characters to be processed
%
%  Outputs:
%    bitMap     - bitmap image
%    fontInfo   - font information structure, contains name and size of the
%                 bitmap generated
%
%  Notes:
%    The idea of this function is adopted from Daniel Warren, University of
%    Oxford.
%    This function now uses an undocumented function 'hardcopy' which could
%    help get an invisible frame
%
% (HJ) May, 2014

%% Init
if notDefined('fontName'), fontName = 'Courier New'; end
if notDefined('size'), fontSz = 16; end
if notDefined('character'), character = 'g'; end

fontSz = round(fontSz);
bitmaps = cell(1, length(character));

%% Set up canvas
hFig = figure('Position', [50 50 150+fontSz 150+fontSz],...
                   'Units', 'pixels', ...
                   'Color', [1 1 1], ...
                   'Visible', 'off');
axes('Position',[0 0 1 1],'Units','Normalized');
axis off;

%% Draw character and capture the frame
for i = 1:length(character)
    % Place each character in the middle of the figure
    texthandle = text(0.5,1,character(i), ...
                    'Units', 'Normalized', ...
                    'FontName', fontName, ...
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
    bitmaps{i} = zeros(size(bitMap));
    bitmaps{i}(bitMap < 127) = 1;
end

close(hFig);

fontInfo.Name = fontName;
fontInfo.Size = fontSz;
fontInfo.Characters = character;

if length(bitmaps) == 1, bitmaps = bitmaps{1}; end

%% END
end