function LEDCommands = setUpLEDCommands(LEDParams, dq, highVoltage) 
%%

LEDCommands = [zeros(LEDParams.baselineTime * dq.Rate, 1);...
                highVoltage * ones(LEDParams.LEDonTime * dq.Rate, 1);...
                zeros(LEDParams.afterTime * dq.Rate, 1)]; % LED on/off sequence matrix
LEDCommands = repmat(LEDCommands,[LEDParams.REP_NUM,1]);

end