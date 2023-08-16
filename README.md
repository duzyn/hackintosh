<!-- omit in toc -->
# OMEN 暗影精灵 2 的 OpenCore 配置

- [初识黑苹果](#初识黑苹果)
- [原则](#原则)
- [总体步骤](#总体步骤)
- [了解硬件](#了解硬件)
- [前期准备](#前期准备)
- [替换无线网卡](#替换无线网卡)
- [制作系统安装盘](#制作系统安装盘)
- [安装 OpenCore](#安装-opencore)
- [安装内核扩展](#安装内核扩展)
- [ACPI 补丁](#acpi-补丁)
- [配置 OpenCore](#配置-opencore)
- [设置 BIOS](#设置-bios)
- [配置图形界面](#配置图形界面)
- [配置声音](#配置声音)
- [配置 USB 映射](#配置-usb-映射)
- [配置 CPU 频率管理](#配置-cpu-频率管理)
- [配置电池状态显示](#配置电池状态显示)
- [无需 USB 启动](#无需-usb-启动)
- [升级 macOS、OpenCore、内核扩展](#升级-macosopencore内核扩展)
- [遗留问题](#遗留问题)
- [日常使用设置](#日常使用设置)
  - [把 PrtSC 键映射为 F13 键](#把-prtsc-键映射为-f13-键)
  - [双系统](#双系统)

```
                    'c.           
                 ,xNMM.          OS: macOS 12.6.8 21G725 x86_64 
               .OMMMMo           Host: Hackintosh (SMBIOS: MacBookPro13,3) 
               OMMM0,            Kernel: 21.6.0 
     .;loddo:' loolloddol;.      Uptime: 6 mins 
   cKMMMMMMMMMMNWMMMMMMMMMM0:    Packages: 158 (brew) 
 .KMMMMMMMMMMMMMMMMMMMMMMMWd.    Shell: zsh 5.8.1 
 XMMMMMMMMMMMMMMMMMMMMMMMX.      Resolution: 1920x1080@2x 
;MMMMMMMMMMMMMMMMMMMMMMMM:       DE: Aqua 
:MMMMMMMMMMMMMMMMMMMMMMMM:       WM: Quartz Compositor 
.MMMMMMMMMMMMMMMMMMMMMMMMX.      WM Theme: Blue (Dark) 
 kMMMMMMMMMMMMMMMMMMMMMMMMWd.    Terminal: Apple_Terminal 
 .XMMMMMMMMMMMMMMMMMMMMMMMMMMk   Terminal Font: SFMono-Regular 
  .XMMMMMMMMMMMMMMMMMMMMMMMMK.   CPU: Intel i7-6700HQ (8) @ 2.60GHz 
    kMMMMMMMMMMMMMMMMMMMMMMd     GPU: Intel HD Graphics 530 
     ;KMMMMMMMWXXWMMMMMMMk.      Memory: 6103MiB / 16384MiB 
       .cooc,.    .,coo:.
```

## 初识黑苹果

我最早接触黑苹果（Hackintosh）是在 2019 年。当时使用 Clover 在我的惠普暗影精灵 2 尝试了黑苹果，有一个大的问题是使用了 DW1820A 无线网卡，系统在开机时会内核崩溃一到两次后才能正常启动。虽然启动后有时能正常使用，但是不方便。

在之后，OpenCore 基本已形成了替代 Clover 的趋势，此次重新尝试黑苹果前，我先了解了 OpenCore 的知识，主要参考的是 [OpenCore 安装指南](https://dortania.github.io/OpenCore-Install-Guide/)，该指南内容详实，可操作性强，更新及时。OpenCore 本身的文档和资源查看也比 Clover 方便。

## 原则

- 不求新，只求稳。系统要比当前最新的 macOS 低一个版本，新系统一般 Bug 较多，Windows 如此，macOS 也如此。各个应用兼容新系统也需要时间。其他驱动或补丁对老系统的支持也会更好。
- 小心求证，做好保护。网上的教程除少数几个真正的大牛的外，都是些复制别人的教程，不注明出处的。要时刻保持清醒，假设每个教程都可能有错，所以需要自己先验证。可在 U 盘中先修改，从 U 盘启动后试用一段时间，没问题后再复制到系统盘。或者常备一个可启动的 U 盘，在玩坏系统后可以从 U 盘启动进行操作。
- 尽量少改动。不做无谓的配置或补丁，除非不做不行。做的多，可能错的多，更难排查问题。
- 站在巨人的肩膀上。同一个配置，多人有不同的方案的，选择更靠谱的大牛的方案。初始配置使用大牛的，这样后续会更简单。
- 不重复造轮子。有现成通用的补丁，拿来用就好，不要瞎折腾。同一机型，其他人有分享的，了解他们的设定作为参考，并验证。
- 知道自己在做什么。只做自己已经理解的修改，不要盲目瞎改。
- 按捺住好奇心。在系统都设定好之后，不要为了新奇去不断尝试新系统、新方案。把时间花在其他更有价值的事上。

## 总体步骤

黑苹果系统安装和 Windows、Linux 等其他系统的安装是类似的。只是三步：

1.  刻盘。准备一个系统安装介质，一般是用 U 盘。只是黑苹果无法直接启动，需要借助 OpenCore 来启动。
2.  装机。和其他系统装机一样，也是有一些地方要注意的。
3.  配置。黑苹果装完后，很多硬件驱动有问题，功能不正常。每一项都有人已经做了 Hack，你需要找到适合自己硬件的部分，并自己一一验证。

## 了解硬件

Windows 上可以使用 AIDA64 或 [HWinfo](https://www.hwinfo.com/download/)（免费）查看硬件的信息，并导出 HTML 或 TXT 的结果存起来。你需要根据自己的型号，先去了解基本的信息，包括：

- 我的设备能不能装黑苹果？如果能装的话，硬件的哪些部分可以正常运行？
- 黑苹果装机的大概步骤？
- 哪里有资源可以看靠谱教程？
- 哪些地方要注意？

惠普官网有暗影精灵 2 的 [硬件规格](https://support.hp.com/cn-zh/document/c05161851)。

## 前期准备

通读一遍 OpenCore 安装指南，并记下和我笔记本相关需要做的步骤，做到心里有底。

## 替换无线网卡

这次重新安装黑苹果前，先在淘宝购买一个 macOS 操作系统原生支持的无线网卡，在 [Wireless Buyers Guide](https://dortania.github.io/Wireless-Buyers-Guide/) 中选了 BCM94352Z Fenvi（奋威）AC1200 这块卡，接口、大小等规格都能适配我的暗夜精灵 2 笔记本，自行拆机并替换网卡后，在 Windows 系统下需要安装 [网卡和蓝牙驱动](https://www.dell.com/support/home/zh-cn/drivers/driversdetails?driverid=74hw9&oscode=wb64a&productcode=xps-13-9343-laptop) 后，Wi-Fi 和蓝牙使用完全正常。

## 制作系统安装盘

因为 U 盘本身有 32GB，为了不浪费只做 macOS 的安装盘，使用 Ventoy 来做一个多启动盘。

先用 Scoop 下载安装 Ventoy：

```powershell
scoop bucket add scoop-cn https://ghproxy.com/github.com/duzyn/scoop-cn
scoop install scoop-cn/ventoy
```

运行 Ventoy2Disk，选中 U 盘，分区类型选择 GPT，分区设置中在磁盘最后保留一段空间，写 16GB。这个 16GB 的空间我们用来放 macOS 的安装盘。然后将空闲的 16GB 空间格式化为 FAT32 格式，盘符为 INSTALLER，这并不是最后要用的格式，但是不格式化的话，在 macOS 的磁盘工具中看不到这个分区。U 盘的 Ventoy 盘分区选 FAT32，后续用来放 WePE、Windows 或 Linux 的 ISO 文件。

分区后的硬盘可见的分区为：

- VENTOY：FAT32 格式，约 14GB
- VTOYEFI：ESP 分区，FAT16 格式，32MB
- INSTALLER：FAT32 格式，16GB

下载 macOS 安装包，需要进到 macOS，运行下方的命令，再按提示下载对应版本的的系统安装包。如果没有 macOS 可以有两种办法，一是 [在 Windows 下载恢复盘，启动恢复盘在线安装](https://dortania.github.io/OpenCore-Install-Guide/installer-guide/windows-install.html)。二是在 Windows 上安装虚拟机跑 macOS，做 U 盘系统安装包。

这里我们使用 [mist](https://github.com/ninxsoft/mist) 来下载 macOS 安装包。

```bash
brew tap --custom-remote --force-auto-update duzyn/cn https://ghproxy.com/github.com/duzyn/homebrew-cn
brew install duzyn/cn/mist
```

运行 Mist，然后选择对应的 Installer 下载，保存为 Application 格式，保存到 Mist 文件夹。

在下载的过程中，此时把 16GB 的分区准备好。打开磁盘工具，把 16GB 的分区格式化为“Mac OS 扩展（日志式）”（即 HFS+）。

下载完成后，会在 ～/Mist 目录下得到一个 app 格式的安装包。然后使用 Apple 官方的 createinstallmedia 工具刻录到 U 盘。createinstallmedia 这个工具就在系统安装包里面，可以参考下方的地址找到后，把文件拖到终端中来输入路径。

```bash
sudo "~/Mist/Install macOS Monterey 12.6.5_21G531.app/Contents/Resources/createinstallmedia" --volume /Volumes/INSTALLER/ 
```

另一种方法是使用 [installinstallmacos.py](https://github.com/munki/macadmin-scripts) 来下载 DMG 格式的安装包。

```bash
mkdir -p ~/macOS-installer && cd ~/macOS-installer && curl https://ghproxy.com/raw.githubusercontent.com/munki/macadmin-scripts/main/installinstallmacos.py > installinstallmacos.py && sudo python3 installinstallmacos.py 
```

然后按提示选择 macOS 版本，等待下载完成。下载完成后打开 DMG 包，再使用和上述类似的方法用 createinstallmedia 工具刻录到 U 盘。

耐心等待安装完成。将电脑上已有的 EFI 文件夹拷贝到 VENTOY 的根目录下去。因为 VTOYEFI 分区只有 32MB，放不下 OpenCore 的文件，所以不适合放那个分区。

接下来配置从 Ventoy 链式启动 OpenCore。打开 VENTOY 盘，建立文件夹 ventoy，然后新建一个文件为 ventoy_grub.cfg，输入以下内容：

```
menuentry "OpenCore" --class=custom {
  insmod part_gpt
  insmod chain
  set root=${vtoy_iso_part}
  chainloader /EFI/OC/OpenCore.efi
}
```

Ventoy 支持 [使用 Grub2 来启动其他 OS](https://ventoy.net/cn/plugin_grubmenu.html)，上述的 `${vtoy_iso_part}` 是内置变量，指的是放 ISO 所在的分区，因为 OpenCore 的 ISO 文件也是放在 VENTOY 分区下，所以在这个分区下找对应的文件。

目录结构如下：

```
/Volumes/VENTOY
├── EFI
├── ISO
│   └── WePE64_V2.2.iso
└── ventoy
    ├── ventoy.json
    └── ventoy_grub.cfg
```

## 安装 OpenCore

下载 OpenCore 最新版本，按照 [教程相应部分](https://dortania.github.io/OpenCore-Install-Guide/installer-guide/opencore-efi.html#adding-the-base-opencore-files) 的来做，重点是保留自己需要的文件即可。

必需的 EFI 列表：

- BOOT/BOOTx64.efi：必需的基础组件
- OC/OpenCore.efi：必需的基础组件
- OC/Drivers/HfsPlus.efi：OpenCore 自带的驱动中缺少 HFS+ 磁盘格式驱动，可以下载 [HfsPlus.efi](https://ghproxy.com/github.com/acidanthera/OcBinaryData/raw/master/Drivers/HfsPlus.efi)
- OC/Drivers/OpenRuntime.efi：必需的基础组件
- OC/Drivers/Ps2KeyboardDxe.efi：笔记本内置键盘的驱动
- OC/Drivers/Ps2MouseDxe.efi：笔记本内置鼠标的驱动
- OC/Drivers/ResetNvramEntry.efi：重置 NVRAM

## 安装内核扩展

按照 [教程相应部分](https://dortania.github.io/OpenCore-Install-Guide/ktext.html#kexts) 加入需要的内核扩展（Kexts）。列表如下：

- [AppleALC.kext](https://github.com/acidanthera/AppleALC)：声卡驱动。
- [BrightnessKeys.kext](https://github.com/acidanthera/BrightnessKeys)：修复屏幕亮度调节的快捷键。
- [CPUFriend.kext](https://github.com/acidanthera/CPUFriend)：CPU 功耗管理，在装机完后再做，后文有说明。
- CPUFriendDataProvider.kext：配合 CPUFriend 用，在装机完后再做，后文有说明。使用 [one-key-cpufriend](https://github.com/stevezhengshiqi/one-key-cpufriend) 来生成。
- [FeatureUnlock.kext](https://github.com/acidanthera/FeatureUnlock)：解锁不支持的特性
- [HibernationFixup.kext](https://github.com/acidanthera/HibernationFixup)：睡眠修复。
- [Lilu.kext](https://github.com/acidanthera/Lilu)：各其他内核扩展基本都是 Lilu 的插件，所以这个是必需。
- [NVMeFix.kext](https://github.com/acidanthera/NVMeFix)：固态硬盘的补丁。
- [RealtekRTL8111.kext](https://github.com/Mieze/RTL8111_driver_for_OS_X)：有线网卡的驱动。
- SMCBatteryManager.kext：VirtualSMC 的插件，电池管理。
- SMCProcessor.kext：VirtualSMC 的插件，CPU 管理。
- SMCSuperIO.kext：VirtualSMC 的插件，IO 管理。
- [USBInjectAll.kext](https://bitbucket.org/RehabMan/os-x-usb-inject-all/downloads/)：USB 端口正常使用前临时用的。在做好 USBMap 后就禁用它。后文有说明。
- USBMap.kext：保留电脑用到的 USB 端口，并正确配置端口类型。需要使用 [USBMap](https://github.com/corpnewt/USBMap) 生成适合自己电脑的内核扩展。
- [VirtualSMC.kext](https://github.com/acidanthera/VirtualSMC)：主板驱动。
- [VoodooInput.kext](https://github.com/acidanthera/VoodooInput)：触控板驱动。
- [VoodooPS2.kext](https://github.com/acidanthera/VoodooPS2)：键鼠驱动。
- [WhateverGreen.kext](https://github.com/acidanthera/WhateverGreen)：显卡驱动。

内核扩展只需要够用就行，不需要装些不必需的。上述内核扩展都是必需的。

## ACPI 补丁

按照 [教程相应部分](https://dortania.github.io/OpenCore-Install-Guide/ktext.html#laptop) 加入需要的 ACPI 补丁。列表如下：

- [SSDT-BAT0.aml](https://github.com/daliansky/OC-little/blob/master/%E4%BF%9D%E7%95%99%E9%83%A8%E4%BB%B6/%E7%94%B5%E6%B1%A0%E8%A1%A5%E4%B8%81/%E5%85%B6%E5%AE%83%E5%93%81%E7%89%8C/SSDT-OCBAT0-HP_Pavilion-15.dsl)：电池电量状态补丁。
- [SSDT-dGPU-Off.aml](https://github.com/dortania/Getting-Started-With-ACPI/blob/master/extra-files/decompiled/SSDT-dGPU-Off.dsl.zip)：屏蔽英伟达独显补丁。
- [SSDT-EC-USBX-LAPTOP.aml](https://github.com/dortania/Getting-Started-With-ACPI/blob/master/extra-files/compiled/SSDT-EC-USBX-LAPTOP.aml)：EC、USB 供电补丁。
- [SSDT-PLUG-DRTNIA.aml](https://github.com/dortania/Getting-Started-With-ACPI/blob/master/extra-files/compiled/SSDT-PLUG-DRTNIA.aml)：CPU 补丁。
- [SSDT-PNLF.aml](https://github.com/dortania/Getting-Started-With-ACPI/blob/master/extra-files/compiled/SSDT-PNLF.aml)：调节显示器亮度补丁。
- SSDT-RMCF-PS2Map.aml：将 PrtSc 键映射为 F13 键，见下文。
- [SSDT-XOSI.aml](https://github.com/dortania/Getting-Started-With-ACPI/blob/master/extra-files/compiled/SSDT-XOSI.aml)：使 Windows 下的功能在 macOS 也可用。

ACPI 补丁只需要够用就行，不需要装些不必需的。上述 ACPI 补丁都是必需的。

## 配置 OpenCore

[按照教程配置 OpenCore](https://dortania.github.io/OpenCore-Install-Guide/config.plist/)。再按照 [SkyLake CPU 笔记本教程](https://dortania.github.io/OpenCore-Install-Guide/config-laptop.plist/skylake.html) 来配置剩下的部分。

按照 [教程相应部分](https://dortania.github.io/OpenCore-Post-Install/cosmetic/verbose.html) 在电脑上的 config.plist 中设置几项隐藏启动时的调试信息：

- boot-args 中去掉 -v
- Debug - AppleDebug 为 NO
- Debug - ApplePanic 为 YES
- Debug - Target 为 3：记录关键信息

以上信息在 U 盘上无需隐藏，在 U 盘上的设置：

- boot-args 中加上 -v
- Debug - AppleDebug 为 YES
- Debug - ApplePanic 为 YES
- Debug - Target 为 67：记录详细的日志信息

伪装设备为 MacBook Pro (15 英寸，2016)，[技术规格](https://support.apple.com/kb/SP749?viewlocale=zh_CN&locale=zh_HK)。

使用 OpenCore 中自带的工具 macserial 来生成要伪装设备的序列号和主板 ID，命令为 `macserial.exe -m MacBookPro13,3`，生成的结果中第一列是序列号，第二列是主板 ID。到 [Apple Check Coverage](https://checkcoverage.apple.com/) 可以查询序列号有没有被人已经使用了，没人使用的就可以用。因为同一人多次查询，苹果会屏蔽，可以使用 Tor 浏览器访问此页面来规避苹果的屏蔽。

## 设置 BIOS

先更新 BIOS 到最新的版本。按照你的电脑的用户手册进行系统的 BIOS 设置。比如惠普暗影精灵 2 的是：开机后按 ESC，然后根据界面提示选 F10 进入设置。

- 关闭安全启动
- 关闭快速启动
- 关闭管理员密码

## 配置图形界面

按 [教程相应部分](https://dortania.github.io/OpenCore-Post-Install/universal/audio.html) 设置。

## 配置声音

按 [教程相应部分](https://dortania.github.io/OpenCore-Post-Install/universal/audio.html) 设置，找到声卡设备的 PCI 地址 PciRoot(0x0)/Pci(0x1f,0x3)，然后设置 layout-id 为 Number 13。

为解决从 Windows 启动进入 macOS 没有声音输出，设置 alctsel 为 Data 01000000。

为解决有时启动时 macOS 没有声音输出，设置 alc-delay 为 Number 1000。

## 配置 USB 映射

先启用 USBInjectAll.kext。按照 [USBMap 使用教程](https://github.com/corpnewt/USBMap) 来设置内置摄像机、蓝牙、USB 2.0 接口、USB 3.0 Type A 接口，可以得到 USBMap.kext。完成后去掉 USBInjectAll.kext。

## 配置 CPU 频率管理

按照 [CPUFriendFriend 教程](https://github.com/corpnewt/CPUFriendFriend) 配置得到 CPUFriend.kext 和 CPUFriendDataProvider.kext。

## 配置电池状态显示

使用 OC-little 的电池信息补丁，做出 SSDT-BAT0.aml，然后使用补丁。

```
* In config, ADJT to XDJT
* Find:    41444A54 08
* Replace: 58444A54 08
* 
* In config, CLRI to XLRI
* Find:    434C5249 08
* Replace: 584C5249 08
* 
* In config, _BST to XBST
* Find:    5F425354 00
* Replace: 58425354 00
* 
* In config, UPBI to XPBI
* Find:    55504249 00
* Replace: 58504249 00
* 
* In config, UPBS to XPBS
* Find:    55504253 00
* Replace: 58504253 00
* 
* In config, SMRD to XMRD
* Find:    534D5244 04
* Replace: 584D5244 04
* 
* In config, SMWR to XMWR
* Find:    534D5752 04
* Replace: 584D5752 04
```

## 无需 USB 启动

先在 U 盘上配置，测试完成后，把 U 盘上的 EFI 目录下的文件全部拷贝到电脑的 EFI 分区下。推出 U 盘，重启电脑即可。

## 升级 macOS、OpenCore、内核扩展

在升级上述东西之前，都先备份 U 盘上目前正常的 OpenCore，然后进行升级。升级后从 U 盘启动，测试下各个功能是否正常，如果正常，则将电脑上的配置升级为和 U 盘一样。

大的 macOS 版本升级，需要有更多小白先试用并发现问题，各个应用程序也需要一段时间来兼容新系统，所以最好在新系统发出至少六个月（最好一年）后再升级系统。

## 遗留问题

目前一个遗留的问题是每次开机前会断电一次再开机，但不是内核崩溃，不影响正常使用。

另外，英伟达独显不能用，HDMI 输出口接在独显上，所以不能用。但可以使用一个 USB 转 HDMI 的转换器实现双屏，只是这类配件在系统升级后因为兼容性问题用不了了。

## 日常使用设置

### 把 PrtSC 键映射为 F13 键

在我的笔记本上，PrtSC 键在 F12 键的右侧，而 macOS 无法识别这个键，可以使用 [PS2 键盘映射 ACPI 补丁](https://github.com/daliansky/OC-little/tree/da97296b6f119681bd89bc26fd662caa7b65b032/docs/07-PS2%E9%94%AE%E7%9B%98%E6%98%A0%E5%B0%84%E5%8F%8A%E4%BA%AE%E5%BA%A6%E5%BF%AB%E6%8D%B7%E9%94%AE) 将其映射为 F13 键，然后在系统偏好设置中调节截图的快捷键为 F13 键，这样就可以实现等同于 Windows 上按 PrtSC 截图的效果。

### 双系统

我将原有的 256GB M.2 SSD 换成了 1TB M.2 SSD，把 1TB HDD 换成了 1TB SATA SSD。前者装 macOS，后者装 Windows。OpenCore 放在 macOS 的 ESP 中，这样 Windows 升级时不会影响 macOS 和 OpenCore。

在 Windows 的电源设置中关闭快速启动，否则在 macOS 下使用 Windows 盘可能会造成文件损坏，导致进不去 Windows。

解决两个系统下时间不一致问题：Windows 中的时间比 macOS 慢 8 个小时，原因是 Windows 和 macOS 处理时间的方式不同。Windows 使用本地时间，macOS 则使用 UTC，东八区的中国时间比 UTC 快 8 小时。可以改为 Windows 也使用 UTC。

以管理员运行以下命令修改注册表：

```cmd
Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_DWORD /d 1
```
