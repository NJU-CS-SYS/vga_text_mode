# VGA controller to display ascii text

简单的 VGA 控制器，可以绘制字符。

可以修改顶层模块设置的 VGA 时序和像素时钟以使用不同的显式模式。

具备写接口，以字符为单位修改显存中的内容。

## Build

### 配置 VGA 时序

在 vga 模块下修改参数与特定显示模式的 VGA 时序一一对应。`h` 前缀表示水平方向的时序，`v` 前缀表示垂直方向的时序，每个时序阶段的命名与网络上大部分资料基本吻合。

自行准备变频模块 pixel_clock_gen，输出时钟为对应 VGA 模式的像素时钟，在 vga 模块下实例化。可以使用 MMCM IP 核 (Vivado) 生成。

### 配置字体以及文本

字体数据在 `vga_ctrl` 模块下，通过 `font_mem` 的实例提供。`font_mem` 需自行生成，比如使用 IP 核。

`font.coe` 包含字体信息，可用于初始化 Block Memory Generator (Vivado) 生成的 IP 核。`font.coe` 根据
[font8x8](https://github.com/dhepper/font8x8)
生成。

文本数据在 `vga_ctrl` 模块下，通过 `text_mem` 的实例提供，与 `font_mem` 一样需要自行生成。Ruby 脚本 `mk_text_mem.rb` 可以将输入的文本文件转换成需要的相应的 coe 文件，除了转换格式，还会在遇到换行符时进行填充处理，生成的 coe 文件注释中有用于设置 block ram 的相关参数。

VGA 模块不负责控制字符的处理，所以在生成初始化文件，在遇到换行符时，要根据屏幕的分辨率在该行剩下的位置填充空格，其他显示相关的控制字符同理。

绘制一个字符的一行需要 8 个像素周期，该行会被缓存，并且在这 8 个周期内可以寻址下一个字符以及对应的字体的一行。根据 `vga_ctrl` 的状态机行为，实际有 7 个像素周期供下一个字符的字体行数据信号稳定下来。要确保两级的存储模块（ `text_mem` 和 `font_mem` ）的时延不超过 7 个像素周期。

### 修改语言设置

为了减少不必要的 warning，以及根据参数动态调整宽度，代码使用了 `$clog2` 以及 `localparam`。Verilog 2001 似乎不支持这两个写在一行里……所以为了回避这种语法级别的错误，请将语言属性从 Verilog 改成 SystemVerilog。
