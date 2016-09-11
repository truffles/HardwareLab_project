
module transmitter(
    input LINK_CLK,
    input RESETN,
    input DATA_READY,
    output TR_READY,
    output reg S_OUT,
    output reg SYNC,
    input [0:15] TR_DATA
    );

    reg [1:0] STATE, STATE_NEXT;
    reg [3:0] BIT_COUNTER, BIT_COUNTER_NEXT;
    reg [0:15] BUFFER, BUFFER_NEXT;
    reg S_OUT_NEXT;
    reg SYNC_NEXT;
    
    assign END_OF_BLOCK = (BIT_COUNTER == 4'b1111) ? 1'b1 : 1'b0 ;
    assign TR_READY = (STATE == S_READY) ? 1'b1 : 1'b0 ;
    
    parameter S_INIT  = 2'b00,
              S_READY = 2'b01,
              S_TRANS = 2'b10;
    
    always @(posedge LINK_CLK or negedge RESETN) begin
        if (~RESETN) begin
            S_OUT <= 1'b0;
            STATE <= S_INIT;
            BIT_COUNTER <= 0;
            SYNC <= 1'b0;
            BUFFER <= 0;
        end else begin
            S_OUT <= S_OUT_NEXT;
            STATE <= STATE_NEXT;
            BIT_COUNTER <= BIT_COUNTER_NEXT;
            SYNC <= SYNC_NEXT;
            BUFFER <= BUFFER_NEXT;
        end
    end
    
    always @(*) begin
        S_OUT_NEXT = S_OUT;
        STATE_NEXT = STATE;
        BIT_COUNTER_NEXT = BIT_COUNTER;
        SYNC_NEXT = 1'b0;
        BUFFER_NEXT = BUFFER;
        
        case (STATE)
            S_INIT: begin
                if (END_OF_BLOCK) STATE_NEXT = S_READY;
                BIT_COUNTER_NEXT = BIT_COUNTER + 1;
                S_OUT_NEXT = 1'b0; // delay
            end
            
            S_READY: begin
                if (DATA_READY) begin
                    STATE_NEXT = S_TRANS;
                    BUFFER_NEXT = TR_DATA;
                    BIT_COUNTER_NEXT = 0;
                end
                S_OUT_NEXT = 1'b0;
            end
            
            S_TRANS: begin
                if (END_OF_BLOCK) begin
                    STATE_NEXT = S_READY;
                    SYNC_NEXT = 1'b1;
                end
                BIT_COUNTER_NEXT = BIT_COUNTER + 1;
                S_OUT_NEXT = BUFFER[BIT_COUNTER];
            end
            
            default: STATE_NEXT = S_INIT;
        endcase
    end
    
endmodule
