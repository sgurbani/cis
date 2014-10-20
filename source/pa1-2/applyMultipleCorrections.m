function corrected = applyMultipleCorrections(coeff, data, frames)
%ceoff should be a matrix of Bernstein coefficiants of the polynomial
%data is the distorted data (from the EM tracker).

num_readings = length(data) / frames;

for f=1:frames
    startIndex = (f-1)*num_readings + 1;
    endIndex = startIndex + num_readings - 1;
    data(startIndex:endIndex) = applyCorrection3(coeff, data(startIndex:endIndex));
end

corrected = data;

end