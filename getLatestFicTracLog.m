function [log, ftFile] = getLatestFicTracLog()

cd C:/Users/fisherlab/Documents/GitHub/ficTrac/
ficTracFiles = dir('fictrac-*.dat');
ftFile = ficTracFiles(end).name;
log = readtable(ftFile);

end