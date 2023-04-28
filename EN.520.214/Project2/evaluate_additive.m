myDir = '/home/lj/git/Classes/EN.520.214/Project2/wav files'; %gets directory
myFiles = dir(fullfile(myDir,'*.wav')); %gets all wav files in struct
total = length(myFiles);
accuracies = [];
noises = 0:0.1:5;
for noise_factor = 0:0.1:5
    correct = 0;
    for k = 1:length(myFiles)
      baseFileName = myFiles(k).name;
      fullFileName = fullfile(myDir, baseFileName);
      [y, fs] = audioread(fullFileName);
      m = max(y);
      y = y/m;
      [noise, FS] = audioread("./Project_2_supplied_files/babble.wav");
      noise = noise/max(noise)*m; %normalize
      noise = noise(mod(0:length(y)-1,length(noise))+1); %expand to size
      noise = noise*noise_factor; %scale
      right_answer = split(baseFileName, '_'); right_answer = string(right_answer(2));
      right_answer = split(right_answer, '.'); right_answer = string(right_answer(1));
      [seq, fs] = DTMFsequencewithArray(y+noise, fs);
      plot(y+noise)
      correct = correct + (right_answer == seq);
      if right_answer ~= seq
          disp(fullFileName); disp(fs)
          %disp([seq right_answer]);
      end
    end
    accuracy = 100*correct/total;
    disp(strcat(string(accuracy), "%"))
    accuracies = [accuracies accuracy];
end
accuracies = [noises;accuracies];