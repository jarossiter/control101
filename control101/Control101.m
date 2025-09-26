function Control101()

browseFile =  "browseInfo.html";
control101_master    %opens the app with softlinks

if  matlab.internal.environment.context.isMATLABOnline
    htmlviewer(browseFile);
else
    if isMATLABReleaseOlderThan('R2024b')
        doc ("Control101 Toolbox")
    else
        open(browseFile)
    end
end