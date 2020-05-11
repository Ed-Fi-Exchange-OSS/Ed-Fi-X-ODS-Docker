# Ed-Fi ODS Deploy for Docker

## Getting Started

* Make sure *Docker for Windows* is installed and running. Install instructions can be found at the [Official Guide](https://docs.docker.com/docker-for-windows/install/)

Test your installation by running `docker run -p 8080:80 microsoft/iis` and opening https://localhost:8080 in your web browser. If you are unable to connect, then you may need to install [KB4340917 hotfix](https://support.microsoft.com/en-us/help/4340917/windows-10-update-kb4340917), which resolved a networking problem that prevented Windows containers from using network address translation (NAT).

To build the Docker images:

```powershell
PS> .\build.ps1
```

This will create `edfi-base:latest`, `edfi-web-api:latest`, `edfi-swagger-ui:latest`, `edfi-restapi-database` and `edfi-admin-web:latest` Docker images. To rebuild the images using newer Nuget Packages, run the build script again. It will download the latest available nuget packages and update the images. To build specific version, supply a `-version x.y.z` parameter, e.g.

```powershell
PS> .\build.ps1 -Version 2.4.0
```

## Creating and Running Individual Containers

To create and run individual containers:

* Enter `.\run\{Application-Name}` folder. Example: `cd .\run\EdFi.Ods.Admin.Web`
* Copy all `.example` files to a new folder.

Example:

```powershell
PS> mkdir c:\containers\Admin-Web
PS> copy *.example C:\containers\Admin-Web
```

Container name is derived from the folder name, so make sure it's readable. In this case, the container name will be similar to `AdminWeb1`. If you want to run multiple containers for the same image, create individual folders for each container and adjust individual settings accordingly.

* Remove .example extension from all files on the destination folder.

Example:

```powershell
PS> mv .env.example .env
PS> mv docker-compose.yml.example docker-compose.yml
PS> mv EdFi.Ods.Admin.Web.env.example EdFi.Ods.Admin.Web.env
```

* Edit relevant settings and connections strings in `.env` file and the specific application .env file. Example: `EdFi.Ods.Admin.Web.env`. Example files are mostly pre-configured, so commented settings should be left commented unless they need to be modified.
* Edit relevant settings in `docker-compose.yml`. Defaults should work out of the box, but external ports can be modified if necessary.
* Run Docker Compose to start the container.

```powershell
PS> docker-compose up -d
```

Application should be up and running in specified port. Example: `https://localhost:8100`

Within each folder there are additional examples using docker CLI to serve as a starting point for running the containers using customized and advanced options.

### Running the Containers Using Docker CLI

An alternative way for running the containers is creating an instance using Docker cli. For each application, there's an example bat file. Go to `./run/{ApplicationName}` and open `create-container.ps1`. Reference [Docker Documentation](https://docs.docker.com/docker-for-windows/) for additional options.

## Orchestrating Containers Using Compose

When running multiple containers on the same Docker environment (local or cloud), `docker-compose` can be used to handle the networking aspects automatically, avoiding the need to manually configure hostnames, ports and other shared settings.

In the examples folder, there are pre-configured environments for the following configurations:

### Web Api + Swagger UI + Web Admin

This example provides a simple scenario where individual application settings are found in `{Application Name}.env` files, while shared settings are located in the `.env` file.

To run this example:

* Go to `.\run\examples\WebApps`
* Copy all files to a new folder such as `C:\containers\WebApps` and remove the `.example` extension from the files. `.env.example` becomes `.env`, `docker-compose.yml.example` becomes `docker-compose.yml`, etc.

Remember that container names will be based on the name of the target folder, so a readable and concise name is recommended.

* Configure relevant options in `.env`, `Edfi.Ods.SwaggerUI.env`, `EdFi.Ods.WebApi.env` and `EdFi.Ods.Admin.Web.env`

Note that Web Api Connection strings are commented, as they are pre-configured to connect to a single SQL server, using variables from `.env` and the `environment` section in `docker-compose.yml`

Run Docker Compose:

```powershell
PS> docker-compose up -d
```

Swagger UI should be accesible by default at [https://localhost:8101](https://localhost:8101), Web API at [https://localhost:8100](https://localhost:8100) and Admin Web at [https://localhost:8102](https://localhost:8102)

### Start and Stop Scripts

To aid in switching between different versions and environments, you may wish to run `docker-compose` using `start.ps1` and `stop.ps1`:

1. Assuming a directory structure like `c:\containers\localdev`, `c:\containers\sandbox`, `c:\containers\production`, copy `start.ps1` and `stop.ps1` into `c:\containers`.
1. In PowerShell, switch to the `c:\containers` directory.
1. To run version 2.3.1 with localdev, run:

   ```powershell
   PS> .\start.ps1 -Version 2.3.1 -Environment localdev
   ```

1. This runs `docker-compose up -d` for you, so all containers should now be starting.
1. To stop that instance, either change to the `localdev` directory and run `docker-compose down` or stay in the parent directory and run:

   ```powershell
   PS> .\stop.ps1 -Environment localdev
   ```

The main purpose of the start script is to change out the version number in `.env` file and create separate working directories, based on the version number, for database files. Otherwise if you try to run multiple versions of the database from the same data directory, you will encounter errors.

### Example Environments

Configurations for 3 sample environments (LocalDev, Sandbox, Production) are provided in the `./run/` folder.  These examples are a more advanced version of the previous example, suitable for local development, sandbox environment, or production, where the database server also runs as as container. Configurations for each application can be found in `{Application Name}.env` files, while shared settings are located in the `.env` file.

Example environments contain the following components / configuration:

#### LocalDev

* Ed-Fi ODS API
    * HTTPS NOT required for API access
    * API running in Sandbox mode
* Swagger Documentation UI
* Sandbox Administration UI
* Ed-Fi ODS Databases

#### Sandbox

* Ed-Fi ODS API
    * HTTPS required for API access
    * API running in Sandbox mode
* Swagger Documentation UI
* Sandbox Administration UI
* Ed-Fi ODS Databases

#### Production

* Ed-Fi ODS API
    * HTTPS required for API access
    * API running in SharedInstance mode
* Ed-Fi ODS Databases

For purposes of simplicity, LocalDev example will be referenced, but same process applies for `Sandbox` and `Production`.

To run the examples:

* Go to `./run/LocalDev`
* Copy all files to a new folder such as `C:\containers\LocalDev` and remove the `.example` extension from the files. `.env.example` becomes `.env`, `docker-compose.yml.example` becomes `docker-compose.yml`, etc.
* Configure relevant options in `.env`, `Edfi.Ods.SwaggerUI.env` and `EdFi.Ods.Web.Api.env`
* Make sure that the local folder defined in the `DATA_FOLDER` environment variable exists and is writeable. By default, this is the `./data` folder relative from the example files. Both relative or absolute paths can be used. Examples: 

```env
DATA_VOLUME=.\data
```

  Or

```env
DATA_VOLUME=C:\SQL\data
```

* run `docker-compose up -d`

Swagger UI should be accesible by default at [http://localhost:8101](http://localhost:8101), Web API at [http://localhost:8100](http://localhost:8100), Admin Web at [http://localhost:8102](http://localhost:8102), and Database at localhost:1433

Note: If you modify the database user in the `.env` file, you will need to create this user manually in the server using the SA credentials also specified in the `.env` file.

## Adding Custom SSL Certificates

Within each example folder there's an included self-signed SSL certificate under the `cert` folder named `certificate.pfx`, for testing HTTPS functionality. However, it is mandatory that you provide a custom certificate to ensure the applications and server safety.

Certificates must be provided in `.pfx` format; filename and location are defined in each example's `cert` folder. Basic instructions for exporting an already existing certificate can be found at [Microsoft Support](https://support.microsoft.com/en-us/help/823503/how-to-import-and-export-certificates-so-that-you-can-use-s-mime-in-ou)

## Known Issues

* A major update to Microsoft Windows 10 in early 2018 broke the loopback port mapping, e.g. after running `docker run -p 8080:80 microsoft/iis` you would be unable to access [https://localhost:8080](https://localhost:8080). This was issue was resolved in July 2018 under [Issue 204](https://github.com/docker/for-win/issues/204), which may require installing [KB4340917](https://support.microsoft.com/en-us/help/4340917/windows-10-update-kb4340917).
* SQL Server is prone to crashing in the container and is the most likely reason that the API would respond with 500. To use a SQL Server instance _outside of Docker_, then modify the application `.env` files to provide correct connection strings before start the containers, for example in `EdFi.Ods.WebApi.env`. A few steps you can take to diagnose if the SQL Server container is crashing
    * Look at the list of running containers and make sure edfi-database is there:

    ```powershell
    PS> docker ps
    CONTAINER ID        IMAGE                         COMMAND                  CREATED             STATUS                             PORTS                           NAMES
    1840cf98d207        edfi-swagger-ui:2.3.1         "powershell.exe c:/a…"   53 seconds ago      Up 21 seconds                      80/tcp, 0.0.0.0:8101->443/tcp   localdev_swagger-ui_1
    953eab20bdc1        edfi-web-api:2.3.1            "powershell.exe c:/a…"   53 seconds ago      Up 22 seconds                      80/tcp, 0.0.0.0:8100->443/tcp   localdev_web-api_1
    d32f18f3686a        edfi-restapi-database:2.3.1   "powershell -command…"   53 seconds ago      Up 16 seconds (health: starting)   0.0.0.0:1433->1433/tcp          localdev_edfi-database_1
    d32ff6ad6d6b        edfi-admin-web:2.3.1          "powershell.exe c:/a…"   53 seconds ago      Up 21 seconds                      80/tcp, 0.0.0.0:8102->443/tcp   localdev_admin-web_1
    ```
    * Open a powershell connection to the API container and try to ping `edfi-database` (the code below assumes running the LocalDev configuration with files in a "localdev" folder):

    ```powershell
    PS> docker exec -it localdev_web-api_1 powershell

    Windows PowerShell
    Copyright (C) 2016 Microsoft Corporation. All rights reserved.

    PS C:\inetpub\wwwroot>ping edfi-database
        
    Pinging edfi-database [172.17.62.112] with 32 bytes of data:
    Reply from 172.17.62.112: bytes=32 time<1ms TTL=128
    Reply from 172.17.62.112: bytes=32 time<1ms TTL=128
    
    Ping statistics for 172.17.62.112:
        Packets: Sent = 2, Received = 2, Lost = 0 (0% loss),
    Approximate round trip times in milli-seconds:
        Minimum = 0ms, Maximum = 0ms, Average = 0ms
    ```

* When running localdev configuration with four containers, a container may encounter an out of memory exception. Stopping and restarting the Docker service seems to help.
* If you are still getting 500 and the database is running properly...
    * Check the log file on your local system, e.g. if running the LocalDev environment from a "localdev" folder, look in `localdev\logs\api`.
    * Disable custom logging in the web.config. To do this, you need to
        * Stop the webapi container
        * Copy the web.config out of it into your local drive
        * Edit the web.config file, disabling custom errors
        * Copy the file back into the container
        * Restart the container

        ```powershell
        docker stop localdev_web-api_1
        docker cp localdev_web-api_1:c:\inetpub\wwwroot\web.config .
        code web.config
        docker cp web.config localdev_web-api_1:c:\inetpub\wwwroot
        docker start localdev_web-api_1
        ```