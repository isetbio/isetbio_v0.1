function emitMessage(obj, message, importanceLevel)

    if (importanceLevel >= obj.messageEmissionStrategy)
        fprintf('%s', message);
    end
    
end

