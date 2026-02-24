

module fifo_rv #(
  parameter int WIDTH = 256,
  parameter int DEPTH = 16
) (
  input  logic clk,
  input  logic rst,        // sync reset 

  // Input (producer -> FIFO)
  input  logic in_valid,
  output logic in_ready,
  input  logic [WIDTH-1:0]in_data,

  // Output (FIFO -> consumer)
  output logic out_valid,
  input  logic out_ready,
  output logic [WIDTH-1:0]out_data,

  output logic full,
  output logic empty,
  output logic [$clog2(DEPTH+1)-1:0] count
);
logic [WIDTH-1:0]mem [0:DEPTH-1];
logic [$clog2(DEPTH)-1:0] wr_ptr;
logic [$clog2(DEPTH)-1:0] rd_ptr;
logic do_write;
logic do_read;

always_comb begin
full=(count==DEPTH);
empty=(count==0);
in_ready=!full;
out_valid=!empty;
do_write=in_valid && in_ready;
do_read= out_valid && out_ready;
end
always_ff @(posedge clk) begin
  if(rst)begin
    wr_ptr<=0;
    rd_ptr<=0;
    count<=0;
  end
  if(do_write)begin
    mem[wr_ptr]<=in_data;
    wr_ptr<=(wr_ptr+1)%DEPTH;
  end
  if(do_read)begin
    rd_ptr<=(rd_ptr+1)%DEPTH;
  end
  if(!do_read && do_write)
  begin
    count<=count+1;
  end
  else if(!do_write && do_read)
  begin
    count<=count-1;
  end
end
assign out_data=mem[rd_ptr];



endmodule




module rr_arb #(
  parameter int N = 4
) (
  input  logic clk,
  input  logic rst,          // sync reset

  input  logic [N-1:0] req,
  output logic [N-1:0] grant,

  input  logic grant_accept, // advance pointer only when 1
  output logic grant_any,
  output logic [$clog2(N)-1:0] grant_idx  // optional convenience
);
logic [$clog2(N)-1:0] ptr;
logic [N-1:0] req_rot;
logic [@clog2(N)-1:0] rot_idx;
logic [N-1:0] grant_rot;
//Rotate Request Vector Cheeky Trick
always_comb begin
  req_rot= {req,req} >>ptr;
end

//priority encoder on rotated req
always_comb begin
  rot_idx='0;
  grant_rot= '0;
  for(int i=0;i<N;i++)
  begin
    if(req_rot[i])begin
      rot_idx=i;
      grant_rt[i]=1'b1;
      break;
    end
  end
end
//unrotate grant cycle
assign grant_idx=(ptr+rot_idx)%N;
always_comb begin
  grant='0;
  if(|req)
  begin
    grant[grant_idx]=1'b1;
  end
end
assign grant_any=|grant;
// pointer update
always_ff @(posedge clk)begin
  if(rst)
  begin
    ptr<='0;
  end
  else if (grant_any &&grant_accept)begin
    ptr<=(grant_idx+1)%N;
  end
end


endmodule

module onehot_mux #(
  parameter int N = 4,
  parameter int WIDTH = 256
) (
  input  logic [N-1:0][WIDTH-1:0] data_in,   // packed array: N lanes of WIDTH
  input  logic [N-1:0]            sel_onehot,
  output logic [WIDTH-1:0]        data_out
);
always_comb begin
  data_out='0;
  for(int i=0;i<N;i++)
  begin
    if(sel_onehot[i])
    begin
      data_out=data_in[i];
    end
  end
end
  
endmodule

module fifo_rr_merge #(
  parameter int N     = 4,
  parameter int WIDTH = 256,
  parameter int DEPTH = 16
) (
  input  logic                     clk,
  input  logic                     rst, // sync reset

  // N input streams
  input  logic [N-1:0]             in_valid,
  output logic [N-1:0]             in_ready,
  input  logic [N-1:0][WIDTH-1:0]  in_data,

  // 1 output stream
  output logic                     out_valid,
  input  logic                     out_ready,
  output logic [WIDTH-1:0]         out_data
);


endmodule


