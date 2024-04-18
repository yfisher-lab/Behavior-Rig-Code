function dataOut = downsampleBallData(dataIn, oldRate, newRate)

q = oldRate/newRate;

dataOut = resample(dataIn, 1, q);

end