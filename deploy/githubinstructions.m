%%% Do manually
!cd C:\Users\Anthony Rossiter\Documents\matlab project\control101


!git status 
!git add .
!git pull 
!git commit -m "Added two tank model "
!git push .
!git push


% copy from github the whole folder
% git clone https://github.com/jarossiter/control101.git

%%% Because file size too large, remove the mltbx to see if that works
>> !git rm -r --cached Control101.mltbx

 
%% Trying t oset up LFS
!git reset --soft HEAD~1
!git lfs track "*.mltbx"
!git add .gitattributes
!git add -f deploy/Control101.mltbx
!git commit -m "Add MATLAB toolbox using Git LFS"
!git push origin main

scoop install git-filter-repo
git filter-repo --invert-paths --path deploy/Control101.mltbx
git remote add origin https://github.com
git push origin main --force

bash# 1. Delete the hidden Git history folder completely
!git rm -rf .git
!git init
!git remote add origin https://github.com
!git lfs track "*.mltbx"
!git add .
!git commit -m "Fresh start without large files"
!git push origin main --force

Running the above line does the following:

Runs git rm with options (rm == remove) :
-r: recurse into directories (remove matching files in subfolders).
--cached: remove the files from the Git index (stop tracking them) but do not delete them from your working directory. ß  Make sure you use --cached otherwise it will delete the files entirely!
*.mltbx matches files with .mltbx extension (you might want to be specific and say Control101.mltbx)
 

Alternatively, you could right click on the .mltbx file -> source control -> remove from source control

remote: error: Trace: 40d36cf6d496b18ef7301e5f4410f752ebbfb7bf522d433a61e5d5aec5ad87af        
remote: error: See https://gh.io/lfs for more information.        
remote: error: File deploy/Control101.mltbx is 108.51 MB; this exceeds GitHub's file size limit of 100.00 MB        
remote: error: GH001: Large files detected. You may want to try Git Large 
File Storage - https://git-lfs.github.com.        
To https://github.com/jarossiter/control101.git
 ! [remote rejected] main -> main (pre-receive hook declined)
error: failed to push some refs to 'https://github.com/jarossiter/control101.git'