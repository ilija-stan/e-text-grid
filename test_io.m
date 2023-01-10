function [txt,interv] = test_io(textgrid_file)
#clear all;

#dir = 'Freddie';
#files = readdir(dir);

# g=glob("Freddie/A/*.wav")
fid = fopen(textgrid_file);
phones_found = 0;
hr ='';
num_segments=0;
intervals = [];
iidx=1;
amin=0;
amax=0;
while( (txtc = fgets(fid)) != -1  )
  x=strtrim(txtc);
  if length(x) > 0
    if phones_found == 0
      phones_found = get_entry(x);
    endif
    if phones_found > 0
      k = get_intervals_size(x);
      if !isempty(k)
        s=k(2);
        intervals=zeros(str2double(s),2);
      endif
      k = get_min(x);
      if !isempty(k)
        s=k(2);
        amin=str2double(s);
      endif
      k = get_max(x);
      if !isempty(k)
        s=k(2);
        amax=str2double(s);
      endif
      k = get_text(x);
      if !isempty(k)
        s=char(k(2));
        hr=strcat(hr,s);
        num_segments +=1;
        intervals(num_segments,1)=amin;
        intervals(num_segments,2)=amax;
      endif
      
      
    endif
  endif
  
endwhile
fclose (fid); 
txt=hr;
interv=intervals;


function [flag]=get_entry(x)
ge = 0;
idx = strfind (x, "name");
    if !isempty(idx)
       idx = strfind (x, "phones"); 
       if !isempty(idx)
          ge=1;
          #idx
        endif
     endif
flag=ge;

function [flag]=get_min(x)
ge = [];
idx = strfind (x, "xmin");
    if !isempty(idx)
       [cstr] = strsplit(x, "=");
       ge=cstr;     
     endif
flag=ge;

function [flag]=get_max(x)
ge = [];
idx = strfind (x, "xmax");
    if !isempty(idx)
       [cstr] = strsplit(x, "=");
       ge=cstr;     
     endif
flag=ge;

function [flag]=get_text(x)
ge = [];
idx = strfind (x, "text");
    if !isempty(idx)
       [cstr] = strsplit(x, "=");
       ge=cstr;     
     endif
flag=ge;

function [flag]=get_intervals_size(x)
ge = [];
idx = strfind (x, "size");
    if !isempty(idx)
       [cstr] = strsplit(x, "=");
       ge=cstr;     
     endif
flag=ge;




      #[cstr] = strsplit(x, "=");
      #strj = strjoin(cstr);
        #strj = strtrim(strjoin(cstr))
        #cstr(1,2)
          #stri = strjoin(cstr(1,2));
          #stri
          #strcmp(strtrim(stri),"phones")


