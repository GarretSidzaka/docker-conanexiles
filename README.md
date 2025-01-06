# docker-conanexiles

This image was forked from the Alinmear's excellent docker image.  The underlying stack has been updated to 2024 versions, and there are various tweaks and fixes added, as well as additional in-line documentation
There are more features on the roadmap, and community feedback, issues, and code pushes are welcome.

---

Source of server tweaks: <https://steamcommunity.com/sharedfiles/filedetails/?id=2130895654>
Original Author: https://github.com/alinmear/docker-conanexiles

---

## Features

* Full automatic provisioning of Steam and Conan Exiles Dedicated Server
* Mod Support
* Autoupdate of the Conan Exiles server
* Full control of every config aspect via Environment variables
* Templates for first time setup
* Running multiple instances with multiple config directories
* RCON Support (supported but unreliable due to Funcom)
* Logging support

---
### Wishlist/ToDo
* Discord integration
---


### Get started

```sh
curl -LJO https://raw.githubusercontent.com/garretsidzaka/docker-conanexiles/master/docker-compose.yml
docker-compose pull
```

#### Start all services 

`docker-compose up -d`


### Update image and rollout

`docker-compose pull && docker-compose up -d`

### Shutdown

`docker-compose down`

---

## Create a simplified `docker-compose.yml`

The `docker-compose.yml` file can be customized e.g. if you do not want to run several game servers.

---

## First Time Setup

### Provide a Config

If there is a folder with configurations found at `/tmp/docker-conanexiles` this folder will be copied to the config folder of the server. This will only happen if there is no configuration already existing (the case of a clean container initialization).

### Default Templates

Use the environment variable `CONANEXILES_SERVER_TYPE=pve` to use the pve template; otherwise the pvp template will be used if no configuration has been provided.

### Host Tweaks

Based on this [reddit thread discussing dedicated server on Linux hangs and players disconnect](https://www.reddit.com/r/ConanExiles/comments/1dbuiqd/dedicated_server_on_linux_hangs_and_players/) that user
[whereismycow42](https://reddit.com/user/whereismycow42) posted with a solution, it's recommended to update `vm.max_map_count` to greater than the default value of `65536`. We tried to integrate this solution in the startup script to set the value in the docker container, but found that you need to set this at the host level as root. Please review the thread post and apply the appropriate fix so you can include as many mods as you want.

---

## Multi Instance Setup

It is possible to run multiple server instances with 1 Server Installation. For better understanding we have to split the conan-exiles installation into two parts:

* Binaries for running the server
* Configurations for an instance (db, configs)

We can create an architecture like this:

```txt
- BINARY
-> Instance 1 (Master-Server)
--> ConfigFolder1
-> Instance 2 (Slave-Server)
--> ConfigFolder2
-> Instance 3 (Slave-Server)
--> ConfigFolder3
-> Instance n (Slave-Server)
--> ConfigFolderN
```

The Master-Server is taking care about the binaries, more precisely keeping it up to date. If there is a new update, the master server will notify the Slave-Servers for shutting down to make the update. Afterwards the master informs the Slave-Servers to spin up again.

**NOTE**: There should always be only 1 Master-Server-Instance, otherwise it could break your setup, if two master server are updating at the same time.

!! **STANDARD-Behavior**: The Docker Image itself sets the master-server value to 1, which means that each server is a master server. For a multi instance setup you have to explicit set CONANEXILES_MASTERSERVER=0. You also have to specify the CONANEXILES_INSTANCENAME, otherwise your instances would write changes into the same db and break everything.

ENV-VARS to Setup:

* CONANEXILES_MASTERSERVER = 0/1
* CONANEXILES_INSTANCENAME = `<name>`
  * Used for the DB and config file dir of the instance (-usedir)
* `CONANEXILES_PORT = 7777`
  * Standard Port, for multiple instance you have to increment this per instance e.g. instance 0 Port 7777, instance 1 Port 7779, instance n Port 77yn
  * NOTE: You also have to adjust the proper port mapping within the compose file
* CONANEXILES_QUERYPORT = 27015
  * Standard QueryPort, same as Port for multiple instances e.g. instance 0 QueryPort 27015, instance 1 QueryPort 27017, instance n QueryPort 270yn
  * NOTE: You also have to adjust the proper port mapping within the compose file

Default: CONANEXILES_MASTERSERVER = 1 (only the master server is able to make updates)
Default: CONANEXILES_INSTANCENAME = saved (the default config folder name)

---

## Mod Support

Mods can be install with the global env variable `CONANEXILES_MODS`. Specify ModIDs as comma separated list there. E.g.

NOTE: Yout can get the modids from Steamworkshop.

After a restart the mods will be downloaded, activated and updated via steamworkshop.

## Environment Variables and Config Options

A conan exiles dedicated server uses a lot of configuration options to influence nearly every aspect of the game logics.
To have full control of this complex configuration situation i implemented a logic to set these values in every config files.

ConanExiles uses a common ini format. That means that a config file has the following logic:

```ini
[section1]
key1=value
key2=value

[section2] 
key1=value
key2=value
```

ConanExiles uses the following config files:

* CharacterLOD.ini
* Compat.ini
* DeviceProfiles.ini
* EditorPerProjectUserSettings.ini
* Engine.ini
* Game.ini
* GameUserSettings.ini
* GameplayTags.ini
* GraniteCooked.ini
* GraniteCookedMod.ini
* Hardware.ini
* Input.ini
* Lightmass.ini
* Scalability.ini
* ServerSettings.ini

### Logic

To set values in one of these ini files use the following logic to set environment variables:
`CONANEXILES_<filename>_<section>_<key>_<value>`

#### Examples

To set e.g. the **AdminPassword** use the following logic:
`CONANEXILES_ServerSettings_ServerSettings_AdminPassword=ThanksForThisSmartSolution`
(Note: The ini files is named   ServerSettings.ini and the Section within the file has also the name ServerSettings)

To set e.g. the **Servername and a ServerPassword**:
`CONANEXILES_Engine_OnlineSubSystemSteam_ServerName="My Cool Server"`
`CONANEXILES_Engine_OnlineSubSystemSteam_ServerPassword="MySecret"`

**NOTE**: If an Environment Variable is set it will override the value within the specified ini file at every container startup. If an ServerAdmin manually changes values within the game, these will be lost after container restart.

### List of separated environment variables

* `CONANEXILES_SERVER_TYPE`
This Variable defines the profile for the first time setup at container provisioning, if no config folder has been provided.  

==> **pvp**
==> pve

* `CONANEXILES_CMDSWITCHES`
With this variable you are able to append switches to the exiles run command.

e.g.  CONANEXILES_CMDSWITCHES="-MULTIHOME=xxx.xxx.xxx.xxx" will result in
command=wine64 /conanexiles/ConanSandbox/Binaries/Win64/ConanSandboxServer-Win64-Test.exe -nosteamclient -game -server -log -userdir=%(ENV_CONANEXILES_INSTANCENAME)s -MULTIHOME=xxx.xxx.xxx.xxx

* `CONANEXILES_UPDATE_SHUTDOWN_TIMER`
With this variable you can set the amount of time in minutes, the server waits to shutdown for an update.
