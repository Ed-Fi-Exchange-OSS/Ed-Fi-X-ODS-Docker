FROM microsoft/mssql-server-windows-express
SHELL ["powershell","-command"]
RUN mkdir c:/sql-init
COPY . c:/sql-init
COPY start-server.ps1 /
RUN sqlcmd -i c:\\sql-init\\SetDefaultSqlFolders.sql -o c:\\sql-init\\DefaultSqlFoldersOutput.txt
WORKDIR /
ENV sa_password OdsInstallPassword123
ENV attach_dbs []
ENV ACCEPT_EULA Y
ENV sa_password_path C:/ProgramData/Docker/secrets/sa-password
ENV InstallType Sandbox
HEALTHCHECK --interval=2m --timeout=15s --start-period=10m --retries=5 CMD [ "sqlcmd", "-Q", "select 1" ]    
CMD ./start-server.ps1
