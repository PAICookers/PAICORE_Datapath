#!/usr/bin/env python
"""
Generates an AXI Stream arbitrated mux wrapper with the specified number of ports
"""

import argparse
from jinja2 import Template


def main():
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument('-p', '--ports',  type=int, default=3, help="number of ports")
    parser.add_argument('-n', '--name',   type=str, help="module name")
    parser.add_argument('-o', '--output', type=str, help="output file name")

    args = parser.parse_args()

    try:
        generate(**args.__dict__)
    except IOError as ex:
        print(ex)
        exit(1)


def generate(ports=4, name=None, output=None):
    n = ports

    if name is None:
        name = "axis_fork_arbiter_wrap_{0}".format(n)

    if output is None:
        output = name + ".v"

    print("Generating {0} port AXI stream arbitrated mux wrapper {1}...".format(n, name))

    cn = (n-1).bit_length()

    t = Template(u"""

// Language: Verilog 2001

/*
 * AXI4-Stream {{n}} port fork arbiter mux (wrapper)
 */
 `timescale 1ns / 1ps
module {{name}} #
(
    parameter DATA_WIDTH = 64
)
(
    input  wire                     clk,
    input  wire                     rst,
                 
    input                           fork_enable,
    input  wire [{{n}}-1:0]         single_mask,
    /*
     * AXI Stream input
     */
    output wire                     s_axis_tready,
    input  wire [DATA_WIDTH-1:0]    s_axis_tdata,
    input  wire                     s_axis_tlast,
    input  wire                     s_axis_tvalid,

    /*
     * AXI Stream outputs
     */
{%- for p in range(n) %}
    input  wire                     m{{'%02d'%p}}_axis_tready,
    output wire [DATA_WIDTH-1:0]    m{{'%02d'%p}}_axis_tdata,
    output wire                     m{{'%02d'%p}}_axis_tlast,
    output wire                     m{{'%02d'%p}}_axis_tvalid{% if not loop.last %},{% endif %}
{% endfor -%}
);

axis_fork_arbiter #(
    .M_COUNT({{n}}),
    .DATA_WIDTH(DATA_WIDTH)
)
axis_fork_arbiter_inst (
    .clk(clk),
    .rst(rst),
    .fork_enable(fork_enable),
    .single_mask(single_mask),

    // AXI input
    .s_axis_tready(s_axis_tready),                 
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tlast(s_axis_tlast),
    .s_axis_tvalid(s_axis_tvalid),

    // AXI outputs
    .m_axis_tready({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tready{% if not loop.last %}, {% endif %}{% endfor %} }),
    .m_axis_tdata({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tdata{% if not loop.last %}, {% endif %}{% endfor %} }),
    .m_axis_tlast({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tlast{% if not loop.last %}, {% endif %}{% endfor %} }),
    .m_axis_tvalid({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tvalid{% if not loop.last %}, {% endif %}{% endfor %} })
);

endmodule


""")

    print(f"Writing file '{output}'...")

    with open(output, 'w') as f:
        f.write(t.render(
            n=n,
            cn=cn,
            name=name
        ))
        f.flush()

    print("Done")


if __name__ == "__main__":
    main()
