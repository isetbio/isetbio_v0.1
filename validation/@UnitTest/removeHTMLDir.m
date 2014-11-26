% Method to remove the root HTML directory   
function removeHTMLDir(obj)
    
    if (exist(obj.htmlDir, 'dir'))
        fprintf('\nRemoving HTML directory ''%s''.\n', obj.htmlDir); 
        rmpath(obj.htmlDir);
        system(sprintf('rm -r -f %s', obj.htmlDir));
    end
end
        