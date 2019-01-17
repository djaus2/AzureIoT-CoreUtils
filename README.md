# AzureIoT-CoreUtils
Some PowerShell scripts for setting up conatiners on Win 10 IoT-Core


>> Nb: On Windows 10 IoT-Core you need a 64 bit version of the OS and so won't current run Containers on the RPI.  I am using a MinnowBoardMax.  I understand (not yet tested) the Dragonboard OS is 64 Bit so should work there as well.


When deploying Azure IoTEdge Containers to a Windows 10 IoT-Core device, the Azure cLI commands need to be a little different to those stated in some of the Azure IoT Hub documentation.  In particular, setting installing and uninstaling requires a local PowerShell script; that is, one copied to the device. I have been working through the tutorials such as:
- [Quickstart: Deploy your first IoT Edge module from the Azure portal to a Windows device - preview](https://docs.microsoft.com/en-us/azure/iot-edge/quickstart)
- [Tutorial: Develop a C# IoT Edge module and deploy to your simulated device](https://docs.microsoft.com/en-us/azure/iot-edge/tutorial-csharp-module)

I found that in "Install and start the IoT Edge runtime/Download and install the IoT Edge service", Step 2 doesn't work if targeting an IoT-Core device. The following is the Step 2 comamnd that won't work:

```
. {Invoke-WebRequest -useb aka.ms/iotedge-win} | Invoke-Expression; `
Install-SecurityDaemon -Manual -ContainerOs Windows
```

There was some discussion of this issue with a workaround presented.  The PowerShell scripts presented here are a formal encapsulation of that solution.
- [My discussion thread on MS Docs on this issue](https://github.com/MicrosoftDocs/azure-docs/issues/21915)
Pivotal was this response from Kelly Gremban @kgremban:
>For unblocking your most recent status update, I've heard from some other users that the current installation bits are buggy on IoT Core. Download [IotEdgeSecurityDaemon.ps1](https://raw.githubusercontent.com/alextnewman/iotedge/3b87d6805fed1e2bdc74dc6f2d3f45cfea328b3e/scripts/windows/setup/IotEdgeSecurityDaemon.ps1) and save it locally on your machine.
And the commnd to invoke it is presented at

```
https://github.com/MicrosoftDocs/azure-docs/issues/21559#issuecomment-451163574
```

## PowerShell scripts
Copy these scripts to (say) c:\iotedge. Then run on the device through the PowerShell portal to the device
- install.ps1: Installation script to replace Step 2 above
- uninstall.ps1: Removal script 
- IotEdgeSecurityDaemon.ps1: This is called by the install and uninstall scripts as per the link from Kelly above.
- logmin.ps1: Requires a parameter m, number of minutes. Show log for last m minutes (eg ./logmin 5)
- logsec.ps1: Requires a parameter s, number of seconds. Show log for last s seconds (eg ./logsec 3) 



*The following assumes you have established a PowerShell window to the device, eg via IoT Dashboard and copied the scripts to a suitable folder and changed to tha tfolder at the prompt.*


Get the Connection string as per the tutorial documentation, then enter the call to the script eg:
```
[192.168.0.26]: PS C:\iotedge> .\install

ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Script     0.0        IotEdgeSecurityDaemon               {Install-SecurityDaemon, Uninstall-SecurityDaemon}

cmdlet Install-SecurityDaemon at command pipeline position 1
Supply values for the following parameters:
DeviceConnectionString:
```

*Enter Connection string here when prompted*
 
```
The container host is on supported build version 17763.
Downloading Moby Engine...
Using Moby Engine from C:\Data\Users\administrator\AppData\Local\Temp\iotedge-moby-engine.zip
Downloading Moby CLI...
Using Moby CLI from C:\Data\Users\administrator\AppData\Local\Temp\iotedge-moby-cli.zip
Downloading IoT Edge security daemon...
Using IoT Edge security daemon from C:\Data\Users\administrator\AppData\Local\Temp\iotedged-windows.zip
Skipping VC Runtime installation on IoT Core.
Generating config.yaml...
Configured device for manual provisioning.
Configured device with hostname 'minwinpcMax'.
Configured device with Moby Engine URL 'npipe://./pipe/iotedge_moby_engine'.
Updated system PATH.
Added IoT Edge registry key.
Initialized the IoT Edge service.
```

** NB: At this stage, the job isn't done! The device is still setting up. Look at the logs until things settle.

You should see logs such as 

```
16/01/2019 4:03:23 PM info: edgelet_docker::runtime -- Successfully pulled image
                      mcr.microsoft.com/azureiotedge-agent:1.0
16/01/2019 4:03:23 PM info: edgelet_docker::runtime -- Creating module edgeAgent...
16/01/2019 4:03:23 PM info: edgelet_docker::runtime -- Successfully created module edgeAgent
16/01/2019 4:03:23 PM info: edgelet_docker::runtime -- Starting module edgeAgent...
16/01/2019 4:03:33 PM info: edgelet_docker::runtime -- Successfully started module edgeAgent
16/01/2019 4:03:33 PM info: edgelet_core::watchdog -- Checking edge runtime statusedge
16/01/2019 4:03:33 PM info: edgelet_core::watchdog -- Edge runtime is running.
```
..and similar for edgehub, tempSensor and CSharpModule.
Eventually ```iotedge list``` will show them all running:

```
[192.168.0.26]: PS C:\iotedge> iotedge list
NAME             STATUS           DESCRIPTION      CONFIG
CSharpModule     running          Up 37 minutes    djauscontainerreg.azurecr.io/csharpmodule:0.0.1-windows-amd64
tempSensor       running          Up 38 minutes    mcr.microsoft.com/azureiotedge-simulated-temperature-sensor:1.0
edgeHub          running          Up 38 minutes    mcr.microsoft.com/azureiotedge-hub:1.0
edgeAgent        running          Up 39 minutes    mcr.microsoft.com/azureiotedge-agent:1.0
```

### Running the Log scripts


### Running the UnInstall script
*Note that this take quite a while before it is done.*

```
[192.168.0.26]: PS C:\iotedge> .\uninstall

ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Script     0.0        IotEdgeSecurityDaemon               {Install-SecurityDaemon, Uninstall-SecurityDaemon}
Uninstalling...
Deleting install directory 'C:\ProgramData\iotedge'...
Deleting Moby data root directory 'C:\Data\ProgramData\iotedge-moby-data'...
Successfully uninstalled IoT Edge.
```
