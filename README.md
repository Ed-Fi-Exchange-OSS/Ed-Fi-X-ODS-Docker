# Ed-Fi ODS Deploy for Docker

Dockerfiles for running the ODS/API in Docker

For more information, see:

* [Deploying Ed-Fi with Docker Containers](https://techdocs.ed-fi.org/display/EXCHANGE/Deploying+Ed-Fi+with+Docker+Containers)
* [How to Submit an Issue](https://techdocs.ed-fi.org/display/ETKB/How+To%3A+Submit+an+Issue)
* [How Submit a Feature Request](https://techdocs.ed-fi.org/display/ETKB/How+To%3A+Submit+a+Feature+Request)
* Review on-going development work at [Tracker](https://tracker.ed-fi.org/browse/EXC)
* [User guide](user-guide.md)

## Overview

This distribution contains a set of tools for building and deploying Docker containers for ODS Web Api, Swagger UI and Admin Web. While there is a configuration called "production", use of these sample configurations in production is not recommended - in particular because SQL Server 2017 in containers is not yet fully supported by Microsoft.

These scripts are provided as-is, but the Alliance welcomes feedback on additions or changes that would make these resources more user friendly. Feedback is best shared by raising a ticket on the Ed-Fi Tracker [Exchange Contributions Project](https://tracker.ed-fi.org/projects/EXC).

## Limitations

Docker does not currently have official support for several enabling technologies used by the Ed-Fi ODS, including accessing an Active Directory Domain and MSMQ.  Therefore, the following items are not included in this distribution:

* Bulk Load Services
* Security Configuration Tool
* Trusted Connections (i.e. Windows Auth) for SQL Server databases

## Contributing

Looking for an easy way to get started? Search for tickets with label
"up-for-grabs" in Tracker **[Link that text to a pre-existing query for the
project]**; these are nice-to-have but low priority tickets that should not
require in-depth knowledge of the code base and architecture.

## Legal Information

Copyright (c) 2020 Ed-Fi Alliance, LLC and contributors.

Licensed under the [Apache License, Version 2.0](LICENSE) (the "License").

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

See [NOTICES](NOTICES.md) for additional copyright and license notifications.