% Method to remove the root HTML directory   
function removeHTMLDir(obj)
    
    if (exist(obj.htmlDir, 'dir'))
        if (obj.verbosity > 4)
            fprintf('\nRemoving HTML directory ''%s''.\n', obj.htmlDir); 
        end
        rmpath(obj.htmlDir);
        system(sprintf('rm -r -f %s', obj.htmlDir));
    end
end
        