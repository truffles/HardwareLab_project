
module top(
    input  SYS_CLK,
    input  RECV_PORT1,
    input  RECV_PORT2,
    output TR_PORT1,
    output TR_PORT2,
    input  LINK_CLK,
    output [7:0] LCD_DATA,
	output LCD_ENABLE,
	output LCD_RW,
	output LCD_RSTN,
	output LCD_CS1,
	output LCD_CS2,
	output LCD_DI,
    input  [0:3] KEY4X4_col,
    output [0:3] KEY4X4_row
    );
    
    reg [0:15] DATA_BUS, DATA_BUS_NEXT;
    reg  DATA_READY, DATA_READY_NEXT, DATA_READY_DELAYED;
    reg  TR_DATA_READY, TR_DATA_READY_NEXT;
    wire [0:48] RECV_DATA;
    wire [0:4] TR_DATA = {up, down, left, right, action};
    wire TR_READY;
    
    clk_div c_div (.clock_40MHz (SYS_CLK),
                   .clock_100KHz(LCD_CLK),
                   .clock_1KHz  (KEY_CLK));
    
    keypad_scanner key_scn (KEY_CLK, 1'b1, KEY4X4_col, KEY4X4_row, up, down, left, right, action);
    
    lcd_control lcd_ctrl (LCD_CLK, DATA_READY_DELAYED, DATA_BUS,
                          LCD_DATA, LCD_ENABLE, LCD_RW, LCD_RSTN, LCD_CS1, LCD_CS2, LCD_DI);
    
    transmitter TR (~LINK_CLK, 1'b1, TR_DATA_READY, TR_READY, TR_PORT1, TR_PORT2, {TR_DATA, ~TR_DATA, TR_DATA, ~^TR_DATA});
    receiver RC (~LINK_CLK, 1'b1, RECV_PORT1, RECV_PORT2, RECV_DATA, RECV_OK);
    
    always @(posedge LINK_CLK) begin
        DATA_BUS <= DATA_BUS_NEXT;
        DATA_READY <= DATA_READY_NEXT;
        DATA_READY_DELAYED <= DATA_READY;
        TR_DATA_READY <= TR_DATA_READY_NEXT;
    end
    
    always @(*) begin
        DATA_BUS_NEXT = DATA_BUS;
        DATA_READY_NEXT = 1'b0;
        TR_DATA_READY_NEXT = TR_READY;
        
        if (RECV_OK) begin
            DATA_READY_NEXT = 1'b1;
            
            if (RECV_DATA[0:15] == ~RECV_DATA[16:31] && RECV_DATA[0:15] == RECV_DATA[32:47])
                DATA_BUS_NEXT = RECV_DATA[0:15];
            else if (RECV_DATA[0:15] == ~RECV_DATA[16:31] && (~^RECV_DATA[0:15]) == RECV_DATA[48]) begin
                DATA_BUS_NEXT = RECV_DATA[0:15];
            end
            else if (RECV_DATA[0:15] == RECV_DATA[32:47] && (~^RECV_DATA[0:15]) == RECV_DATA[48]) begin
                DATA_BUS_NEXT = RECV_DATA[0:15];
            end
            else if (~RECV_DATA[16:31] == RECV_DATA[32:47] && (~^RECV_DATA[32:47]) == RECV_DATA[48]) begin
                DATA_BUS_NEXT = RECV_DATA[32:47];
            end
            else begin
                DATA_READY_NEXT = 1'b0;
            end
        end
    end
    
endmodule
