myDir = '/home/lj/git/Classes/EN.520.214/Project2/wav files'; %gets directory
myFiles = dir(fullfile(myDir,'*.wav')); %gets all wav files in struct
total = length(myFiles);
correct = 0;
for k = 1:1
  baseFileName = myFiles(k).name;
  fullFileName = fullfile(myDir, baseFileName);
  [y, fs] = audioread(fullFileName);
  m = max(y)
  noise, FS = audioread("./Project_2_supplied_files/babble.wav");
  noise = noise/max(noise)*m
  plot(y+noise)
  x = split(baseFileName, '_'); x = string(x(2));
  x = split(x, '.'); x = string(x(1));
  [seq, fs] = DTMFsequence(fullFileName);
  correct = correct + (x == seq);
  if x ~= seq
      disp(seq); disp(x);
      plot(y)
      if x == "#810#9*95"
        ;
      end
      disp(baseFileName);
  end
end
disp(strcat(string(100*correct/total), "%"))