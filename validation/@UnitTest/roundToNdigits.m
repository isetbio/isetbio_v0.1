% Method to round numeric values to N decimal digits
function roundedValue = roundToNdigits(numericValue, decimalDigits)
    
    if (isempty(numericValue))
        roundedValue = numericValue;
        return;
    end
    
    truncator = 10^(-decimalDigits);
    roundedValue = sign(numericValue) .* round(abs(numericValue/truncator)) * truncator;
end

%
% FOLLOWING IS JUST FOR TESTING
%
function testRoundToNdigits

    aNumber = 1.289736487293648972363259784 * ones(2, 2);
    decimalDigits = UnitTest.decimalDigitNumRoundingForHashComputation;
    
    format long
    N1 = round(aNumber, decimalDigits)
    N2 = myRound(aNumber, decimalDigits)
    N3 = myRoundOLD(aNumber, decimalDigits)
    
    
    diff = abs(N1 - N2);
    any(N1(:) ~= N2(:))
    any(N1(:) ~= N3(:))
end

function roundedN = myRound(N, decimalDigits)

truncator = 10^(-decimalDigits);
roundedN  = round(N/truncator ) * truncator;

end

function roundedN = myRoundOLD(N, decimalDigits)

    precision = sprintf(' %%.%df ', decimalDigits);
    
    nDimensions = ndims(N);
    if (prod(nDimensions) == 1)
        roundedN  = str2double(num2str(N, precision));
    else
        roundedN  = str2double(cellstr(num2str(N(:), precision)));
        numel(roundedN)
        roundedN = reshape(roundedN, size(N));
    end
end


