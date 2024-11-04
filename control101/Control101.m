function Control101()

browseFile =  "browseInfo.html";

if  matlab.internal.environment.context.isMATLABOnline
    htmlviewer(browseFile);
else
    if isMATLABReleaseOlderThan('R2024b')
        doc ("Control101 Toolbox")
    else
        open(browseFile)
    end
end