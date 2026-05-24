ARIDataset = sofaread("ReferenceHRTF.sofa");
ARIDataset.SourcePositionType

% Create a sphere with a distribution of points
nPoints = 24;   % number of points to pick
rng(0);         % seed random number generator
sphereAZ = 360*rand(1,nPoints);
sphereEL = rad2deg(acos(2*rand(1,nPoints)-1))-90;
pickedSphere = [sphereAZ' sphereEL'];

filters = interpolateHRTF(ARIDataset,pickedSphere,Algorithm="vbap");

order = 3;
dmtrx = ambisonicDecoderMatrix(order, pickedSphere,Normalization="sn3d",ChannelOrder="acn");

filters = permute(filters,[2 1 3]);
filters = reshape(filters,size(filters,1)*size(filters,2),[]);
filt = dsp.MIMOFIRFilter(filters, SumFilteredOutputs=true);

desiredFs = 48e3;
[audio,fs] = audioread("prueba.wav");
audio = resample(audio,desiredFs,fs);
audiowrite("prueba_48.wav",audio,desiredFs);

samplesPerFrame = 2048;
fileReader = dsp.AudioFileReader("prueba_48.wav", ...
                    SamplesPerFrame=samplesPerFrame);
deviceWriter = audioDeviceWriter(SampleRate=desiredFs);
audioFiltered = zeros(samplesPerFrame,size(filters,1),2);

while ~isDone(fileReader)
    audioAmbi = fileReader();
    audioDecoded = audioAmbi*dmtrx;
    audioFiltered = 10*filt(audioDecoded);
    numUnderrun = deviceWriter(audioFiltered); 
end

% Release resources
release(fileReader)
release(deviceWriter)