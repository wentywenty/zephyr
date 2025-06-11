# 定义颜色主题
$Theme = @{
    Title = 'Cyan'
    Menu = 'Green'
    Warning = 'Yellow'
    Error = 'Red'
    Success = 'Green'
}

# 显示欢迎界面
function Show-Welcome {
    Clear-Host
    Write-Host "`n=====================================" -ForegroundColor $Theme.Title
    Write-Host "      Zephyr 开发环境一键安装工具     " -ForegroundColor $Theme.Title
    Write-Host "====================================" -ForegroundColor $Theme.Title
    Write-Host "`n作者: Github@wentywenty" -ForegroundColor $Theme.Title
    Write-Host "版本: v1.2.1`n" -ForegroundColor $Theme.Title
}

# 显示主菜单
function Show-Menu {
    Write-Host "请选择安装选项：" -ForegroundColor $Theme.Menu
    Write-Host "1. 默认安装(第一部分)" -ForegroundColor $Theme.Menu
    Write-Host "2. 默认安装(第二部分)" -ForegroundColor $Theme.Menu
    Write-Host "3. 安装scoop及相关依赖" -ForegroundColor $Theme.Menu
    Write-Host "4. 安装choco及相关依赖" -ForegroundColor $Theme.Menu
    Write-Host "5. 安装zephyr sdk" -ForegroundColor $Theme.Menu
    Write-Host "6. 配置powershell代理" -ForegroundColor $Theme.Menu
    Write-Host "0. 退出" -ForegroundColor $Theme.Menu
    Write-Host "`n请输入选项 [0-6]: " -NoNewline -ForegroundColor $Theme.Menu
}


# 主程序
function Start-Installation {
    Show-Welcome
    while ($true) {
        Show-Menu
        $choice = Read-Host
        
        switch ($choice) {
            '1' {
                Write-Host "`n默认安装(第一部分)" -ForegroundColor $Theme.Success
                
                Write-Host "`n正在检查并安装 Scoop 包管理器..." -ForegroundColor Green
                if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
                    Write-Host "`n请选择scoop安装位置" -ForegroundColor Green
                    # 设置 Scoop 安装路径
                    $SCOOP_ROOT = "$env:USERPROFILE\scoop"
                    Write-Host "Scoop 将安装到: $SCOOP_ROOT" -ForegroundColor Yellow

                    # 设置 Scoop 环境变量
                    [Environment]::SetEnvironmentVariable('SCOOP', $SCOOP_ROOT, 'User')
                    [Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', "$env:ProgramData\scoop", 'Machine')
                    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
                }
                else {
                    Write-Host "`nScoop 已安装..." -ForegroundColor Yellow
                    scoop bucket add extras
                }

                Write-Host "正在更新Scoop..." -ForegroundColor Yellow
                scoop update *

                Write-Host "`n正在安装基础开发工具..." -ForegroundColor Green
                scoop install git
                scoop install ninja wget uv cmake

                Write-Host "`n正在克隆 Zephyr 仓库..." -ForegroundColor Green
                if (!(Test-Path "zephyr")) {
                    git clone https://github.com/wentywenty/zephyr.git
                }
                else {
                    Write-Host "Zephyr 目录已存在，跳过克隆..." -ForegroundColor Yellow
                }
                git checkout zephyr

                # 如果您想将名为 "zephyr" 的文件夹重命名为其他名称，例如 "zephyr"
                if (Test-Path "zephyr" -PathType Container) {
                    # 检查目标文件夹是否已存在
                    if (Test-Path "zephyr" -PathType Container) {
                        Write-Host "目标文件夹 'zephyr' 已存在，无法重命名..." -ForegroundColor $Theme.Warning
                    }
                    else {
                        Write-Host "正在重命名 zephyr 文件夹为 zephyr..." -ForegroundColor Green
                        Rename-Item -Path "zephyr" -NewName "zephyr"
                    }
                }
                Set-Location zephyr

                # Write-Host "`n正在安装编译工具..." -ForegroundColor Green
                scoop install ./app/dtc.json 
                scoop install ./app/gperf.json 

                # 安装nRF工具
                Write-Host "`n正在安装 west 开发工具..." -ForegroundColor Green

                Write-Host "安装工具链管理器..." -ForegroundColor Yellow
                wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.17.0/zephyr-sdk-0.17.0_windows-x86_64.7z --no-check-certificate
                7z x zephyr-sdk-0.17.0_windows-x86_64.7z

                Write-Host "配置工具链安装目录..." -ForegroundColor Yellow
                Set-Location zephyr-sdk-0.17.0
                ./setup.cmd
                Set-Location ..

                Write-Host "`n正在配置 Python 环境..." -ForegroundColor Green
                uv python install 3.10
                uv venv
                Write-Host "正在激活虚拟环境..." -ForegroundColor Green
                .venv\Scripts\activate  

                Write-Host "`n正在安装 west..." -ForegroundColor Green
                uv pip install west

                Write-Host "`n初始化 West 工作区..." -ForegroundColor Green
                west init

            }
            '2' {
                Write-Host "`n默认安装(第二部分)" -ForegroundColor $Theme.Menu
                .venv\Scripts\activate  
                
                Write-Host "`n正在更新 West..." -ForegroundColor Green
                Write-Host "这可能需要一段时间，请保持网络稳定..." -ForegroundColor Yellow
                Set-Location zephyr
                west update

                Write-Host "`n安装项目依赖..." -ForegroundColor Green
                west packages pip --install
                uv pip install -r zephyr/scripts/requirements.txt -r bootloader/mcuboot/scripts/requirements.txt

                Write-Host "`n配置 West Cmake环境..." -ForegroundColor Yellow
                west zephyr-export

                Write-Host "`n配置 Zephyr 环境变量..." -ForegroundColor Green
                .\zephyr\zephyr-env.cmd

                Write-Host "安装 jlink,请手动访问" -ForegroundColor Yellow
                Write-Host "https://www.segger.com/downloads/jlink/JLink_Windows_x86_64.exe" -ForegroundColor Yellow

                Write-Host "安装 nrf_command_line_tools,请手动访问" -ForegroundColor Yellow
                Write-Host "https://www.nordicsemi.com/Products/Development-tools/nrf-command-line-tools/download#infotabs" -ForegroundColor Yellow
                
            }
            '3' {
                uv venv
                Write-Host "安装scoop及相关依赖" -ForegroundColor Green
                .venv\Scripts\activate  
                uv pip install west

                Write-Host "`n初始化 West 工作区..." -ForegroundColor Green
                west init -m https://github.com/nrfconnect/sdk-nrf --mr v2.9.0


            }
            '4' {
                Write-Host "`n安装choco及相关依赖" -ForegroundColor $Theme.Success

            }            
            '5' {
                Write-Host "`n安装zephyr sdk" -ForegroundColor $Theme.Success

            }
            '6' {
                Write-Host "`n配置powershell代理" -ForegroundColor $Theme.Success

            }
            '0' {
                Write-Host "`n感谢使用！" -ForegroundColor $Theme.Success
                return
            }
            default {
                Write-Host "`n无效选项，请重新选择" -ForegroundColor $Theme.Error
            }
        }
    }
}

# 启动安装程序
try {
    Start-Installation
} catch {
    Write-Host "`n安装过程中出现错误：" -ForegroundColor $Theme.Error
    Write-Host $_.Exception.Message -ForegroundColor $Theme.Error
    Write-Host "请截图保存并联系作者解决。" -ForegroundColor $Theme.Warning
} finally {
    Write-Host "`n按任意键退出..." -ForegroundColor $Theme.Menu
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}
