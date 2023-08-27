myDir = '/home/lj/git/Classes/EN.520.214/Project2/wav files'; %gets directory
myFiles = dir(fullfile(myDir,'*.wav')); %gets all wav files in struct
total = length(myFiles);
accuracies = [];
reverb = 0:0.1:5
for reverb = 0:0.1:5
    correct = 0;
    for k = 1:length(myFiles)
      baseFileName = myFiles(k).name;
      fullFileName = fullfile(myDir, baseFileName);
      [y, fs] = audioread(fullFileName);
      m = max(y);
      y = y/m;
      [y, h, FS] = addreverb(y,fs,reverb);
      if k==1
        sound(y, FS)
      end
      right_answer = split(baseFileName, '_'); right_answer = string(right_answer(2));
      right_answer = split(right_answer, '.'); 
      right_answer = string(right_answer(1))
      [seq, fs] = DTMFsequenceREVERB(y, fs);
      correct = correct + (right_answer == seq);
      if right_answer ~= seq
          disp(strcat(string(seq), " mistaken with ", string(right_answer)));
      end
    end
    accuracy = 100*correct/total;
    disp(strcat(string(accuracy), "%"))
    accuracies = [accuracies accuracy];
end
accuracies = [noises;accuracies];