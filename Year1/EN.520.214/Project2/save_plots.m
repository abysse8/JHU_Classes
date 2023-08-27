keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#']
for iii= 1:length(keys)
    [y, fs] = DTMFencode(keys(iii));
    pl = plot(1/fs:1/fs:0.2, y);
    if keys(iii) == '*'
        saveas(pl, strcat('./plots/Plot','S'))
        continue
    end
    saveas(pl, strcat('./plots/Plot',keys(iii)))
end