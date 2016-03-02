# VGA controller to display ascii text

简单的 VGA 控制器，可以绘制字符。

## Build

### 配置 VGA 时序

`vga_view` 模块负责 VGA 时序的处理，在此模块下修改参数以匹配 VGA 的显示模式。同时在 `vga_ctrl` 模块下修改 `h_disp`，使其与显示模式的分辨率宽度一致。

`vga_view` 的输入时钟为像素时钟。该时钟需要根据 VGA 的显示模式计算得出。像素时钟在 `vga_ctrl` 中通过 `pixel_clock_gen` 调整时钟频率产生，可以使用 MMCM IP 核 (Vivado) 生成。

### 配置字体以及文本

字体数据在 `vga_ctrl` 模块下，通过 `font_mem` 的实例提供。`font_mem` 需自行生成，比如使用 IP 核。

`font.coe` 包含字体信息，可用于初始化 Block Memory Generator (Vivado) 生成的 IP 核。`font.coe` 根据
[font8x8](https://github.com/dhepper/font8x8)
生成。

文本数据在 `vga_ctrl` 模块下，通过 `text_mem` 的实例提供，与 `font_mem` 一样需要自行生成。Ruby 脚本 `mk_text_mem.rb` 可以将输入的文本文件转换成需要的相应的 coe 文件，除了转换格式话，还会在遇到换行符时进行填充处理，生成的 coe 文件注释中有用于设置 block ram 的相关参数。

VGA 模块不负责控制字符的处理，所以在生成初始化文件，在遇到换行符时，要根据屏幕的分辨率在该行剩下的位置填充空格，其他显示相关的控制字符同理。

绘制一个字符的一行需要 8 个像素周期，该行会被缓存，并且在这 8 个周期内可以寻址下一个字符以及对应的字体的一行。根据 `vga_ctrl` 的状态机行为，实际有 7 个像素周期供下一个字符的字体行数据信号稳定下来。要确保两级的存储模块（ `text_mem` 和 `font_mem` ）的时延不超过 7 个像素周期。

## TODO

进一步切分 `vga_ctrl` 模块，形成类似 MVC 的架构，并且提供写接口。

使用 Block Memory Generator 生成 `text_mem` 时，如果初始化数据非常大，可能会一直输出空格 (0x20) 。由于换行以及实际文本较少，所以空格填充了大部分空间，但是即便是固定使用头几个非空白字符的地址，也会输出空格。原因不明，而且在行为仿真下是正常的。
