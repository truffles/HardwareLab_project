Bomber: Master 機台
  bit: \Bomber\top.bit
  mcs: \Bomber\bomber.mcs

Bomber_slave: Slave 機台
  bit: \Bomber_slave\top.bit
  mcs: \Bomber_slave\bomber_slave.mcs

連接方式：
連線雙方各占用 J1 Connector 六個腳位
(Master - Slave)
1) A - C
2) B - D
3) C - A
4) D - B
5) E - E
6) F - F

圖示：在 J1 的右側

  A B C D E F
.[. . . . . .]. GND
. . . . . . . . +3.3V
. . . . . . . . +5V


因為這份實作會用掉太多LUT，為了能夠燒進板子裡，我們做了如下設定：

  Design Goal: Area Reduction

  Strategy:
    Synthesize:
      Optimization Goal: Area
      Optimization Effort: High
      Netlist Hierachy: Rebuilt
      FSM Style: Bram
      RAM Extraction: Yes
      ROM Extraction: Yes
      Automatic BRAM Packing: Yes
      Register Balancing: No
      LUT Combining: Area
      Optimize Instantiated Primitives: Yes

    Map:
      Placer Effort Level: High
      Placer Extra Effort: Continue on Impossible
      Combinational Logic Optimization: Yes
      Global Optimization: Area
      Maximum Compression: Yes
      LUT Combining: Area
      Map Slice Logic into Unused Block RAMs: Yes

    Place & Route:
      Place And Route Mode: Reentrant Route
      Place & Route Effort Level (Overall): High
