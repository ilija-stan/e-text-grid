function edit_textgrid()

textgrid_input_dir = 'C:\Develop\fs_oliver\MFA_croatian_mfa';

wavs_input_dir = 'C:\Develop\fs_oliver\MFA_in';

intervals_out_dir = 'grid_out';

grids = glob(sprintf('%s\\*.TextGrid',textgrid_input_dir));

grid_input_file='';
 
[sel, ok] = listdlg ("ListString", grids,
                     "SelectionMode", "Multiple","ListSize",[500,300]);
if (ok == 1)
    for i = 1:numel (sel)
      grid_input_file=sprintf ("%s", grids{sel(i)});
    endfor
else
    disp ("You cancelled.");
endif 

clear grids;

utt_id = char(strsplit(grid_input_file,'\\')(end));
utt_id = char(strsplit(utt_id,'.')(1));

array_out_file = sprintf("%s\\%s.txt",intervals_out_dir,utt_id);

mode = 0;

if exist(array_out_file)
  btn = questdlg ("Do you want to owerwrite\n \tor to modify file?", "File Exist", ...
                "Owerwrite", "Modify","Cancel", "Cancel");
  if (strcmp (btn, "Cancel"))
      return
  endif 
  if (strcmp (btn, "Modify"))
      mode=1;
  endif 
endif

wav_file = sprintf("%s\\%s.wav",wavs_input_dir,utt_id);

if !exist(wav_file)
  disp(wav_file);
  disp("WAW file not exist -> exiting"); 
      return 
endif


[x_input, fs] = audioread(wav_file);

[txt,intervals]=test_io(grid_input_file);

if mode
    [txtm,intervals]=read_grid_array(array_out_file);   
    mask = txtm;
else
   txta = ones(1,size(intervals)(1));
   [gg]=strsplit(txt," ");
   for i=1:size(intervals)(1)
     if char(gg(1,i+1))(1) == '"' && char(gg(1,i+1))(2) == '"'
       txta(i) = 0;
     endif
   endfor
   mask = txta;
endif

txt=strsplit(txt," ");

num_segments=length(intervals);

hold on;
plot(x_input);
[limes]=axis();
draw_phoneme_boundry(intervals,mask,num_segments,fs,limes,txt);
hold off;

######################
% q - quit and close
% p - play segment at cursor position
% l - move segment bound from left to cursor position
% r - move segment bound from right to cursor position
# s - save array
% space - play all segments
% b - stop executing
#return

button = 0;
#player = audioplayer(x_input,fs);
#pause(player);
while button != 113
[x,y,button] = ginput(1);
  if button == 113   % q quit
    close();
    continue;
  endif
  if button == 98    % b break
    break;  
  endif
  if button == 114   % r move from right
    i = find_i(intervals,x,fs);
    if i > num_segments
      intervals(num_segments,2) = length(x_input);
    endif
    intervals(i,2) = x/fs;
    if i < num_segments
      intervals(i+1,1) = x/fs;
    endif
    #hold off
    plot(x_input);
    draw_phoneme_boundry(intervals,mask,num_segments,fs,limes,txt);
  endif
  if button == 108   % l move from left
    i = find_i(intervals,x,fs);   
    if x > length(x_input)
      intervals(num_segments,2) = length(x_input)/fs;
    elseif i == 0
      intervals(num_segments,2) = x/fs;
    else
      intervals(i,1) = x/fs;
    endif
    if i > 1
      intervals(i-1,2) = x/fs;
    endif
    
    #hold off
    plot(x_input);
    draw_phoneme_boundry(intervals,mask,num_segments,fs,limes,txt);
  endif
  if button == 112   % p play
    i = find_i(intervals,x,fs);
    if i > 0
      if i == 1
        seg = [1,round(intervals(i,2)*fs)];
       else
          seg = [round(intervals(i,1)*fs),round(intervals(i,2)*fs)];
       endif
       try
          player = audioplayer(x_input,fs);
          play(player,seg);
       catch
          stop(player);
          continue
       end_try_catch;
      
    endif
  endif
  if button == 32    % space play all
    seg = [1,round(intervals(num_segments,2)*fs)];
    player = audioplayer(x_input,fs);
    play(player,seg);
  endif
  if button == 115   % s save to file
    save_array(intervals,mask,array_out_file);
  endif
   
endwhile

function [idx]=find_i(interv,x,fs)
  k=0;
  for i = 1:size(interv)(1)
    s=interv(i,1)*fs;
    e=interv(i,2)*fs;
    if x > s && x < e
      k=i;
      break  
    endif
  endfor
  idx=k;

function [txto,intervali]=read_grid_array(grid_input_file);
    M=dlmread(grid_input_file);
    l=size(M(1));
    intervali=zeros(l,2);
    intervali = M(:,1:2);    
    txto = M(:,3)'; 
    
function draw_phoneme_boundry(intervals,mask,num_segments,fs,lim,tx)
  for i=1:num_segments
    xx=[intervals(i,1)*fs,intervals(i,1)*fs];
    yy=[lim(3),lim(4)];
    line(xx,yy); # ,"color","g");  
    if mask(i) == 0
      xx=[intervals(i,1)*fs,intervals(i,2)*fs];
      line(xx,yy); # ,"color","g");
      SS = "SIL";  
    #if tx(1,i+1)(1) == '"' && tx(1,i+1)(2) == '"'
    elseif strcmp(tx(1,i+1),"\"spn\"") 
      SS="**";
    else
      SS=char(unicode2native(char(tx(1,i+1)), 'ISO-8859-1'))(2);
    endif
    text(xx(1),lim(4),SS);
  endfor
  line([intervals(num_segments,2)*fs,intervals(num_segments,2)*fs], ...
        [lim(3),lim(4)]);
        
function draw_space_boundry(intervals,num_segments,fs,lim)
  for i=1:num_segments
    xx=[intervals(i,1)*fs,intervals(i,1)*fs];
    yy=[lim(3),lim(4)];
    line(xx,yy); # ,"color","g");
  endfor    

function save_array(intervals,mask,file_name)
  M = zeros(size(intervals)(1),3);
  M(:,1) = intervals(:,1);
  M(:,2) = intervals(:,2);
  for i = 1:size(intervals)(1)
    M(i,3) = mask(i);
  endfor
  dlmwrite(file_name,M,"\t");
  

 