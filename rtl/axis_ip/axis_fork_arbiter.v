module axis_fork_arbiter #(
    parameter M_COUNT = 4,
    parameter DATA_WIDTH = 64
)(
    input                                   clk,
    input                                   rst,

    input                                   fork_enable,

    output wire                             s_axis_tready,
    input  wire [DATA_WIDTH-1:0]            s_axis_tdata,
    input  wire                             s_axis_tlast,
    input  wire                             s_axis_tvalid,
    
    input  wire [M_COUNT-1:0]               m_axis_tready,
    output wire [M_COUNT*DATA_WIDTH-1:0]    m_axis_tdata,
    output wire [M_COUNT-1:0]               m_axis_tlast,
    output wire [M_COUNT-1:0]               m_axis_tvalid
);

    wire [M_COUNT-1:0] grant_out;

    parameter Use_Fixed = 0;

    generate
        if (Use_Fixed) begin
            Fixed_arbiter #(
                .NUM_REQ    (M_COUNT)
            ) u_Fixed_arbiter(
                .arb_enable (fork_enable    ),
                .request    (m_axis_tready  ),
                .grant      (grant_out      )
            );
        end else begin
            Round_Robin_arbiter #(
                .NUM_REQ    (M_COUNT)
            ) u_Round_Robin_arbiter(
                .clk        (clk            ),
                .rst_n      (!rst           ),
                .arb_enable (fork_enable    ),
                .request    (m_axis_tready  ),
                .grant      (grant_out      )
            );
        end
    endgenerate

    wire fork_done;
    reg fork_done_reg;
    always @(posedge clk) begin
        if(rst) begin
            fork_done_reg   <= 1'b0;
        end else if(fork_done_reg && (&(m_axis_tready & m_axis_tvalid) )) begin                   
            fork_done_reg   <= 1'b0;
        end else if(s_axis_tready && s_axis_tvalid && s_axis_tlast) begin                   
            fork_done_reg   <= 1'b1;
        end
    end
    
    assign fork_done = fork_done_reg && (&m_axis_tready);
    assign s_axis_tready = fork_enable ? |m_axis_tready : m_axis_tready[0];
    assign m_axis_tdata  = fork_done_reg ? {M_COUNT{{DATA_WIDTH{1'b1}}}} : {M_COUNT{s_axis_tdata}};
    assign m_axis_tlast  = {M_COUNT{fork_done_reg}};
    assign m_axis_tvalid = ({M_COUNT{s_axis_tvalid}} & grant_out) | {M_COUNT{fork_done}};
endmodule
