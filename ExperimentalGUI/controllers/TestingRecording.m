FzRec = 48000;
recObj = audiorecorder(FzRec, 16, 1, 0); %Only need to change the last number, the input IDs
[y,Fs] = audioread('AudioInstructionsMP3/standAndB.mp3');
tic
record(recObj);
toc
sound(y,Fs);
% pause(3);
% record(recObj);
pause(10);
sound(y,Fs);
pause(3);
tic
stop(recObj);
toc
audioData = getaudiodata(recObj);
audiowrite('recordingTest07162021-4.wav',audioData,FzRec)
audioinfo('recordingTest07162021-4.wav')

%%
[y2,Fs2] = audioread('recordingTest07162021-4.wav');
sound(y2,Fs2);
% sound(y,Fs);

%%
afr = dsp.AudioFileReader('AudioInstructionsMP3/standAndB.mp3');
adw = audioDeviceWriter('SampleRate', afr.SampleRate);
fs = afr.SampleRate;
fileWriter = dsp.AudioFileWriter('testingRecording-3.wav', ...
    'SampleRate',fs);
aPR = audioPlayerRecorder(fs);

t0 = clock;
temp = []
while etime(clock, t0) < 5
    audio = afr();
    adw(audio);
    [audioRecorded,nUnderruns,nOverruns] = aPR(audio);
    temp = [temp; audioRecorded]
    fileWriter(audioRecorded)
end
release(afr); 
release(adw);
release(aPR); 
release(fileWriter); 

%%
afr2 = dsp.AudioFileReader('testingRecording-1.wav');
adw2 = audioDeviceWriter('SampleRate', afr2.SampleRate);
while ~isDone(afr2)
    audio = afr2();
    adw2(audio);
end
release(afr2); 
release(adw2);
[y,Fs] = audioread('testingRecording-3.wav');
sound(y,Fs)
audioinfo('testingRecording-3.wav')

%%



while ~isDone(fileReader)
    audioToPlay = fileReader();
    
    [audioRecorded,nUnderruns,nOverruns] = aPR(audioToPlay);
    
    fileWriter(audioRecorded)
    
    if nUnderruns > 0
        fprintf('Audio player queue was underrun by %d samples.\n',nUnderruns);
    end
    if nOverruns > 0
        fprintf('Audio recorder queue was overrun by %d samples.\n',nOverruns);
    end
end