Bomber: Master ���x
  bit: \Bomber\top.bit
  mcs: \Bomber\bomber.mcs

Bomber_slave: Slave ���x
  bit: \Bomber_slave\top.bit
  mcs: \Bomber_slave\bomber_slave.mcs

�s���覡�G
�s�u����U�e�� J1 Connector ���Ӹ}��
(Master - Slave)
1) A - C
2) B - D
3) C - A
4) D - B
5) E - E
6) F - F

�ϥܡG�b J1 ���k��

  A B C D E F
.[. . . . . .]. GND
. . . . . . . . +3.3V
. . . . . . . . +5V


�]���o����@�|�α��ӦhLUT�A���F����N�i�O�l�̡A�ڭ̰��F�p�U�]�w�G

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
