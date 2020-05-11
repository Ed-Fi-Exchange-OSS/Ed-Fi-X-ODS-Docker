FROM microsoft/aspnet:4.7.1
SHELL ["powershell","-command"]
RUN md c:/aspnet-startup
RUN md c:/tools
COPY . c:/aspnet-startup
ENV RUN_ENV Release
ENV DO_NOT_REQUIRE_HTTPS FALSE
ENV LOG4NET_LOG_LEVEL WARN
ENTRYPOINT ["powershell.exe", "c:/aspnet-startup/Startup.ps1"]

