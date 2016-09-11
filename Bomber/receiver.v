
module receiver(
    input LINK_CLK,
    input RESETN,
    input S_IN,
    input SYNC,
    output reg [0:15] DATA_OUT,
    output reg RECV_OK
    );
    
    reg [0:14] RECV_DATA, RECV_DATA_NEXT = 0;
    reg [0:15] DATA_OUT_NEXT = 0;
    reg RECV_OK_NEXT;
    
    
    always @(posedge LINK_CLK or negedge RESETN) begin
        if (~RESETN) begin
            RECV_DATA <= 0;
            DATA_OUT <= 0;
            RECV_OK <= 1'b0;
        end else begin
            RECV_DATA <= RECV_DATA_NEXT;
            DATA_OUT <= DATA_OUT_NEXT;
            RECV_OK <= RECV_OK_NEXT;
        end
    end
    
    always @(*) begin
        RECV_DATA_NEXT = RECV_DATA;
        DATA_OUT_NEXT = DATA_OUT;
        RECV_OK_NEXT = 1'b0;
        
        if (SYNC) begin
            DATA_OUT_NEXT = {RECV_DATA[0:14], S_IN};
            RECV_OK_NEXT = 1'b1;
        end
        RECV_DATA_NEXT = {RECV_DATA[1:14], S_IN};
    end

endmodule
