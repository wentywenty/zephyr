# 一键安装zephyr环境(作者：wentywenty)   

## 使用方法

### 设置执行策略

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 下载并执行安装脚本(依次执行两个部分即可~)

```powershell
(Invoke-WebRequest -Uri "https://raw.githubusercontent.com/wentywenty/zephyr/main/install.ps1").Content | Invoke-Expression
```

## 忘记要Star了，点了再走哦~

安装scoop及相关依赖

Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

scoop update

scoop install git

scoop bucket add extras

scoop update

scoop install openocd cmake ninja uv wget 7zip zstd python

scoop install https://raw.githubusercontent.com/wentywenty/zephyr/main/app/gperf.json

scoop install https://raw.githubusercontent.com/wentywenty/zephyr/main/app/dtc.json

scoop install https://raw.githubusercontent.com/wentywenty/zephyr/main/app/nrfutil.json

创建工作区及虚拟环境

mkdir zephyr && cd zephyr

mkdir ncs && cd ncs

uv python install 3.10

uv venv

.venv\Scripts\activate  

uv pip install west pyocd

west init

west init -m https://github.com/nrfconnect/sdk-nrf --mr 3.0.1

下载west代码

west update

导出west的cmake及pip依赖

west zephyr-export

uv pip install -r zephyr/scripts/requirements.txt -r bootloader/mcuboot/scripts/requirements.txt

uv pip install -r nrf/scripts/requirements.txt

安装west工具链

west sdk install

nrfutil install sdk-manager

nrfutil sdk-manager search

nrfutil sdk-manager config install-dir set $PWD

nrfutil sdk-manager toolchain install --ncs-version v3.1.0-preview1
