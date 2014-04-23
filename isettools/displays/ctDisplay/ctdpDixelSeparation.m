function vd = ctdpDixelSeparation(vd,newSeparation)
% Change the separation (no psf scaling) between pixels
%
%    ctdpDixelSeparation(vd,newSeparation)
%
% Example:
%   ctdpDixelSeparation(vd)
%

if ieNotDefined('vd'), vd = displayGet(ctGetObject('display'),'vDisplay'); end

% Current dixel size
dixel   = vDisplayGet(vd,'dixel');
curSize = vDisplayGet(vd,'dixelSize');  % In mm by default

if ieNotDefined('newSeparation')
    done = 0;
    while ~done
        if exist('iFig','var'), close(iFig); end

        newSeparation = ieReadNumber('New pixel separation (mm)',curSize,' %.2f');
        if isempty(newSeparation), vd = []; return; end

        % We can change the separation between the dixels without scaling the psf.
        % (The default is to scale it).
        dixel = dixelSet(dixel,'pixelSizeNoPsfScaling',newSeparation);
        vd    = vDisplaySet(vd,'dixel',dixel);

        % Default is a little white patch image
        pixelImg = vdisplayCompute(vd);
        iFig     = imtool(pixelImg);
        done     = ieReadBoolean('Done?');
        if isempty(done)
            disp('User canceled');
            if exist('iFig','var')
                close(iFig); 
                vd = [];   % Indicates user canceled on return
            end
            return;
        end
    end
else
    % Should this be vDisplaySet?
    dixel = dixelSet(dixel,'pixelSizeNoPsfScaling',newSeparation);
    vd    = vDisplaySet(vd,'dixel',dixel);
end

if exist('iFig','var'), close(iFig); end

return
