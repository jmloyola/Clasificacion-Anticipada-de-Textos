function [str, fullPath, file, directory]= file2str(file)
% file2str   Reads a text file into a cell array of strings 
% 
% Input:
% * file ... name of the file, i.e. file = 'test.txt'
%
% Output:
% * str ... cell array of strings
% * fullPath ... path + filename + extension
% * file ... filename
% * directory ... path to file
%
% Example
% Write cell array to textfile.
%+ str2file( {'aa','bbbb','','cc'}, 'test.txt' );
% Read the text file with
%+ t = file2str( 'test.txt' )
%
% See also: str2file
%
%% Signature
% Author: W.Garn
% E-Mail: wgarn@yahoo.com
% Date: 2005/12/01 20:00:00 
% 
% Copyright 2005 W.Garn
%
go = 1;
str=[];fullPath=[]; directory=[];
[fullPath, directory] = locateFile(file);
if isempty(fullPath)
    %disp('Can not find file.');
    [file, directory] = uigetfile('*.m','Please select file.');
    if ~ischar(file), go=0; end
    fullPath = [directory file];
end
if go
    % Read file into cell array of strings
    fid = fopen(fullPath);
    k=1;
    while 1
        str{k} = fgetl(fid);
        if ~ischar(str{k}),   break,   end
        k=k+1;
    end
    fclose(fid);
    if k>1, str(k)=[]; end % delete last entry.
end %of go


%-------------------------------------------------------------------
function [fullPathToFile, directory] = locateFile(file)
% LOCATEFILE Resolve a filename to an absolute location.
%   LOCATEFILE(FILE) returns the absolute path to FILE.  If FILE cannot be
%   found, it returns an empty string.

% original:Matthew J. Simoneau, November 2003
% Modified by W.Garn, Nov. 2005

% Checking that the length is exactly one in the first two checks automatically
% excludes directories, since directory listings always include '.' and '..'.

if (length(dir(fullfile(pwd,file))) == 1)
    % Relative path.
    fullPathToFile = fullfile(pwd,file);
elseif (length(dir(file)) == 1)
    % Absolute path.
    fullPathToFile = file;
elseif ~isempty(which(file))
    % An m-file on the path.
    fullPathToFile = which(file);
else
    fullPathToFile = '';
end
if isempty(fullPathToFile)
    directory='';
else
    s = max(allSlashes(fullPathToFile));
    if isempty(s)
        directory='';
    else
        directory = fullPathToFile(1:s);
    end
end

%-------------------------------------------------------------------
function pos = allSlashes(str)
% allSlashes  Returns the postion of all slashes ('/','\')
%
% Example
% Reads all directories in the current path.
%+ allSlashes( 'C:\MATLAB704\work\publish\wg_publish.m')
%
%% Signature
% Author: W.Garn
% E-Mail: wgarn@yahoo.com
% Date: 2005/12/01 20:00:00 
% 
% Copyright 2005 W.Garn
%
Ib = strfind(str,'\');
Is = strfind(str,'/');
pos = union(Ib,Is);

