% Method to remove the root HTML directory   
function removeHTMLDir(obj)
    if (exist(obj.htmlDir, 'dir'))
        rmpath(obj.htmlDir);
    end
    system(sprintf('rm -r -f %s', obj.htmlDir));
end
        